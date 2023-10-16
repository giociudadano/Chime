part of main;

// ignore: must_be_immutable
class StoreProductsEditPage extends StatefulWidget {
  StoreProductsEditPage(this.productID, this.product,
      {super.key, this.editProductCallback, this.deleteProductCallback});

  String productID;
  Map product;

  final Function(String name, String price)? editProductCallback;
  final Function(String productID)? deleteProductCallback;

  @override
  State<StoreProductsEditPage> createState() => _StoreProductsEditPageState();
}

class _StoreProductsEditPageState extends State<StoreProductsEditPage> {
  // Variables for controllers.
  final GlobalKey<FormState> formEditProductKey = GlobalKey<FormState>();
  late final inputEditProductName =
      TextEditingController(text: widget.product['productName']);
  late final inputEditProductDesc =
      TextEditingController(text: widget.product['productDesc']);
  late final inputEditProductPrice =
      TextEditingController(text: widget.product['productPrice'].toString());

  // Edits the current product at database.
  void editProduct(String name, String description, String price) {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      db.collection("products").doc(widget.productID).update({
        "productName": name,
        "productDesc": description == '' ? null : description,
        "productPrice": price == '' ? 0 : int.parse(price)
      });
      widget.editProductCallback!(name, price);
      Navigator.pop(context);
    } catch (e) {
      return;
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
    db.collection("products").doc(widget.productID).delete();
    db.collection("places").doc(widget.product['placeID']).update({
      "products": FieldValue.arrayRemove([widget.productID])
    });
    Navigator.pop(context);
    widget.deleteProductCallback!(widget.productID);
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
                const SizedBox(height: 20),
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
              ],
            ),
          ),
        ));
  }
}
