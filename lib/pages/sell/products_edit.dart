part of '../../main.dart';

// ignore: must_be_immutable
class StoreProductsEditPage extends StatefulWidget {
  StoreProductsEditPage(this.productID, this.categories, this.product,
      {super.key,
      this.editProductCallback,
      this.deleteProductCallback,
      this.editDefaultProductVariantCallback});

  String productID;
  Map product;
  List categories;

  final Function(
    String name,
    String price,
    String? productImageURL,
    List categories,
    List addedCategories,
    List removedCategories,
    bool isLimited,
    bool isVisible,
    String ordersRemaining,
  )? editProductCallback;

  final Function(String price, bool isLimited, String ordersRemaining)?
      editDefaultProductVariantCallback;

  final Function()? deleteProductCallback;

  @override
  State<StoreProductsEditPage> createState() => _StoreProductsEditPageState();
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);

class _StoreProductsEditPageState extends State<StoreProductsEditPage> {
  // Variables for controllers.
  final GlobalKey<FormState> formEditProductKey = GlobalKey<FormState>();
  late final inputEditProductName =
      TextEditingController(text: widget.product['productName']);
  late final inputEditProductDesc =
      TextEditingController(text: widget.product['productDesc']);
  late final inputEditProductPrice =
      TextEditingController(text: widget.product['productPrice'].toString());

  late List selectedValue = widget.product['categories'];
  bool showStockField = false;

  // Variables for image picker.
  final ImagePicker _picker = ImagePicker();
  File? newImage;
  bool toDeleteProductImage = false;

  late bool isAcceptPreorders = widget.product['isAcceptPreorders'] ?? false;
  late bool isLimited = widget.product['isLimited'] ?? false;
  late bool isVisible = widget.product['isVisible'] ?? true;
  late final inputEditProductOrdersRemaining =
      TextEditingController(text: widget.product['ordersRemaining'].toString());

  void deleteProductImage() {
    setState(() {
      toDeleteProductImage = true;
      newImage = null;
    });
  }

