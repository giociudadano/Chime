part of main;

// ignore: must_be_immutable
class StoreProductsPage extends StatefulWidget {
  StoreProductsPage(this.placeID, this.categories, this.productIDs,
      {super.key,
      this.setFeaturedProductCallback,
      this.addProductCallback,
      this.editProductCallback,
      this.deleteProductCallback});

  String placeID;
  List productIDs;
  List categories;

  final Function(String placeID, String productID, bool state)?
      setFeaturedProductCallback;
  final Function(String placeID, String productID, List categories)?
      addProductCallback;
  final Function(String placeID, String productID, List addedCategories,
      List removedCategories)? editProductCallback;
  final Function(String placeID, String productID, List categories)?
      deleteProductCallback;

  @override
  State<StoreProductsPage> createState() => _StoreProductsPageState();
}

class _StoreProductsPageState extends State<StoreProductsPage> {
  Map productsFeatured = {};
  Map products = {};

  void initProducts() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    for (String productID in widget.productIDs) {
      db.collection("products").doc(productID).get().then((document) async {
        List categories = document.data()!['categories'] ?? [];
        if (categories.contains('Featured')) {
          productsFeatured[productID] = document.data()!;
        } else {
          products[productID] = document.data()!;
        }
        setProductImageURL(productID, categories.contains('Featured'));
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void setProductImageURL(String productID, bool isFeatured) async {
    String ref = "products/$productID.jpg";
    try {
      String url = await FirebaseStorage.instance.ref(ref).getDownloadURL();
      setState(() {
        if (isFeatured) {
          productsFeatured[productID]['productImageURL'] = url;
        } else {
          products[productID]['productImageURL'] = url;
        }
      });
    } catch (e) {
      return;
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
    widget.setFeaturedProductCallback!(widget.placeID, productID, state);
    if (mounted) {
      setState(() {});
    }
  }

  void addProduct(String productID, String? productImageURL, Map data) {
    widget.addProductCallback!(widget.placeID, productID, data['categories']);
    if (mounted) {
      setState(() {
        if (data['categories'].contains('Featured')) {
          productsFeatured[productID] = data;
          if (productImageURL != null) {
            productsFeatured[productID]['productImageURL'] = productImageURL;
          }
        } else {
          products[productID] = data;
          if (productImageURL != null) {
            products[productID]['productImageURL'] = productImageURL;
          }
        }
      });
    }
  }

  void editProduct(String productID, List categories, List addedCategories,
      List removedCategories) {
    if (addedCategories.remove('Featured')) {
      setFeaturedProduct(productID, true);
      categories.remove('Featured');
    } else if (removedCategories.remove('Featured')) {
      setFeaturedProduct(productID, false);
      categories.remove('Featured');
    }
    widget.editProductCallback!(
        widget.placeID, productID, addedCategories, removedCategories);
  }

  void deleteProduct(String productID, List categories) {
    products.remove(productID);
    productsFeatured.remove(productID);
    widget.deleteProductCallback!(widget.placeID, productID, categories);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    initProducts();
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
                builder: (context) => StoreProductsAddPage(
                    widget.placeID, widget.categories,
                    addProductCallback: addProduct)),
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
                                  key, widget.categories, productsFeatured[key],
                                  setFeaturedProductCallback:
                                      setFeaturedProduct,
                                  editProductCallback: editProduct,
                                  deleteProductCallback: deleteProduct);
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
                            physics: const NeverScrollableScrollPhysics(),
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
                              return ProductCardEditable(
                                  key, widget.categories, products[key],
                                  setFeaturedProductCallback:
                                      setFeaturedProduct,
                                  editProductCallback: editProduct,
                                  deleteProductCallback: deleteProduct);
                            },
                          ),
                        ])
                ],
              ),
            ),
    );
  }
}
