part of main;

// ignore: must_be_immutable
class StoreProductsAddPage extends StatefulWidget {
  StoreProductsAddPage(this.placeID, {super.key, this.addProductCallback});

  String placeID;

  final Function(String productID, Map data)? addProductCallback;

  @override
  State<StoreProductsAddPage> createState() => _StoreProductsAddPageState();
}

class _StoreProductsAddPageState extends State<StoreProductsAddPage> {
  // Variables for controllers.
  final GlobalKey<FormState> formAddProductKey = GlobalKey<FormState>();
  final inputAddProductName = TextEditingController();
  final inputAddProductDesc = TextEditingController();
  final inputAddProductPrice = TextEditingController();

  // Writes a new product to database.
  void addProduct(String name, String description, String price) {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      Map<String, Object?> data = {
        "placeID": widget.placeID,
        "productName": name,
        "productDesc": description == '' ? null : description,
        "productPrice": price == '' ? 0 : int.parse(price),
        "categories": []
      };
      db.collection("products").add(data).then((docRef) {
        db.collection("places").doc(widget.placeID).update({
          "products": FieldValue.arrayUnion([docRef.id])
        });
        widget.addProductCallback!(docRef.id, data);
      });
      Navigator.pop(context);
    } catch (e) {
      return;
    }
  }

  // Checks if the name field is empty and returns an error if so.
  String? _verifyNameField(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your name";
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
                            "Submit",
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
              ],
            ),
          ),
        ));
  }
}
