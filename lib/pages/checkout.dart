/*
  [Title]
  CheckoutPage

  [Description]
  A page that appears when tapping on a checkout button from CartPage.
  Displays user options to order via pickup or delivery. Displays the current address and allows the option to add an
    address through the AddressesPage.
*/

part of main;

// ignore: must_be_immutable
class CheckoutPage extends StatefulWidget {
  CheckoutPage({super.key, required this.placeID, required this.subtotal});
  String placeID = '';
  int subtotal = 0;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // Variables for listeners.
  StreamSubscription? selectedAddressListener;

  // Form variables.
  String? deliveryMethod;
  String? paymentMethod = 'Cash on delivery';

  // Variables for place information.
  int? deliveryPrice;

  // Variables for user information.
  String? selectedAddress;
  Map addresses = {};

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
        addresses[address.id] = {
          "name": address.data()["name"],
          "address": address.data()["address"]
        };
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

  // Gets the total price of the order.
  int getTotal() {
    return getDeliveryFee() + widget.subtotal;
  }

  void addOrder(
      String placeID, Map items, String deliveryMethod, String paymentMethod) {
    print(
        "PlaceID: $placeID\nItems: $items\n Delivery Method: $deliveryMethod \n Payment Method: $paymentMethod");
  }

  // Initializes a selected address listener.
  // Periodically checks the user's profile in database for write updates and modifies the
  // addresses list and selected address if so.
  void initSelectedAddressListener() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;

