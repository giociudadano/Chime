part of '../../main.dart';

class StoreAddPage extends StatefulWidget {
  const StoreAddPage({super.key});

  @override
  State<StoreAddPage> createState() => _StoreAddPageState();
}

class _StoreAddPageState extends State<StoreAddPage> {
  // Variables for controllers.
  final GlobalKey<FormState> formAddStoreKey = GlobalKey<FormState>();
  final inputAddStoreName = TextEditingController();
  final inputAddStoreDesc = TextEditingController();
  final inputAddStoreDeliveryFee = TextEditingController();
  final inputAddStorePhoneNumber = TextEditingController();

  // Writes a new address to database.
  void addStore(
      String name, String description, String deliveryFee, String phoneNumber) {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      String uid = FirebaseAuth.instance.currentUser!.uid;
      db.collection("places").add({
        "placeName": name,
        "placeTagline": description == '' ? null : description,
        "deliveryPrice": deliveryFee == '' ? 0 : int.parse(deliveryFee),
        "phoneNumber": phoneNumber == '' ? null : phoneNumber,
        "products": [],
        "categories": {"Featured": []},
        "usersFavorited": []
      }).then((docRef) {
        db.collection("users").doc(uid).update({
          "places": FieldValue.arrayUnion([docRef.id])
        });
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

  // Checks if the delivery fee field is a non-integer and returns an error if so.
  String? _verifyDeliveryFeeField(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      int.parse(value);
      return null;
    } on FormatException {
      return 'Please enter only digits';
    }
  }

  // Checks if the delivery fee field is a non-integer and returns an error if so.
  String? _verifyContactNumberField(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      int.parse(value);
      if (value.length != 9) {
        return 'Please enter a valid 11-digit number';
      }
      return null;
    } on FormatException {
      return 'Please enter only digits';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
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
            padding: const EdgeInsets.only(right: 40),
            child: Text(
              "Create a Store",
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
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Form(
          key: formAddStoreKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      "Required items are marked with an asterisk *",
                      style: TextStyle(
                          color: ChimeColors.getRed800(),
                          fontFamily: 'Source Sans 3',
                          fontVariations: const [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(text: "Store Name", children: [
                        TextSpan(
                            text: "*",
                            style: TextStyle(color: ChimeColors.getRed800()))
                      ]),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Source Sans 3',
                          fontVariations: const [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3),
                    ),
                    TextFormField(
                      controller: inputAddStoreName,
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
                        hintText: "Name",
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
                        filled: true,
                        fillColor:
                            MaterialColors.getSurfaceContainerLowest(darkMode),
                        isDense: true,
                      ),
                      style: const TextStyle(
                          letterSpacing: -0.3,
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
                    Text(
                      "Description",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Source Sans 3',
                          fontVariations: const [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3),
                    ),
                    TextFormField(
                      controller: inputAddStoreDesc,
                      maxLength: 150,
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
                        hintText: "Description",
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
                        filled: true,
                        fillColor:
                            MaterialColors.getSurfaceContainerLowest(darkMode),
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Source Sans 3',
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3,
                      ),
                      minLines: 3,
                      maxLines: 3,
                      validator: (String? value) {
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Delivery Fee",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Source Sans 3',
                          fontVariations: const [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: inputAddStoreDeliveryFee,
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
                        prefixIcon: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 8, 0, 0),
                          child: Text(
                            "₱",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
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
                        fillColor:
                            MaterialColors.getSurfaceContainerLowest(darkMode),
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Source Sans 3',
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3,
                      ),
                      minLines: 1,
                      maxLines: 1,
                      validator: (String? value) {
                        return _verifyDeliveryFeeField(value);
                      },
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Contact Number",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Source Sans 3',
                          fontVariations: const [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: inputAddStorePhoneNumber,
                      maxLength: 9,
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
                        hintText: "123 456 789",
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 10, 8, 0),
                          child: Text(
                            "+639",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Source Sans 3',
                                fontVariations: const [
                                  FontVariation('wght', 400),
                                ],
                                fontSize: 14,
                                letterSpacing: -0.3),
                          ),
                        ),
                        filled: true,
                        fillColor:
                            MaterialColors.getSurfaceContainerLowest(darkMode),
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Source Sans 3',
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3,
                      ),
                      minLines: 1,
                      maxLines: 1,
                      validator: (String? value) {
                        return _verifyContactNumberField(value);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formAddStoreKey.currentState!.validate()) {
                            addStore(
                                inputAddStoreName.text,
                                inputAddStoreDesc.text,
                                inputAddStoreDeliveryFee.text,
                                inputAddStorePhoneNumber.text != ""
                                    ? "+639${inputAddStorePhoneNumber.text}"
                                    : "");
                          }
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                ChimeColors.getGreen200()),
                            shape:
                                MaterialStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide.none,
                            ))),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Save",
                            style: TextStyle(
                              color: ChimeColors.getGreen800(),
                              fontFamily: 'Manrope',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 14,
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
      ),
    );
  }
}
