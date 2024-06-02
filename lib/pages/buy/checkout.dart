/*
  [Title]
  CheckoutPage

  [Description]
  A page that appears when tapping on a checkout button from CartPage.
  Displays user options to order via pickup or delivery. Displays the current address and allows the option to add an
    address through the AddressesPage.
*/

part of '../../main.dart';

// ignore: must_be_immutable
class CheckoutPage extends StatefulWidget {
  CheckoutPage({super.key, required this.placeID, required this.items});
  String placeID = '';
  Map items = {};

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool showAddressCard = false;
  // Form variables.
  String? deliveryMethod;
  String? paymentMethod;

  // Variables for place information.
  int? deliveryPrice;
  String? storeName;

  // Variables for user information.
  String? selectedAddress;
  Map user = {};
  Map addresses = {};

  final inputAdditionalNotes = TextEditingController();

  void getUserInfo() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    db.collection("users").doc(uid).get().then((snapshot) {
      user = snapshot.data()!;
    });
  }

  // Gets a list of addresses from the database.
  void getAddresses() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;
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
  }

  // Gets the delivery price of the place.
  void getDeliveryPrice() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("places").doc(widget.placeID).get().then((document) {
      setState(() {
        deliveryPrice = document.data()!['deliveryPrice'];
      });
    });
  }

  // Gets the delivery fee of the order.
  // The delivery fee does not always match the delivery price, especially if (a) the shop did not mention their
  // delivery prices; and (b) the user did not select the 'delivery' option.
  int getDeliveryFee() {
    if (deliveryPrice == null || deliveryMethod != 'Delivery') {
      return 0;
    } else {
      return deliveryPrice!;
    }
  }

  // Retrieves and sets the place information given the place ID of the page.
  // Place ID is retrieved when obtaining product information.
  void getStoreName() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("places").doc(widget.placeID).get().then((document) async {
      if (document.exists) {
        storeName = document.data()!['placeName'] ?? '';
      }
    });
  }

  // Gets the total price of the order.
  int getTotal() {
    int subtotal = 0;
    for (String key in widget.items.keys) {
      int itemPrice =
          widget.items[key]['price'] * widget.items[key]['quantity'];
      subtotal += itemPrice;
    }
    return getDeliveryFee() + subtotal;
  }

  // Creates an order.
  void addOrder(String deliveryMethod, String paymentMethod) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;
    getStoreName();

    Map items = {};
    // 1. Fetch cart items from place to check out
    db
        .collection("users")
        .doc(uid)
        .collection("cart")
        .doc(widget.placeID)
        .get()
        .then((document) {
      items = document.data()!;
    }).then((res) {
      // 2. Update inventories for limited items
      for (var key in items.keys) {
        if (items[key]['isLimited'] ?? false) {
          db.collection("products").doc(key).update({
            "ordersRemaining": FieldValue.increment(-1 * items[key]['quantity'])
          });
        }
      }
      // 3. Remove items from cart
      db
          .collection("users")
          .doc(uid)
          .collection("cart")
          .doc(widget.placeID)
          .delete();
      // 4. Add items as an order entry
      Map<String, dynamic> data = {
        "additionalNotes": inputAdditionalNotes.text,
        "address": deliveryMethod == 'Pickup'
            ? "N/A (Pickup)"
            : addresses[selectedAddress!]["addressLine"],
        "createdAt": FieldValue.serverTimestamp(),
        "customerName": user['displayName'],
        "deliveryFee": getDeliveryFee(),
        "deliveryMethod": deliveryMethod,
        "items": items,
        "isPaid": false,
        "landmark": deliveryMethod == 'Pickup'
            ? "N/A (Pickup)"
            : addresses[selectedAddress]["landmark"],
        "paymentMethod": paymentMethod,
        "phoneNumber": addresses[selectedAddress] == null ||
                addresses[selectedAddress]["phoneNumber"] == null
            ? 'No Phone Number'
            : addresses[selectedAddress]["phoneNumber"],
        "placeID": widget.placeID,
        "price": getTotal(),
        "status": "Unread",
        "storeName": storeName ?? 'Unknown Store',
        "userID": uid,
      };
      db.collection("orders").add(data).then((docRef) {
        // 5. Add order to list of orders of user
        db.collection("users").doc(uid).update({
          "orders": FieldValue.arrayUnion([docRef.id])
        });
        // 6. Add order to list of orders of place
        db.collection("places").doc(widget.placeID).update({
          "orders": FieldValue.arrayUnion([docRef.id])
        });
      });
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const CheckoutSuccessPage()),
          (Route<dynamic> route) => false);
    });
  }

  void initSelectedAddress() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;

    db.collection("users").doc(uid).get().then((document) {
      if (mounted) {
        setState(() {
          selectedAddress = document.data()!['selectedAddress'];
          if (selectedAddress == null && deliveryMethod == 'Delivery') {
            deliveryMethod = null;
          }
        });
      }
    });
  }

  void setSelectedAddress(String? id) {
    if (mounted) {
      setState(() {
        selectedAddress = id;
        if (selectedAddress == null && deliveryMethod == 'Delivery') {
          deliveryMethod = null;
        }
      });
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

  void editAddress(String? id, Map data) {
    if (mounted) {
      setState(() {
        addresses[id] = data;
      });
    }
  }

  @override
  void initState() {
    getUserInfo();
    getAddresses();
    getDeliveryPrice();
    initSelectedAddress();
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
        backgroundColor: Theme.of(context).colorScheme.surface,
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
              AppLocalizations.of(context)!.checkout,
              style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontVariations: [
                    FontVariation('wght', 700),
                  ],
                  fontSize: 20,
                  letterSpacing: -0.3),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          Expanded(
            child: ListView(
              children: [
                Text(
                  "Delivery",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Manrope',
                    fontVariations: const [
                      FontVariation('wght', 700),
                    ],
                    fontSize: 16,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 5),
                Opacity(
                  opacity: selectedAddress == null ? 0.5 : 1,
                  child: AbsorbPointer(
                    absorbing: selectedAddress == null,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Radio(
                              value: 'Delivery',
                              groupValue: deliveryMethod,
                              onChanged: (String? value) {
                                setState(() {
                                  deliveryMethod = value;
                                  showAddressCard = true;
                                });
                              },
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Deliver to my address",
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
                                      height: 1.3,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Text(
                                  deliveryPrice == null
                                      ? "FREE Delivery"
                                      : "₱$deliveryPrice",
                                  maxLines: 1,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontFamily: 'Source Sans 3',
                                      fontVariations: const [
                                        FontVariation('wght', 400),
                                      ],
                                      fontSize: 14,
                                      letterSpacing: -0.3,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: selectedAddress == null ? true : showAddressCard,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (context.mounted) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CheckoutAddressesPage(
                                                    setSelectedAddressCallback:
                                                        setSelectedAddress,
                                                    addAddressCallback:
                                                        editAddress,
                                                    editAddressCallback:
                                                        editAddress)));
                                  }
                                },
                                child: Card(
                                  elevation: 0,
                                  color: Theme.of(context).colorScheme.surface,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: -3,
                                          right: -3,
                                          child: SizedBox(
                                            height: 25,
                                            width: 25,
                                            child: IconButton(
                                              padding: const EdgeInsets.all(0),
                                              icon: Icon(
                                                Icons.arrow_forward,
                                                size: 18,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                              onPressed: () {
                                                if (context.mounted) {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CheckoutAddressesPage(
                                                                setSelectedAddressCallback:
                                                                    setSelectedAddress,
                                                                addAddressCallback:
                                                                    editAddress,
                                                                editAddressCallback:
                                                                    editAddress)),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                selectedAddress == null ||
                                                        addresses[
                                                                selectedAddress] ==
                                                            null
                                                    ? "No address"
                                                    : addresses[selectedAddress]
                                                        ["name"],
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
                                                  height: 1.4,
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: Text(
                                                  selectedAddress == null ||
                                                          addresses[
                                                                  selectedAddress] ==
                                                              null
                                                      ? "Select this card to add a new address and enable deliveries."
                                                      : parseAddress(
                                                          addresses[
                                                                  selectedAddress]
                                                              ["addressLine"],
                                                          addresses[
                                                                  selectedAddress]
                                                              ["barangay"],
                                                          addresses[
                                                                  selectedAddress]
                                                              ["municipality"]),
                                                  maxLines: 3,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                      fontFamily:
                                                          'Source Sans 3',
                                                      fontVariations: const [
                                                        FontVariation(
                                                            'wght', 400),
                                                      ],
                                                      fontSize: 14,
                                                      height: 1,
                                                      letterSpacing: -0.3,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                              ),
                                              // If there is an address, show phone number.
                                              if (addresses[selectedAddress] !=
                                                  null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  child: Text(
                                                    addresses[selectedAddress]
                                                            ["phoneNumber"] ??
                                                        'No Phone Number',
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                        fontFamily:
                                                            'Source Sans 3',
                                                        fontVariations: const [
                                                          FontVariation(
                                                              'wght', 400),
                                                        ],
                                                        fontSize: 14,
                                                        letterSpacing: -0.3,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                ),
                                              // If there is an address, show the landmark.
                                              if (addresses[selectedAddress] !=
                                                  null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
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
                                                        addresses[selectedAddress]
                                                                ["landmark"] ??
                                                            'No Landmark',
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .outline,
                                                            fontFamily:
                                                                'Source Sans 3',
                                                            fontVariations: const [
                                                              FontVariation(
                                                                  'wght', 400),
                                                            ],
                                                            fontSize: 14,
                                                            letterSpacing: -0.3,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ]),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ])
                        ]),
                  ),
                ),
                Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(children: [
                        Radio(
                          value: 'Pickup',
                          groupValue: deliveryMethod,
                          onChanged: (String? value) {
                            setState(() {
                              deliveryMethod = value;
                              showAddressCard = false;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pickup",
                                maxLines: 1,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontFamily: 'Manrope',
                                    fontVariations: const [
                                      FontVariation('wght', 700),
                                    ],
                                    fontSize: 14,
                                    letterSpacing: -0.3,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Text(
                                "No delivery fees",
                                maxLines: 1,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontFamily: 'Source Sans 3',
                                    fontVariations: const [
                                      FontVariation('wght', 400),
                                    ],
                                    fontSize: 14,
                                    letterSpacing: -0.3,
                                    height: 0.7,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ])
                      ]),
                    )),
                const SizedBox(height: 30),
                Text(
                  "Payment",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Manrope',
                    fontVariations: const [
                      FontVariation('wght', 700),
                    ],
                    fontSize: 16,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 5),
                Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(children: [
                        Radio(
                          value: 'Cash on Pickup/Delivery',
                          groupValue: paymentMethod,
                          onChanged: (String? value) {
                            setState(() {
                              paymentMethod = value;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Cash on Pickup/Delivery",
                          maxLines: 1,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Manrope',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3,
                              overflow: TextOverflow.ellipsis),
                        )
                      ]),
                    )),
                // Card(
                //   shape: RoundedRectangleBorder(
                //     side: BorderSide(
                //       color:
                //           MaterialColors.getSurfaceContainerHighest(darkMode),
                //     ),
                //     borderRadius: BorderRadius.circular(10.0),
                //   ),
                //   elevation: 0,
                //   color: MaterialColors.getSurfaceContainerLowest(darkMode),
                //   child: Padding(
                //     padding: const EdgeInsets.all(10),
                //     child: Row(
                //       children: [
                //         Radio(
                //           value: 'Others',
                //           groupValue: paymentMethod,
                //           onChanged: (String? value) {
                //             setState(() {
                //               paymentMethod = value;
                //             });
                //           },
                //         ),
                //         const SizedBox(width: 10),
                //         Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               "Others",
                //               style: TextStyle(
                //                   color: Theme.of(context)
                //                       .colorScheme
                //                       .onSurfaceVariant,
                //                   fontFamily: 'Manrope',
                //                   fontVariations: const [
                //                     FontVariation('wght', 700),
                //                   ],
                //                   fontSize: 14,
                //                   letterSpacing: -0.3,
                //                   height: 1.3,
                //                   overflow: TextOverflow.ellipsis),
                //             ),
                //           ],
                //         )
                //       ],
                //     ),
                //   ),
                // ),
                const SizedBox(height: 30),
                Text(
                  "Special Note (Optional)",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Source Sans 3',
                    fontVariations: const [
                      FontVariation('wght', 400),
                    ],
                    fontSize: 16,
                    letterSpacing: -0.1,
                  ),
                ),
                TextFormField(
                  controller: inputAdditionalNotes,
                  maxLength: 300,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: "Add additional notes here",
                    hintStyle:
                        TextStyle(color: Theme.of(context).colorScheme.outline),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
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
                  minLines: 3,
                  maxLines: 3,
                  validator: (String? value) {
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    itemBuilder: (BuildContext context, int index) {
                      String key = widget.items.keys.elementAt(index);
                      Map item = widget.items[key];
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${item['name']} (x${item['quantity']})",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontFamily: 'Source Sans 3',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                  ],
                                  fontSize: 14,
                                  letterSpacing: -0.3,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Text(
                              "${item['price'] * item['quantity']}",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontFamily: 'Source Sans 3',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                  ],
                                  fontSize: 14,
                                  letterSpacing: -0.3,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ]);
                    }),
                // If delivery fee is free or if order is for pickup, do not display delivery fee.
                if (getDeliveryFee() > 0)
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Delivery fee",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text(
                          "${getDeliveryFee()}",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                Divider(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order Total",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 700),
                            ],
                            fontSize: 16,
                            letterSpacing: -0.3,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(
                        "${getTotal()}",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 700),
                            ],
                            fontSize: 16,
                            letterSpacing: -0.3,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                const SizedBox(height: 30),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Opacity(
                  opacity: (deliveryMethod == null || paymentMethod == null)
                      ? 0.5
                      : 1,
                  child: ElevatedButton(
                    onPressed: () {
                      if (deliveryMethod != null && paymentMethod != null) {
                        addOrder(deliveryMethod!, paymentMethod!);
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Theme.of(context).colorScheme.primary),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide.none,
                        ))),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Place Order",
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
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