  Future setProductImage(
    ImageSource source, {
    required BuildContext context,
    bool isMultiImage = false,
    bool isMedia = false,
  }) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        // TODO: Add functionality to edit images on web devices.
        SnackBar(
          content: Text(
              "Sorry, you cannot edit product images on web devices at this time.",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontFamily: 'Source Sans 3',
                fontVariations: const [
                  FontVariation('wght', 400),
                ],
              )),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      );
      return;
    } else {
      try {
        final List<XFile> pickedFileList = <XFile>[];
        final XFile? media = await _picker.pickMedia();
        if (media != null) {
          pickedFileList.add(media);
          setState(() {
            toDeleteProductImage = false;
            newImage = File(media.path);
          });
        }
      } catch (e) {
        //
      }
    }
  }

  void setSelectedValue(List<dynamic> value) {
    setState(() => selectedValue = value);
  }

  // Edits the current product at database.
  void editProduct(String name, String description, String price,
      String ordersRemaining, List categories) async {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;

      // 1. Update product with new name, description, price, and categories
      db.collection("products").doc(widget.productID).update({
        "productName": name,
        "productDesc": description == '' ? null : description,
        "productPrice": price == '' ? 0 : int.parse(price),
        "categories": categories,
        "ordersRemaining":
            ordersRemaining == '' ? 0 : int.parse(ordersRemaining),
        "isLimited": isLimited,
        "isVisible": isVisible,
        "isAcceptPreorders": isAcceptPreorders,
      });

      // 2. Add product reference to added categories
      List oldCategories = widget.product['categories'];
      Set addedCategories =
          categories.toSet().difference(oldCategories.toSet());
      for (String category in addedCategories) {
        db.collection("places").doc(widget.product['placeID']).update({
          "categories.$category": FieldValue.arrayUnion([widget.productID])
        });
      }

      // 3. Remove product reference on removed categories
      Set removedCategories =
          oldCategories.toSet().difference(categories.toSet());
      for (String category in removedCategories) {
        db.collection("places").doc(widget.product['placeID']).update({
          "categories.$category": FieldValue.arrayRemove([widget.productID])
        });
      }

      Navigator.pop(context);

      // 4. Update new profile picture
      Reference ref =
          FirebaseStorage.instance.ref('products/${widget.productID}.jpg');
      if (toDeleteProductImage) {
        await ref.delete();
      }
      if (newImage != null) {
        try {
          await ref.putFile(
              newImage!,
              SettableMetadata(
                contentType: "image/jpeg",
              ));
          String productImageURL = await ref.getDownloadURL();
          widget.editProductCallback!(
              name,
              price,
              productImageURL,
              categories,
              addedCategories.toList(),
              removedCategories.toList(),
              isLimited,
              isVisible,
              ordersRemaining);
        } catch (e) {
          // ...
        }
      } else {
        widget.editProductCallback!(
          name,
          price,
          toDeleteProductImage ? '' : null,
          categories,
          addedCategories.toList(),
          removedCategories.toList(),
          isLimited,
          isVisible,
          ordersRemaining,
        );
      }
    } catch (e) {
      //
    }
  }

  // Checks if the name field is empty and returns an error if so.
  String? _verifyNameField(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a name";
    }
    return null;
  }

  // Checks if the product price field is a non-integer and returns an error if so.
  String? _verifyProductPriceField(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      int.parse(value);
      return null;
    } on FormatException {
      return 'Please enter a whole number';
    }
  }

  void deleteProduct() {
    FirebaseFirestore db = FirebaseFirestore.instance;

    // 1. Remove product reference from place
    db.collection("places").doc(widget.product['placeID']).update({
      "products": FieldValue.arrayRemove([widget.productID])
    });

    // 2. Remove product reference from place categories
    for (String category in widget.categories) {
      db.collection("places").doc(widget.product['placeID']).update({
        "categories.$category": FieldValue.arrayRemove([widget.productID])
      });
    }

    // 3. Remove favorite product reference from users
    for (String uid in widget.product['usersFavorited']) {
      db.collection("users").doc(uid).update({
        "favoriteProducts": FieldValue.arrayRemove([widget.productID])
      });
    }

    // 4. Delete image from storage
    if (widget.product['productImageURL'] != null) {
      Reference ref =
          FirebaseStorage.instance.ref('products/${widget.productID}.jpg');
      ref.delete();
    }

    // 5. Delete product from list of products
    db.collection("products").doc(widget.productID).delete();
    Navigator.pop(context);
    widget.deleteProductCallback!();
  }

  void editDefaultProductVariant(
      String price, bool isVariantLimited, String ordersRemaining) {
    if (mounted) {
      setState(() {
        inputEditProductPrice.text = price;
        isLimited = isVariantLimited;
        inputEditProductOrdersRemaining.text = ordersRemaining;
      });
    }
    if (widget.editDefaultProductVariantCallback != null) {
      widget.editDefaultProductVariantCallback!(
          price, isVariantLimited, ordersRemaining);
    }
  }

  void editProductVariant(List data) {
    if (mounted) {
      setState(() {
        widget.product['variants'] = data;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 50),
                child: Text(
                  "Edit Product",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontFamily: 'Manrope',
                      fontVariations: const [
                        FontVariation('wght', 700),
                      ],
                      fontSize: 20,
                      letterSpacing: -0.3),
                ),
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error),
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Delete this Product',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontVariations: [
                            FontVariation('wght', 700),
                          ],
                          fontSize: 16,
                          letterSpacing: -0.3,
                        )),
                    content: const Text(
                        'This cannot be undone. Although you can always create a new product.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, 'Cancel');
                        },
                        child: const Text('Cancel',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontVariations: [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 16,
                              letterSpacing: -0.3,
                            )),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteProduct();
                          Navigator.pop(context, 'OK');
                          const snackBar = SnackBar(
                            content: Text('Product has been deleted.'),
                          );

                          // Find the ScaffoldMessenger in the widget tree
                          // and use it to show a SnackBar.
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        child: const Text('OK',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontVariations: [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 16,
                              letterSpacing: -0.3,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formEditProductKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 30),
                      Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Show in Store',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontFamily: 'Source Sans 3',
                                      fontVariations: const [
                                        FontVariation('wght', 400),
                                      ],
                                      fontSize: 16,
                                      height: 1,
                                      letterSpacing: -0.1),
                                  textAlign: TextAlign.left,
                                ),
                                Transform.scale(
                                  scale: 0.75,
                                  child: Switch(
                                    value: isVisible,
                                    onChanged: (bool value) {
                                      setState(() {
                                        isVisible = value;
                                      });
                                    },
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Card(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          elevation: 0,
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: FittedBox(
                              clipBehavior: Clip.hardEdge,
                              fit: BoxFit.cover,
                              child: newImage != null
                                  ? Image.file(newImage!)
                                  : CachedNetworkImage(
                                      imageUrl: toDeleteProductImage
                                          ? ''
                                          : widget.product['productImageURL'] ??
                                              '',
                                      placeholder: (context, url) =>
                                          const Padding(
                                        padding: EdgeInsets.all(40.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Padding(
                                        padding: const EdgeInsets.all(40.0),
                                        child: Icon(Icons.local_mall_outlined,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline),
                                      ),
                                      fadeInCurve: Curves.easeIn,
                                      fadeOutCurve: Curves.easeOut,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!toDeleteProductImage)
                            ElevatedButton(
                              onPressed: () {
                                deleteProductImage();
                              },
                              style: ButtonStyle(
                                  shadowColor: const MaterialStatePropertyAll(
                                      Colors.transparent),
                                  backgroundColor: MaterialStatePropertyAll(
                                      Theme.of(context).colorScheme.surface),
                                  shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide.none,
                                  ))),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "Remove",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    fontFamily: 'Manrope',
                                    fontVariations: const [
                                      FontVariation('wght', 700),
                                    ],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              setProductImage(ImageSource.gallery,
                                  context: context);
                            },
                            style: ButtonStyle(
                                shadowColor: const MaterialStatePropertyAll(
                                    Colors.transparent),
                                backgroundColor: MaterialStatePropertyAll(
                                    Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide.none,
                                ))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Upload",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "Required items are marked with an asterisk *",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 16,
                            letterSpacing: -0.1),
                      ),
                      const SizedBox(height: 16),
                      Text.rich(
                        TextSpan(text: "Product Name", children: [
                          TextSpan(
                              text: "*",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary))
                        ]),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 16,
                            letterSpacing: -0.1),
                      ),
                      TextFormField(
                        controller: inputEditProductName,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          hintText: "Name",
                          hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.outline),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          isDense: true,
                        ),
                        style: const TextStyle(
                            letterSpacing: -0.1,
                            fontFamily: 'Source Sans 3',
                            fontVariations: [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 14),
                        validator: (String? value) {
                          return _verifyNameField(value);
                        },
                      ),
                      const SizedBox(height: 15),
                      Text.rich(
                        TextSpan(text: "Price", children: [
                          TextSpan(
                              text: "*",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary))
                        ]),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 16,
                            letterSpacing: -0.1),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: inputEditProductPrice,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 8, 0, 0),
                            child: Text(
                              "₱",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontFamily: 'Source Sans 3',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                  ],
                                  fontSize: 16,
                                  letterSpacing: -0.3),
                            ),
                          ),
                          hintText: "0",
                          hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.outline),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontFamily: 'Source Sans 3',
                          fontVariations: [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.1,
                        ),
                        minLines: 1,
                        maxLines: 1,
                        validator: (String? value) {
                          return _verifyProductPriceField(value);
                        },
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Description",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 16,
                            letterSpacing: -0.1),
                      ),
                      TextFormField(
                        controller: inputEditProductDesc,
                        maxLength: 300,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          hintText:
                              "Ingredients, allergens, or other information...",
                          hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.outline),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontFamily: 'Source Sans 3',
                          fontVariations: [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.1,
                        ),
                        minLines: 3,
                        maxLines: 3,
                        validator: (String? value) {
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Limit Orders',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontFamily: 'Source Sans 3',
                                      fontVariations: const [
                                        FontVariation('wght', 400),
                                      ],
                                      fontSize: 16,
                                      height: 1,
                                      letterSpacing: -0.1),
                                  textAlign: TextAlign.left,
                                ),
                                Transform.scale(
                                  scale: 0.75,
                                  child: Switch(
                                    value: isLimited,
                                    onChanged: (bool value) {
                                      setState(() {
                                        isLimited = value;
                                      });
                                    },
                                  ),
                                ),
                              ]),
                          Visibility(
                            visible: isLimited,
                            child: TextFormField(
                              enabled: isLimited,
                              keyboardType: TextInputType.number,
                              controller: inputEditProductOrdersRemaining,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                errorMaxLines: 3,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                hintText: "0",
                                hintStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                                isDense: true,
                              ),
                              style: const TextStyle(
                                fontFamily: 'Source Sans 3',
                                fontVariations: [
                                  FontVariation('wght', 400),
                                ],
                                fontSize: 14,
                                letterSpacing: -0.1,
                              ),
                              minLines: 1,
                              maxLines: 1,
                              validator: (String? value) {
                                return _verifyProductPriceField(value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: InkWell(
                          onTap: () {
                            if (context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        StoreProductsVariantsPage(
                                            widget.productID, widget.product,
                                            editDefaultProductVariantCallback:
                                                editDefaultProductVariant,
                                            editProductVariantCallback:
                                                editProductVariant)),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Variants",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontFamily: 'Manrope',
                                        fontVariations: const [
                                          FontVariation('wght', 700),
                                        ],
                                        fontSize: 16,
                                        letterSpacing: -0.3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "(${widget.product['variants'] == null ? 0 : widget.product['variants'].length.toString()})",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        fontFamily: 'Source Sans 3',
                                        fontVariations: const [
                                          FontVariation('wght', 400),
                                        ],
                                        fontSize: 16,
                                        letterSpacing: -0.1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    size: 16)
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       Text(
                      //         'Available for Pre-Orders',
                      //         style: TextStyle(
                      //             color: Theme.of(context)
                      //                 .colorScheme
                      //                 .onSurfaceVariant,
                      //             fontFamily: 'Source Sans 3',
                      //             fontVariations: const [
                      //               FontVariation('wght', 400),
                      //               FontVariation('wdth', 100),
                      //             ],
                      //             fontSize: 14,
                      //             height: 1,
                      //             letterSpacing: -0.3),
                      //         textAlign: TextAlign.left,
                      //       ),
                      //       Transform.scale(
                      //         scale: 0.6,
                      //         child: Switch(
                      //           value: isAcceptPreorders,
                      //           onChanged: (bool value) {
                      //             setState(() {
                      //               isAcceptPreorders = value;
                      //             });
                      //           },
                      //         ),
                      //       ),
                      //     ]),
                      const SizedBox(height: 30),
                      Text(
                        "Categories",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 16,
                            letterSpacing: -0.1),
                      ),
                      const SizedBox(height: 10),
                      InlineChoice<dynamic>(
                        multiple: true,
                        clearable: true,
                        value: selectedValue,
                        onChanged: setSelectedValue,
                        itemCount: widget.categories.length,
                        itemBuilder: (selection, i) {
                          return ChoiceChip(
                            selected: selection.selected(widget.categories[i]),
                            onSelected:
                                selection.onSelected(widget.categories[i]),
                            label: Text(widget.categories[i],
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontFamily: 'Source Sans 3',
                                    fontVariations: const [
                                      FontVariation('wght', 400),
                                    ],
                                    fontSize: 16,
                                    letterSpacing: -0.1)),
                          );
                        },
                        listBuilder: ChoiceList.createWrapped(
                          spacing: 10,
                          runSpacing: 10,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            elevation: const MaterialStatePropertyAll(0),
                            backgroundColor: MaterialStatePropertyAll(
                                Theme.of(context).colorScheme.surface),
                            shape:
                                MaterialStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            )),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formEditProductKey.currentState!.validate()) {
                              editProduct(
                                inputEditProductName.text,
                                inputEditProductDesc.text,
                                inputEditProductPrice.text,
                                inputEditProductOrdersRemaining.text,
                                selectedValue,
                              );
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Theme.of(context).colorScheme.primary),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide.none,
                              ))),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "Save",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
