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
  CheckoutPage({super.key, required this.subtotal});
  int subtotal = 0;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // Variables for listeners.
  StreamSubscription? selectedAddressListener;

  // Form variables.
  String? deliveryMethod;

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
          if (selectedAddress == null && deliveryMethod == 'delivery') {
            deliveryMethod = null;
          }
        });
      }
    });
  }

  @override
  void initState() {
    getAddresses();
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
              icon: Icon(Icons.info_outline,
                  color: Theme.of(context).colorScheme.outline),
              onPressed: () {
                //TODO: Add information about the checkout page.
                throw UnimplementedError(
                    "TODO: Add information about the checkout page.");
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
                          value: 'pickup',
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
                              value: 'delivery',
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
                                  "Unknown amount",
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
                    "0",
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
                    "0",
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
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: Opacity(
                  opacity: deliveryMethod == null ? 0.5 : 1,
                  child: ElevatedButton(
                    onPressed: deliveryMethod == null
                        ? null
                        : () {
                            //TODO: Add pop-up.
                            throw UnimplementedError("Add pop-up.");
                          },
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          Theme.of(context).colorScheme.primary),
                      foregroundColor: MaterialStatePropertyAll(
                          Theme.of(context).colorScheme.onPrimary),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.checkout,
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
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
