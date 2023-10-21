part of main;

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
        orderIDs = document.data()!['orders'].reversed.toList();
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
    if (orders.isEmpty) {
      return Scaffold(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text.rich(
                  const TextSpan(children: [
                    TextSpan(
                        text: 'You have no orders yet. ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            'Browse store catalogs, fill in your cart, and checkout. Afterwards, you can monitor that status of your orders here.'),
                  ]),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Bahnschrift',
                      fontVariations: const [
                        FontVariation('wght', 400),
                        FontVariation('wdth', 100),
                      ],
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 15,
                      height: 1.1,
                      letterSpacing: -0.3),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          //TODO: Add a callback to the home function that changes the current tab index of the user.
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.primary),
                          foregroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.onPrimary),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Check out the places",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontFamily: 'Bahnschrift',
                              fontVariations: const [
                                FontVariation('wght', 600),
                                FontVariation('wdth', 100),
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
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            Text(
              "My Orders",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontFamily: 'Bahnschrift',
                  fontVariations: const [
                    FontVariation('wght', 700),
                    FontVariation('wdth', 100),
                  ],
                  fontSize: 16,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 10),
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
