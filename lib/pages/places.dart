/*
  [Title]
  PlacesPage

  [Description]
  Displays information about places in the database and currently favorited places.
  Contains options to search for a place.
  Creates a list of PlaceCards for each place in the database.
  Visited as a tab in the HomePage.
*/

part of main;

// The 'Places' page displays a list of places for the user to buy from.
class PlacesPage extends StatefulWidget {
  const PlacesPage({super.key});

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  // Variables for controllers.
  final _searchBox = TextEditingController();
  final _scrollController = ScrollController();
  StreamSubscription? favoritesListener;
  StreamSubscription? cartListener;

  // Variables for pagination.
  List<PlaceModel> places = [];
  List<PlaceModel> placesSearched = [];
  int placesPerPage = 5;
  int placesDisplayed = 0;
  String? lastVisible;

  // Variables for search function.
  FocusNode focus = FocusNode();
  Timer? _debounce;

  // Variables for user information.
  List<PlaceModel> placesFavorited = [];
  int cartItems = 0;

  // Initializes a listener that checks if the user scrolls to the bottom of the GridView. If true,
  // adds a list of products to the bottom of the list.
  void addScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        addPlaces();
      }
    });
  }

  // Initializes a listener that tracks if the current pkace favorites have changed from other screens.
  void addFavoritesListener() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    favoritesListener =
        db.collection("users").doc(uid).snapshots().listen((event) async {
      placesFavorited = [];
      var favorites = event.data()!['favoritePlaces'];
      for (String favorite in favorites) {
        await db
            .collection("places")
            .doc(favorite)
            .get()
            .then((document2) async {
          if (document2.exists) {
            PlaceModel place = PlaceModel(document2.id, document2.data());
            placesFavorited.add(place);
          }
        });
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  // Queries a list of places sorted by distance from the device. Called on page initialization
  // and on reaching the bottom of the ListView.
  void addPlaces() async {
    Query getQuery() {
      FirebaseFirestore db = FirebaseFirestore.instance;
      if (lastVisible == null) {
        return db
            .collection("places")
            .orderBy(FieldPath.documentId)
            .limit(placesPerPage);
      } else {
        return db
            .collection("places")
            .orderBy(FieldPath.documentId)
            .startAfter([lastVisible]).limit(placesPerPage);
      }
    }

    getQuery().get().then((querySnapshot) async {
      for (var docSnapshot in querySnapshot.docs) {
        if (mounted) {
          PlaceModel place = PlaceModel(docSnapshot.id, docSnapshot.data());
          setState(() {
            places.add(place);
            placesDisplayed += placesPerPage;
            lastVisible = docSnapshot.id;
          });
        }
      }
    });
  }

  // Adds a listener that detects if an item is added to cart.
  // Used in displaying the number of current items in cart.
  void addSearchListener() {
    _searchBox.addListener(() {
      if (focus.hasFocus) {
        if (_debounce != null) {
          _debounce!.cancel();
        }
        _debounce = Timer(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              placesSearched = [];
              for (PlaceModel place in places) {
                if (place.placeName
                    .toLowerCase()
                    .contains(_searchBox.value.text.toString().toLowerCase())) {
                  placesSearched.add(place);
                }
              }
            });
          }
        });
      }
    });
  }

  void addCartListener() async {
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
        setState(() {
          this.cartItems = cartItems;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    addScrollListener();
    addFavoritesListener();
    addPlaces();
    addSearchListener();
    addCartListener();
  }

  @override
  void dispose() {
    _searchBox.dispose();
    favoritesListener!.cancel();
    cartListener!.cancel();
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
                        if (cartItems != 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: CircleAvatar(
                                radius: 10,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
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
                          )
                      ])
                    ],
                  ),
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
                          //TODO: Add speech-to-text search functionality
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
                  if (placesFavorited.isNotEmpty && _searchBox.text == '')
                    Text(
                      AppLocalizations.of(context)!.placesFavorited,
                      style: const TextStyle(
                          fontFamily: 'Bahnschrift',
                          fontVariations: [
                            FontVariation('wght', 700),
                            FontVariation('wdth', 100),
                          ],
                          fontSize: 18,
                          letterSpacing: -0.3),
                    ),
                  if (placesFavorited.isNotEmpty && _searchBox.text == '')
                    const SizedBox(height: 10),
                  if (placesFavorited.isNotEmpty && _searchBox.text == '')
                    GridView.builder(
                      key: UniqueKey(),
                      shrinkWrap: true,
                      itemCount: placesFavorited.length,
                      itemBuilder: (BuildContext context, int index) {
                        return PlaceCard(
                            placeID: placesFavorited[index].placeID,
                            placeName: placesFavorited[index].placeName,
                            placeTagline: placesFavorited[index].placeTagline);
                      },
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              mainAxisExtent: 100,
                              maxCrossAxisExtent: 450,
                              childAspectRatio: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 0),
                    ),
                  Text(
                    _searchBox.text.isEmpty
                        ? AppLocalizations.of(context)!.placesNear
                        : AppLocalizations.of(context)!
                            .placesSearch(_searchBox.text.toLowerCase()),
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
                              mainAxisExtent: 100,
                              maxCrossAxisExtent: 450,
                              childAspectRatio: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 0),
                      itemCount: (_searchBox.text.isEmpty)
                          ? places.length
                          : placesSearched.length,
                      itemBuilder: (context, index) {
                        if (_searchBox.text.isEmpty) {
                          return PlaceCard(
                            placeID: places[index].placeID,
                            placeName: places[index].placeName,
                            placeTagline: places[index].placeTagline,
                          );
                        } else {
                          return PlaceCard(
                            placeID: placesSearched[index].placeID,
                            placeName: placesSearched[index].placeName,
                            placeTagline: placesSearched[index].placeTagline,
                          );
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
