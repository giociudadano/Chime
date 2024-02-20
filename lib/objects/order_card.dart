part of '../main.dart';

// ignore: must_be_immutable
class OrderCard extends StatefulWidget {
  OrderCard(this.orderID, this.order,
      {super.key, this.adminControls = false, this.setOrderStatusCallback});

  String orderID;
  Map order;
  bool adminControls;
  final Function(String orderID, String newStatus)? setOrderStatusCallback;

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  GlobalKey? dropdownButtonKey = GlobalKey();
  late int itemQuantity;

  void showDropdown() {
    GestureDetector? detector;
    void searchForGestureDetector(BuildContext? element) {
      element?.visitChildElements((element) {
        if (element.widget is GestureDetector) {
          detector = element.widget as GestureDetector?;
        } else {
          searchForGestureDetector(element);
        }
      });
    }

    searchForGestureDetector(dropdownButtonKey?.currentContext);
    assert(detector != null);

    detector?.onTap?.call();
  }

  @override
  void initState() {
    itemQuantity = widget.order['items'].length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: MaterialColors.getSurfaceContainerLowest(darkMode),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: MaterialColors.getSurfaceContainerHighest(darkMode),
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.adminControls
                        ? widget.order['customerName']
                        : widget.order['storeName'],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontFamily: 'Plus Jakarta Sans',
                      fontVariations: const [
                        FontVariation('wght', 700),
                      ],
                      fontSize: 14,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    itemQuantity == 1 ? "1 item" : "$itemQuantity items",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontFamily: 'Source Sans 3',
                      fontVariations: const [
                        FontVariation('wght', 400),
                      ],
                      fontSize: 14,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Text(
                "₱${widget.order['price']}",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'Plus Jakarta Sans',
                  fontVariations: const [
                    FontVariation('wght', 700),
                  ],
                  fontSize: 20,
                  letterSpacing: -0.3,
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.pin_drop_outlined,
                  size: 20, color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  widget.order['address'] ?? 'Unknown address',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontFamily: 'Product Sans 3',
                    fontVariations: const [
                      FontVariation('wght', 400),
                    ],
                    fontSize: 14,
                    letterSpacing: -0.3,
                  ),
                ),
              )
            ]),
            const SizedBox(height: 5),
            Row(children: [
              Icon(Icons.schedule,
                  size: 20, color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: 5),
              Text(
                DateFormat('MMM dd, yyyy, h:mm a')
                    .format(widget.order['createdAt'].toDate()),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontFamily: 'Product Sans 3',
                  fontVariations: const [
                    FontVariation('wght', 400),
                  ],
                  fontSize: 14,
                  letterSpacing: -0.3,
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => OrderReceiptPage(
                              widget.adminControls,
                              widget.orderID,
                              widget.order,
                              setOrderStatusCallback:
                                  widget.setOrderStatusCallback)),
                    );
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(ChimeColors.getGreen200()),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide.none,
                      ))),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Review",
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
            ])
          ],
        ),
      ),
    );
  }
}
