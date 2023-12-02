part of main;

// ignore: must_be_immutable
class StoreProductsEditPage extends StatefulWidget {
  StoreProductsEditPage(this.productID, this.categories, this.product,
      {super.key, this.editProductCallback, this.deleteProductCallback});

  String productID;
  Map product;
  List categories;

  final Function(
      String name,
      String price,
      String? productImageURL,
      List categories,
      List addedCategories,
      List removedCategories)? editProductCallback;
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

  // Variables for image picker.
  final ImagePicker _picker = ImagePicker();
  File? newImage;
  bool toDeleteProductImage = false;

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
      bool darkMode = Theme.of(context).brightness == Brightness.dark;
      ScaffoldMessenger.of(context).showSnackBar(
        // TODO: Add functionality to edit images on web devices.
        SnackBar(
          content: Text(
              "Sorry, you cannot edit product images on web devices at this time.",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontFamily: 'Bahnschrift',
                fontVariations: const [
                  FontVariation('wght', 350),
                  FontVariation('wdth', 100),
                ],
              )),
          backgroundColor: MaterialColors.getSurfaceContainer(darkMode),
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
  void editProduct(
      String name, String description, String price, List categories) async {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;

      // 1. Update product with new name, description, price, and categories
      db.collection("products").doc(widget.productID).update({
        "productName": name,
        "productDesc": description == '' ? null : description,
        "productPrice": price == '' ? 0 : int.parse(price),
        "categories": categories,
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
          widget.editProductCallback!(name, price, productImageURL, categories,
              addedCategories.toList(), removedCategories.toList());
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
            removedCategories.toList());
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
                "Edit product",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Bahnschrift',
                    fontVariations: const [
                      FontVariation('wght', 700),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 20,
                    letterSpacing: -0.3),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formEditProductKey,
            child: ListView(
              children: [
                const SizedBox(height: 20),
                Text(
                  "Appearance",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontFamily: 'Bahnschrift',
                      fontVariations: const [
                        FontVariation('wght', 700),
                        FontVariation('wdth', 100),
                      ],
                      fontSize: 16,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 10),
                Card(
                  color: MaterialColors.getSurfaceContainerLow(darkMode),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 0,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 400,
                        height: 200,
                        child: FittedBox(
                          clipBehavior: Clip.hardEdge,
                          fit: BoxFit.cover,
                          child: newImage != null
                              ? Image.file(newImage!)
                              : CachedNetworkImage(
                                  imageUrl: toDeleteProductImage
                                      ? ''
                                      : widget.product['productImageURL'] ?? '',
                                  placeholder: (context, url) => const Padding(
                                    padding: EdgeInsets.all(40.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => Padding(
                                    padding: const EdgeInsets.all(40.0),
                                    child: Icon(Icons.local_mall_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outlineVariant),
                                  ),
                                  fadeInCurve: Curves.easeIn,
                                  fadeOutCurve: Curves.easeOut,
                                ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 45,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: Container(
                            height: 30,
                            width: 30,
                            color: (widget.product['productImageURL'] == null &&
                                        newImage == null) ||
                                    toDeleteProductImage
                                ? Colors.transparent
                                : const Color.fromARGB(120, 0, 0, 0),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: (widget.product['productImageURL'] ==
                                                null &&
                                            newImage == null) ||
                                        toDeleteProductImage
                                    ? Theme.of(context).colorScheme.outline
                                    : Colors.grey[100],
                              ),
                              onPressed: () {
                                setProductImage(ImageSource.gallery,
                                    context: context);
                              },
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: Container(
                            height: 30,
                            width: 30,
                            color: (widget.product['productImageURL'] == null &&
                                        newImage == null) ||
                                    toDeleteProductImage
                                ? Colors.transparent
                                : const Color.fromARGB(120, 0, 0, 0),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.close,
                                size: 22,
                                color: (widget.product['productImageURL'] ==
                                                null &&
                                            newImage == null) ||
                                        toDeleteProductImage
                                    ? Theme.of(context).colorScheme.outline
                                    : Colors.grey[100],
                              ),
                              onPressed: () {
                                deleteProductImage();
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Basic Information",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontFamily: 'Bahnschrift',
                      fontVariations: const [
                        FontVariation('wght', 700),
                        FontVariation('wdth', 100),
                      ],
                      fontSize: 16,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 10),
                Text(
                  'Name',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontFamily: 'Bahnschrift',
                      fontVariations: const [
                        FontVariation('wght', 450),
                        FontVariation('wdth', 100),
                      ],
                      fontSize: 14,
                      letterSpacing: -0.3),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: inputEditProductName,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: "Insert your product's name",
                    hintStyle:
                        TextStyle(color: Theme.of(context).colorScheme.outline),
                    filled: true,
                    fillColor:
                        MaterialColors.getSurfaceContainerLowest(darkMode),
                    isDense: true,
                  ),
                  style: const TextStyle(
                      fontFamily: 'Bahnschrift',
                      fontVariations: [
                        FontVariation('wght', 300),
                        FontVariation('wdth', 100),
                      ],
                      fontSize: 14),
                  validator: (String? value) {
                    return _verifyNameField(value);
                  },
                ),
                const SizedBox(height: 15),
                Text(
                  'Description',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontFamily: 'Bahnschrift',
                      fontVariations: const [
                        FontVariation('wght', 400),
                        FontVariation('wdth', 100),
                      ],
                      fontSize: 14,
                      letterSpacing: -0.3),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: inputEditProductDesc,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: "Insert your product's description",
                    hintStyle:
                        TextStyle(color: Theme.of(context).colorScheme.outline),
                    filled: true,
                    fillColor:
                        MaterialColors.getSurfaceContainerLowest(darkMode),
                    isDense: true,
                  ),
                  style: const TextStyle(
                      fontFamily: 'Bahnschrift',
                      fontVariations: [
                        FontVariation('wght', 300),
                        FontVariation('wdth', 100),
                      ],
                      fontSize: 14),
                  minLines: 3,
                  maxLines: 3,
                  validator: (String? value) {
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                Row(children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      'Price',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: 'Bahnschrift',
                          fontVariations: const [
                            FontVariation('wght', 400),
                            FontVariation('wdth', 100),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ]),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: inputEditProductPrice,
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
                              padding: EdgeInsets.all(12), child: Text('₱ ')),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          errorMaxLines: 3,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          hintText: "0",
                          hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.outline),
                          filled: true,
                          fillColor: MaterialColors.getSurfaceContainerLowest(
                              darkMode),
                          isDense: true,
                        ),
                        style: const TextStyle(
                            fontFamily: 'Bahnschrift',
                            fontVariations: [
                              FontVariation('wght', 300),
                              FontVariation('wdth', 100),
                            ],
                            fontSize: 14),
                        minLines: 1,
                        maxLines: 1,
                        validator: (String? value) {
                          return _verifyProductPriceField(value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  "Categories",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontFamily: 'Bahnschrift',
                      fontVariations: const [
                        FontVariation('wght', 700),
                        FontVariation('wdth', 100),
                      ],
                      fontSize: 16,
                      letterSpacing: -0.5),
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
                      onSelected: selection.onSelected(widget.categories[i]),
                      label: Text(widget.categories[i],
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Bahnschrift',
                              fontVariations: const [
                                FontVariation('wght', 450),
                                FontVariation('wdth', 100),
                              ],
                              fontSize: 13.5,
                              letterSpacing: -0.3)),
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formEditProductKey.currentState!.validate()) {
                            editProduct(
                              inputEditProductName.text,
                              inputEditProductDesc.text,
                              inputEditProductPrice.text,
                              selectedValue,
                            );
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.primary),
                          foregroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.onPrimary),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Save changes",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontFamily: 'Bahnschrift',
                              fontVariations: const [
                                FontVariation('wght', 600),
                                FontVariation('wdth', 100),
                              ],
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          deleteProduct();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                MaterialColors.getSurfaceContainerLowest(
                                    darkMode),
                            side: BorderSide(
                              width: 2.0,
                              color: Theme.of(context).colorScheme.primary,
                            )),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Delete product",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontFamily: 'Bahnschrift',
                              fontVariations: const [
                                FontVariation('wght', 600),
                                FontVariation('wdth', 100),
                              ],
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ));
  }
}
