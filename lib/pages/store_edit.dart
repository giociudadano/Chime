part of main;

// ignore: must_be_immutable
class StoreEditPage extends StatefulWidget {
  StoreEditPage(this.placeID, this.place, {super.key, this.editStoreCallback});

  String placeID;
  Map place;

  final Function(String placeID, Map data)? editStoreCallback;

  @override
  State<StoreEditPage> createState() => _StoreEditPageState();
}

class _StoreEditPageState extends State<StoreEditPage> {
  // Variables for controllers.
  final GlobalKey<FormState> formEditStoreKey = GlobalKey<FormState>();
  final inputEditStoreName = TextEditingController();
  final inputEditStoreDesc = TextEditingController();
  final inputEditStoreDeliveryFee = TextEditingController();
  final inputEditStorePhoneNumber = TextEditingController();

  void editStore(String placeID, Map data) {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      db.collection("places").doc(placeID).update(Map.from(data));
      widget.editStoreCallback!(placeID, data);
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
  void initState() {
    inputEditStoreName.text = widget.place['placeName'];
    inputEditStoreDesc.text = widget.place['placeTagline'] ?? '';
    inputEditStoreDeliveryFee.text = widget.place['deliveryPrice'] != null
        ? widget.place['deliveryPrice'].toString()
        : '0';
    inputEditStorePhoneNumber.text = widget.place['phoneNumber'] ?? '';
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
              "Edit Store",
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
          key: formEditStoreKey,
          child: ListView(
            children: [
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
                controller: inputEditStoreName,
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
                controller: inputEditStoreDesc,
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
                      controller: inputEditStoreDeliveryFee,
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
                      controller: inputEditStorePhoneNumber,
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
                        if (formEditStoreKey.currentState!.validate()) {
                          Map data = {
                            "placeName": inputEditStoreName.text,
                            "placeTagline": inputEditStoreDesc.text,
                            "deliveryPrice":
                                inputEditStoreDeliveryFee.text.isNotEmpty
                                    ? int.parse(inputEditStoreDeliveryFee.text)
                                    : 0,
                            "phoneNumber":
                                inputEditStorePhoneNumber.text.isNotEmpty
                                    ? inputEditStorePhoneNumber.text
                                    : null,
                          };
                          editStore(widget.placeID, data);
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
