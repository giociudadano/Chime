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

  void setOrderStatus(String newStatus) {
    FirebaseFirestore db = FirebaseFirestore.instance;

    // 1. Set product to new status in database
    db.collection("orders").doc(widget.orderID).update({"status": newStatus});

    // 2. Set product to new status in app
    if (mounted) {
      setState(() {
        widget.order['status'] = newStatus;
      });
    }

    widget.setOrderStatusCallback!(widget.orderID, newStatus);
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
        child: Column(children: [
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
            // For sellers: Review - White for all states, Green for 'Received' and 'Completed', Red for 'Cancelled'.
            // For buyers: Review - Green for all states, White for 'Received' and Red for 'Completed'.
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => OrderReceiptPage(
                            widget.adminControls, widget.orderID, widget.order,
                            setOrderStatusCallback:
                                widget.setOrderStatusCallback)),
                  );
                },
                style: ButtonStyle(
                  elevation: const MaterialStatePropertyAll(0),
                  backgroundColor: MaterialStatePropertyAll(widget.adminControls
                      ? (widget.order['status'] == 'Received' ||
                              widget.order['status'] == 'Completed')
                          ? ChimeColors.getGreen200()
                          : widget.order['status'] == 'Cancelled'
                              ? ChimeColors.getRed200()
                              : MaterialColors.getSurfaceContainerLowest(
                                  darkMode)
                      : widget.order['status'] == 'Received'
                          ? MaterialColors.getSurfaceContainerLowest(darkMode)
                          : ChimeColors.getGreen200()),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: widget.adminControls
                        ? (widget.order['status'] == 'Received' ||
                                widget.order['status'] == 'Completed' ||
                                widget.order['status'] == 'Cancelled')
                            ? BorderSide.none
                            : BorderSide(
                                color: ChimeColors.getGreen300(),
                              )
                        : widget.order['status'] == 'Received'
                            ? BorderSide(
                                color: ChimeColors.getGreen300(),
                              )
                            : BorderSide.none,
                  )),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "Review",
                    style: TextStyle(
                      color: widget.adminControls
                          ? (widget.order['status'] == 'Received' ||
                                  widget.order['status'] == 'Completed')
                              ? ChimeColors.getGreen800()
                              : widget.order['status'] == 'Cancelled'
                                  ? ChimeColors.getRed800()
                                  : Theme.of(context).colorScheme.outline
                          : widget.order['status'] == 'Received'
                              ? Theme.of(context).colorScheme.outline
                              : ChimeColors.getGreen800(),
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
            // For sellers: If the current order is unread, add a button
            // that allows the seller to prepare that order.
            if (widget.adminControls && widget.order['status'] == "Unread")
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      setOrderStatus("Preparing");
                    },
                    style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(0),
                      backgroundColor:
                          MaterialStatePropertyAll(ChimeColors.getGreen200()),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide.none,
                      )),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Prepare",
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
              ),
            // For sellers: If the current order is preparing, add a button
            // that allows the seller to ready that order for pickup/delivery.
            if (widget.adminControls && widget.order['status'] == 'Preparing')
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.order['deliveryMethod'] == 'Pickup') {
                        setOrderStatus("Ready for Pickup");
                      } else if (widget.order['deliveryMethod'] == 'Delivery') {
                        setOrderStatus("On Delivery");
                      }
                    },
                    style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(0),
                      backgroundColor:
                          MaterialStatePropertyAll(ChimeColors.getGreen200()),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide.none,
                      )),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        widget.order['deliveryMethod'] == "Pickup"
                            ? "Ready for Pickup"
                            : "Ready for Delivery",
                        textAlign: TextAlign.center,
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
              ),
            // For sellers: If the current order is ready for pickup/delivery, add a button
            // that allows the seller to mark that order as received.
            if (widget.adminControls &&
                (widget.order['status'] == 'Ready for Pickup' ||
                    widget.order['status'] == 'On Delivery'))
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      setOrderStatus("Received");
                    },
                    style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(0),
                      backgroundColor:
                          MaterialStatePropertyAll(ChimeColors.getGreen200()),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide.none,
                      )),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Mark as Received",
                        textAlign: TextAlign.center,
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
              ),
            // For buyers: If the current order is received, add a button
            // that allows the seller to mark that order as completed.
            if (!widget.adminControls && (widget.order['status'] == 'Received'))
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      setOrderStatus("Completed");
                    },
                    style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(0),
                      backgroundColor:
                          MaterialStatePropertyAll(ChimeColors.getGreen200()),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide.none,
                      )),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Mark as Complete",
                        textAlign: TextAlign.center,
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
              ),
          ]),
        ]),
      ),
    );
  }
}
