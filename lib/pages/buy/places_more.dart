part of '../../main.dart';

// ignore: must_be_immutable
class PlacesMorePage extends StatefulWidget {
  // Variables used for place information.
  String placeID;
  Map place;

  // Variables used for user-related information.
  late bool isFavorited = place['isFavorited'] ?? false;
  int cartItems = 0;

  PlacesMorePage(this.placeID, this.place,
      {super.key, this.setFavoritePlaceCallback});

  @override
  State<PlacesMorePage> createState() => _PlacesMorePageState();
  final Function(String placeID, bool state)? setFavoritePlaceCallback;
}

class _PlacesMorePageState extends State<PlacesMorePage>
    with TickerProviderStateMixin {
  StreamSubscription? cartListener;
  late TabController tabController;
  Map products = {};
  List productsFeatured = [], productsFavorited = [];

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
      widget.setFavoritePlaceCallback!(widget.placeID, !isFavorited);
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
        initProductState(productID);
        setProductImageURL(productID);
      });
    }
    if (mounted) {
      setState(() {});
    }
  }

  void initProductState(String productID) async {
    if (widget.place['categories']['Featured'].contains(productID)) {
      products[productID]['isFeatured'] = true;
      productsFeatured.add(productID);
      productsFeatured.sort((a, b) => products[a]['productName']
          .toLowerCase()
          .compareTo(products[b]['productName'].toLowerCase()));
    }
  }

  void initFavorites() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("users").doc(uid).get().then((document) {
      if (document.exists) {
        for (String productID in document.data()!['favoriteProducts'] ?? []) {
          if (products[productID] != null) {
            productsFavorited.add(productID);
            products[productID]['isFavorited'] = true;
          }
        }
      }
    });
  }

  void setProductImageURL(String productID) async {
    String ref = "products/$productID.jpg";
    try {
      String url = await FirebaseStorage.instance.ref(ref).getDownloadURL();
      if (mounted) {
        setState(() {
          products[productID]['productImageURL'] = url;
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

  void _showAdditionalDetails(Offset offset) async {
    await showMenu(
      elevation: 0,
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
      items: [
        // TO REMOVE?
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
                  fontFamily: 'Manrope',
                  fontVariations: const [
                    FontVariation('wght', 700),
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
              Radius.circular(16.0),
            ),
          ),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
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
              const SizedBox(height: 12),
              Text(
                "Here's your code",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Manrope',
                    fontVariations: const [
                      FontVariation('wght', 700),
                    ],
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: 24,
                    letterSpacing: -0.3),
              ),
              const SizedBox(height: 10),
              Text(
                "Scanning this QR Code will redirect a friend to this place. Share it or save it for later!",
                maxLines: 3,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
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
    initProducts();
    initFavorites();
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
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
                      color: Theme.of(context).colorScheme.primary),
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
                              fontFamily: 'Manrope',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3),
                        )),
                  )
              ]),
            ),
          ]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 75,
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.place['placeName'],
                            maxLines: 2,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 20,
                                letterSpacing: -0.3,
                                height: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.place['placeTagline'] ?? '',
                            maxLines: 2,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontFamily: 'Source Sans 3',
                                fontVariations: const [
                                  FontVariation('wght', 400),
                                ],
                                fontSize: 14,
                                letterSpacing: -0.3,
                                height: 1,
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
                const SizedBox(height: 8),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setFavoritePlace(widget.isFavorited);
                        },
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.surface,
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(
                                  width: 1,
                                  color: Theme.of(context).colorScheme.outline),
                            ),
                          ),
                        ),
                        icon: Icon(
                          widget.isFavorited
                              ? Icons.favorite_outlined
                              : Icons.favorite_outline,
                          size: 20,
                          color: widget.isFavorited
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.outline,
                        ),
                        label: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                widget.isFavorited ? "Following" : "Follow",
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.outline,
                                    fontFamily: 'Manrope',
                                    fontVariations: const [
                                      FontVariation('wght', 700),
                                    ],
                                    fontSize: 14,
                                    letterSpacing: -0.3),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "${widget.place['usersFavorited'] != null ? widget.place['usersFavorited'].length : 0}",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontFamily: 'Source Sans 3',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                  ],
                                  fontSize: 14,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ]),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showQRCode();
                        },
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.surface,
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(
                                  width: 1,
                                  color: Theme.of(context).colorScheme.outline),
                            ),
                          ),
                        ),
                        icon: Icon(
                          Icons.qr_code_scanner,
                          size: 20,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        label: Text(
                          "QR Code",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontFamily: 'Manrope',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3),
                        ),
                      ),
                    ]),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SizedBox(
              height: 30,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          tabController.index == 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceVariant),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          "Food",
                          style: TextStyle(
                              color: tabController.index == 0
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontFamily: 'Manrope',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 13,
                              letterSpacing: -0.3,
                              overflow: TextOverflow.ellipsis),
                        )),
                    onPressed: () {
                      tabController.animateTo(0);
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          tabController.index == 1
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceVariant),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          "Categories",
                          style: TextStyle(
                              color: tabController.index == 1
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontFamily: 'Manrope',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 13,
                              letterSpacing: -0.3,
                              overflow: TextOverflow.ellipsis),
                        )),
                    onPressed: () {
                      tabController.animateTo(1);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        if (!(widget.place['noticeTitle'] == null &&
                            widget.place['noticeDesc'] == null))
                          Column(children: [
                            const SizedBox(height: 8),
                            Card(
                              elevation: 0,
                              color: Theme.of(context).colorScheme.tertiaryContainer,
                              shape: RoundedRectangleBorder(
                                  //<-- SEE HERE
                                  side: BorderSide.none,
                                  borderRadius: BorderRadius.circular(16.0)),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.place['noticeTitle'] ?? 'Notice',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onTertiaryContainer,
                                        fontFamily: 'Manrope',
                                        fontVariations: const [
                                          FontVariation('wght', 700),
                                        ],
                                        fontSize: 16,
                                        letterSpacing: 0,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (!(widget.place['noticeDesc'] == null &&
                                        widget.place['noticeTitle'] != null))
                                      const SizedBox(height: 8),
                                    if (!(widget.place['noticeDesc'] == null &&
                                        widget.place['noticeTitle'] != null))
                                      Text(
                                        widget.place['noticeDesc'],
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onTertiaryContainer,
                                          fontFamily: 'Source Sans 3',
                                          fontVariations: const [
                                            FontVariation('wght', 400),
                                          ],
                                          fontSize: 14,
                                          letterSpacing: 0,
                                          height: 1.2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 4,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ]),
                        if (productsFavorited.isNotEmpty)
                          Column(children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Favorites",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontFamily: 'Manrope',
                                          fontVariations: const [
                                            FontVariation('wght', 700),
                                          ],
                                          fontSize: 16,
                                          letterSpacing: -0.5),
                                    ),
                                  ]),
                            ),
                            const SizedBox(height: 8),
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
                            const SizedBox(height: 24),
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
                                    Text(
                                      "Featured",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontFamily: 'Source Sans 3',
                                          fontVariations: const [
                                            FontVariation('wght', 400),
                                          ],
                                          fontSize: 16,
                                          letterSpacing: 0),
                                    ),
                                  ]),
                            ),
                            const SizedBox(height: 8),
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
                            const SizedBox(height: 24),
                          ]),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "All Products",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontFamily: 'Manrope',
                                      fontVariations: const [
                                        FontVariation('wght', 700),
                                      ],
                                      fontSize: 16,
                                      letterSpacing: 0),
                                ),
                              ]),
                        ),
                        const SizedBox(height: 8),
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          key: UniqueKey(),
                          shrinkWrap: true,
                          itemCount: products.length,
                          itemBuilder: (BuildContext context, int index) {
                            String key = products.keys.elementAt(index);
                            return ProductCard(key, products[key],
                                widget.placeID, widget.place,
                                setFavoriteProductCallback: setFavoriteProduct);
                          },
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  mainAxisExtent: 205,
                                  maxCrossAxisExtent: 200,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 0),
                        ),
                        const SizedBox(
                            height: 64,
                            child: Center(child: Text("This is the end of the list!"))),
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    children: [
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
                            color: MaterialColors.getSurfaceContainerLowest(
                                darkMode),
                            shape: RoundedRectangleBorder(
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
                                      builder: (context) =>
                                          PlacesMoreCategoriesPage(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          categoryKeys[index],
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                            fontFamily: 'Manrope',
                                            fontVariations: const [
                                              FontVariation('wght', 700),
                                            ],
                                            fontSize: 14,
                                            height: 1,
                                            letterSpacing: -0.3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "(${widget.place['categories'][categoryKeys[index]].length.toString()})",
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                            fontFamily: 'Source Sans 3',
                                            fontVariations: const [
                                              FontVariation('wght', 400),
                                            ],
                                            fontSize: 14,
                                            height: 1.2,
                                            letterSpacing: -0.3,
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
