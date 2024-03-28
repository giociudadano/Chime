part of '../../main.dart';

class CheckoutAddressesPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  CheckoutAddressesPage(
      {super.key,
      this.setSelectedAddressCallback,
      this.addAddressCallback,
      this.editAddressCallback});

  final Function(String? addressID)? setSelectedAddressCallback;
  final Function(String addressID, Map data)? addAddressCallback;
  final Function(String addressID, Map data)? editAddressCallback;

  @override
  State<CheckoutAddressesPage> createState() => _CheckoutAddressesPageState();
}

class _CheckoutAddressesPageState extends State<CheckoutAddressesPage> {
  // Variables for controllers.
  final GlobalKey<FormState> _formAddAddressKey = GlobalKey<FormState>();
  final _inputAddAddressName = TextEditingController();
  final _inputAddAddressPhoneNumber = TextEditingController();
  final _inputAddAddressAddress = TextEditingController();
  String? landmark;

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
  void _addAddress(
      String name, String? phoneNumber, String? landmark, String address) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      Map<String, dynamic> data = {
        "name": name,
        "phoneNumber": phoneNumber == "" ? null : "+63" + phoneNumber!,
        "landmark": landmark,
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
  void _editAddress(String id, String name, String? landmark, String address) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      Map<String, dynamic> data = {
        "name": name,
        "landmark": landmark,
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
    // Variables for dropdown box.
    List<DropdownMenuItem> landmarks = [
      DropdownMenuItem(
        value: null,
        child: Text(
          "No Landmark",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = null;
        },
      ),
      DropdownMenuItem(
        value: "UPV CAS",
        child: Text(
          "UPV CAS",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = "UPV CAS";
        },
      ),
      DropdownMenuItem(
        value: "UPV New Admin",
        child: Text(
          "UPV New Admin",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = "UPV New Admin";
        },
      ),
      DropdownMenuItem(
        value: "UPV Old Admin",
        child: Text(
          "UPV Old Admin",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = "UPV Old Admin";
        },
      ),
      DropdownMenuItem(
        value: "UPV CFOS",
        child: Text(
          "UPV CFOS",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = "UPV CFOS";
        },
      ),
      DropdownMenuItem(
        value: "UPV Wet Lab",
        child: Text(
          "UPV Wet Lab",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = "UPV Wet Lab";
        },
      ),
      DropdownMenuItem(
        value: "ISAT U",
        child: Text(
          "ISAT U",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = "ISAT U";
        },
      ),
      DropdownMenuItem(
        value: "Miagao NHS",
        child: Text(
          "Miagao NHS",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = "Miagao NHS";
        },
      ),
      DropdownMenuItem(
        value: "UPV Dorm Area",
        child: Text(
          "UPV Dorm Area",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = "UPV Dorm Area";
        },
      ),
    ];

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(20),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            elevation: 0,
            backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
            content: Form(
              key: _formAddAddressKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Add Address",
                          style: TextStyle(
                              color: ChimeColors.getGreen800(),
                              fontFamily: 'Plus Jakarta Sans',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 20,
                              letterSpacing: -0.3),
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 24,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ]),
                  const SizedBox(height: 15),
                  Text.rich(
                    TextSpan(text: "Label", children: [
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
                      fontFamily: 'Source Sans 3',
                      fontVariations: [
                        FontVariation('wght', 400),
                      ],
                      fontSize: 14,
                      letterSpacing: -0.3,
                    ),
                    validator: (String? value) {
                      return _verifyNameField(value);
                    },
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Phone Number",
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
                    controller: _inputAddAddressPhoneNumber,
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
                        padding: const EdgeInsets.fromLTRB(15, 10, 8, 0),
                        child: Text(
                          "+63",
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
                      hintText: "Phone Number",
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
                      return _verifyContactNumberField(value);
                    },
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Address Line 1",
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
                      hintText:
                          "House Number, Street Name, Subdivision Name, etc.",
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
                    minLines: 2,
                    maxLines: 2,
                    validator: (String? value) {
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  Text.rich(
                    TextSpan(text: "Landmark", children: [
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
                  SizedBox(
                    height: 50,
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      elevation: 1,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                              width: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant), //<-- SEE HERE
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                              width: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant), //<-- SEE HERE
                        ),
                      ),
                      value: landmark,
                      items: landmarks,
                      onChanged: (value) {
                        value = value;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
                          style: ButtonStyle(
                            elevation: const MaterialStatePropertyAll(0),
                            backgroundColor: MaterialStatePropertyAll(
                                MaterialColors.getSurfaceContainerLowest(
                                    darkMode)),
                            shape:
                                MaterialStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: ChimeColors.getGreen300(),
                              ),
                            )),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: ChimeColors.getGreen800(),
                                fontFamily: 'Plus Jakarta Sans',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formAddAddressKey.currentState!.validate()) {
                              {
                                _addAddress(
                                    _inputAddAddressName.text,
                                    _inputAddAddressPhoneNumber.text,
                                    landmark,
                                    _inputAddAddressAddress.text);
                              }
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  ChimeColors.getGreen200()),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide.none,
                              ))),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "Save",
                              style: TextStyle(
                                color: ChimeColors.getGreen800(),
                                fontFamily: 'Plus Jakarta Sans',
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
                ],
              ),
            ),
          );
        });
  }

  // Shows a form that allows the user to edit an address.
  // Visible when clicking on the 'edit' button at an address card.
  Future showEditAddressForm(BuildContext context, String id, String name,
      String? landmark, String address) async {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    final GlobalKey<FormState> formEditAddressKey = GlobalKey<FormState>();
    final inputEditAddressName = TextEditingController(text: name);
    final inputEditAddressAddress = TextEditingController(text: address);

    // Variables for dropdown box.
    List<DropdownMenuItem> landmarks = [
      DropdownMenuItem(
        value: null,
        child: Text(
          "No Landmark",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = null;
        },
      ),
      DropdownMenuItem(
        value: "UPV CAS",
        child: Text(
          "UPV CAS",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = "UPV CAS";
        },
      ),
      DropdownMenuItem(
        value: "UPV New Admin",
        child: Text(
          "UPV New Admin",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = "UPV New Admin";
        },
      ),
      DropdownMenuItem(
        value: "UPV Old Admin",
        child: Text(
          "UPV Old Admin",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = "UPV Old Admin";
        },
      ),
      DropdownMenuItem(
        value: "UPV CFOS",
        child: Text(
          "UPV CFOS",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = "UPV CFOS";
        },
      ),
      DropdownMenuItem(
        value: "UPV Wet Lab",
        child: Text(
          "UPV Wet Lab",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = "UPV Wet Lab";
        },
      ),
      DropdownMenuItem(
        value: "ISAT U",
        child: Text(
          "ISAT U",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = "ISAT U";
        },
      ),
      DropdownMenuItem(
        value: "Miagao NHS",
        child: Text(
          "Miagao NHS",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = "Miagao NHS";
        },
      ),
      DropdownMenuItem(
        value: "UPV Dorm Area",
        child: Text(
          "UPV Dorm Area",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Source Sans 3',
            fontVariations: const [
              FontVariation('wght', 400),
            ],
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
        onTap: () {
          landmark = "UPV Dorm Area";
        },
      ),
    ];

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(20),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            elevation: 0,
            backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
            content: Form(
              key: formEditAddressKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Edit Address",
                          style: TextStyle(
                              color: ChimeColors.getGreen800(),
                              fontFamily: 'Plus Jakarta Sans',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 20,
                              letterSpacing: -0.3),
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 24,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ]),
                  const SizedBox(height: 15),
                  Text.rich(
                    TextSpan(text: "Label", children: [
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
                        fontFamily: 'Source Sans 3',
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        letterSpacing: -0.3,
                        fontSize: 14),
                    validator: (String? value) {
                      return _verifyNameField(value);
                    },
                  ),
                  const SizedBox(height: 15),
                  Text.rich(
                    TextSpan(text: "Address", children: [
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
                        fontFamily: 'Source Sans 3',
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        letterSpacing: -0.3,
                        fontSize: 14),
                    minLines: 2,
                    maxLines: 2,
                    validator: (String? value) {
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  Text.rich(
                    TextSpan(text: "Landmark", children: [
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
                  SizedBox(
                    height: 50,
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      elevation: 1,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                              width: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant), //<-- SEE HERE
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                              width: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant), //<-- SEE HERE
                        ),
                      ),
                      value: landmark,
                      items: landmarks,
                      onChanged: (value) {
                        value = value;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _deleteAddress(id);
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  ChimeColors.getRed200()),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide.none,
                              ))),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "Delete",
                              style: TextStyle(
                                color: ChimeColors.getRed800(),
                                fontFamily: 'Plus Jakarta Sans',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formEditAddressKey.currentState!.validate()) {
                              _editAddress(id, inputEditAddressName.text,
                                  landmark, inputEditAddressAddress.text);
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  ChimeColors.getGreen200()),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide.none,
                              ))),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "Save",
                              style: TextStyle(
                                color: ChimeColors.getGreen800(),
                                fontFamily: 'Plus Jakarta Sans',
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
            child: Padding(
              padding: const EdgeInsets.only(right: 40),
              child: Text(
                "Addresses",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Plus Jakarta Sans',
                    fontVariations: const [
                      FontVariation('wght', 700),
                    ],
                    fontSize: 20,
                    letterSpacing: -0.3),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              showAddAddressForm(context);
            },
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            backgroundColor: ChimeColors.getGreen800(),
            child: Icon(
              Icons.add_location_outlined,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 24,
            )),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  String key = addresses.keys.elementAt(index);
                  return Card(
                    elevation: 0,
                    color: MaterialColors.getSurfaceContainerLowest(darkMode),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: selectedAddress == key
                            ? ChimeColors.getGreen800()
                            : MaterialColors.getSurfaceContainerHighest(
                                darkMode),
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        setSelectedAddress(key);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Stack(children: [
                          Positioned(
                            top: 0,
                            right: 0,
                            child: SizedBox(
                              height: 25,
                              width: 25,
                              child: IconButton(
                                padding: const EdgeInsets.all(0),
                                icon: Icon(
                                  Icons.arrow_forward,
                                  size: 18,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                onPressed: () {
                                  showEditAddressForm(
                                      context,
                                      key,
                                      addresses[key]["name"],
                                      addresses[key]["landmark"],
                                      addresses[key]["address"]);
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      addresses[key]["name"],
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontVariations: const [
                                            FontVariation('wght', 700),
                                          ],
                                          fontSize: 14,
                                          letterSpacing: -0.3,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text(
                                        addresses[key]["address"],
                                        maxLines: 3,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            fontFamily: 'Source Sans 3',
                                            fontVariations: const [
                                              FontVariation('wght', 400),
                                            ],
                                            fontSize: 14,
                                            letterSpacing: -0.3,
                                            height: 1,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text(
                                        addresses[key]["phoneNumber"] ??
                                            "No Phone Number",
                                        maxLines: 3,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            fontFamily: 'Source Sans 3',
                                            fontVariations: const [
                                              FontVariation('wght', 400),
                                            ],
                                            fontSize: 14,
                                            letterSpacing: -0.3,
                                            height: 1,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.pin_drop_outlined,
                                            size: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            addresses[key]["landmark"] ??
                                                'No Landmark',
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outline,
                                                fontFamily: 'Source Sans 3',
                                                fontVariations: const [
                                                  FontVariation('wght', 400),
                                                ],
                                                fontSize: 14,
                                                letterSpacing: -0.3,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
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
