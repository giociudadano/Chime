/*
  [Title]
  PlacePage

  [Description]
  Displays the name of a place, its location on the map, and its products.
  Visited when the user clicks on a place from PlacesPage.
*/

part of main;

// The 'place' page displays additional information about a place and its products.
// This page is visited when the user clicks on a place from the 'places' page.

// ignore: must_be_immutable
class PlacePage extends StatefulWidget {
  // Variables used for place information.
  String placeID;
  String placeName = '', placeTagline = '', placeImageURL = '';
  LatLng latLng = const LatLng(0, 0);
  CameraPosition cameraPosition =
      const CameraPosition(target: LatLng(0, 0), zoom: 16);
  List<ProductModel> products = [];

  // Variables used for user-related information.
  bool isFavorited = false;
  int cartItems = 0;

  PlacePage(this.placeID, {super.key});

  @override
  State<PlacePage> createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  StreamSubscription? cartListener;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  // Retrieves and sets the place information given the place ID of the page.
  // Place ID is retrieved when obtaining product information.
  Future _getPlaceInfo() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection("places")
        .doc(widget.placeID)
        .get()
        .then((document) async {
      if (document.exists) {
        var placePosition = document.data()!['placePosition'];
        setState(() {
          widget.placeName = document.data()!['placeName'] ?? '';
          widget.placeTagline = document.data()!['placeTagline'] ?? '';
          widget.latLng =
              LatLng(placePosition.latitude, placePosition.longitude);
        });

        var products = document.data()!['products'] ?? [];
        for (var product in products) {
          await db.collection("products").doc(product).get().then((document) {
            ProductModel productModel =
                ProductModel(document.id, document.data());
            widget.products.add(productModel);
            setState(() {
              widget.products;
            });
          });
        }

        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: widget.latLng, zoom: 16)));
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
          widget.cartItems = cartItems;
        });
      });
    });
  }

  @override
  void initState() {
    void initPlace() async {
      _getPlaceInfo();
      _getPlaceImageURL();
      _getUserInfo();
    }

    initPlace();
    addCartListener();
    super.initState();
  }

  @override
  void dispose() {
    cartListener!.cancel();
    super.dispose();
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
              child: Stack(children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined,
                      color: Theme.of(context).colorScheme.outline),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const CartPage()));
                  },
                ),
                if (widget.cartItems != 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          widget.cartItems.toString(),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontFamily: 'Bahnschrift',
                              fontVariations: const [
                                FontVariation('wght', 700),
                                FontVariation('wdth', 100),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3),
                        )),
                  )
              ]),
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
                  padding: const EdgeInsets.only(left: 10),
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
        SizedBox(
            height: 250,
            child: GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: widget.cameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: {
                Marker(
                  markerId: MarkerId(widget.placeName),
                  position: widget.latLng,
                )
              },
            )),
        if (widget.products.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                AppLocalizations.of(context)!.recommendedProducts,
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
                  itemCount: widget.products.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ProductCard(
                        productID: widget.products[index].productID,
                        productName: widget.products[index].productName,
                        productPrice: widget.products[index].productPrice,
                        placeID: widget.products[index].placeID);
                  },
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      mainAxisExtent: 165,
                      maxCrossAxisExtent: 220,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 10),
                ),
              ),
            ]),
          )
      ]),
    );
  }
}