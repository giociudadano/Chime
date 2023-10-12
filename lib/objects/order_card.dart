/*
  [Title]
  OrderCard

  [Description]
  An OrderCard is an object containing a place name, a list of order items from that place, and a checkout button.
  
  Created when visiting the CartPage. Each place in the cart has its own OrderCard.
*/

part of main;

// ignore: must_be_immutable
class OrderCard extends StatefulWidget {
  OrderCard({super.key, required this.placeID, required this.orderItems});
  String placeID = '', placeName = '';
  Map orderItems = {};
  bool isVisible = true;

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  int total = 0;
  final ValueNotifier<bool> valueNotifierTotal = ValueNotifier(false);

  // Retrieves and sets the place information given the place ID of the page.
  // Place ID is retrieved when obtaining product information.
  Future getPlaceName() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection("places")
        .doc(widget.placeID)
        .get()
        .then((document) async {
      if (document.exists) {
        if (mounted) {
          setState(() {
            widget.placeName = document.data()!['placeName'] ?? '';
          });
        }
      }
    });
  }

  void getTotal() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    for (var orderItem in widget.orderItems.entries) {
      await db.collection("products").doc(orderItem.key).get().then((document) {
        int productPrice = document.data()!['productPrice'] * orderItem.value;
        setState(() {
          total += productPrice;
        });
      });
    }
  }

  void deleteFrame() {
    setState(() {
      widget.isVisible = false;
    });
  }

  void updateTotal(int delta) {
    total += delta;
    valueNotifierTotal.value = !valueNotifierTotal.value;
  }

  @override
  void initState() {
    super.initState();
    getPlaceName();
    getTotal();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    if (widget.isVisible) {
      return Card(
          color: MaterialColors.getSurfaceContainerLow(darkMode),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                  child: Text(
                    widget.placeName,
                    maxLines: 1,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 700),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 16,
                        letterSpacing: -0.3,
                        height: 0.85,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  key: UniqueKey(),
                  shrinkWrap: true,
                  itemCount: widget.orderItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    String key = widget.orderItems.keys.elementAt(index);
                    return OrderItemCard(
                        placeID: widget.placeID,
                        productID: key,
                        quantity: widget.orderItems[key],
                        deleteFrame: deleteFrame,
                        updateTotal: updateTotal);
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (context.mounted) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CheckoutPage(
                                    placeID: widget.placeID, subtotal: total)));
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.primary),
                          foregroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.onPrimary),
                        ),
                        child: ValueListenableBuilder<bool>(
                            valueListenable: valueNotifierTotal,
                            builder: (context, val, child) {
                              return Text(
                                "${AppLocalizations.of(context)!.checkout} (₱$total)",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontFamily: 'Bahnschrift',
                                  fontVariations: const [
                                    FontVariation('wght', 500),
                                    FontVariation('wdth', 100),
                                  ],
                                  fontSize: 14,
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ));
    } else {
      return const SizedBox.shrink();
    }
  }
}
