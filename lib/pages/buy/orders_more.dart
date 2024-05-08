part of '../../main.dart';

// ignore: must_be_immutable
class OrdersMorePage extends StatefulWidget {
  OrdersMorePage(this.adminControls, this.orderID, this.order,
      {super.key, this.setOrderStatusCallback});

  bool adminControls;
  String orderID;
  Map order;
  final Function(String orderID, String newStatus)? setOrderStatusCallback;

  @override
  State<OrdersMorePage> createState() => _OrdersMorePageState();
}

class _OrdersMorePageState extends State<OrdersMorePage> {
  void initProducts() {
    for (var productID in widget.order['items'].keys) {
      setProductImageURL(productID);
    }
  }

  void setProductImageURL(String productID) async {
    String ref = "products/$productID.jpg";
    String url = await FirebaseStorage.instance.ref(ref).getDownloadURL();
    if (mounted) {
      setState(() {
        widget.order['items'][productID]['productImageURL'] = url;
      });
    }
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
    initProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onBackground),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 60),
            child: Text(
              "Order Info",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontFamily: 'Manrope',
                  fontVariations: const [
                    FontVariation('wght', 700),
                  ],
                  fontSize: 20,
                  letterSpacing: -0.3),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListView.builder(
                      key: UniqueKey(),
                      shrinkWrap: true,
                      itemCount: widget.order['items'].length,
                      itemBuilder: (BuildContext context, int index) {
                        String key =
                            widget.order['items'].keys.elementAt(index);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Card(
                            color: Theme.of(context).colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color:
                                    Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: FittedBox(
                                        clipBehavior: Clip.hardEdge,
                                        fit: BoxFit.cover,
                                        child: CachedNetworkImage(
                                          imageUrl: widget.order['items'][key]
                                                  ['productImageURL'] ??
                                              '',
                                          placeholder: (context, url) =>
                                              const Padding(
                                            padding: EdgeInsets.all(20.0),
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            color: Theme.of(context).colorScheme.surfaceVariant,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Icon(
                                                  Icons.local_mall_outlined,
                                                  color: Theme.of(context).colorScheme.onSurfaceVariant),
                                            ),
                                          ),
                                          fadeInCurve: Curves.easeIn,
                                          fadeOutCurve: Curves.easeOut,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.order['items'][key]['name'],
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontFamily: 'Manrope',
                                          fontVariations: const [
                                            FontVariation('wght', 700),
                                          ],
                                          fontSize: 14,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      Text(
                                        "₱${widget.order['items'][key]['price']}",
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontFamily: 'Manrope',
                                          fontVariations: const [
                                            FontVariation('wght', 700),
                                          ],
                                          fontSize: 14,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      if (widget.order['items'][key]
                                              ['variant'] !=
                                          null)
                                        Padding(
                                            padding: const EdgeInsets.only(top: 10),
                                            child: Text(
                                              "Variant: ${widget.order['items'][key]['variant']}",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outline,
                                                fontFamily: 'Source Sans 3',
                                                fontVariations: const [
                                                  FontVariation('wght', 400),
                                                ],
                                                fontSize: 14,
                                                height: 0.85,
                                                letterSpacing: -0.3,
                                              ),
                                            )),
                                      const SizedBox(height: 10),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            style: BorderStyle.none
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 8),
                                          child: Text(
                                            "x${widget.order['items'][key]['quantity']}",
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline,
                                              fontFamily: 'Source Sans 3',
                                              fontVariations: const [
                                                FontVariation('wght', 450),
                                              ],
                                              fontSize: 13,
                                              letterSpacing: -0.3,
                                              height: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // If order contains additional notes, display subsection.
                      if (widget.order['additionalNotes'] != null)
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              Text(
                                "Additional Notes",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontFamily: 'Source Sans 3',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                  ],
                                  fontSize: 14,
                                  height: 1.1,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.order['additionalNotes'] ?? "",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Source Sans 3',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                  ],
                                  fontSize: 14,
                                  height: 1.15,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Divider(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                                height: 0.5,
                              ),
                            ]),
                      const SizedBox(height: 20),
                      Text(
                        "Details",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontFamily: 'Source Sans 3',
                          fontVariations: const [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order ID",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            widget.orderID,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
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
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Cost",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            "₱${widget.order['price']}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
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
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "No. of Items",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            widget.order['items'].length.toString(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
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
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Delivery Method",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            widget.order['deliveryMethod'],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
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
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Delivery Fee",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            "₱${widget.order['deliveryFee']}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
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
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Mode of Payment",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            widget.order['paymentMethod'],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
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
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Payment Status",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            widget.order['isPaid'] ?? false == true
                                ? 'Paid'
                                : 'Unpaid',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
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
                      const SizedBox(height: 15),
                      Divider(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        height: 0.5,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Order Status",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontFamily: 'Source Sans 3',
                          fontVariations: const [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Status",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            widget.order['status'],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
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
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Date of Order",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            DateFormat('MMMM dd, yyyy')
                                .format(widget.order['createdAt'].toDate()),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
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
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Time of Order",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            DateFormat('h:mm a')
                                .format(widget.order['createdAt'].toDate()),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
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
                      const SizedBox(height: 15),
                      Divider(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        height: 0.5,
                      ),
                      const SizedBox(height: 15),

                      Text(
                        "Customer Info",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontFamily: 'Source Sans 3',
                          fontVariations: const [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Name",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            widget.order['customerName'],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
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
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Phone Number",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            widget.order['phoneNumber'] ?? 'N/A',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
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
                      const SizedBox(height: 10),

                      // If delivery method is pickup, do not display the user's address and landmark fields.
                      if (widget.order['deliveryMethod'] != 'Pickup')
                        Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Address",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Source Sans 3',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                  ],
                                  fontSize: 14,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 60),
                                  child: Text(
                                    widget.order['address'] ??
                                        'Unknown address',
                                    textAlign: TextAlign.right,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontFamily: 'Source Sans 3',
                                      fontVariations: const [
                                        FontVariation('wght', 400),
                                      ],
                                      fontSize: 14,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Landmark",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Source Sans 3',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                  ],
                                  fontSize: 14,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                widget.order['landmark'],
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
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
                          const SizedBox(height: 40),
                        ]),

                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel Order button. Enabled only if the current status of the order is 'Unread'.
                  Expanded(
                    child: AbsorbPointer(
                      absorbing: widget.order['status'] != "Unread",
                      child: ElevatedButton(
                        onPressed: () => showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Cancel this order'),
                                  content: const Text('After cancelling, the order will no longer be processed. Please contact the seller to request applicable refunds.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'Cancel');
                                      },
                  
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setOrderStatus("Cancelled");
                                        Navigator.pop(context, 'OK');
                                        const  snackBar = SnackBar(
                                          content: Text('Order has been cancelled.'),
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
                          backgroundColor: MaterialStatePropertyAll(
                              widget.order['status'] == "Unread"
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.surfaceVariant),
                          shape:
                              MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Cancel Order",
                            style: TextStyle(
                              color: widget.order['status'] == "Unread"
                                  ? Theme.of(context).colorScheme.onError
                                  : Theme.of(context).colorScheme.surfaceVariant,
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
                  // For sellers: If the status is unread, add a new button that allows the
                  // seller to prepare that order.
                  if (widget.adminControls &&
                      widget.order['status'] == 'Unread')
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            setOrderStatus("Preparing");
                          },
                          style: ButtonStyle(
                            elevation: const MaterialStatePropertyAll(0),
                            backgroundColor: MaterialStatePropertyAll(
                                Theme.of(context).colorScheme.secondaryContainer),
                            shape:
                                MaterialStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Prepare",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // For sellers: If the status is preparing, add a new button that allows the
                  // seller to ready that order for pickup or delivery.
                  if (widget.adminControls &&
                      widget.order['status'] == 'Preparing')
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            setOrderStatus("To Receive");
                          },
                          style: ButtonStyle(
                            elevation: const MaterialStatePropertyAll(0),
                            backgroundColor: MaterialStatePropertyAll(
                                Theme.of(context).colorScheme.secondaryContainer),
                            shape:
                                MaterialStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "To Receive",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // For sellers: If the status is ready for pickup or on delivery, add a new button
                  // that allows the seller to mark that item as received.
                  if (widget.adminControls &&
                      (widget.order['status'] == 'To Receive'))
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            setOrderStatus("Received");
                          },
                          style: ButtonStyle(
                            elevation: const MaterialStatePropertyAll(0),
                            backgroundColor: MaterialStatePropertyAll(
                                Theme.of(context).colorScheme.secondaryContainer),
                            shape:
                                MaterialStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Received",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!widget.adminControls &&
                      (widget.order['status'] == 'Received'))
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            setOrderStatus("Completed");
                          },
                          style: ButtonStyle(
                            elevation: const MaterialStatePropertyAll(0),
                            backgroundColor: MaterialStatePropertyAll(
                                Theme.of(context).colorScheme.secondaryContainer),
                            shape:
                                MaterialStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Completed",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
