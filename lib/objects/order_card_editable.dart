part of main;

// ignore: must_be_immutable
class OrderCardEditable extends StatefulWidget {
  OrderCardEditable(this.orderID, this.order, {super.key});

  String orderID;
  Map order;

  @override
  State<OrderCardEditable> createState() => _OrderCardEditableState();
}

class _OrderCardEditableState extends State<OrderCardEditable> {
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

  void updateStatus(String? value) {
    if (value == null) {
      return;
    }
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("orders").doc(widget.orderID).update({"status": value});
    if (mounted) {
      setState(() {
        widget.order['status'] = value;
      });
    }
  }

  Color? getStatusColor(String status, bool darkMode) {
    switch (status) {
      case 'Pending':
        return Theme.of(context).colorScheme.primary;
      case 'Preparing':
        return darkMode ? Colors.cyan[200] : Colors.cyan[700];
      case 'On Delivery':
      case 'Pickup Ready':
        return darkMode ? Colors.lightBlue[200] : Colors.lightBlue[800];
      case 'Delivered':
      case 'Picked Up':
        return darkMode ? Colors.indigo[300] : Colors.indigo[700];
      case 'Cancelled':
        return darkMode ? Colors.redAccent[200] : Colors.redAccent[700];
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  @override
  void initState() {
    itemQuantity = widget.order['items'].length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dropdown = DropdownButton<String>(
      isDense: true,
      key: dropdownButtonKey,
      items: [
        DropdownMenuItem(
          value: 'Pending',
          child: Text('Pending',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: 'Bahnschrift',
                  fontVariations: const [
                    FontVariation('wght', 450),
                    FontVariation('wdth', 100),
                  ],
                  fontSize: 14,
                  letterSpacing: -0.3)),
        ),
        DropdownMenuItem(
          value: 'Preparing',
          child: Text('Preparing',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: 'Bahnschrift',
                  fontVariations: const [
                    FontVariation('wght', 450),
                    FontVariation('wdth', 100),
                  ],
                  fontSize: 14,
                  letterSpacing: -0.3)),
        ),
        DropdownMenuItem(
          value: widget.order['deliveryMethod'] == 'Delivery'
              ? 'On Delivery'
              : 'Pickup Ready',
          child: Text(
              widget.order['deliveryMethod'] == 'Delivery'
                  ? 'On Delivery'
                  : 'Pickup Ready',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: 'Bahnschrift',
                  fontVariations: const [
                    FontVariation('wght', 450),
                    FontVariation('wdth', 100),
                  ],
                  fontSize: 14,
                  letterSpacing: -0.3)),
        ),
        DropdownMenuItem(
          value: widget.order['deliveryMethod'] == 'Delivery'
              ? 'Delivered'
              : 'Picked Up',
          child: Text(
              widget.order['deliveryMethod'] == 'Delivery'
                  ? 'Delivered'
                  : 'Picked Up',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: 'Bahnschrift',
                  fontVariations: const [
                    FontVariation('wght', 450),
                    FontVariation('wdth', 100),
                  ],
                  fontSize: 14,
                  letterSpacing: -0.3)),
        ),
        DropdownMenuItem(
          value: 'Cancelled',
          child: Text(
            'Cancelled',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontFamily: 'Bahnschrift',
                fontVariations: const [
                  FontVariation('wght', 450),
                  FontVariation('wdth', 100),
                ],
                fontSize: 14,
                letterSpacing: -0.3),
          ),
        ),
      ],
      onChanged: (String? value) {
        updateStatus(value);
      },
    );

    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Card(
          color: MaterialColors.getSurfaceContainerLow(darkMode),
          elevation: 0,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) =>
                        StoreOrdersMorePage(widget.orderID, widget.order)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM dd, yyyy')
                            .format(widget.order['createdAt'].toDate())
                            .toUpperCase(),
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
                      InkWell(
                          onTap: () {
                            showDropdown();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: getStatusColor(
                                          widget.order['status'], darkMode) ??
                                      Colors.black,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              width: 100,
                              height: 30,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Offstage(child: dropdown),
                                    Text(
                                      widget.order['status'],
                                      style: TextStyle(
                                        color: getStatusColor(
                                            widget.order['status'], darkMode),
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
                                    ),
                                    const SizedBox(height: 20),
                                    Icon(Icons.expand_more,
                                        color: getStatusColor(
                                            widget.order['status'], darkMode),
                                        size: 16)
                                  ]))),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.order['displayName'],
                              style: TextStyle(
                                color: getStatusColor(
                                    widget.order['status'], darkMode),
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
                        "₱${widget.order['price']}",
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
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
