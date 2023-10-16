part of main;

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
        "categories": {"Featured": []}
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
      return 'Please enter a whole number';
    }
  }

  // Checks if the delivery fee field is a non-integer and returns an error if so.
  String? _verifyContactNumberField(String? value) {
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
              "Create a new store",
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
          key: formAddStoreKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Basic Information",
                style: TextStyle(
                    fontFamily: 'Bahnschrift',
                    fontVariations: [
                      FontVariation('wght', 700),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 18,
                    letterSpacing: -0.3),
              ),
              const SizedBox(height: 15),
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
                  hintText: "Insert your store's name",
                  hintStyle:
                      TextStyle(color: Theme.of(context).colorScheme.outline),
                  filled: true,
                  fillColor: MaterialColors.getSurfaceContainerLowest(darkMode),
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
                controller: inputAddStoreDesc,
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
                  fillColor: MaterialColors.getSurfaceContainerLowest(darkMode),
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
                    'Delivery Fee',
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
                const SizedBox(width: 20),
                Text('Contact Number',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 400),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3)),
              ]),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: inputAddStoreDeliveryFee,
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
                      minLines: 1,
                      maxLines: 1,
                      validator: (String? value) {
                        return _verifyDeliveryFeeField(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: inputAddStorePhoneNumber,
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
                        hintText: "0912 3456 789",
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
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
                      minLines: 1,
                      maxLines: 1,
                      validator: (String? value) {
                        return _verifyContactNumberField(value);
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formAddStoreKey.currentState!.validate()) {
                          addStore(
                              inputAddStoreName.text,
                              inputAddStoreDesc.text,
                              inputAddStoreDeliveryFee.text,
                              inputAddStorePhoneNumber.text);
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
      ),
    );
  }
}
