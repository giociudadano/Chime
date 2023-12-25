part of main;

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
      bool darkMode = Theme.of(context).brightness == Brightness.dark;
      ScaffoldMessenger.of(context).showSnackBar(
        // TODO: Add functionality to edit images on web devices.
        SnackBar(
          content: Text(
              "Sorry, you cannot add product images on web devices at this time.",
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
                "Add a new product",
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
            key: formAddProductKey,
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
                              : Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Icon(Icons.local_mall_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant),
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
                            color: newImage == null
                                ? Colors.transparent
                                : const Color.fromARGB(120, 0, 0, 0),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: newImage == null
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
                            color: newImage == null
                                ? Colors.transparent
                                : const Color.fromARGB(120, 0, 0, 0),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.close,
                                size: 22,
                                color: newImage == null
                                    ? Theme.of(context).colorScheme.outline
                                    : Colors.grey[100],
                              ),
                              onPressed: () {
                                setState(() {
                                  newImage = null;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Divider(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 10),
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
                  controller: inputAddProductName,
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
                    fontSize: 13.5,
                    letterSpacing: -0.5,
                  ),
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
                  controller: inputAddProductDesc,
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
                    hintText: "Insert your store's description",
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
                    fontSize: 13.5,
                    letterSpacing: -0.5,
                  ),
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
                        controller: inputAddProductPrice,
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
                          fontSize: 13.5,
                          letterSpacing: -0.5,
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
                const SizedBox(height: 10),
                Divider(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 10),
                Text(
                  "Order Options",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontFamily: 'Bahnschrift',
                      fontVariations: const [
                        FontVariation('wght', 700),
                        FontVariation('wdth', 100),
                      ],
                      fontSize: 16,
                      letterSpacing: -0.3),
                ),
                const SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Limited quantity',
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontFamily: 'Bahnschrift',
                            fontVariations: const [
                              FontVariation('wght', 400),
                              FontVariation('wdth', 100),
                            ],
                            fontSize: 14,
                            height: 1,
                            letterSpacing: -0.3),
                        textAlign: TextAlign.left,
                      ),
                      Row(children: [
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            enabled: isLimited,
                            keyboardType: TextInputType.number,
                            controller: inputAddProductOrdersRemaining,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
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
                              fillColor:
                                  MaterialColors.getSurfaceContainerLowest(
                                      darkMode),
                              isDense: true,
                            ),
                            style: const TextStyle(
                              fontFamily: 'Bahnschrift',
                              fontVariations: [
                                FontVariation('wght', 300),
                                FontVariation('wdth', 100),
                              ],
                              fontSize: 13.5,
                              letterSpacing: -0.5,
                            ),
                            minLines: 1,
                            maxLines: 1,
                            validator: (String? value) {
                              return _verifyProductPriceField(value);
                            },
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: isLimited,
                            onChanged: (bool value) {
                              setState(() {
                                isLimited = value;
                              });
                            },
                          ),
                        ),
                      ])
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Pre-orders',
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontFamily: 'Bahnschrift',
                            fontVariations: const [
                              FontVariation('wght', 400),
                              FontVariation('wdth', 100),
                            ],
                            fontSize: 14,
                            height: 1,
                            letterSpacing: -0.3),
                        textAlign: TextAlign.left,
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: isAcceptPreorders,
                          onChanged: (bool value) {
                            setState(() {
                              isAcceptPreorders = value;
                            });
                          },
                        ),
                      ),
                    ]),
                const SizedBox(height: 10),
                Divider(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 10),
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
                          foregroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.onPrimary),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Add new product",
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
                const SizedBox(height: 30),
              ],
            ),
          ),
        ));
  }
}
