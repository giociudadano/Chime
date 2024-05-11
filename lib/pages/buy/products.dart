part of '../../main.dart';

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

  // Variables for pagination.
  Map products = {};
  Map productsFavorited = {};
  Map productsSearched = {};
  int productsPerPage = 10;
  int productsDisplayed = 0;
  String? lastVisible;

  // Variables for search function.
  FocusNode focus = FocusNode();
  Timer? _debounce;

  // Initializes a listener that checks if the user scrolls to the bottom of the GridView. If true,
  // adds a list of products to the bottom of the list.
  void addScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        initProducts();
      }
    });
  }

  void initProducts() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;

    List favoriteProducts = [];
    await db.collection("users").doc(uid).get().then((document) {
      if (document.exists) {
        favoriteProducts = document.data()!['favoriteProducts'] ?? [];
      }
    });

    Query getQuery() {
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

    getQuery().get().then((querySnapshot) {
      for (var product in querySnapshot.docs) {
        if (mounted) {
          products[product.id] = product.data();
          setProductImageURL(product.id).then((res) {
            setFavoriteState(favoriteProducts, product.id);
          });
          productsDisplayed += productsPerPage;
          lastVisible = product.id;
        }
      }
      if (mounted) {
        setState(() {
          products = Map.fromEntries(products.entries.toList()
            ..sort((a, b) => (a.value['productName'].toLowerCase())
                .compareTo(b.value['productName'].toLowerCase())));
        });
      }
    });
  }

  void setFavoriteState(List favoriteProducts, String productID) {
    if (favoriteProducts.contains(productID)) {
      productsFavorited[productID] = products.remove(productID);
      productsFavorited[productID]['isFavorited'] = true;
      productsFavorited = Map.fromEntries(productsFavorited.entries.toList()
        ..sort((a, b) => (a.value['productName'].toLowerCase())
            .compareTo(b.value['productName'].toLowerCase())));
    }
  }

  Future setProductImageURL(String productID) async {
    String url = '';
    String ref = "products/$productID.jpg";
    try {
      url = await FirebaseStorage.instance.ref(ref).getDownloadURL();
    } catch (e) {
      //
    } finally {
      if (mounted) {
        setState(() {
          products[productID]['productImageURL'] = url;
        });
      }
    }
  }

  void addSearchListener() {
    _searchBox.addListener(() {
      if (focus.hasFocus) {
        if (_debounce != null) {
          _debounce!.cancel();
        }
        _debounce = Timer(const Duration(milliseconds: 800), () {
          productsSearched.clear();
          products.forEach((productID, product) {
            if (product['productName']
                .toLowerCase()
                .contains(_searchBox.value.text.toString().toLowerCase())) {
              productsSearched[productID] = product;
              productsSearched = Map.fromEntries(
                  productsSearched.entries.toList()
                    ..sort((a, b) => (a.value['productName'].toLowerCase())
                        .compareTo(b.value['productName'].toLowerCase())));
            }
          });
          productsFavorited.forEach((productID, product) {
            if (product['productName']
                .toLowerCase()
                .contains(_searchBox.value.text.toString().toLowerCase())) {
              productsSearched[productID] = product;
              productsSearched = Map.fromEntries(
                  productsSearched.entries.toList()
                    ..sort((a, b) => (a.value['productName'].toLowerCase())
                        .compareTo(b.value['productName'].toLowerCase())));
            }
          });
          if (mounted) {
            setState(() {});
          }
        });
      }
    });
  }

  getPlace(String placeID) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("places").doc(placeID).get().then((document) {
      if (document.exists) {
        return document.data();
      }
    });
    return {};
  }

  void setFavoriteProduct(String productID, bool state) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    if (state) {
      productsFavorited[productID] = products.remove(productID);
      productsFavorited[productID]['isFavorited'] = true;
      productsFavorited[productID]['usersFavorited'].add(uid);
      productsFavorited = Map.fromEntries(productsFavorited.entries.toList()
        ..sort((a, b) => (a.value['productName'].toLowerCase())
            .compareTo(b.value['productName'].toLowerCase())));
    } else {
      products[productID] = productsFavorited.remove(productID);
      products[productID]['isFavorited'] = false;
      products[productID]['usersFavorited'].remove(uid);
      products = Map.fromEntries(products.entries.toList()
        ..sort((a, b) => (a.value['productName'].toLowerCase())
            .compareTo(b.value['productName'].toLowerCase())));
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    addScrollListener();
    initProducts();
    addSearchListener();
  }

  @override
  void dispose() {
    _searchBox.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              focusNode: focus,
              controller: _searchBox,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    // style: BorderStyle.none,
                  ),
                ),
                hintText: "Search for food",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                prefixIcon: Icon(Icons.search_outlined,
                    color: Theme.of(context).colorScheme.secondary, size: 20),
              ),
              style: const TextStyle(
                fontFamily: 'Source Sans 3',
                fontVariations: [
                  FontVariation('wght', 400),
                ],
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: ListView(
                controller: _scrollController,
                children: [
                  const SizedBox(height: 10),
                  if (productsFavorited.isNotEmpty && _searchBox.text == '')
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              "Your favorites",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 16,
                                  letterSpacing: 0),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            key: UniqueKey(),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: productsFavorited.length,
                            itemBuilder: (BuildContext context, int index) {
                              String key =
                                  productsFavorited.keys.elementAt(index);
                              return ProductCard(
                                  key,
                                  productsFavorited[key],
                                  productsFavorited[key]['placeID'],
                                  getPlace(productsFavorited[key]['placeID']),
                                  setFavoriteProductCallback:
                                      setFavoriteProduct);
                            },
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                    mainAxisExtent: 205,
                                    maxCrossAxisExtent: 200,
                                    childAspectRatio: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 0),
                          ),
                          const SizedBox(height: 20),
                        ]),
                  if (_searchBox.text.isEmpty ||
                      (_searchBox.text.isNotEmpty &&
                          productsSearched.isNotEmpty))
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              _searchBox.text.isEmpty
                                  ? "Popular products"
                                  : 'Popular products named "${_searchBox.text.toLowerCase()}"',
                              maxLines: 2,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 16,
                                  letterSpacing: 0,
                                  height: 1.2,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ]),
                  if (productsSearched.isEmpty && _searchBox.text.isNotEmpty)
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
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
                                    text: 'Search for product(s) not found. ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text:
                                        'Please check for spelling errors or try a different name.'),
                              ]),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Source Sans 3',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                  ],
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 15,
                                  height: 1.1,
                                  letterSpacing: -0.3),
                            ),
                          )
                        ]),
                  const SizedBox(height: 10),
                  GridView.builder(
                      key: UniqueKey(),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              mainAxisExtent: 205,
                              maxCrossAxisExtent: 200,
                              childAspectRatio: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 0),
                      itemCount: (_searchBox.text.isEmpty)
                          ? products.length
                          : productsSearched.length,
                      itemBuilder: (context, index) {
                        String key = _searchBox.text.isEmpty
                            ? products.keys.elementAt(index)
                            : productsSearched.keys.elementAt(index);
                        return ProductCard(
                            key,
                            _searchBox.text.isEmpty
                                ? products[key]
                                : productsSearched[key],
                            _searchBox.text.isEmpty
                                ? products[key]['placeID']
                                : productsSearched[key]['placeID'],
                            getPlace(_searchBox.text.isEmpty
                                ? products[key]['placeID']
                                : productsSearched[key]['placeID']),
                            setFavoriteProductCallback: setFavoriteProduct);
                      }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
