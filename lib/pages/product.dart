part of main;

// The 'Product' page displays additional information about a product.
// This page is visited when the user clicks on a product from the 'Products' page.
// ignore: must_be_immutable
class ProductPage extends StatefulWidget {
  String productID;
  String productName = '',
      productDesc = '',
      productImageURL = '',
      placeID = '',
      placeName = '',
      placeImageURL = '';
  int productPrice = 0;
  int cartItems = 0;
  bool isFavorited = false;
  ProductPage(this.productID, {super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  StreamSubscription? cartListener;
  // Retrieves and sets product information from FirebaseDB given the product ID of the page.
  Future _getProductInfo() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection("products")
        .doc(widget.productID)
        .get()
        .then((document) {
      if (document.exists) {
        setState(() {
          widget.productName = document.data()!['productName'] ?? '';
          widget.productDesc = document.data()!['productDesc'] ?? '';
          widget.productPrice = document.data()!['productPrice'] ?? 0;
          widget.placeID = document.data()!['placeID'] ?? '';
        });
      }
    });
  }

  // Retrieves and sets the product image from FirebaseStorage given the product ID of the page.
  Future _getProductImageURL() async {
    String url = '';
    String ref = "products/${widget.productID}.jpg";
    try {
      url = await FirebaseStorage.instance.ref(ref).getDownloadURL();
    } catch (e) {
      //
    } finally {
      if (mounted) {
        setState(() {
          widget.productImageURL = url;
        });
      }
    }
  }

  // Retrieves and sets the place information given the place ID of the page.
  // Place ID is retrieved when obtaining product information.
  Future _getPlaceInfo() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("places").doc(widget.placeID).get().then((document) {
      if (document.exists) {
        setState(() {
          widget.placeName = document.data()!['placeName'] ?? '';
        });
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

  // Retrieves and sets user information (e.g. favorited) on the product.
  Future _getUserInfo() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("users").doc(uid).get().then((document) {
      if (document.exists) {
        List favorites = document.data()!['favoriteProducts'];
        if (favorites.contains(widget.productID)) {
          if (mounted) {
            setState(() {
              widget.isFavorited = true;
            });
          }
        }
      }
    });
  }

  // Sets the product as a favorite/unfavorite.
  void setFavoriteProduct(bool isFavorited) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      if (isFavorited) {
        db.collection("users").doc(uid).update({
          "favoriteProducts": FieldValue.arrayRemove([widget.productID])
        });
      } else {
        db.collection("users").doc(uid).update({
          "favoriteProducts": FieldValue.arrayUnion([widget.productID])
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

  // Adds the product to the user's cart. Creates a collection for that product's place if it does not already exist
  // and stores the product as an entry in that collection.
  void addToCart() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      db
          .collection("users")
          .doc(uid)
          .collection("cart")
          .doc(widget.placeID)
          .set({widget.productID: 1}, SetOptions(merge: true));
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

  // Initializes page. Retrieves and sets the product information and image first to retrieve the place ID. Place ID is
  // then used to retrieve and set the place information and image.
  @override
  void initState() {
    super.initState();

    void initProduct() async {
      await _getProductInfo();
      _getProductImageURL();
      _getPlaceInfo();
      _getPlaceImageURL();
      _getUserInfo();
    }

    initProduct();
    addCartListener();
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 6, 6),
            child: Ink(
              decoration: ShapeDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: const CircleBorder(),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Ink(
                decoration: ShapeDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: const CircleBorder(),
                ),
                child: Stack(children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined,
                        color: Colors.white),
                    onPressed: () {
                      //TODO: Add cart functionality
                    },
                  ),
                  if (widget.cartItems != 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(
                          radius: 10,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Text(
                            widget.cartItems.toString(),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontFamily: 'Bahnschrift',
                                fontVariations: [
                                  FontVariation('wght', 700),
                                  FontVariation('wdth', 100),
                                ],
                                fontSize: 14,
                                letterSpacing: -0.3),
                          )),
                    )
                ]),
              ),
            ),
          ]),
      backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
      floatingActionButton: SizedBox(
        height: 50,
        child: FittedBox(
          child: FloatingActionButton.extended(
              onPressed: () {
                addToCart();
              },
              icon: Icon(Icons.shopping_cart_outlined,
                  color: Theme.of(context).colorScheme.onPrimary),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              label: Text(AppLocalizations.of(context)!.addToCart,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontFamily: 'Bahnschrift',
                    fontVariations: const [
                      FontVariation('wght', 500),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 18,
                    letterSpacing: -0.3,
                  )),
              backgroundColor: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 0),
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 300,
            child: FittedBox(
              clipBehavior: Clip.hardEdge,
              fit: BoxFit.cover,
              child: CachedNetworkImage(
                imageUrl: widget.productImageURL,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Icon(Icons.local_mall_outlined,
                      color: Theme.of(context).colorScheme.outlineVariant),
                ),
                fadeInCurve: Curves.easeIn,
                fadeOutCurve: Curves.easeOut,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.productName,
                              maxLines: 2,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontFamily: 'Bahnschrift',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                    FontVariation('wdth', 100),
                                  ],
                                  fontSize: 15,
                                  letterSpacing: -0.3,
                                  height: 0.85,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "₱${widget.productPrice.toString()}",
                              maxLines: 2,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontFamily: 'Bahnschrift',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                    FontVariation('wdth', 100),
                                  ],
                                  fontSize: 28,
                                  letterSpacing: -0.3,
                                  height: 0.85,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: IconButton(
                          icon: Icon(
                            widget.isFavorited
                                ? Icons.favorite_outlined
                                : Icons.favorite_outline,
                            size: 28,
                            color: widget.isFavorited
                                ? Colors.redAccent
                                : Theme.of(context).colorScheme.outline,
                          ),
                          onPressed: () {
                            setFavoriteProduct(widget.isFavorited);
                          },
                        ),
                      ),
                    ]),
              ),
              widget.productDesc != ''
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Text(
                        widget.productDesc,
                        maxLines: 3,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontFamily: 'Bahnschrift',
                            fontVariations: const [
                              FontVariation('wght', 300),
                              FontVariation('wdth', 100),
                            ],
                            fontSize: 14,
                            letterSpacing: -0.3,
                            height: 1.1,
                            overflow: TextOverflow.ellipsis),
                      ))
                  : const SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Card(
                  color: MaterialColors.getSurfaceContainerLow(darkMode),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 0,
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                  child: InkWell(
                    onTap: () {
                      if (context.mounted) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PlacePage(widget.placeID)));
                      }
                    },
                    child: SizedBox(
                      height: 70,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 70,
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant),
                                ),
                                fadeInCurve: Curves.easeIn,
                                fadeOutCurve: Curves.easeOut,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      child: Text(
                                    AppLocalizations.of(context)!.soldBy,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        fontFamily: 'Bahnschrift',
                                        fontVariations: const [
                                          FontVariation('wght', 500),
                                          FontVariation('wdth', 100),
                                        ],
                                        height: 0.9,
                                        fontSize: 13,
                                        letterSpacing: -0.3,
                                        overflow: TextOverflow.ellipsis),
                                  )),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    child: Text(
                                      widget.placeName,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontFamily: 'Bahnschrift',
                                          fontVariations: const [
                                            FontVariation('wght', 700),
                                            FontVariation('wdth', 100),
                                          ],
                                          fontSize: 15,
                                          letterSpacing: -0.3,
                                          height: 0.9,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          )
        ],
      ),
    );
  }
}
