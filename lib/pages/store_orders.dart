part of '../main.dart';

// ignore: must_be_immutable
class StoreOrdersPage extends StatefulWidget {
  StoreOrdersPage(this.placeID, {super.key});

  String placeID = '';

  @override
  State<StoreOrdersPage> createState() => _StoreOrdersPageState();
}

class _StoreOrdersPageState extends State<StoreOrdersPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  StreamSubscription? ordersListener;
  Map orders = {};

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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                                    if (orders[key]['status'] == 'Unread') {
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                                    if (orders[key]['status'] == 'Preparing' ||
                                        orders[key]['status'] == 'To Receive') {
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                                    if (orders[key]['status'] == 'Received') {
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                                    if (orders[key]['status'] == 'Completed') {
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                                    if (orders[key]['status'] == 'Cancelled') {
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
