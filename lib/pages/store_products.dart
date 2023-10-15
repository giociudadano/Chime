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
  Map productsFeatured = {};
  Map products = {};

  void addProducts() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    for (String productID in widget.productIDs) {
      db.collection("products").doc(productID).get().then((document) {
        if (mounted) {
          List categories = document.data()!['categories'] ?? [];
          if (categories.contains('Featured')) {
            setState(() {
              productsFeatured[productID] = document.data()!;
            });
          } else {
            setState(() {
              products[productID] = document.data()!;
            });
          }
        }
      });
    }
  }

  void setFeaturedProduct(String productID, bool state) {
    if (state) {
      productsFeatured[productID] = products.remove(productID);
      productsFeatured[productID]['categories'].add('Featured');
    } else {
      products[productID] = productsFeatured.remove(productID);
      products[productID]['categories'].remove('Featured');
    }
    if (mounted) {
      setState(() {});
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
    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.add,
          color: MaterialColors.getSurfaceContainerLowest(darkMode),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => StoreProductsAddPage(widget.placeID)),
          );
        },
      ),
      body: (products.isEmpty && productsFeatured.isEmpty)
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  if (productsFeatured.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Featured Products",
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
                        GridView.builder(
                            key: UniqueKey(),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                    mainAxisExtent: 205,
                                    maxCrossAxisExtent: 200,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 0),
                            itemCount: productsFeatured.length,
                            itemBuilder: (context, index) {
                              String key =
                                  productsFeatured.keys.elementAt(index);
                              return ProductCardEditable(
                                  key, productsFeatured[key],
                                  setFeaturedProductCallback:
                                      setFeaturedProduct);
                            })
                      ],
                    ),
                  if (products.isNotEmpty)
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "All Products",
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
                          GridView.builder(
                            key: UniqueKey(),
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                    mainAxisExtent: 205,
                                    maxCrossAxisExtent: 200,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 0),
                            itemCount: products.length,
                            itemBuilder: (BuildContext context, int index) {
                              String key = products.keys.elementAt(index);
                              return ProductCardEditable(key, products[key],
                                  setFeaturedProductCallback:
                                      setFeaturedProduct);
                            },
                          ),
                        ])
                ],
              ),
            ),
    );
  }
}
