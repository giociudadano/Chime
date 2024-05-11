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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            TextField(
              focusNode: focus,
              controller: _searchBox,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    // style: BorderStyle.none,
                  ),
                ),
                hintText: "Search for an order",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                prefixIcon: Icon(Icons.search_outlined,
                    color: Theme.of(context).colorScheme.secondary, size: 20),
              ),
              style: const TextStyle(
                fontFamily: 'Source Sans 3',
                fontVariations: [
                  FontVariation('wght', 400),
                ],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                height: 30,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        shadowColor:
                            const MaterialStatePropertyAll(Colors.transparent),
                        backgroundColor: MaterialStatePropertyAll(
                            tabController.index == 0
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Unread",
                            style: TextStyle(
                                color: tabController.index == 0
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 14,
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
                        shadowColor:
                            const MaterialStatePropertyAll(Colors.transparent),
                        backgroundColor: MaterialStatePropertyAll(
                            tabController.index == 1
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Preparing",
                            style: TextStyle(
                                color: tabController.index == 1
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 14,
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
                        shadowColor:
                            const MaterialStatePropertyAll(Colors.transparent),
                        backgroundColor: MaterialStatePropertyAll(
                            tabController.index == 2
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Delivered",
                            style: TextStyle(
                                color: tabController.index == 2
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 14,
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
                        shadowColor:
                            const MaterialStatePropertyAll(Colors.transparent),
                        backgroundColor: MaterialStatePropertyAll(
                            tabController.index == 3
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Completed",
                            style: TextStyle(
                                color: tabController.index == 3
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 14,
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
                        shadowColor:
                            const MaterialStatePropertyAll(Colors.transparent),
                        backgroundColor: MaterialStatePropertyAll(
                            tabController.index == 4
                                ? Theme.of(context).colorScheme.onErrorContainer
                                : Theme.of(context).colorScheme.surface),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Cancelled",
                            style: TextStyle(
                                color: tabController.index == 4
                                    ? Theme.of(context)
                                        .colorScheme
                                        .errorContainer
                                    : Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 14,
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
                        Column(
                          children: [
                            const SizedBox(
                              height: 240,
                              width: 240,
                              child: Image(
                                  image: AssetImage(
                                      'lib/assets/images/Empty.png')),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "You have no new orders. Come back later.",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontFamily: 'Source Sans 3',
                                fontVariations: const [
                                  FontVariation('wght', 400),
                                ],
                                fontSize: 14,
                                letterSpacing: -0.1,
                                height: 1,
                              ),
                            ),
                          ],
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
                        Column(
                          children: [
                            const SizedBox(
                              height: 240,
                              width: 240,
                              child: Image(
                                  image: AssetImage(
                                      'lib/assets/images/Empty.png')),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "There are no orders that are being prepared or delivered.",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontFamily: 'Source Sans 3',
                                fontVariations: const [
                                  FontVariation('wght', 400),
                                ],
                                fontSize: 14,
                                letterSpacing: -0.1,
                                height: 1,
                              ),
                            ),
                          ],
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
                        Column(
                          children: [
                            const SizedBox(
                              height: 240,
                              width: 240,
                              child: Image(
                                  image: AssetImage(
                                      'lib/assets/images/Empty.png')),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "You have no delivered orders right now.",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontFamily: 'Source Sans 3',
                                fontVariations: const [
                                  FontVariation('wght', 400),
                                ],
                                fontSize: 14,
                                letterSpacing: -0.1,
                                height: 1,
                              ),
                            ),
                          ],
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
                        Column(
                          children: [
                            const SizedBox(
                              height: 240,
                              width: 240,
                              child: Image(
                                  image: AssetImage(
                                      'lib/assets/images/Empty.png')),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "You have not completed any orders yet.",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontFamily: 'Source Sans 3',
                                fontVariations: const [
                                  FontVariation('wght', 400),
                                ],
                                fontSize: 14,
                                letterSpacing: -0.1,
                                height: 1,
                              ),
                            ),
                          ],
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
                            letterSpacing: -0.1,
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
