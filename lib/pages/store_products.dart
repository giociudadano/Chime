part of main;

// ignore: must_be_immutable
class StoreProductsPage extends StatefulWidget {
  StoreProductsPage(this.placeID, this.productIDs, {super.key});

  String placeID = '';
  List productIDs = [];
  @override
  State<StoreProductsPage> createState() => _StoreProductsPageState();
}

class _StoreProductsPageState extends State<StoreProductsPage> {
  Map products = {};

  void addProducts() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    for (String productID in widget.productIDs) {
      db.collection("products").doc(productID).get().then((document) {
        if (mounted) {
          setState(() {
            products[productID] = document.data()!;
            print(products);
          });
        }
      });
    }
  }

  @override
  void initState() {
    addProducts();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    if (products.isEmpty) {
      return SizedBox.shrink();
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          key: UniqueKey(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisExtent: 220,
              maxCrossAxisExtent: 200,
              crossAxisSpacing: 10,
              mainAxisSpacing: 0),
          itemCount: products.length,
          itemBuilder: (BuildContext context, int index) {
            String key = products.keys.elementAt(index);
            return ProductCard(
                productID: key,
                productName: products[key]["productName"],
                productPrice: products[key]["productPrice"],
                placeID: products[key]["placeID"]);
          },
        ),
      ),
    );
  }
}
