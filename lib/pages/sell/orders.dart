part of '../../main.dart';

// ignore: must_be_immutable
class StoreOrdersPage extends StatefulWidget {
  StoreOrdersPage(this.placeID, {super.key});

  String placeID = '';

  @override
  State<StoreOrdersPage> createState() => _StoreOrdersPageState();
}

class _StoreOrdersPageState extends State<StoreOrdersPage>
    with TickerProviderStateMixin {
  final _searchBox = TextEditingController();

  late TabController tabController;
  StreamSubscription? ordersListener;
  Map orders = {};

  // Variables for search function.
  FocusNode focus = FocusNode();
  Timer? _debounce;

  void initOrdersListener() {
    FirebaseFirestore db = FirebaseFirestore.instance;

    ordersListener =
        db.collection("places").doc(widget.placeID).snapshots().listen((event) {
      db.collection("places").doc(widget.placeID).get().then((document) {
        if (document.exists) {
          List orderIDs = document.data()!['orders'].reversed.toList();
          for (String orderID in orderIDs) {
            db.collection("orders").doc(orderID).get().then((document) {
              if (document.exists) {
                if (mounted) {
                  setState(() {
                    orders[orderID] = document.data()!;
                  });
                }
              }
            });
          }
        }
      });
    });
  }

  void setOrderStatus(String orderID, String newStatus) {
    if (mounted) {
      setState(() {
        orders[orderID]['status'] = newStatus;
      });
    }
  }

  int getOrderCount(String category) {
    int orderCount = 0;
    for (var key in orders.keys) {
      if (orders[key]['status'] == category) {
        orderCount++;
      }
    }
    return orderCount;
  }

  void initSearchListener() {
    _searchBox.addListener(() {
      if (focus.hasFocus) {
        if (_debounce != null) {
          _debounce!.cancel();
        }
        _debounce = Timer(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {});
          }
        });
      }
    });
  }

  @override
  void initState() {
    tabController = TabController(
      initialIndex: 0,
      length: 5,
      vsync: this,
    );
    tabController.addListener(() {
      setState(() {});
    });
    initOrdersListener();
    initSearchListener();
    super.initState();
  }

  @override
  void dispose() {
    ordersListener!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            TextField(
              focusNode: focus,
              controller: _searchBox,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: EdgeInsets.zero,
                hintText: "Search",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  letterSpacing: -0.3,
                ),
                filled: true,
                fillColor: MaterialColors.getSurfaceContainerLowest(darkMode),
                isDense: true,
                prefixIcon: const Icon(Icons.search_outlined, size: 16),
              ),
              style: const TextStyle(
                fontFamily: 'Source Sans 3',
                fontVariations: [
                  FontVariation('wght', 400),
                ],
                height: 1.2,
                letterSpacing: -0.3,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                height: 30,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            tabController.index == 0
                                ? ChimeColors.getGreen800()
                                : ChimeColors.getGreen100()),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Unread",
                            style: TextStyle(
                                color: tabController.index == 0
                                    ? ChimeColors.getGreen100()
                                    : ChimeColors.getGreen800(),
                                fontFamily: 'Plus Jakarta Sans',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 13,
                                letterSpacing: -0.3,
                                overflow: TextOverflow.ellipsis),
                          )),
                      onPressed: () {
                        tabController.animateTo(0);
                      },
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            tabController.index == 1
                                ? ChimeColors.getGreen800()
                                : ChimeColors.getGreen100()),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Preparing",
                            style: TextStyle(
                                color: tabController.index == 1
                                    ? ChimeColors.getGreen100()
                                    : ChimeColors.getGreen800(),
                                fontFamily: 'Plus Jakarta Sans',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 13,
                                letterSpacing: -0.3,
                                overflow: TextOverflow.ellipsis),
                          )),
                      onPressed: () {
                        tabController.animateTo(1);
                      },
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            tabController.index == 2
                                ? ChimeColors.getGreen800()
                                : ChimeColors.getGreen100()),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Receiving",
                            style: TextStyle(
                                color: tabController.index == 2
                                    ? ChimeColors.getGreen100()
                                    : ChimeColors.getGreen800(),
                                fontFamily: 'Plus Jakarta Sans',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 13,
                                letterSpacing: -0.3,
                                overflow: TextOverflow.ellipsis),
                          )),
                      onPressed: () {
                        tabController.animateTo(2);
                      },
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            tabController.index == 3
                                ? ChimeColors.getGreen800()
                                : ChimeColors.getGreen100()),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Completed",
                            style: TextStyle(
                                color: tabController.index == 3
                                    ? ChimeColors.getGreen100()
                                    : ChimeColors.getGreen800(),
                                fontFamily: 'Plus Jakarta Sans',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 13,
                                letterSpacing: -0.3,
                                overflow: TextOverflow.ellipsis),
                          )),
                      onPressed: () {
                        tabController.animateTo(3);
                      },
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            tabController.index == 4
                                ? ChimeColors.getGreen800()
                                : ChimeColors.getGreen100()),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Cancelled",
                            style: TextStyle(
                                color: tabController.index == 4
                                    ? ChimeColors.getGreen100()
                                    : ChimeColors.getGreen800(),
                                fontFamily: 'Plus Jakarta Sans',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 13,
                                letterSpacing: -0.3,
                                overflow: TextOverflow.ellipsis),
                          )),
                      onPressed: () {
                        tabController.animateTo(4);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  ListView(
                    children: [
                      if (getOrderCount('Unread') == 0)
                        Text(
                          "No unread orders",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 14,
                            letterSpacing: -0.3,
                            height: 1,
                          ),
                        )
                      else
                        Expanded(
                          child: Column(
                            children: [
                              ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  key: UniqueKey(),
                                  shrinkWrap: true,
                                  itemCount: orders.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    String key = orders.keys.elementAt(index);
                                    if (orders[key]['status'] == 'Unread' &&
                                        ((_searchBox.text == '')
                                            ? true
                                            : orders[key]['customerName']
                                                .toLowerCase()
                                                .contains(_searchBox.text
                                                    .toLowerCase()))) {
                                      return OrderCard(key, orders[key],
                                          adminControls: true,
                                          setOrderStatusCallback:
                                              setOrderStatus);
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  }),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                    ],
                  ),
                  ListView(
                    children: [
                      if (getOrderCount('Preparing') +
                              getOrderCount('To Receive') ==
                          0)
                        Text(
                          "No preparing orders or orders to receive",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 14,
                            letterSpacing: -0.3,
                            height: 1,
                          ),
                        )
                      else
                        Expanded(
                          child: Column(
                            children: [
                              ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  key: UniqueKey(),
                                  shrinkWrap: true,
                                  itemCount: orders.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    String key = orders.keys.elementAt(index);
                                    if ((orders[key]['status'] == 'Preparing' ||
                                            orders[key]['status'] ==
                                                'To Receive') &&
                                        ((_searchBox.text == '')
                                            ? true
                                            : orders[key]['customerName']
                                                .toLowerCase()
                                                .contains(_searchBox.text
                                                    .toLowerCase()))) {
                                      return OrderCard(key, orders[key],
                                          adminControls: true,
                                          setOrderStatusCallback:
                                              setOrderStatus);
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  }),
                            ],
                          ),
                        ),
                    ],
                  ),
                  ListView(
                    children: [
                      if (getOrderCount('Received') == 0)
                        Text(
                          "No received orders",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 14,
                            letterSpacing: -0.3,
                            height: 1,
                          ),
                        )
                      else
                        Expanded(
                          child: Column(
                            children: [
                              ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  key: UniqueKey(),
                                  shrinkWrap: true,
                                  itemCount: orders.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    String key = orders.keys.elementAt(index);
                                    if (orders[key]['status'] == 'Received' &&
                                        ((_searchBox.text == '')
                                            ? true
                                            : orders[key]['customerName']
                                                .toLowerCase()
                                                .contains(_searchBox.text
                                                    .toLowerCase()))) {
                                      return OrderCard(key, orders[key],
                                          adminControls: true,
                                          setOrderStatusCallback:
                                              setOrderStatus);
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  }),
                            ],
                          ),
                        ),
                    ],
                  ),
                  ListView(
                    children: [
                      if (getOrderCount('Completed') == 0)
                        Text(
                          "No completed orders",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 14,
                            letterSpacing: -0.3,
                            height: 1,
                          ),
                        )
                      else
                        Expanded(
                          child: Column(
                            children: [
                              ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  key: UniqueKey(),
                                  shrinkWrap: true,
                                  itemCount: orders.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    String key = orders.keys.elementAt(index);
                                    if (orders[key]['status'] == 'Completed' &&
                                        ((_searchBox.text == '')
                                            ? true
                                            : orders[key]['customerName']
                                                .toLowerCase()
                                                .contains(_searchBox.text
                                                    .toLowerCase()))) {
                                      return OrderCard(key, orders[key],
                                          adminControls: true,
                                          setOrderStatusCallback:
                                              setOrderStatus);
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  }),
                            ],
                          ),
                        ),
                    ],
                  ),
                  ListView(
                    children: [
                      if (getOrderCount('Cancelled') == 0)
                        Text(
                          "No cancelled orders",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 14,
                            letterSpacing: -0.3,
                            height: 1,
                          ),
                        )
                      else
                        Expanded(
                          child: Column(
                            children: [
                              ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  key: UniqueKey(),
                                  shrinkWrap: true,
                                  itemCount: orders.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    String key = orders.keys.elementAt(index);
                                    if (orders[key]['status'] == 'Cancelled' &&
                                        ((_searchBox.text == '')
                                            ? true
                                            : orders[key]['customerName']
                                                .toLowerCase()
                                                .contains(_searchBox.text
                                                    .toLowerCase()))) {
                                      return OrderCard(key, orders[key],
                                          adminControls: true,
                                          setOrderStatusCallback:
                                              setOrderStatus);
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  }),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
