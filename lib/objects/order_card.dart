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
  OrderCard(this.order, {super.key});

  Map order;
  String placeName = '';

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  late DateTime createdAt;
  late int itemQuantity;
  late int price;

  Future getPlaceInfo() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("places")
        .doc(widget.order['placeID'])
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

  @override
  void initState() {
    createdAt = widget.order['createdAt'].toDate();
    itemQuantity = widget.order['items'].length;
    price = widget.order['price'];
    getPlaceInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Card(
          color: MaterialColors.getSurfaceContainerLow(darkMode),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('yMMMMd').format(createdAt).toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontFamily: 'Bahnschrift',
                          fontVariations: const [
                            FontVariation('wght', 500),
                            FontVariation('wdth', 100),
                          ],
                          fontSize: 13,
                          letterSpacing: -0.3,
                          height: 0.85,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          width: 100,
                          height: 30,
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                widget.order['status'],
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontFamily: 'Bahnschrift',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                    FontVariation('wdth', 100),
                                  ],
                                  fontSize: 13,
                                  letterSpacing: -0.3,
                                  height: 0.85,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )))
                    ]),
                const SizedBox(height: 15),
                Row(children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.placeName,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Bahnschrift',
                              fontVariations: const [
                                FontVariation('wght', 650),
                                FontVariation('wdth', 100),
                              ],
                              fontSize: 15,
                              letterSpacing: -0.3,
                              height: 0.85,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            itemQuantity == 1
                                ? "1 item"
                                : "$itemQuantity items",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontFamily: 'Bahnschrift',
                              fontVariations: const [
                                FontVariation('wght', 500),
                                FontVariation('wdth', 100),
                              ],
                              fontSize: 13,
                              letterSpacing: -0.3,
                              height: 1.2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      "₱$price",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 700),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 32,
                        letterSpacing: -0.3,
                        height: 0.85,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(
                  widget.order['address'] ?? 'No address',
                  maxLines: 3,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontFamily: 'Bahnschrift',
                    fontVariations: const [
                      FontVariation('wght', 400),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 13,
                    letterSpacing: -0.3,
                    height: 1.1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
