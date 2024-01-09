/*
  [Title]
  PlacePage

  [Description]
  Displays the name of a place, its location on the map, and its products.
  Visited when the user clicks on a place from PlacesPage.
*/

part of '../main.dart';

// The 'place' page displays additional information about a place and its products.
// This page is visited when the user clicks on a place from the 'places' page.

// ignore: must_be_immutable
class PlacePage extends StatefulWidget {
  // Variables used for place information.
  String placeID;
  Map place;

  // Variables used for user-related information.
  late bool isFavorited = place['isFavorited'] ?? false;
  int cartItems = 0;

  PlacePage(this.placeID, this.place,
      {super.key, this.setFavoritePlaceCallback});

  @override
  State<PlacePage> createState() => _PlacePageState();
  final Function(bool state)? setFavoritePlaceCallback;
}

class _PlacePageState extends State<PlacePage> with TickerProviderStateMixin {
  StreamSubscription? cartListener;
  late TabController tabController;
  Map products = {};
  List productsFeatured = [], productsNotFeatured = [], productsFavorited = [];

  void setFavoritePlace(bool isFavorited) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      if (isFavorited) {
        db.collection("users").doc(uid).update({
          "favoritePlaces": FieldValue.arrayRemove([widget.placeID])
        });
        db.collection("places").doc(widget.placeID).update({
          "usersFavorited": FieldValue.arrayRemove([uid])
        });
      } else {
        db.collection("users").doc(uid).update({
          "favoritePlaces": FieldValue.arrayUnion([widget.placeID])
        });
        db.collection("places").doc(widget.placeID).update({
          "usersFavorited": FieldValue.arrayUnion([uid])
        });
      }
      widget.setFavoritePlaceCallback!(!isFavorited);
      if (mounted) {
        setState(() {
          widget.isFavorited = !isFavorited;
        });
      }
    } catch (e) {
      return;
    }
  }

  void setFavoriteProduct(String productID, bool state) {
    if (state == true) {
      if (productsFeatured.contains(productID)) {
        productsFeatured.remove(productID);
      } else {
        productsNotFeatured.remove(productID);
      }
      productsFavorited.add(productID);
      productsFavorited.sort((a, b) => products[a]['productName']
          .toLowerCase()
          .compareTo(products[b]['productName'].toLowerCase()));
    } else {
      productsFavorited.remove(productID);
      initProductState(productID);
    }
    if (mounted) {
      setState(() {});
    }
  }

  void initProducts() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    for (String productID in widget.place['products']) {
      db.collection("products").doc(productID).get().then((document) async {
        products[productID] = document.data()!;
        if (!productsFavorited.contains(productID)) {
          initProductState(productID);
        }
        setProductImageURL(productID);
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void initProductState(String productID) async {
    if (widget.place['categories']['Featured'].contains(productID)) {
      products[productID]['isFeatured'] = true;
      productsFeatured.add(productID);
      productsFeatured.sort((a, b) => products[a]['productName']
          .toLowerCase()
          .compareTo(products[b]['productName'].toLowerCase()));
    } else {
      productsNotFeatured.add(productID);
      productsNotFeatured.sort((a, b) => products[a]['productName']
          .toLowerCase()
          .compareTo(products[b]['productName'].toLowerCase()));
    }
  }

  void initFavorites() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("users").doc(uid).get().then((document) {
      if (document.exists) {
        productsFavorited = document.data()!['favoriteProducts'] ?? [];
      }
    });
  }

  void setProductImageURL(String productID) async {
    String ref = "products/$productID.jpg";
    try {
      String url = await FirebaseStorage.instance.ref(ref).getDownloadURL();
      setState(() {
        products[productID]['productImageURL'] = url;
      });
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

  void _showAdditionalDetails(Offset offset) async {
    await showMenu(
      elevation: 0,
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
      items: [
        PopupMenuItem(
          onTap: () {
            _showQRCode();
          },
          child: Row(children: [
            Icon(Icons.qr_code_scanner,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(
              "Share QR Code",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: 'Bahnschrift',
                  fontVariations: const [
                    FontVariation('wght', 500),
                    FontVariation('wdth', 100),
                  ],
                  fontSize: 13,
                  letterSpacing: -0.3),
            )
          ]),
        ),
      ],
    );
  }

  void _showQRCode() async {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          elevation: 0,
          backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: QrImageView(
                  data: widget.placeID,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Here's your code",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Bahnschrift',
                    fontVariations: const [
                      FontVariation('wght', 700),
                      FontVariation('wdth', 100),
                    ],
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                    letterSpacing: -0.3),
              ),
              const SizedBox(height: 10),
              Text(
                "Scanning this QR Code will redirect a friend to this place. Share it or save it for later!",
                maxLines: 3,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontFamily: 'Bahnschrift',
                    fontVariations: const [
                      FontVariation('wght', 400),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 13,
                    letterSpacing: -0.3,
                    height: 1.1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
    tabController.addListener(() {
      setState(() {});
    });
    initFavorites();
    initProducts();
    addCartListener();
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    cartListener!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    List categoryKeys = widget.place['categories'] == null
        ? []
        : widget.place['categories'].keys.toList()
      ..sort();
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
      body: Column(
        children: [
          Container(
            color: MaterialColors.getSurfaceContainerLow(darkMode),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 75,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: FittedBox(
                            clipBehavior: Clip.hardEdge,
                            fit: BoxFit.cover,
                            child: CachedNetworkImage(
                              imageUrl: widget.place['placeImageURL'] ?? '',
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
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.place['placeName'],
                              maxLines: 2,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Bahnschrift',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                    FontVariation('wdth', 100),
                                  ],
                                  fontSize: 20,
                                  letterSpacing: -0.3,
                                  height: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              widget.place['placeTagline'] ?? '',
                              maxLines: 2,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontFamily: 'Bahnschrift',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                    FontVariation('wdth', 100),
                                  ],
                                  fontSize: 13,
                                  letterSpacing: -0.3,
                                  height: 0.75,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTapDown: (TapDownDetails details) {
                          _showAdditionalDetails(details.globalPosition);
                        },
                        child: Icon(
                          Icons.more_vert,
                          size: 20,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setFavoritePlace(widget.isFavorited);
                          },
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant)))),
                          icon: Icon(
                            widget.isFavorited
                                ? Icons.favorite_outlined
                                : Icons.favorite_outline,
                            size: 20,
                            color: widget.isFavorited
                                ? Colors.redAccent
                                : Theme.of(context).colorScheme.outline,
                          ),
                          label: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  widget.isFavorited ? "Liked" : "Like",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontFamily: 'Bahnschrift',
                                      fontVariations: const [
                                        FontVariation('wght', 600),
                                        FontVariation('wdth', 100),
                                      ],
                                      fontSize: 14,
                                      letterSpacing: -0.5),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "${widget.place['usersFavorited'] != null ? widget.place['usersFavorited'].length : 0}",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    fontFamily: 'Bahnschrift',
                                    fontVariations: const [
                                      FontVariation('wght', 500),
                                      FontVariation('wdth', 100),
                                    ],
                                    fontSize: 14,
                                    letterSpacing: -0.3,
                                    height: 0.7,
                                  ),
                                ),
                              ]),
                        ),
                        const SizedBox(width: 5),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showQRCode();
                          },
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant)))),
                          icon: Icon(
                            Icons.qr_code_scanner,
                            size: 20,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          label: Text(
                            "QR Code",
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontFamily: 'Bahnschrift',
                                fontVariations: const [
                                  FontVariation('wght', 600),
                                  FontVariation('wdth', 100),
                                ],
                                fontSize: 14,
                                letterSpacing: -0.5),
                          ),
                        ),
                      ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SizedBox(
              height: 30,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Opacity(
                    opacity: tabController.index == 0 ? 1 : 0.5,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(tabController
                                    .index ==
                                0
                            ? MaterialColors.getSurfaceContainerLow(darkMode)
                            : MaterialColors.getSurfaceContainerLowest(
                                darkMode)),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Food",
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
                          )),
                      onPressed: () {
                        tabController.animateTo(0);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Opacity(
                    opacity: tabController.index == 1 ? 1 : 0.5,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(tabController
                                    .index ==
                                1
                            ? MaterialColors.getSurfaceContainerLow(darkMode)
                            : MaterialColors.getSurfaceContainerLowest(
                                darkMode)),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Categories",
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
                          )),
                      onPressed: () {
                        tabController.animateTo(1);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        if (widget.place['noticeTitle'] != null ||
                            widget.place['noticeDesc'] != null)
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                //<-- SEE HERE
                                side: BorderSide(
                                  color:
                                      MaterialColors.getSurfaceContainerHighest(
                                          darkMode),
                                ),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 15, 20, 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.place['noticeTitle'] ?? 'Notice',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontFamily: 'Bahnschrift',
                                      fontVariations: const [
                                        FontVariation('wght', 650),
                                        FontVariation('wdth', 100),
                                      ],
                                      fontSize: 15,
                                      letterSpacing: -0.3,
                                      height: 1.2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (!(widget.place['noticeDesc'] == null &&
                                      widget.place['noticeTitle'] != null))
                                    const SizedBox(height: 10),
                                  if (!(widget.place['noticeDesc'] == null &&
                                      widget.place['noticeTitle'] != null))
                                    Text(
                                      widget.place['noticeDesc'],
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        fontFamily: 'Bahnschrift',
                                        fontVariations: const [
                                          FontVariation('wght', 400),
                                          FontVariation('wdth', 100),
                                        ],
                                        fontSize: 13,
                                        letterSpacing: -0.3,
                                        height: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 5,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        if (!(widget.place['noticeTitle'] == null &&
                            widget.place['noticeDesc'] == null))
                          const SizedBox(height: 15),
                        if (productsFavorited.isNotEmpty)
                          Column(children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      const Icon(Icons.favorite,
                                          color: Colors.redAccent, size: 16),
                                      const SizedBox(width: 5),
                                      Text(
                                        "Favorited Products",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                            fontFamily: 'Bahnschrift',
                                            fontVariations: const [
                                              FontVariation('wght', 700),
                                              FontVariation('wdth', 100),
                                            ],
                                            fontSize: 16,
                                            letterSpacing: -0.5),
                                      ),
                                    ]),
                                    Text(
                                      "Sorted A-Z   🡻",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
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
                            const SizedBox(height: 10),
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              key: UniqueKey(),
                              shrinkWrap: true,
                              itemCount: productsFavorited.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ProductCard(
                                    productsFavorited[index],
                                    products[productsFavorited[index]],
                                    widget.placeID,
                                    widget.place,
                                    setFavoriteProductCallback:
                                        setFavoriteProduct);
                              },
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                      mainAxisExtent: 205,
                                      maxCrossAxisExtent: 200,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 0),
                            ),
                            const SizedBox(height: 15),
                          ]),
                        if (productsFeatured.isNotEmpty)
                          Column(children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      const Icon(Icons.bookmark,
                                          color: Colors.orangeAccent, size: 16),
                                      const SizedBox(width: 5),
                                      Text(
                                        "Featured Products",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                            fontFamily: 'Bahnschrift',
                                            fontVariations: const [
                                              FontVariation('wght', 700),
                                              FontVariation('wdth', 100),
                                            ],
                                            fontSize: 16,
                                            letterSpacing: -0.5),
                                      ),
                                    ]),
                                    Text(
                                      "Sorted A-Z   🡻",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
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
                            const SizedBox(height: 10),
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              key: UniqueKey(),
                              shrinkWrap: true,
                              itemCount: productsFeatured.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ProductCard(
                                    productsFeatured[index],
                                    products[productsFeatured[index]],
                                    widget.placeID,
                                    widget.place,
                                    setFavoriteProductCallback:
                                        setFavoriteProduct);
                              },
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                      mainAxisExtent: 205,
                                      maxCrossAxisExtent: 200,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 0),
                            ),
                            const SizedBox(height: 15),
                          ]),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  const Icon(Icons.view_agenda,
                                      color: Colors.grey, size: 16),
                                  const SizedBox(width: 5),
                                  Text(
                                    "All Products",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        fontFamily: 'Bahnschrift',
                                        fontVariations: const [
                                          FontVariation('wght', 700),
                                          FontVariation('wdth', 100),
                                        ],
                                        fontSize: 16,
                                        letterSpacing: -0.5),
                                  ),
                                ]),
                                Text(
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
                              ]),
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          key: UniqueKey(),
                          shrinkWrap: true,
                          itemCount: productsNotFeatured.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ProductCard(
                                productsNotFeatured[index],
                                products[productsNotFeatured[index]],
                                widget.placeID,
                                widget.place,
                                setFavoriteProductCallback: setFavoriteProduct);
                          },
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  mainAxisExtent: 205,
                                  maxCrossAxisExtent: 200,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 0),
                        ),
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Categories",
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.outline,
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
                            ]),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        key: UniqueKey(),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.place['categories'] == null
                            ? 0
                            : widget.place['categories'].length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                //<-- SEE HERE
                                side: BorderSide(
                                  color:
                                      MaterialColors.getSurfaceContainerHighest(
                                          darkMode),
                                ),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: InkWell(
                              onTap: () {
                                if (context.mounted) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => PlaceCategoryPage(
                                          widget.placeID,
                                          widget.place,
                                          categoryKeys[index],
                                          products,
                                          widget.place['categories']
                                              [categoryKeys[index]])));
                                }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 20, 20, 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          categoryKeys[index],
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                            fontFamily: 'Bahnschrift',
                                            fontVariations: const [
                                              FontVariation('wght', 650),
                                              FontVariation('wdth', 100),
                                            ],
                                            fontSize: 15,
                                            letterSpacing: -0.3,
                                            height: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          widget
                                              .place['categories']
                                                  [categoryKeys[index]]
                                              .length
                                              .toString(),
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                            fontFamily: 'Bahnschrift',
                                            fontVariations: const [
                                              FontVariation('wght', 500),
                                              FontVariation('wdth', 100),
                                            ],
                                            fontSize: 15,
                                            letterSpacing: -0.3,
                                            height: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(Icons.arrow_forward_ios,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        size: 15)
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                mainAxisExtent: 60,
                                maxCrossAxisExtent: 450,
                                childAspectRatio: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
