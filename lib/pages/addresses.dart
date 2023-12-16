part of main;

class AddressesPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  AddressesPage(
      {super.key,
      this.setSelectedAddressCallback,
      this.addAddressCallback,
      this.editAddressCallback});

  final Function(String? addressID)? setSelectedAddressCallback;
  final Function(String addressID, Map data)? addAddressCallback;
  final Function(String addressID, Map data)? editAddressCallback;

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  // Variables for controllers.
  final GlobalKey<FormState> _formAddAddressKey = GlobalKey<FormState>();
  final _inputAddAddressName = TextEditingController();
  final _inputAddAddressAddress = TextEditingController();

  // Variables for user information.
  Map addresses = {};
  String? selectedAddress;

  // Fetches all user addresses and currently selected address.
  void initAddresses() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    // 1. Fetches all user addresses
    db
        .collection("users")
        .doc(uid)
        .collection("addresses")
        .get()
        .then((snapshot) {
      for (var address in snapshot.docs) {
        addresses[address.id] = address.data();
      }
      if (mounted) {
        setState(() {});
      }
    });
    // 2. Fetches currently selected address
    db.collection("users").doc(uid).get().then((document) {
      if (mounted) {
        setState(() {
          selectedAddress = document.data()!['selectedAddress'];
        });
      }
    });
  }

  // Sets the currently selected address.
  void setSelectedAddress(String? id) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      db.collection("users").doc(uid).update({"selectedAddress": id});
      if (mounted) {
        setState(() {
          selectedAddress = id;
        });
      }
      widget.setSelectedAddressCallback!(id);
    } catch (e) {
      return;
    }
  }

  // Writes a new address to database.
  void _addAddress(String name, String address) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      Map<String, dynamic> data = {
        "name": name,
        "address": address,
      };
      db
          .collection("users")
          .doc(uid)
          .collection("addresses")
          .add(data)
          .then((document) {
        if (mounted) {
          setState(() {
            addresses[document.id] = data;
          });
          widget.addAddressCallback!(document.id, data);
        }
      });
      Navigator.pop(context);
    } catch (e) {
      return;
    }
  }

  // Overwrites an address in database.
  void _editAddress(String id, String name, String address) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      Map<String, dynamic> data = {
        "name": name,
        "address": address,
      };
      db
          .collection("users")
          .doc(uid)
          .collection("addresses")
          .doc(id)
          .update(data);
      if (mounted) {
        setState(() {
          addresses[id] = data;
        });
        widget.editAddressCallback!(id, data);
      }
      Navigator.pop(context);
    } catch (e) {
      return;
    }
  }

  // Removes an address in database.
  void _deleteAddress(String id) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      if (mounted) {
        setState(() {
          addresses.remove(id);
          if (selectedAddress == id) {
            setSelectedAddress(null);
          }
        });
      }
      db.collection("users").doc(uid).collection("addresses").doc(id).delete();
      Navigator.pop(context);
    } catch (e) {
      return;
    }
  }

  // Shows a form that allows the user to add an address.
  // Visible when clicking on the 'plus' button at the upper right of the page.
  Future showAddAddressForm(BuildContext context) async {
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
              key: _formAddAddressKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _inputAddAddressName,
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
                    controller: _inputAddAddressAddress,
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
                            if (_formAddAddressKey.currentState!.validate()) {
                              {
                                _addAddress(_inputAddAddressName.text,
                                    _inputAddAddressAddress.text);
                              }
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
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                MaterialColors.getSurfaceContainerLow(
                                    darkMode)),
                            foregroundColor: MaterialStatePropertyAll(
                                MaterialColors.getSurfaceContainerLow(
                                    darkMode)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
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
          );
        });
  }

  // Shows a form that allows the user to edit an address.
  // Visible when clicking on the 'edit' button at an address card.
  Future showEditAddressForm(
      BuildContext context, String id, String name, String address) async {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    final GlobalKey<FormState> formEditAddressKey = GlobalKey<FormState>();
    final inputEditAddressName = TextEditingController(text: name);
    final inputEditAddressAddress = TextEditingController(text: address);

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
              "Edit address",
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
              key: formEditAddressKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: inputEditAddressName,
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
                    controller: inputEditAddressAddress,
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
                            if (formEditAddressKey.currentState!.validate()) {
                              _editAddress(id, inputEditAddressName.text,
                                  inputEditAddressAddress.text);
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
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _deleteAddress(id);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                Colors.red[darkMode ? 200 : 900]),
                            foregroundColor: MaterialStatePropertyAll(
                                Colors.red[darkMode ? 200 : 900]),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "Delete",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
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
          );
        });
  }

  // Checks if the name field is empty and returns an error if so.
  String? _verifyNameField(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a name";
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
    initAddresses();
    super.initState();
  }

  @override
  void dispose() {
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
                  showAddAddressForm(context);
                },
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Text(
                "Select an address",
                maxLines: 2,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontFamily: 'Bahnschrift',
                    fontVariations: const [
                      FontVariation('wght', 700),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 16,
                    letterSpacing: -0.5,
                    height: 1.2,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(height: 5),
              ListView.builder(
                shrinkWrap: true,
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  String key = addresses.keys.elementAt(index);
                  return Card(
                    elevation: 0,
                    color: MaterialColors.getSurfaceContainerLow(darkMode),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        side: BorderSide(
                          width: 3,
                          color: selectedAddress == key
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                        )),
                    child: InkWell(
                      onTap: () {
                        setSelectedAddress(key);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          addresses[key]["name"],
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontFamily: 'Bahnschrift',
                                              fontVariations: const [
                                                FontVariation('wght', 700),
                                                FontVariation('wdth', 100),
                                              ],
                                              fontSize: 18,
                                              letterSpacing: -0.3,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          addresses[key]["landmark"] ??
                                              'No Landmark',
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              fontFamily: 'Bahnschrift',
                                              fontVariations: const [
                                                FontVariation('wght', 700),
                                                FontVariation('wdth', 100),
                                              ],
                                              fontSize: 14,
                                              letterSpacing: -0.3,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        Text(
                                          addresses[key]["address"],
                                          maxLines: 3,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline,
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
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 25,
                                width: 25,
                                child: IconButton(
                                  padding: const EdgeInsets.all(0),
                                  icon: Icon(
                                    Icons.edit,
                                    size: 18,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  onPressed: () {
                                    showEditAddressForm(
                                        context,
                                        key,
                                        addresses[key]["name"],
                                        addresses[key]["address"]);
                                  },
                                ),
                              )
                            ]),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ));
  }
}
