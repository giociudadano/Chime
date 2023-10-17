part of main;

// ignore: must_be_immutable
class StoreOrdersMorePage extends StatefulWidget {
  StoreOrdersMorePage(this.orderID, this.order, {super.key});

  String orderID;
  Map order;

  @override
  State<StoreOrdersMorePage> createState() => _StoreOrdersMoreState();
}

class _StoreOrdersMoreState extends State<StoreOrdersMorePage> {
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
          child: Text(
            "Order Info",
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
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () {
                //TODO: Add functionality to delete an order.
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "Total Cost",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'Bahnschrift',
                    fontVariations: const [
                      FontVariation('wght', 650),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 14,
                    letterSpacing: -0.3,
                    height: 0.85,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "₱${widget.order['price']}",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Bahnschrift',
                    fontVariations: const [
                      FontVariation('wght', 700),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 40,
                    letterSpacing: -1.2,
                    height: 0.85,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "No. of Items",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 650),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3,
                        height: 0.85,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      widget.order['items'].length.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 400),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3,
                        height: 0.85,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Status",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 650),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3,
                        height: 0.85,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      widget.order['status'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 400),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3,
                        height: 0.85,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Phone Number",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 650),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3,
                        height: 0.85,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      widget.order['phoneNumber'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 400),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3,
                        height: 0.85,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 70),
                      child: Text(
                        "Address",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Bahnschrift',
                          fontVariations: const [
                            FontVariation('wght', 650),
                            FontVariation('wdth', 100),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3,
                          height: 0.85,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.order['address'] ?? 'No address',
                        maxLines: 10,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: 'Bahnschrift',
                          fontVariations: const [
                            FontVariation('wght', 400),
                            FontVariation('wdth', 100),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3,
                          height: 1.2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Date of Order",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 650),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3,
                        height: 0.85,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM dd, yyyy')
                          .format(widget.order['createdAt'].toDate()),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 400),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3,
                        height: 0.85,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Time of Order",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 650),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3,
                        height: 0.85,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      DateFormat('h:mm a')
                          .format(widget.order['createdAt'].toDate()),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 400),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3,
                        height: 0.85,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: List.generate(
                      450 ~/ 10,
                      (index) => Expanded(
                            child: Container(
                              color: index % 2 == 0
                                  ? Colors.transparent
                                  : Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                              height: 1.5,
                            ),
                          )),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.builder(
                      key: UniqueKey(),
                      shrinkWrap: true,
                      itemCount: widget.order['items'].length,
                      itemBuilder: (BuildContext context, int index) {
                        String key =
                            widget.order['items'].keys.elementAt(index);
                        return Column(children: [
                          Row(
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
                                        color: MaterialColors
                                            .getSurfaceContainerLow(darkMode),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Icon(Icons.local_mall_outlined,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.order['items'][key]['name'],
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontFamily: 'Bahnschrift',
                                      fontVariations: const [
                                        FontVariation('wght', 650),
                                        FontVariation('wdth', 100),
                                      ],
                                      fontSize: 14,
                                      letterSpacing: -0.3,
                                      height: 0.85,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "₱${widget.order['items'][key]['price']}",
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontFamily: 'Bahnschrift',
                                      fontVariations: const [
                                        FontVariation('wght', 650),
                                        FontVariation('wdth', 100),
                                      ],
                                      fontSize: 24,
                                      letterSpacing: -0.3,
                                      height: 0.85,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Container(
                                    color:
                                        MaterialColors.getSurfaceContainerLow(
                                            darkMode),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
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
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                        ]);
                      }),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
