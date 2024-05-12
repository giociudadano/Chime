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
  final GlobalKey<FormState> formAddKey = GlobalKey<FormState>();
  final inputAddLabel = TextEditingController();
  final inputAddPhoneNumber = TextEditingController();
  final inputAddAddressLine = TextEditingController();

  // Variables for landmarks.
  String? landmark;
  List landmarks = [
    "No Landmark",
    "UPV CAS",
    "UPV New Admin",
    "UPV Old Admin",
    "UPV CFOS",
    "UPV Wet Lab",
    "ISAT U",
    "Miagao NHS",
    "UPV Dorm Area"
  ];

  String? municipality;
  List municipalities = ["MIAGAO"];

  String? barangay;
  List barangays = [
    "",
    "AGDUM",
    "AGUIAUAN",
    "ALIMODIAS",
    "AWANG",
    "BACAUAN",
    "BACOLOD",
    "BAGUMBAYAN",
    "BANBANAN",
    "BANGA",
    "BANGLADAN",
    "BANUYAO",
    "BARACLAYAN",
    "BARIRI",
    "BAYBAY NORTE",
    "BAYBAY SUR",
    "BELEN",
    "BOLHO",
    "BOLOCAUE",
    "BUENAVISTA NORTE",
    "BUENAVISTA SUR",
    "BUGTONG LUMANGAN",
    "BUGTONG NAULID",
    "CABALAUNAN",
    "CABANGCALAN",
    "CABUNOTAN",
    "CADOLDOLAN",
    "CAGBANG",
    "CAITIB",
    "CALAGTANGAN",
    "CALAMPITAO",
    "CAVITE",
    "CAWAYANAN",
    "CUBAY",
    "CUBAY UBOS",
    "DALIJE",
    "DAMILISAN",
    "DAWOG",
    "DIDAY",
    "DINGLE",
    "DUROG",
    "FRANTILLA",
    "FUNDACION",
    "GINES",
    "GUIBONGAN",
    "IGBITA",
    "IGBUGO",
    "IGCABIDIO",
    "IGCABITO-ON",
    "IGCATAMBOR",
    "IGDALAQUIT",
    "IGDULACA",
    "IGPAJO",
    "IGPANDAN",
    "IGPURO",
    "IGPURO-BARIRI",
    "IGSOLIGUE",
    "IGTUBA",
    "ILOG-ILOG",
    "INDAG-AN",
    "KIRAYAN NORTE",
    "KIRAYAN SUR",
    "KIRAYAN TACAS",
    "LA CONSOLACION",
    "LACADON",
    "LANUTAN",
    "LUMANGAN",
    "MABAYAN",
    "MADUYO",
    "MALAGYAN",
    "MAMBATAD",
    "MANINILA",
    "MARICOLCOL",
    "MARINGYAN",
    "MAT-Y (POB.)",
    "MATALNGON",
    "NACLUB",
    "NAM-O NORTE",
    "NAM-O SUR",
    "NARAT-AN",
    "NAROROGAN",
    "NAULID",
    "OLANGO",
    "ONGYOD",
    "ONOP",
    "OYA-OY",
    "OYUNGAN",
    "PALACA",
    "PARO-ON",
    "POTRIDO",
    "PUDPUD",
    "PUNGTOD MONTECLARO",
    "PUNGTOD NAULID",
    "SAG-ON",
    "SAN FERNANDO",
    "SAN JOSE",
    "SAN RAFAEL",
    "SAPA",
    "SARING",
    "SIBUCAO",
    "TAAL",
    "TABUNACAN",
    "TACAS (POB.)",
    "TAMBONG",
    "TAN-AGAN",
    "TATOY",
    "TICDALAN",
    "TIG-AMAGA",
    "TIG-APOG-APOG",
    "TIGBAGACAY",
    "TIGLAWA",
    "TIGMALAPAD",
    "TIGMARABO",
    "TO-OG",
    "TUGURA-AO",
    "TUMAGBOC",
    "UBOS ILAWOD",
    "UBOS ILAYA",
    "VALENCIA",
    "WAYANG"
  ];

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

  String parseAddress(
      String? addressLine, String? barangay, String? municipality) {
    String address = '';
    if (addressLine != null) {
      address += addressLine;
    }
    if (addressLine != null && barangay != null) {
      address += ", ";
    }
    if (barangay != null) {
      address += barangay;
    }
    if ((addressLine != null || barangay != null) && municipality != null) {
      address += ", ";
    }
    if (municipality != null) {
      address += municipality;
    }
    return address;
  }

  // Writes a new address to database.
  void addAddress(String name, String? phoneNumber, String? municipality,
      String? barangay, String? landmark, String addressLine) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      Map<String, dynamic> data = {
        "name": name,
        "phoneNumber": phoneNumber == "" ? null : "+63" + phoneNumber!,
        "municipality": "${municipality}".title(),
        "barangay":
            barangay == "" || barangay == null ? null : "${barangay}".title(),
        "landmark": landmark == "No Landmark" ? null : landmark,
        "addressLine": addressLine == "" ? null : addressLine,
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
  void editAddress(
      String id,
      String name,
      String? phoneNumber,
      String? municipality,
      String? barangay,
      String? landmark,
      String addressLine) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      Map<String, dynamic> data = {
        "name": name,
        "phoneNumber": phoneNumber == "" ? null : "+63" + phoneNumber!,
        "municipality": "${municipality}".title(),
        "barangay":
            barangay == "" || barangay == null ? null : "${barangay}".title(),
        "landmark": landmark == "No Landmark" ? null : landmark,
        "addressLine": addressLine == "" ? null : addressLine,
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
    // Variables for dropdown box.
    List<DropdownMenuItem> dropdownLandmarks = List.generate(
      landmarks.length,
      (index) => DropdownMenuItem(
        value: landmarks[index],
        child: Text(
          landmarks[index],
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
          landmark = landmarks[index];
        },
      ),
    );
    landmark = "No Landmark";

    List<DropdownMenuItem> dropdownMunicipalities = List.generate(
      municipalities.length,
      (index) => DropdownMenuItem(
        value: municipalities[index],
        child: Text(
          "${municipalities[index]}".title(),
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
          municipality = municipalities[index];
        },
      ),
    );
    municipality = "MIAGAO";

    // List<DropdownMenuItem> dropdownBarangays = List.generate(
    //   barangays.length,
    //   (index) => DropdownMenuItem(
    //     value: barangays[index],
    //     child: Text(
    //       "${barangays[index]}".title(),
    //       style: TextStyle(
    //         color: Theme.of(context).colorScheme.onSurface,
    //         fontFamily: 'Source Sans 3',
    //         fontVariations: const [
    //           FontVariation('wght', 400),
    //         ],
    //         fontSize: 14,
    //         letterSpacing: -0.3,
    //       ),
    //     ),
    //     onTap: () {
    //       barangay = barangays[index];
    //     },
    //   ),
    // );

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
            backgroundColor: Theme.of(context).colorScheme.surface,
            content: Form(
              key: formAddKey,
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
                              color: Theme.of(context).colorScheme.primary,
                              fontFamily: 'Manrope',
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
                              color: Theme.of(context).colorScheme.onSurface,
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
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary))
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
                    controller: inputAddLabel,
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
                      hintText: "Name",
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.outline),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surface,
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontFamily: 'Source Sans 3',
                      fontVariations: [
                        FontVariation('wght', 400),
                      ],
                      fontSize: 16,
                      letterSpacing: -0.1,
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
                        fontSize: 16,
                        letterSpacing: -0.1),
                  ),
                  TextFormField(
                    controller: inputAddPhoneNumber,
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
                        padding: const EdgeInsets.fromLTRB(15, 10, 8, 0),
                        child: Text(
                          "+63",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.1),
                        ),
                      ),
                      hintText: "Phone Number",
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.outline),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surface,
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
                        fontSize: 16,
                        letterSpacing: -0.1),
                  ),
                  TextFormField(
                    controller: inputAddAddressLine,
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
                      hintText:
                          "House Number, Street Name, Subdivision Name, etc.",
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.outline),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surface,
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
                    minLines: 2,
                    maxLines: 2,
                    validator: (String? value) {
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  Text.rich(
                    TextSpan(text: "Municipality", children: [
                      TextSpan(
                          text: "*",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary))
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
                      value: municipality,
                      items: dropdownMunicipalities,
                      onChanged: (value) {
                        value = value;
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Barangay",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Source Sans 3',
                        fontVariations: const [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 16,
                        letterSpacing: -0.1),
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
                      value: barangay,
                      items: dropdownBarangays,
                      onChanged: (value) {
                        value = value;
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text.rich(
                    TextSpan(text: "Landmark", children: [
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
                      items: dropdownLandmarks,
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
                                Theme.of(context).colorScheme.surface),
                            shape:
                                MaterialStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
                            if (formAddKey.currentState!.validate()) {
                              {
                                addAddress(
                                    inputAddLabel.text,
                                    inputAddPhoneNumber.text,
                                    municipality,
                                    barangay,
                                    landmark,
                                    inputAddAddressLine.text);
                              }
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Theme.of(context).colorScheme.primary),
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
                                color: Theme.of(context).colorScheme.onPrimary,
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
                ],
              ),
            ),
          );
        });
  }

  // Shows a form that allows the user to edit an address.
  // Visible when clicking on the 'edit' button at an address card.
  Future showEditAddressForm(
      BuildContext context,
      String id,
      String name,
      String? phoneNumber,
      String? selectedMunicipality,
      String? selectedBarangay,
      String? landmark,
      String? addressLine) async {
    final GlobalKey<FormState> formEditKey = GlobalKey<FormState>();
    final inputEditLabel = TextEditingController(text: name);
    final inputEditPhoneNumber = TextEditingController(
        text: phoneNumber == null ? '' : phoneNumber.substring(3));
    final inputEditAddressLine = TextEditingController(text: addressLine ?? "");

    List<DropdownMenuItem> dropdownLandmarks = List.generate(
      landmarks.length,
      (index) => DropdownMenuItem(
        value: landmarks[index],
        child: Text(
          landmarks[index],
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
          landmark = landmarks[index];
        },
      ),
    );

    List<DropdownMenuItem> dropdownMunicipalities = List.generate(
      municipalities.length,
      (index) => DropdownMenuItem(
        value: municipalities[index],
        child: Text(
          "${municipalities[index]}".title(),
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
          municipality = municipalities[index];
        },
      ),
    );
    municipality = selectedMunicipality == null
        ? "MIAGAO"
        : "${selectedMunicipality}".toUpperCase();

    List<DropdownMenuItem> dropdownBarangays = List.generate(
      barangays.length,
      (index) => DropdownMenuItem(
        value: barangays[index],
        child: Text(
          "${barangays[index]}".title(),
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
          barangay = barangays[index];
        },
      ),
    );
    barangay =
        selectedBarangay == null ? "" : "${selectedBarangay}".toUpperCase();

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
            backgroundColor: Theme.of(context).colorScheme.surface,
            content: Form(
              key: formEditKey,
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
                              color: Theme.of(context).colorScheme.primary,
                              fontFamily: 'Manrope',
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
                          style: TextStyle(color: Theme.of(context).colorScheme.primary))
                    ]),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Source Sans 3',
                        fontVariations: const [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 16,
                        letterSpacing: -0.31),
                  ),
                  TextFormField(
                    controller: inputEditLabel,
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
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      hintText: "Name",
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.outline),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surface,
                      isDense: true,
                    ),
                    style: const TextStyle(
                        fontFamily: 'Source Sans 3',
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        letterSpacing: -0.1,
                        fontSize: 14),
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
                        fontSize: 16,
                        letterSpacing: -0.1),
                  ),
                  TextFormField(
                    controller: inputEditPhoneNumber,
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
                        padding: const EdgeInsets.fromLTRB(15, 10, 8, 0),
                        child: Text(
                          "+63",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.1),
                        ),
                      ),
                      hintText: "9123 456 789",
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
                        letterSpacing: -0.1,
                        fontSize: 14),
                    minLines: 1,
                    maxLines: 1,
                    validator: (String? value) {
                      return null;
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
                        fontSize: 16,
                        letterSpacing: -0.1),
                  ),
                  TextFormField(
                    controller: inputEditAddressLine,
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
                      hintText:
                          "House Number, Street Name, Subdivision Name, etc.",
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
                    TextSpan(text: "Municipality", children: [
                      TextSpan(
                          text: "*",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary))
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
                      value: municipality,
                      items: dropdownMunicipalities,
                      onChanged: (value) {
                        value = value;
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Barangay",
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
                      value: barangay,
                      items: dropdownBarangays,
                      onChanged: (value) {
                        value = value;
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text.rich(
                    TextSpan(text: "Landmark", children: [
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
                        fontSize: 14,
                        letterSpacing: -0.1),
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
                      items: dropdownLandmarks,
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
                                  Theme.of(context).colorScheme.surface),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                    color: Theme.of(context).colorScheme.error),
                              ))),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "Delete",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formEditKey.currentState!.validate()) {
                              editAddress(
                                  id,
                                  inputEditLabel.text,
                                  inputEditPhoneNumber.text,
                                  municipality,
                                  barangay,
                                  landmark,
                                  inputEditAddressLine.text);
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Theme.of(context).colorScheme.primary),
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
                                color: Theme.of(context).colorScheme.onPrimary,
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
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              showAddAddressForm(context);
            },
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.add_location_outlined,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 24,
            )),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Expanded(
            child: ListView(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    String key = addresses.keys.elementAt(index);
                    return Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: selectedAddress == key
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
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
                                    Icons.pin_drop_outlined,
                                    size: 18,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  onPressed: () {
                                    showEditAddressForm(
                                        context,
                                        key,
                                        addresses[key]["name"],
                                        addresses[key]['phoneNumber'],
                                        addresses[key]['municipality'],
                                        addresses[key]['barangay'],
                                        addresses[key]["landmark"],
                                        addresses[key]["addressLine"]);
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
                                            fontFamily: 'Manrope',
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
                                          parseAddress(
                                              addresses[key]["addressLine"],
                                              addresses[key]["barangay"],
                                              addresses[key]["municipality"]),
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
          ),
        ));
  }
}
