part of main;

// The 'place' page displays additional information about a place and its products.
// This page is visited when the user clicks on a place from the 'places' page.

// ignore: must_be_immutable
class PlacePage extends StatefulWidget {
  String placeID;
  String placeName = '', placeTagline = '', placeImageURL = '';
  bool isFavorited = false;
  PlacePage(this.placeID, {super.key});

  @override
  State<PlacePage> createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  // Retrieves and sets the place information given the place ID of the page.
  // Place ID is retrieved when obtaining product information.
  Future _getPlaceInfo() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("places").doc(widget.placeID).get().then((document) {
      if (document.exists) {
        setState(() {
          widget.placeName = document.data()!['placeName'] ?? '';
          widget.placeTagline = document.data()!['placeTagline'] ?? '';
        });
      }
    });
  }

  // Retrieves and sets user information (e.g. favorited) on the place.
  Future _getUserInfo() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("users").doc(uid).get().then((document) {
      if (document.exists) {
        List favorites = document.data()!['favoritePlaces'];
        if (favorites.contains(widget.placeID)) {
          if (mounted) {
            setState(() {
              widget.isFavorited = true;
            });
          }
        }
      }
    });
  }

  // Retrieves and sets the place image given the place ID of the page.
  // Place ID is retrieved when obtaining product information.
  Future _getPlaceImageURL() async {
    String url = '';
    String ref = "places/${widget.placeID}.jpg";
    try {
      url = await FirebaseStorage.instance.ref(ref).getDownloadURL();
    } catch (e) {
      //
    } finally {
      if (mounted) {
        setState(() {
          widget.placeImageURL = url;
        });
      }
    }
  }

  void setFavoritePlace(bool isFavorited) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      if (isFavorited) {
        db.collection("users").doc(uid).update({
          "favoritePlaces": FieldValue.arrayRemove([widget.placeID])
        });
      } else {
        db.collection("users").doc(uid).update({
          "favoritePlaces": FieldValue.arrayUnion([widget.placeID])
        });
      }
      if (mounted) {
        setState(() {
          widget.isFavorited = !isFavorited;
        });
      }
    } catch (e) {
      return;
    }
  }

  // Initializes page.
  @override
  void initState() {
    void initPlace() async {
      _getPlaceInfo();
      _getPlaceImageURL();
      _getUserInfo();
    }

    super.initState();
    initPlace();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: MaterialColors.getSurfaceContainerLow(darkMode),
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).colorScheme.outline),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: IconButton(
                icon: Icon(Icons.shopping_cart_outlined,
                    color: Theme.of(context).colorScheme.outline),
                onPressed: () {
                  //TODO: Add cart functionality
                },
              ),
            ),
          ]),
      backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
      body: ListView(children: [
        Container(
          color: MaterialColors.getSurfaceContainerLow(darkMode),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: FittedBox(
                      clipBehavior: Clip.hardEdge,
                      fit: BoxFit.cover,
                      child: CachedNetworkImage(
                        imageUrl: widget.placeImageURL,
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Icon(Icons.storefront_outlined,
                              color:
                                  Theme.of(context).colorScheme.outlineVariant),
                        ),
                        fadeInCurve: Curves.easeIn,
                        fadeOutCurve: Curves.easeOut,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.placeName,
                        maxLines: 1,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: 'Bahnschrift',
                            fontVariations: const [
                              FontVariation('wght', 700),
                              FontVariation('wdth', 100),
                            ],
                            fontSize: 16,
                            letterSpacing: -0.3,
                            height: 0.85,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.placeTagline,
                        maxLines: 2,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontFamily: 'Bahnschrift',
                            fontVariations: const [
                              FontVariation('wght', 400),
                              FontVariation('wdth', 100),
                            ],
                            fontSize: 12,
                            letterSpacing: -0.3,
                            height: 0.85,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: IconButton(
                    icon: Icon(
                      widget.isFavorited
                          ? Icons.favorite_outlined
                          : Icons.favorite_outline,
                      size: 24,
                      color: widget.isFavorited
                          ? Colors.redAccent
                          : Theme.of(context).colorScheme.outline,
                    ),
                    onPressed: () {
                      setFavoritePlace(widget.isFavorited);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
