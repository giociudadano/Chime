part of '../main.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
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

  @override
  void initState() {
    super.initState();
    addOrders();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                key: UniqueKey(),
                shrinkWrap: true,
                itemCount: orders.length,
                itemBuilder: (BuildContext context, int index) {
                  String key = orders.keys.elementAt(index);
                  return OrderCard(key, orders[key], adminControls: false);
                })
          ],
        ),
      ),
    );
  }
}
