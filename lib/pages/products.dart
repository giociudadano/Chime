/*
  [Title]
  ProductsPage

  [Description]
  Displays information about products in the database and currently favorited products.
  Contains options to search for a product.
  Creates a list of ProductCards for each product in the database.
  Visited as a tab in the HomePage.
*/

part of main;

// The 'Products' page displays a list of recommended products for the user to buy.
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  // Variables for controllers.
  final _searchBox = TextEditingController();
  final _scrollController = ScrollController();
  StreamSubscription? favoritesListener;
  StreamSubscription? cartListener;

  // Variables for pagination.
  List<ProductModel> products = [];
  List<ProductModel> productsSearched = [];
  int productsPerPage = 10;
  int productsDisplayed = 0;
  String? lastVisible;

  // Variables for search function.
  FocusNode focus = FocusNode();
  Timer? _debounce;

  // Variables for user information.
  List<ProductModel> productsFavorited = [];
  int cartItems = 0;
  final ValueNotifier<bool> valueNotifierCartItems = ValueNotifier(false);
  final ValueNotifier<bool> valueNotifierFavorites = ValueNotifier(false);

  // Initializes a listener that checks if the user scrolls to the bottom of the GridView. If true,
  // adds a list of products to the bottom of the list.
  void initScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        initProducts();
      }
    });
  }

  // Queries a list of products sorted by distance from the device. Called on page initialization
  // and on reaching the bottom of the ListView.
  void initProducts() async {
    Query getQuery() {
      FirebaseFirestore db = FirebaseFirestore.instance;
      if (lastVisible == null) {
        return db
            .collection("products")
            .orderBy(FieldPath.documentId)
            .limit(productsPerPage);
      } else {
        return db
            .collection("products")
            .orderBy(FieldPath.documentId)
            .startAfter([lastVisible]).limit(productsPerPage);
      }
    }

    getQuery().get().then((querySnapshot) async {
      await Future.forEach(querySnapshot.docs, (docSnapshot) async {
        ProductModel product = ProductModel(docSnapshot.id, docSnapshot.data());
        if (mounted) {
          setState(() {
            products.add(product);
            productsDisplayed += productsPerPage;
            lastVisible = docSnapshot.id;
          });
        }
      });
    });
  }

  // Initializes a listener that tracks if the current product favorites have changed from other screens.
  void initFavoritesListener() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    favoritesListener =
        db.collection("users").doc(uid).snapshots().listen((event) async {
      productsFavorited = [];
      var favorites = event.data()!['favoriteProducts'];
      for (String favorite in favorites) {
        await db
            .collection("products")
            .doc(favorite)
            .get()
            .then((document2) async {
          if (document2.exists) {
            ProductModel product = ProductModel(document2.id, document2.data());
            productsFavorited.add(product);
          }
        });
      }
      valueNotifierFavorites.value = !valueNotifierFavorites.value;
    });
  }

  // Adds a text field listener that detects if the user searches for an item. Adds all matching
  // items to a list and displays that list in the GridView.
  void initSearchListener() {
    _searchBox.addListener(() {
      if (focus.hasFocus) {
        if (_debounce != null) {
          _debounce!.cancel();
        }
        _debounce = Timer(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              productsSearched = [];
              for (ProductModel product in products) {
                if (product.productName
                    .toLowerCase()
                    .contains(_searchBox.value.text.toString().toLowerCase())) {
                  productsSearched.add(product);
                }
              }
            });
          }
        });
      }
    });
  }

  // Adds a listener that detects if an item is added to cart.
  // Used in displaying the number of current items in cart.
  void initCartListener() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;

    cartListener = db
        .collection("users")
        .doc(uid)
        .collection("cart")
        .snapshots()
        .listen((event) async {
      db.collection("users").doc(uid).collection("cart").get().then((snapshot) {
        int cartItems = 0;
        for (var place in snapshot.docs) {
          cartItems += place.data().length;
        }
        this.cartItems = cartItems;
        valueNotifierCartItems.value = !valueNotifierCartItems.value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initScrollListener();
    initFavoritesListener();
    initProducts();
    initSearchListener();
    initCartListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    favoritesListener!.cancel();
    cartListener!.cancel();
    _searchBox.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: MaterialColors.getSurfaceContainerLow(darkMode),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.appName,
                          style: const TextStyle(
                              fontFamily: 'Bahnschrift',
                              fontVariations: [
                                FontVariation('wght', 700),
                                FontVariation('wdth', 100),
                              ],
                              fontSize: 22,
                              letterSpacing: -0.3),
                        ),
                        Stack(children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_cart_outlined),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const CartPage()));
                            },
                          ),
                          ValueListenableBuilder<bool>(
                              valueListenable: valueNotifierCartItems,
                              builder: (context, val, child) {
                                if (cartItems != 0) {
                                  return Positioned(
                                    right: 0,
                                    top: 0,
                                    child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        child: Text(
                                          cartItems.toString(),
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              fontFamily: 'Bahnschrift',
                                              fontVariations: const [
                                                FontVariation('wght', 700),
                                                FontVariation('wdth', 100),
                                              ],
                                              fontSize: 14,
                                              letterSpacing: -0.3),
                                        )),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                        ]),
                      ]),
                  const SizedBox(height: 10),
                  TextField(
                    focusNode: focus,
                    controller: _searchBox,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: EdgeInsets.zero,
                      hintText: AppLocalizations.of(context)!.searchBoxHint,
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.outline),
                      filled: true,
                      fillColor:
                          MaterialColors.getSurfaceContainerLowest(darkMode),
                      isDense: true,
                      prefixIcon: const Icon(Icons.search_outlined),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.mic_outlined),
                        onPressed: () {
                          //TODO: Add method that converts speech to text.
                        },
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Bahnschrift',
                      fontVariations: [
                        FontVariation('wght', 300),
                        FontVariation('wdth', 100),
                      ],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: _scrollController,
                children: [
                  ValueListenableBuilder<bool>(
                      valueListenable: valueNotifierFavorites,
                      builder: (context, val, child) {
                        if (productsFavorited.isNotEmpty &&
                            _searchBox.text == '') {
                          return Column(children: [
                            Text(
                              AppLocalizations.of(context)!.productsFavorited,
                              style: const TextStyle(
                                  fontFamily: 'Bahnschrift',
                                  fontVariations: [
                                    FontVariation('wght', 700),
                                    FontVariation('wdth', 100),
                                  ],
                                  fontSize: 18,
                                  letterSpacing: -0.3),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 220,
                              child: GridView.builder(
                                key: UniqueKey(),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: productsFavorited.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return ProductCard(
                                      productID:
                                          productsFavorited[index].productID,
                                      productName:
                                          productsFavorited[index].productName,
                                      productPrice:
                                          productsFavorited[index].productPrice,
                                      placeID:
                                          productsFavorited[index].placeID);
                                },
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                        mainAxisExtent: 165,
                                        maxCrossAxisExtent: 220,
                                        crossAxisSpacing: 0,
                                        mainAxisSpacing: 10),
                              ),
                            )
                          ]);
                        } else {
                          return SizedBox.shrink();
                        }
                      }),
                  Text(
                    _searchBox.text.isEmpty
                        ? AppLocalizations.of(context)!.productsNear
                        : AppLocalizations.of(context)!
                            .productsSearch(_searchBox.text.toLowerCase()),
                    style: const TextStyle(
                        fontFamily: 'Bahnschrift',
                        fontVariations: [
                          FontVariation('wght', 700),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 18,
                        letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                      key: UniqueKey(),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              mainAxisExtent: 220,
                              maxCrossAxisExtent: 200,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 0),
                      itemCount: (_searchBox.text.isEmpty)
                          ? products.length
                          : productsSearched.length,
                      itemBuilder: (context, index) {
                        if (_searchBox.text.isEmpty) {
                          return ProductCard(
                              productID: products[index].productID,
                              productName: products[index].productName,
                              productPrice: products[index].productPrice,
                              placeID: products[index].placeID);
                        } else {
                          return ProductCard(
                              productID: productsSearched[index].productID,
                              productName: productsSearched[index].productName,
                              productPrice:
                                  productsSearched[index].productPrice,
                              placeID: productsSearched[index].placeID);
                        }
                      }),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
