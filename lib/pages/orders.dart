part of main;

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  Map orders = {};

  void addOrders() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    db.collection("users").doc(uid).get().then((document) {
      if (document.exists) {
        List orderIDs = document.data()!['orders'];
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
    });
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
            key: UniqueKey(),
            shrinkWrap: true,
            itemCount: orders.length,
            itemBuilder: (BuildContext context, int index) {
              String key = orders.keys.elementAt(index);
              return OrderCard(orders[key]);
            }),
      ),
    );
  }
}
