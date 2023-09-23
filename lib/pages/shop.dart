part of main;

// The 'Shop' page displays a list of recommended products for the user to buy.
class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final _searchBox = TextEditingController();
  final _scrollController = ScrollController();
  final products = [];
  Timer? _debounce;
  int productsPerPage = 5;
  int productsDisplayed = 0;
  String? lastVisible;

  // Initializes a listener that checks if the user scrolls to the bottom of the ListView. If true,
  // adds a list of products to the bottom of the list.
  void addScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        addProducts();
      }
    });
  }

  // Fetches the current coordinates of the user.
  Future<Position> getDevicePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Queries a list of products sorted by distance from the device. Called on page initialization
  // and on reaching the bottom of the ListView.
  void addProducts() async {
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

    Position position = await getDevicePosition();
    getQuery().get().then((querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        if (mounted) {
          setState(() {
            products.add(
                ProductModel(docSnapshot.id, docSnapshot.data(), position));
            productsDisplayed += productsPerPage;
            lastVisible = docSnapshot.id;
            products.sort((a, b) => a.distance.compareTo(b.distance));
          });
        }
      }
    });
  }

  void addSearchListener() {
    _searchBox.addListener(() {
      if (_debounce != null) {
        _debounce!.cancel();
      }
      _debounce = Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    addScrollListener();
    addProducts();
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
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: MaterialColors.getSurface(darkMode),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: MaterialColors.getSurfaceContainer(darkMode),
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
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
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
                        onPressed: () {},
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
                  Text(
                    AppLocalizations.of(context)!.sectionRecommended,
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
                  ListView.builder(
                    key: UniqueKey(),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      if (products[index].productName.toLowerCase().contains(
                              _searchBox.value.text.toString().toLowerCase()) &&
                          _searchBox.value.toString().toLowerCase() != '') {
                        return ProductCard(
                            id: products[index].id,
                            productName: products[index].productName,
                            placeName: products[index].placeName,
                            productPrice: products[index].productPrice);
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