    selectedAddressListener =
        db.collection("users").doc(uid).snapshots().listen((event) async {
      if (mounted) {
        setState(() {
          selectedAddress = event.data()!['selectedAddress'];
          if (selectedAddress == null && deliveryMethod == 'Delivery') {
            deliveryMethod = null;
          }
        });
      }
    });
  }

  // Shows a reminder when clicking on the 'information' button at the upper right of the screen.
  Future showReminder(BuildContext context) async {
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
          title: Text(
            "Reminder",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Bahnschrift',
                fontVariations: const [
                  FontVariation('wght', 700),
                  FontVariation('wdth', 100),
                ],
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20,
                letterSpacing: -0.3),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "By default, delivery address is expected to be within the locality. However, you may contact the seller for special requests.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontFamily: 'Bahnschrift',
                      fontVariations: const [
                        FontVariation('wght', 400),
                        FontVariation('wdth', 100),
                      ],
                      fontSize: 14,
                      height: 1.1,
                      letterSpacing: -0.3),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
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
                          "I understand",
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
        );
      },
    );
  }

  // Shows a dialog that allows the user to select a payment method.
  Future showPaymentMethodDialog(BuildContext context) async {
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
          title: Text(
            "Pay ₱${getTotal()}",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Bahnschrift',
                fontVariations: const [
                  FontVariation('wght', 700),
                  FontVariation('wdth', 100),
                ],
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20,
                letterSpacing: -0.3),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "E-wallet transactions will be verified through the automated text to the seller. Please pay in full to avoid delays in processing.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontFamily: 'Bahnschrift',
                      fontVariations: const [
                        FontVariation('wght', 400),
                        FontVariation('wdth', 100),
                      ],
                      fontSize: 14,
                      height: 1.1,
                      letterSpacing: -0.3),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: DropdownButtonFormField(
                  isExpanded: true,
                  elevation: 1,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                          width: 3,
                          color: Theme.of(context)
                              .colorScheme
                              .primary), //<-- SEE HERE
                    ),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                          width: 3,
                          color: Theme.of(context)
                              .colorScheme
                              .primary), //<-- SEE HERE
                    ),
                  ),
                  value: paymentMethod,
                  items: [
                    DropdownMenuItem(
                      value: 'Cash on delivery',
                      child: Text(
                        "Cash on delivery",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontFamily: 'Bahnschrift',
                          fontVariations: const [
                            FontVariation('wght', 400),
                            FontVariation('wdth', 100),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3,
                        ),
                      ),
                      onTap: () {
                        paymentMethod = "Cash on delivery";
                      },
                    ),
                  ],
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
                        addOrder(widget.placeID, {}, deliveryMethod!,
                            paymentMethod!);
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
                          "Pay now",
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
                            MaterialColors.getSurfaceContainerLow(darkMode)),
                        foregroundColor: MaterialStatePropertyAll(
                            MaterialColors.getSurfaceContainerLow(darkMode)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
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
        );
      },
    );
  }

  @override
  void initState() {
    getAddresses();
    getDeliveryPrice();
    initSelectedAddressListener();
    super.initState();
  }

  @override
  void dispose() {
    selectedAddressListener!.cancel();
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
            AppLocalizations.of(context)!.checkout,
            style: const TextStyle(
                fontFamily: 'Bahnschrift',
                fontVariations: [
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
              icon: Icon(Icons.info_outline,
                  color: Theme.of(context).colorScheme.outline),
              onPressed: () {
                showReminder(context);
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          Expanded(
            child: ListView(
              children: [
                const Text(
                  "Delivery",
                  style: TextStyle(
                      fontFamily: 'Bahnschrift',
                      fontVariations: [
                        FontVariation('wght', 700),
                        FontVariation('wdth', 100),
                      ],
                      fontSize: 18,
                      letterSpacing: -0.3),
                ),
                const SizedBox(height: 5),
                Card(
                    elevation: 0,
                    color: MaterialColors.getSurfaceContainerLow(darkMode),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(children: [
                        Radio(
                          value: 'Pick Up',
                          groupValue: deliveryMethod,
                          onChanged: (String? value) {
                            setState(() {
                              deliveryMethod = value;
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
                                    height: 1.3,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Text(
                                "₱0",
                                maxLines: 1,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    fontFamily: 'Bahnschrift',
                                    fontVariations: const [
                                      FontVariation('wght', 500),
                                      FontVariation('wdth', 100),
                                    ],
                                    fontSize: 14,
                                    letterSpacing: -0.3,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ])
                      ]),
                    )),
                Opacity(
                  opacity: selectedAddress == null ? 0.5 : 1,
                  child: AbsorbPointer(
                    absorbing: selectedAddress == null,
                    child: Card(
                      elevation: 0,
                      color: MaterialColors.getSurfaceContainerLow(darkMode),
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
                                          .onSurfaceVariant,
                                      fontFamily: 'Bahnschrift',
                                      fontVariations: const [
                                        FontVariation('wght', 700),
                                        FontVariation('wdth', 100),
                                      ],
                                      fontSize: 14,
                                      letterSpacing: -0.3,
                                      height: 1.3,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Text(
                                  deliveryPrice == null
                                      ? "Unknown amount"
                                      : "₱$deliveryPrice",
                                  maxLines: 1,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      fontFamily: 'Bahnschrift',
                                      fontVariations: const [
                                        FontVariation('wght', 500),
                                        FontVariation('wdth', 100),
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
                Card(
                  elevation: 0,
                  color: MaterialColors.getSurfaceContainerLow(darkMode),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: Text(
                                    "My address",
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontFamily: 'Bahnschrift',
                                        fontVariations: const [
                                          FontVariation('wght', 700),
                                          FontVariation('wdth', 100),
                                        ],
                                        fontSize: 18,
                                        letterSpacing: -0.3,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ),
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
                                      if (context.mounted) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const AddressesPage()),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ]),
                          Row(children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (context.mounted) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AddressesPage()));
                                  }
                                },
                                child: Card(
                                  elevation: 0,
                                  color:
                                      MaterialColors.getSurfaceContainerLowest(
                                          darkMode),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
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
                                                    .onSurfaceVariant,
                                                fontFamily: 'Bahnschrift',
                                                fontVariations: const [
                                                  FontVariation('wght', 700),
                                                  FontVariation('wdth', 100),
                                                ],
                                                fontSize: 14,
                                                letterSpacing: -0.3,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            selectedAddress == null ||
                                                    addresses[
                                                            selectedAddress] ==
                                                        null
                                                ? "This user has no address selected. To allow delivery, please add an address."
                                                : addresses[selectedAddress!]
                                                    ["address"],
                                            maxLines: 3,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outline,
                                                fontFamily: 'Bahnschrift',
                                                fontVariations: const [
                                                  FontVariation('wght', 400),
                                                  FontVariation('wdth', 100),
                                                ],
                                                fontSize: 14,
                                                height: 1,
                                                letterSpacing: -0.3,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                        ]),
                                  ),
                                ),
                              ),
                            )
                          ])
                        ]),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Delivery fee",
                    maxLines: 2,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 700),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        height: 1,
                        letterSpacing: -0.3,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    getDeliveryFee().toString(),
                    maxLines: 1,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 500),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        height: 1,
                        letterSpacing: -0.3,
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Subtotal",
                    maxLines: 2,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 700),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        height: 1,
                        letterSpacing: -0.3,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    widget.subtotal.toString(),
                    maxLines: 1,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 500),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        height: 1,
                        letterSpacing: -0.3,
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(
                  450 ~/ 10,
                  (index) => Expanded(
                        child: Container(
                          color: index % 2 == 0
                              ? Colors.transparent
                              : Theme.of(context).colorScheme.outlineVariant,
                          height: 2,
                        ),
                      )),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    maxLines: 2,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 700),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        height: 1,
                        letterSpacing: -0.3,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    getTotal().toString(),
                    maxLines: 1,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 500),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        height: 1,
                        letterSpacing: -0.3,
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: Opacity(
                  opacity: deliveryMethod == null ? 0.5 : 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: ElevatedButton(
                      onPressed: deliveryMethod == null
                          ? null
                          : () {
                              showPaymentMethodDialog(context);
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
                          "Proceed to payment",
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
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
