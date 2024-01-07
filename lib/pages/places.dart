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

  // Variables for pagination.
  Map places = {};
  Map placesFavorited = {};
  Map placesSearched = {};
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
        initPlaces();
      }
    });
  }

  // Queries a list of places sorted by distance from the device. Called on page initialization
  // and on reaching the bottom of the ListView.
  void initPlaces() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;

    List favoritePlaces = [];
    await db.collection("users").doc(uid).get().then((document) {
      if (document.exists) {
        favoritePlaces = document.data()!['favoritePlaces'] ?? [];
      }
    });

    Query getQuery() {
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

    getQuery().get().then((querySnapshot) {
      for (var place in querySnapshot.docs) {
        if (mounted) {
          places[place.id] = place.data();
          setPlaceImageURL(place.id).then((res) {
            setFavoriteState(favoritePlaces, place.id);
          });
          placesDisplayed += placesPerPage;
          lastVisible = place.id;
        }
      }
      setState(() {
        places = Map.fromEntries(places.entries.toList()
          ..sort((a, b) => (a.value['placeName'].toLowerCase())
              .compareTo(b.value['placeName'].toLowerCase())));
      });
    });
  }

  void setFavoriteState(List favoritePlaces, String placeID) {
    if (favoritePlaces.contains(placeID)) {
      placesFavorited[placeID] = places.remove(placeID);
      placesFavorited[placeID]['isFavorited'] = true;
      placesFavorited = Map.fromEntries(placesFavorited.entries.toList()
        ..sort((a, b) => (a.value['placeName'].toLowerCase())
            .compareTo(b.value['placeName'].toLowerCase())));
    }
  }

  Future setPlaceImageURL(String placeID) async {
    String url = '';
    String ref = "places/$placeID.jpg";
    try {
      url = await FirebaseStorage.instance.ref(ref).getDownloadURL();
    } catch (e) {
      //
    } finally {
      if (mounted) {
        setState(() {
          places[placeID]['placeImageURL'] = url;
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
          placesSearched.clear();
          places.forEach((placeID, place) {
            if (place['placeName']
                .toLowerCase()
                .contains(_searchBox.value.text.toString().toLowerCase())) {
              placesSearched[placeID] = place;
              placesSearched = Map.fromEntries(placesSearched.entries.toList()
                ..sort((a, b) => (a.value['placeName'].toLowerCase())
                    .compareTo(b.value['placeName'].toLowerCase())));
            }
          });
          placesFavorited.forEach((placeID, place) {
            if (place['placeName']
                .toLowerCase()
                .contains(_searchBox.value.text.toString().toLowerCase())) {
              placesSearched[placeID] = place;
              placesSearched = Map.fromEntries(placesSearched.entries.toList()
                ..sort((a, b) => (a.value['placeName'].toLowerCase())
                    .compareTo(b.value['placeName'].toLowerCase())));
            }
          });
          if (mounted) {
            setState(() {});
          }
        });
      }
    });
  }

  void setFavoritePlace(String placeID, bool state) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    if (state) {
      placesFavorited[placeID] = places.remove(placeID);
      placesFavorited[placeID]['isFavorited'] = true;
      placesFavorited[placeID]['usersFavorited'].add(uid);
      placesFavorited = Map.fromEntries(placesFavorited.entries.toList()
        ..sort((a, b) => (a.value['placeName'].toLowerCase())
            .compareTo(b.value['placeName'].toLowerCase())));
    } else {
      places[placeID] = placesFavorited.remove(placeID);
      places[placeID]['isFavorited'] = false;
      places[placeID]['usersFavorited'].remove(uid);
      places = Map.fromEntries(places.entries.toList()
        ..sort((a, b) => (a.value['placeName'].toLowerCase())
            .compareTo(b.value['placeName'].toLowerCase())));
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    addScrollListener();
    initPlaces();
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              focusNode: focus,
              controller: _searchBox,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: EdgeInsets.zero,
                hintText: AppLocalizations.of(context)!.placesSearchBoxHint,
                hintStyle:
                    TextStyle(color: Theme.of(context).colorScheme.outline),
                filled: true,
                fillColor: MaterialColors.getSurfaceContainerLowest(darkMode),
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
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: ListView(
                controller: _scrollController,
                children: [
                  if (placesFavorited.isNotEmpty && _searchBox.text == '')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.placesFavorited,
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
                            Text(
                              "Sorted A-Z   🡻",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontFamily: 'Bahnschrift',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                    FontVariation('wdth', 100),
                                  ],
                                  fontSize: 12.5,
                                  letterSpacing: -0.5),
                            ),
                          ]),
                    ),
                  if (placesFavorited.isNotEmpty && _searchBox.text == '')
                    const SizedBox(height: 10),
                  if (placesFavorited.isNotEmpty && _searchBox.text == '')
                    GridView.builder(
                      key: UniqueKey(),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: placesFavorited.length,
                      itemBuilder: (BuildContext context, int index) {
                        String key = placesFavorited.keys.elementAt(index);
                        return PlaceCard(key, placesFavorited[key],
                            setFavoritePlaceCallback: setFavoritePlace);
                      },
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              mainAxisExtent: 100,
                              maxCrossAxisExtent: 450,
                              childAspectRatio: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 0),
                    ),
                  if (_searchBox.text.isEmpty ||
                      (_searchBox.text.isNotEmpty && placesSearched.isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _searchBox.text.isEmpty
                                    ? AppLocalizations.of(context)!.placesNear
                                    : AppLocalizations.of(context)!
                                        .placesSearch(
                                            _searchBox.text.toLowerCase()),
                                maxLines: 2,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    fontFamily: 'Bahnschrift',
                                    fontVariations: const [
                                      FontVariation('wght', 700),
                                      FontVariation('wdth', 100),
                                    ],
                                    fontSize: 16,
                                    letterSpacing: -0.5,
                                    height: 1.2,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                "Sorted A-Z   🡻",
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    fontFamily: 'Bahnschrift',
                                    fontVariations: const [
                                      FontVariation('wght', 400),
                                      FontVariation('wdth', 100),
                                    ],
                                    fontSize: 12.5,
                                    letterSpacing: -0.5),
                              ),
                            )
                          ]),
                    ),
                  if (placesSearched.isEmpty && _searchBox.text.isNotEmpty)
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
                                    text: 'Search for place(s) not found. ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text:
                                        'Please check for spelling errors or try a different name.'),
                              ]),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Bahnschrift',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                    FontVariation('wdth', 100),
                                  ],
                                  color: Theme.of(context).colorScheme.outline,
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
                              mainAxisExtent: 100,
                              maxCrossAxisExtent: 450,
                              childAspectRatio: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 0),
                      itemCount: (_searchBox.text.isEmpty)
                          ? places.length
                          : placesSearched.length,
                      itemBuilder: (context, index) {
                        String key = _searchBox.text.isEmpty
                            ? places.keys.elementAt(index)
                            : placesSearched.keys.elementAt(index);
                        return PlaceCard(
                            key,
                            _searchBox.text.isEmpty
                                ? places[key]
                                : placesSearched[key],
                            setFavoritePlaceCallback: setFavoritePlace);
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
