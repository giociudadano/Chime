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

  bool isPaid = false;

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

  void setStatusState(String newState) {
    FirebaseFirestore db = FirebaseFirestore.instance;

    // 1. Set product to new status in database
    db.collection("orders").doc(widget.orderID).update({"status": newState});

    // 2. Set product to new status in app
    if (mounted) {
      setState(() {
        widget.order['status'] = newState;
      });
    }

    widget.setOrderStatusCallback!(widget.orderID, newState);
  }

  void setPaidState(bool newState) {
    // 1. Set product to new status in database
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("orders").doc(widget.orderID).update({"isPaid": newState});
  }

  @override
  void initState() {
    itemQuantity = widget.order['items'].length;
    isPaid = widget.order['isPaid'] ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
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
                    fontFamily: 'Manrope',
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
                fontFamily: 'Manrope',
                fontVariations: const [
                  FontVariation('wght', 700),
                ],
                fontSize: 20,
                letterSpacing: -0.3,
              ),
            ),
          ]),
          const SizedBox(height: 10),
          // Checkbox
          if (widget.adminControls && widget.order['status'] != 'Cancelled')
            Row(children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  checkColor: Colors.white,
                  activeColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  side: MaterialStateBorderSide.resolveWith(
                    (states) => BorderSide(
                        width: 1.0,
                        color: Theme.of(context).colorScheme.outline),
                  ),
                  value: isPaid,
                  onChanged: (bool? value) {
                    setPaidState(value ?? false);
                    widget.order['isPaid'] = value ?? false;
                    setState(() {
                      isPaid = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  "Mark as Paid",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontFamily: 'Product Sans 3',
                    fontVariations: const [
                      FontVariation('wght', 400),
                    ],
                    fontSize: 14,

                  ),
                ),
              )
            ]),
          if (widget.adminControls && widget.order['status'] != 'Cancelled')
            const SizedBox(height: 10),
          if (!widget.adminControls)
            Row(children: [
              Icon(Icons.update,
                  size: 20, color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  widget.order['status'] ?? 'Unknown Status',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontFamily: 'Product Sans 3',
                    fontVariations: const [
                      FontVariation('wght', 400),
                    ],
                    fontSize: 14,
                  ),
                ),
              )
            ]),
          if (widget.adminControls)
          //   Row(children: [
          //     Icon(Icons.tag,
          //         size: 20, color: Theme.of(context).colorScheme.outline),
          //     const SizedBox(width: 5),
          //     Expanded(
          //       child: Text(
          //         widget.orderID,
          //         maxLines: 1,
          //         overflow: TextOverflow.ellipsis,
          //         style: TextStyle(
          //           color: Theme.of(context).colorScheme.outline,
          //           fontFamily: 'Product Sans 3',
          //           fontVariations: const [
          //             FontVariation('wght', 400),
          //           ],
          //           fontSize: 16,
          //           letterSpacing: -0.3,
          //         ),
          //       ),
          //     )
          //   ]),
          // const SizedBox(height: 5),
          Row(children: [
            Icon(Icons.pin_drop_outlined,
                size: 20, color: Theme.of(context).colorScheme.outline),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                widget.order['deliveryMethod'] == "Pickup"
                    ? "For Pickup"
                    : "Deliver to " + widget.order['landmark'],
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
          if (widget.adminControls)
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
                ),
              ),
            ]),
          if (!widget.adminControls && widget.order['status'] != 'Cancelled')
            Row(children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 5),
              Text(
                widget.order['isPaid'] ?? false == true ? 'Paid' : 'To be Paid',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontFamily: 'Product Sans 3',
                  fontVariations: const [
                    FontVariation('wght', 400),
                  ],
                  fontSize: 14,
      
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
                        builder: (context) => OrdersMorePage(
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
                          ? Theme.of(context).colorScheme.surfaceVariant
                          : widget.order['status'] == 'Cancelled'
                              ? Theme.of(context).colorScheme.surfaceVariant
                              : Theme.of(context).colorScheme.surfaceVariant
                      : widget.order['status'] == 'Received'
                          ? Theme.of(context).colorScheme.surfaceVariant
                          : widget.order['status'] == 'Cancelled'
                              ? Theme.of(context).colorScheme.surfaceVariant
                              : Theme.of(context).colorScheme.surfaceVariant),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: widget.adminControls
                        ? (widget.order['status'] == 'Received' ||
                                widget.order['status'] == 'Completed' ||
                                widget.order['status'] == 'Cancelled')
                            ? BorderSide.none
                            : BorderSide(
                                color: Theme.of(context).colorScheme.surface,
                              )
                        : widget.order['status'] == 'Received'
                            ? BorderSide(color: Theme.of(context).colorScheme.surfaceVariant)
                            : widget.order['status'] == 'Cancelled'
                                ? BorderSide(color: Theme.of(context).colorScheme.surfaceVariant)
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
                              ? Theme.of(context).colorScheme.onSecondaryContainer
                              : widget.order['status'] == 'Cancelled'
                                  ? Theme.of(context).colorScheme.onSecondaryContainer
                                  : Theme.of(context).colorScheme.onSecondaryContainer
                          : widget.order['status'] == 'Received'
                              ? Theme.of(context).colorScheme.outline
                              : widget.order['status'] == 'Cancelled'
                                  ? Theme.of(context).colorScheme.onSecondaryContainer
                                  : Theme.of(context).colorScheme.onSecondaryContainer,
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
            // For sellers: If the current order is unread, add a button
            // that allows the seller to prepare that order.
            if (widget.adminControls && widget.order['status'] == "Unread")
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      setStatusState("Preparing");
                    },
                    style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(0),
                      backgroundColor:
                          MaterialStatePropertyAll(Theme.of(context).colorScheme.secondaryContainer),
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
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
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
            // For sellers: If the current order is preparing, add a button
            // that allows the seller to ready that order for pickup/delivery.
            if (widget.adminControls && widget.order['status'] == 'Preparing')
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      setStatusState('To Receive');
                    },
                    style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(0),
                      backgroundColor:
                          MaterialStatePropertyAll(Theme.of(context).colorScheme.secondaryContainer),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide.none,
                      )),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        widget.order['deliveryMethod'] == "Pickup"
                            ? "For Pickup"
                            : "For Delivery",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
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
            // For sellers: If the current order is ready for pickup/delivery, add a button
            // that allows the seller to mark that order as received.
            if (widget.adminControls &&
                (widget.order['status'] == 'To Receive'))
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ElevatedButton(
                    onPressed: () => showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Mark Order as Delivered'),
                                  content: const Text('Please make sure everything is in check.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'Cancel');
                                      },
                  
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setStatusState("Received");
                                        Navigator.pop(context, 'OK');
                                        final snackBar = SnackBar(
                                          content: const Text('Order is marked as delivered.'),
                                        );

                                        // Find the ScaffoldMessenger in the widget tree
                                        // and use it to show a SnackBar.
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        } ,
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              ),
                    style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(0),
                      backgroundColor:
                          MaterialStatePropertyAll(Theme.of(context).colorScheme.secondaryContainer),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide.none,
                      )),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Delivered",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          fontFamily: 'Manrope',
                          fontVariations: const [
                            FontVariation('wght', 700),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3,
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
                    onPressed: () => showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Mark Order as Complete'),
                                  content: const Text('Please make sure everything is in check.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'Cancel');
                                      },
                  
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setStatusState("Completed");
                                        Navigator.pop(context, 'OK');
                                        final snackBar = SnackBar(
                                          content: const Text('Order is marked as completed.'),
                                        );

                                        // Find the ScaffoldMessenger in the widget tree
                                        // and use it to show a SnackBar.
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        } ,
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              ),
                    style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(0),
                      backgroundColor:
                          MaterialStatePropertyAll(Theme.of(context).colorScheme.secondaryContainer),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide.none,
                      )),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Completed",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          fontFamily: 'Manrope',
                          fontVariations: const [
                            FontVariation('wght', 700),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3,
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
