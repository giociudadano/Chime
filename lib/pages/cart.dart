/*
  [Title]
  CartPage

  [Description]
  Displays information about the cart.
  Creates a list of OrderCards for each place in the cart the user is ordering from.
  Each OrderCard contains a list of OrderItemCards for each product the user is ordering from that place.
*/

part of main;

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  StreamSubscription? cartListener;
  final _scrollController = ScrollController();
  Map orders = {};

  // Fetches a list of products from the user's cart.
  void addProducts() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    db.collection("users").doc(uid).collection("cart").get().then((snapshot) {
      for (var place in snapshot.docs) {
        orders[place.id] = place.data();
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    addProducts();
    super.initState();
  }

  @override
  void dispose() {
    cartListener!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text(
          "My cart",
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
      body: ListView(
        controller: _scrollController,
        children: [
          if (orders.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  key: UniqueKey(),
                  shrinkWrap: true,
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    String key = orders.keys.elementAt(index);
                    return OrderCard(placeID: key, orderItems: orders[key]);
                  }),
            ),
        ],
      ),
    );
  }
}