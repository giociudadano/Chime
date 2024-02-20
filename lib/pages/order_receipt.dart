part of '../main.dart';

// ignore: must_be_immutable
class OrderReceiptPage extends StatefulWidget {
  OrderReceiptPage(this.adminControls, this.orderID, this.order,
      {super.key, this.setOrderStatusCallback});

  bool adminControls;
  String orderID;
  Map order;
  final Function(String orderID, String newStatus)? setOrderStatusCallback;

  @override
  State<OrderReceiptPage> createState() => _OrderReceiptPageState();
}

class _OrderReceiptPageState extends State<OrderReceiptPage> {
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
      backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
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
          child: Padding(
            padding: const EdgeInsets.only(right: 60),
            child: Text(
              "Order Info",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'Plus Jakarta Sans',
                  fontVariations: const [
                    FontVariation('wght', 700),
                    FontVariation('wdth', 100),
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
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Status",
                            style: TextStyle(
                              color: ChimeColors.getGreen800(),
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
                              color: ChimeColors.getGreen800(),
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
                            "Customer",
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

                      // If delivery method is pickup, do not display the user's address.
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
                                  padding: const EdgeInsets.only(left: 30),
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
                          const SizedBox(height: 10),
                        ]),

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
                      const SizedBox(height: 40),
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
                                color: MaterialColors.getSurfaceContainerLowest(
                                    darkMode),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: MaterialColors
                                        .getSurfaceContainerHighest(darkMode),
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
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: FittedBox(
                                            clipBehavior: Clip.hardEdge,
                                            fit: BoxFit.cover,
                                            child: CachedNetworkImage(
                                              imageUrl: widget.order['items']
                                                          [key]
                                                      ['productImageURL'] ??
                                                  '',
                                              placeholder: (context, url) =>
                                                  const Padding(
                                                padding: EdgeInsets.all(20.0),
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                color: MaterialColors
                                                    .getSurfaceContainerLow(
                                                        darkMode),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      20.0),
                                                  child: Icon(
                                                      Icons.local_mall_outlined,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .outlineVariant),
                                                ),
                                              ),
                                              fadeInCurve: Curves.easeIn,
                                              fadeOutCurve: Curves.easeOut,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.order['items'][key]['name'],
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              fontFamily: 'Plus Jakarta Sans',
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
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontVariations: const [
                                                FontVariation('wght', 700),
                                              ],
                                              fontSize: 14,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outline,
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 5),
                                              child: Text(
                                                "x${widget.order['items'][key]['quantity']}",
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .outline,
                                                  fontFamily: 'Bahnschrift',
                                                  fontVariations: const [
                                                    FontVariation('wght', 450),
                                                    FontVariation('wdth', 100),
                                                  ],
                                                  fontSize: 13,
                                                  letterSpacing: -0.3,
                                                  height: 0.85,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                      const SizedBox(height: 20),
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
                        onPressed: () {
                          Navigator.pop(context);
                          setOrderStatus("Cancelled");
                        },
                        style: ButtonStyle(
                          elevation: const MaterialStatePropertyAll(0),
                          backgroundColor: MaterialStatePropertyAll(
                              widget.order['status'] == "Unread"
                                  ? ChimeColors.getRed200()
                                  : MaterialColors.getSurfaceContainerLow(
                                      darkMode)),
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
                                  ? ChimeColors.getRed800()
                                  : Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                              fontFamily: 'Plus Jakarta Sans',
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
