part of '../../main.dart';

// ignore: must_be_immutable
class StoreProductsAddPage extends StatefulWidget {
  StoreProductsAddPage(this.placeID, this.categories,
      {super.key, this.addProductCallback});

  String placeID;
  List categories;

  final Function(String productID, String? productImageURL, Map data)?
      addProductCallback;

  @override
  State<StoreProductsAddPage> createState() => _StoreProductsAddPageState();
}

class _StoreProductsAddPageState extends State<StoreProductsAddPage> {
  // Variables for controllers.
  final GlobalKey<FormState> formAddProductKey = GlobalKey<FormState>();
  final inputAddProductName = TextEditingController();
  final inputAddProductDesc = TextEditingController();
  final inputAddProductPrice = TextEditingController();
  final inputAddProductOrdersRemaining = TextEditingController();
  List selectedValue = [];
  bool showStockField = false;

  // Variables for image picker.
  final ImagePicker _picker = ImagePicker();
  File? newImage;

  // Variables for buttons.
  bool isLimited = false, isAcceptPreorders = false;

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
              "Sorry, you cannot add product images on web devices at this time.",
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 16,
                fontFamily: 'Source Sans 3',
                fontVariations: const [
                  FontVariation('wght', 400),
                ],
              )),
          backgroundColor: Theme.of(context).colorScheme.onError,
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
            newImage = File(media.path);
          });
        }
      } catch (e) {
        //
      }
    }
  }

  // Writes a new product to database.
  void addProduct(String name, String description, String price,
      List categories, String ordersRemaining) {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;

      // 1. Add new product to list of products
      Map<String, Object?> data = {
        "placeID": widget.placeID,
        "productName": name,
        "productDesc": description == '' ? null : description,
        "productPrice": price == '' ? 0 : int.parse(price),
        "categories": categories,
        "ordersRemaining":
            ordersRemaining == '' ? 0 : int.parse(ordersRemaining),
        "isLimited": isLimited,
        "isAcceptPreorders": isAcceptPreorders,
      };

      db.collection("products").add(data).then((product) async {
        // 2. Add product reference to place
        db.collection("places").doc(widget.placeID).update({
          "products": FieldValue.arrayUnion([product.id])
        });

        // 3. Add product reference to place categories
        for (String category in categories) {
          db.collection("places").doc(widget.placeID).update({
            "categories.$category": FieldValue.arrayUnion([product.id])
          });
        }

        // 4. Add product image
        String? productImageURL;
        if (newImage != null) {
          Reference ref =
              FirebaseStorage.instance.ref('products/${product.id}.jpg');
          await ref.putFile(
              newImage!,
              SettableMetadata(
                contentType: "image/jpeg",
              ));
          productImageURL = await ref.getDownloadURL();
        }
        widget.addProductCallback!(product.id, productImageURL, data);
      });
      Navigator.pop(context);
    } catch (e) {
      return;
    }
  }

  void setSelectedValue(List<dynamic> value) {
    setState(() => selectedValue = value);
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
                "Add Product",
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
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formAddProductKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Card(
                          color:
                              Theme.of(context).colorScheme.surfaceVariant,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          elevation: 0,
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: FittedBox(
                              clipBehavior: Clip.hardEdge,
                              fit: BoxFit.cover,
                              child: newImage != null
                                  ? Image.file(newImage!)
                                  : Padding(
                                      padding: const EdgeInsets.all(40.0),
                                      child: Icon(Icons.local_mall_outlined,
                                          color: Theme.of(context).colorScheme.outline),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (newImage != null)
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      newImage = null;
                                    });
                                  },
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Theme.of(context).colorScheme.surface),
                                      shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide.none,
                                      ))),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      "Remove",
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.outline,
                                        fontFamily: 'Manrope',
                                        fontVariations: const [
                                          FontVariation('wght', 700),
                                        ],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 10),
                              ],
                            ),
                          ElevatedButton(
                            onPressed: () {
                              setProductImage(ImageSource.gallery,
                                  context: context);
                            },
                            style: ButtonStyle(
                                shadowColor: MaterialStatePropertyAll(Colors.transparent),
                                backgroundColor: MaterialStatePropertyAll(
                                    Theme.of(context).colorScheme.primaryContainer),
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
                                  color:
                                      Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 16,
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
                              style: TextStyle(color: Theme.of(context).colorScheme.primary))
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
                        controller: inputAddProductName,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          hintText: "Strawberry Cake",
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
                              style: TextStyle(color: Theme.of(context).colorScheme.primary))
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
                        controller: inputAddProductPrice,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 8, 0, 0),
                            child: Text(
                              "₱",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.outline,
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                  ],
                                  fontSize: 16,
                                  letterSpacing: -0.1),
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
                        controller: inputAddProductDesc,
                        maxLength: 300,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          hintText: "Ingredients, allergens, or other information...",
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
                                      color: Theme.of(context).colorScheme.onSurface,
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
                                  child:
                                    Switch(
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
                                          controller: inputAddProductOrdersRemaining,
                                          decoration: InputDecoration(
                                        
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.outlineVariant,
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                            errorMaxLines: 3,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.outlineVariant,
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                            hintText: "0",
                                            hintStyle: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outline),
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
                                  
                                  ),
                        ],
                      ),
                      // Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       Text(
                      //         'Pre-Orders',
                      //         style: TextStyle(
                      //             color: Theme.of(context)
                      //                 .colorScheme
                      //                 .onSurfaceVariant,
                      //             fontFamily: 'Source Sans 3',
                      //             fontVariations: const [
                      //               FontVariation('wght', 400),
                      //             ],
                      //             fontSize: 16,
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
                      const SizedBox(height: 20),
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
                            shadowColor: MaterialStatePropertyAll(Colors.transparent),
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formAddProductKey.currentState!.validate()) {
                              addProduct(
                                inputAddProductName.text,
                                inputAddProductDesc.text,
                                inputAddProductPrice.text,
                                selectedValue,
                                inputAddProductOrdersRemaining.text,
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
