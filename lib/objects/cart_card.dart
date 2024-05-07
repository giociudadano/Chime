/*
  [Title]
  OrderCard

  [Description]
  An OrderCard is an object containing a place name, a list of order items from that place, and a checkout button.
  
  Created when visiting the CartPage. Each place in the cart has its own OrderCard.
*/

part of '../main.dart';

// ignore: must_be_immutable
class CartCard extends StatefulWidget {
  CartCard(this.placeID, this.items, {super.key});
  String placeID;
  Map items;
  bool isVisible = true;

  @override
  State<CartCard> createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  String placeName = '';
  int deliveryFee = 0;
  int total = 0;

  // Retrieves and sets the place information given the place ID of the page.
  // Place ID is retrieved when obtaining product information.
  void getPlaceInfo() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection("places")
        .doc(widget.placeID)
        .get()
        .then((document) async {
      if (document.exists) {
        if (mounted) {
          setState(() {
            placeName = document.data()!['placeName'] ?? '';
            deliveryFee = document.data()!['deliveryPrice'] ?? 0;
          });
        }
      }
    });
  }

  void getTotal() async {
    for (String key in widget.items.keys) {
      int itemPrice =
          widget.items[key]['price'] * widget.items[key]['quantity'];
      setState(() {
        total += itemPrice;
      });
    }
  }

  void deleteFrame() {
    setState(() {
      widget.isVisible = false;
    });
  }

  void updateTotal(int delta) {
    if (mounted) {
      setState(() {
        total += delta;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getPlaceInfo();
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
          color:  Theme.of(context).colorScheme.surface,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
            color:  Theme.of(context).colorScheme.outline,
          ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      placeName,
                      maxLines: 1,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Manrope',
                        fontVariations: const [
                          FontVariation('wght', 700),
                        ],
                        fontSize: 20,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius:
                                BorderRadius.all(Radius.circular(8))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          child: Row(
                            children: [
                              Icon(Icons.motorcycle,
                                  size: 24, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              SizedBox(height: 12),
                              Text(
                                "₱${deliveryFee}",
                                maxLines: 1,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 16,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ))
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  key: UniqueKey(),
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemBuilder: (BuildContext context, int index) {
                    String key = widget.items.keys.elementAt(index);
                    return CartItemCard(widget.placeID, key, widget.items[key],
                        deleteFrame: deleteFrame, updateTotal: updateTotal);
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
                                    placeID: widget.placeID,
                                    items: widget.items)));
                          }
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                Theme.of(context).colorScheme.primary),
                            shape:
                                MaterialStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide.none,
                            ))),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            "Checkout (₱$total)",
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
          ));
    } else {
      return const SizedBox.shrink();
    }
  }
}
