part of main;

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  // Variables for controllers.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _inputName = TextEditingController();
  final _inputAddress = TextEditingController();

  // Variables for listeners.
  StreamSubscription? addressesListener;
  StreamSubscription? selectedAddressListener;

  // Variables for user information.
  List addresses = [];
  int? selectedAddressIndex;

  // Writes address to database.
  void _addAddress(String name, String address) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      db.collection("users").doc(uid).update({
        "addresses": FieldValue.arrayUnion([
          {"name": name, "address": address}
        ])
      });
      Navigator.pop(context);
    } catch (e) {
      return;
    }
  }

  void setSelectedAddressIndex(int index) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      db.collection("users").doc(uid).update({"selectedAddressIndex": index});
    } catch (e) {
      return;
    }
  }

  // Initializes an addresses list listener.
  // Periodically checks the user's profile for updates and modifies
  // the addresses list and selected address index if so.
  void initAddressesListener() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    addressesListener =
        db.collection("users").doc(uid).snapshots().listen((event) async {
      if (mounted) {
        setState(() {
          addresses = event.data()!['addresses'];
          selectedAddressIndex = event.data()!['selectedAddressIndex'];
        });
      }
    });
  }

  // Shows a form that allows the user to add an address.
  // Visible when clicking on the 'plus' button at the upper right of the page.
  Future showForm(BuildContext context) async {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            elevation: 0,
            backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
            title: const Text(
              "Add new address",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Bahnschrift',
                  fontVariations: [
                    FontVariation('wght', 700),
                    FontVariation('wdth', 100),
                  ],
                  fontSize: 20,
                  letterSpacing: -0.3),
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _inputName,
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
                  TextFormField(
                    controller: _inputAddress,
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
                      hintText: "Address",
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
                    minLines: 3,
                    maxLines: 3,
                    validator: (String? value) {
                      return _verifyAddressField(value);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              {
                                _addAddress(
                                    _inputName.text, _inputAddress.text);
                              }
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                Theme.of(context).colorScheme.primary),
                            foregroundColor: MaterialStatePropertyAll(
                                Theme.of(context).colorScheme.onPrimary),
                          ),
                          child: Text(
                            "Submit",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontFamily: 'Bahnschrift',
                              fontVariations: const [
                                FontVariation('wght', 500),
                                FontVariation('wdth', 100),
                              ],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  // Checks if the name field is empty and returns an error if so.
  String? _verifyNameField(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your name";
    }
    return null;
  }

  // Checks if the address field is empty and returns an error message if so.
  String? _verifyAddressField(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your address";
    }
    return null;
  }

  @override
  void initState() {
    initAddressesListener();
    super.initState();
  }

  @override
  void dispose() {
    addressesListener!.cancel();
    super.dispose();
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
            child: Text(
              "Addresses",
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
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: IconButton(
                icon: Icon(Icons.add,
                    color: Theme.of(context).colorScheme.outline),
                onPressed: () {
                  showForm(context);
                },
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView.builder(
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 0,
                color: MaterialColors.getSurfaceContainerLow(darkMode),
                shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    side: BorderSide(
                      width: 3,
                      color: selectedAddressIndex == index
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                    )),
                child: InkWell(
                  onTap: () {
                    setSelectedAddressIndex(index);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            addresses[index]["name"],
                            maxLines: 1,
                            style: const TextStyle(
                                fontFamily: 'Bahnschrift',
                                fontVariations: [
                                  FontVariation('wght', 700),
                                  FontVariation('wdth', 100),
                                ],
                                fontSize: 14,
                                letterSpacing: -0.3,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            addresses[index]["address"],
                            maxLines: 3,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontFamily: 'Bahnschrift',
                                fontVariations: const [
                                  FontVariation('wght', 500),
                                  FontVariation('wdth', 100),
                                ],
                                fontSize: 14,
                                letterSpacing: -0.3,
                                height: 0.9,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ]),
                  ),
                ),
              );
            },
          ),
        ));
  }
}
