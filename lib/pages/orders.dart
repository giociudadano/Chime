part of '../main.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TickerProviderStateMixin {
  late TabController tabController;
  Map orders = {};

  void addOrders() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    List orderIDs = [];
    await db.collection("users").doc(uid).get().then((document) {
      if (document.exists) {
        if (document.data()!['orders'] != null) {
          orderIDs = document.data()!['orders'].reversed.toList();
        } else {
          orderIDs = [];
        }
      }
    });
    for (String orderID in orderIDs) {
      db.collection("orders").doc(orderID).get().then((document) {
        if (mounted) {
          setState(() {
            orders[orderID] = document.data()!;
          });
        }
      });
    }
  }

  void setOrderStatus(String orderID, String newStatus) {
    if (mounted) {
      setState(() {
        orders[orderID]['status'] = newStatus;
      });
    }
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
    super.initState();
    addOrders();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;

    // If orders are empty, return a screen that prompts the user to order.
    if (orders.isEmpty) {
      return Scaffold(
        backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: Image.network(
                    "https://em-content.zobj.net/source/microsoft-teams/363/rabbit-face_1f430.png"),
              ),
              const SizedBox(height: 20),
              Text(
                "You have no orders yet.",
                style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontVariations: const [
                      FontVariation('wght', 700),
                    ],
                    color: ChimeColors.getGreen800(),
                    fontSize: 20,
                    height: 1.1,
                    letterSpacing: -0.3),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Browse store catalogs, fill in your cart, and checkout. Afterwards, you can monitor that status of your orders here.",
                  style: TextStyle(
                      fontFamily: 'Source Sans 3',
                      fontVariations: const [
                        FontVariation('wght', 400),
                      ],
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 14,
                      height: 1.1,
                      letterSpacing: -0.3),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      key: UniqueKey(),
                      shrinkWrap: true,
                      itemCount: orders.length,
                      itemBuilder: (BuildContext context, int index) {
                        String key = orders.keys.elementAt(index);
                        if (orders[key]['status'] == 'Unread') {
                          return OrderCard(key, orders[key],
                              adminControls: false,
                              setOrderStatusCallback: setOrderStatus);
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      key: UniqueKey(),
                      shrinkWrap: true,
                      itemCount: orders.length,
                      itemBuilder: (BuildContext context, int index) {
                        String key = orders.keys.elementAt(index);
                        if (orders[key]['status'] == 'Preparing' ||
                            orders[key]['status'] == 'To Receive') {
                          return OrderCard(key, orders[key],
                              adminControls: false,
                              setOrderStatusCallback: setOrderStatus);
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      key: UniqueKey(),
                      shrinkWrap: true,
                      itemCount: orders.length,
                      itemBuilder: (BuildContext context, int index) {
                        String key = orders.keys.elementAt(index);
                        if (orders[key]['status'] == 'Received') {
                          return OrderCard(key, orders[key],
                              adminControls: false,
                              setOrderStatusCallback: setOrderStatus);
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      key: UniqueKey(),
                      shrinkWrap: true,
                      itemCount: orders.length,
                      itemBuilder: (BuildContext context, int index) {
                        String key = orders.keys.elementAt(index);
                        if (orders[key]['status'] == 'Completed') {
                          return OrderCard(key, orders[key],
                              adminControls: false,
                              setOrderStatusCallback: setOrderStatus);
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      key: UniqueKey(),
                      shrinkWrap: true,
                      itemCount: orders.length,
                      itemBuilder: (BuildContext context, int index) {
                        String key = orders.keys.elementAt(index);
                        if (orders[key]['status'] == 'Cancelled') {
                          return OrderCard(key, orders[key],
                              adminControls: false,
                              setOrderStatusCallback: setOrderStatus);
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
