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
  List favoriteProducts = [];

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

  void initProducts() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    for (String productID in widget.place['products']) {
      db.collection("products").doc(productID).get().then((document) async {
        products[productID] = document.data()!;
        if (favoriteProducts.contains(productID)) {
          products[productID]['isFavorited'] = true;
        }
        setProductImageURL(productID);
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void initFavorites() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("users").doc(uid).get().then((document) {
      if (document.exists) {
        favoriteProducts = document.data()!['favoriteProducts'];
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
                color: Theme.of(context).colorScheme.outline),
            const SizedBox(width: 5),
            Text(
              "Share QR Code",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
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
              Text(
                "Scanning this QR Code will redirect a user to this place. Share it to a friend or save it for later!",
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
    Map productsSorted = Map.fromEntries(products.entries.toList()
      ..sort((a, b) => (a.value['productName'].toLowerCase())
          .compareTo(b.value['productName'].toLowerCase())));
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 65,
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
                              height: 1.2,
                              overflow: TextOverflow.ellipsis),
                        ),
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
                              fontSize: 12.5,
                              letterSpacing: -0.3,
                              height: 0.85,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(height: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  widget.isFavorited
                                      ? Icons.favorite_outlined
                                      : Icons.favorite_outline,
                                  size: 20,
                                  color: widget.isFavorited
                                      ? Colors.redAccent
                                      : Theme.of(context).colorScheme.outline,
                                ),
                                onPressed: () {
                                  setFavoritePlace(widget.isFavorited);
                                },
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "${widget.place['usersFavorited'] != null ? widget.place['usersFavorited'].length : 0}",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
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
                            ])
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      _showAdditionalDetails(details.globalPosition);
                    },
                    child: Icon(
                      Icons.more_vert,
                      size: 22,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
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
                if (products.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
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
                            itemCount: products.length,
                            itemBuilder: (BuildContext context, int index) {
                              String key = productsSorted.keys.elementAt(index);
                              return ProductCard(
                                  key, products[key], widget.placeID);
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
                  child: GridView.builder(
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
                              color: MaterialColors.getSurfaceContainerHighest(
                                  darkMode),
                            ),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: InkWell(
                          onTap: () {
                            if (context.mounted) {}
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        height: 1.2,
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
                                        height: 1.2,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
