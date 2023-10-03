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

  // Variables for pagination.
  List<PlaceModel> places = [];
  List<PlaceModel> placesSearched = [];
  int placesPerPage = 5;
  int placesDisplayed = 0;
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
        addPlaces();
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

    Position position = await getDevicePosition();
    getQuery().get().then((querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        if (mounted) {
          setState(() {
            places
                .add(PlaceModel(docSnapshot.id, docSnapshot.data(), position));
            placesDisplayed += placesPerPage;
            lastVisible = docSnapshot.id;
            places.sort((a, b) => a.distance.compareTo(b.distance));
          });
        }
      }
    });
  }

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

  @override
  void initState() {
    super.initState();
    addScrollListener();
    addPlaces();
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
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        onPressed: () {},
                      ),
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
                              crossAxisSpacing: 0,
                              mainAxisSpacing: 0),
                      itemCount: (_searchBox.text.isEmpty)
                          ? places.length
                          : placesSearched.length,
                      itemBuilder: (context, index) {
                        if (_searchBox.text.isEmpty) {
                          return PlaceCard(
                            id: places[index].id,
                            placeName: places[index].placeName,
                            placeTagline: places[index].placeTagline,
                          );
                        } else {
                          return PlaceCard(
                            id: placesSearched[index].id,
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
