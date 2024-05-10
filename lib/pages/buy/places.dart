/*
  [Title]
  PlacesPage

  [Description]
  Displays information about places in the database and currently favorited places.
  Contains options to search for a place.
  Creates a list of PlaceCards for each place in the database.
  Visited as a tab in the HomePage.
*/

part of '../../main.dart';

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

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

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
      if (mounted) {
        setState(() {
          places = Map.fromEntries(places.entries.toList()
            ..sort((a, b) => (a.value['placeName'].toLowerCase())
                .compareTo(b.value['placeName'].toLowerCase())));
        });
      }
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
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    _searchBox.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ignore: non_constant_identifier_names
  Widget QRScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: const Icon(Icons.flashlight_on_outlined),
              onPressed: () {
                controller!.toggleFlash();
              }),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
                icon: const Icon(Icons.flip_camera_ios_outlined),
                onPressed: () {
                  controller!.flipCamera();
                }),
          )
        ],
        title: const Center(
          child: Text(
            "Scan a Place",
            style: TextStyle(
                fontFamily: 'Manrope',
                fontVariations: [
                  FontVariation('wght', 700),
                ],
                fontSize: 20,
                letterSpacing: -0.3),
          ),
        ),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: (controller) {
          bool scannedData = false;
          controller.scannedDataStream.listen((scanData) {
            setState(() {
              result = scanData;
            });
            if (!scannedData) {
              scannedData = true;
              Navigator.pop(context);
            }
          });
        },
        overlay: QrScannerOverlayShape(
            borderColor: Theme.of(context).colorScheme.primary,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: 300),
      ),
    );
  }

  void viewPlaceFromScan(String? data) {
    if (places[data] != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PlacesMorePage(data!, places[data],
              setFavoritePlaceCallback: setFavoritePlace)));
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            bool darkMode = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              elevation: 0,
              backgroundColor:
                  MaterialColors.getSurfaceContainerLowest(darkMode),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 240,
                    width: 240,
                    child: Image(image: AssetImage('lib/assets/images/Chime.png')),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "This place does not exist",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontVariations: const [
                          FontVariation('wght', 700),
                        ],
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 20,),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Sorry, we couldn't find the place you were looking for. Please try scanning the code again.",
                    maxLines: 3,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Source Sans 3',
                        fontVariations: const [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 16,
                        height: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            );
          });
    }
    result = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SizedBox(
        height: 56,
        child: FittedBox(
          child: FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScreen(context)),
                );
                if (result != null) {
                  viewPlaceFromScan(result!.code);
                }
              },
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.qr_code_scanner,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 28,
              )),
        ),
      ),
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
                hintText: "Search for a place",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                prefixIcon: Icon(Icons.search_outlined, color: Theme.of(context).colorScheme.secondary, size: 20),
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

                  // If there are favorited places, display the items at the top of the list.
                  if (placesFavorited.isNotEmpty && _searchBox.text == '')
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              "Followed Stores",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 16,
                                  letterSpacing: -0.5),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            key: UniqueKey(),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: placesFavorited.length,
                            itemBuilder: (BuildContext context, int index) {
                              String key =
                                  placesFavorited.keys.elementAt(index);
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

                        ]),

                  // If there are no places being searched, display the list of popular places.
                  // If there are places being searched and there are results returned, display the list of
                  // popular places with the matching search text.
                  if (_searchBox.text.isEmpty ||
                      (_searchBox.text.isNotEmpty && placesSearched.isNotEmpty))
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              _searchBox.text.isEmpty
                                  ? "What's Popular"
                                  : 'Popular places named "${_searchBox.text.toLowerCase()}"',
                              maxLines: 2,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 16,
                                  letterSpacing: -0.5,
                                  height: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ]),

                  // If there are places being searched which yields no results, display an error.
                  if (placesSearched.isEmpty && _searchBox.text.isNotEmpty)
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          const SizedBox(
                            height: 240,
                            width: 240,
                            child: Image(image: AssetImage('lib/assets/images/Empty.png')),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Text.rich(
                              const TextSpan(children: [
                                TextSpan(
                                    text: 'Nothing found. ',
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
                                  fontSize: 16,
                                  height: 1),
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
