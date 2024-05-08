part of '../../main.dart';

class StorePage extends StatefulWidget {
  StorePage(this.places, {super.key, this.updateNavigationBarCallback});
  
  final Function(bool newState)? updateNavigationBarCallback;
  Map places = {};

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with TickerProviderStateMixin {
  StreamSubscription? placesListener;
  late TabController tabController;

  // Adds a place listener
  void addPlacesListener() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;

    placesListener =
        db.collection("users").doc(uid).snapshots().listen((event) async {
      // Shows the navigation bar if a new place is added
      db.collection("users").doc(uid).get().then((document) {
        List placeIDs = document.data()!['places'];
        for (String placeID in placeIDs) {
          db.collection("places").doc(placeID).get().then((document) {
            if (mounted) {
              setState(() {
                widget.places[placeID] = document.data()!;
              });
              if (widget.updateNavigationBarCallback != null &&
                  widget.places.isNotEmpty) {
                widget.updateNavigationBarCallback!(true);
              }
            }
          }).then((res) {
            String key = widget.places.keys.elementAt(0);
            getPlaceImageURL(key);
          });
        }
      });
    });
  }

  // Retrieves and sets the place image given the place ID of the page.
  // Place ID is retrieved when obtaining product information.
  Future getPlaceImageURL(String key) async {
    String url = '';
    String ref = "places/$key.jpg";
    try {
      url = await FirebaseStorage.instance.ref(ref).getDownloadURL();
      if (mounted) {
        setState(() {
          widget.places[key]["placeImageURL"] = url;
        });
      }
    } catch (e) {
      //
    }
  }

  void setFeaturedProduct(String placeID, String productID, bool state) {
    if (state) {
      (widget.places[placeID]['categories']['Featured']).insert(0, productID);
    } else {
      (widget.places[placeID]['categories']['Featured']).remove(productID);
    }
  }

  void editProduct(String placeID, String productID, List addedCategories,
      List removedCategories) {
    for (String addedCategory in addedCategories) {
      (widget.places[placeID]['categories'][addedCategory]).add(productID);
    }
    for (String removedCategory in removedCategories) {
      (widget.places[placeID]['categories'][removedCategory]).remove(productID);
    }
  }

  void addProduct(String placeID, String productID, List categories) {
    widget.places[placeID]['products'].add(productID);
    for (String category in categories) {
      widget.places[placeID]['categories'][category].add(productID);
    }
  }

  void deleteProduct(String placeID, String productID, List categories) {
    widget.places[placeID]['products'].remove(productID);
    for (String category in categories) {
      widget.places[placeID]['categories'][category].remove(productID);
    }
  }
  
  void _showAdditionalDetails(Offset offset) async {
    await showMenu(
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 0,
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
      items: [
        // TO REMOVE?
        PopupMenuItem(
          onTap: () {
            // _showQRCode();
          },
          child: Row(children: [
            Icon(Icons.qr_code_scanner,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
            const SizedBox(width: 5),
            Text(
              "Share QR Code",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
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

  @override
  void initState() {
    addPlacesListener();
    tabController = TabController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
    tabController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    placesListener!.cancel();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If there is no existing store, display a prompt to add a new one.
    if (widget.places.isEmpty) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                const SizedBox(
                  height: 240,
                  width: 240,
                  child: Image(image: AssetImage('lib/assets/images/Chime.png')),
                ),
              const SizedBox(height: 20),
              Text(
                "Meow-hoo!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Manrope',
                    fontVariations: const [
                      FontVariation('wght', 700),
                    ],
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                    letterSpacing: -0.3),
              ),
              Text(
                "Ready to sell your products? Set up your store in just a few steps.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Source Sans 3',
                    fontVariations: const [
                      FontVariation('wght', 400),
                    ],
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    letterSpacing: -0.1),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const StoreAddPage()),
                          );
                        }
                      },
                      style: ButtonStyle(
                        elevation: const MaterialStatePropertyAll(0),
                        backgroundColor:
                            MaterialStatePropertyAll(Theme.of(context).colorScheme.primary),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Create",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontFamily: 'Manrope',
                            fontVariations: const [
                              FontVariation('wght', 700),
                            ],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    String key = widget.places.keys.elementAt(0);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: FittedBox(
                          clipBehavior: Clip.hardEdge,
                          fit: BoxFit.cover,
                          child: CachedNetworkImage(
                            imageUrl: widget.places[key]["placeImageURL"] ?? '',
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
                            widget.places[key]["placeName"],
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
                            widget.places[key]["placeTagline"] ?? '',
                            maxLines: 2,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontFamily: 'Source Sans 3',
                                fontVariations: const [
                                  FontVariation('wght', 400),
                                ],
                                fontSize: 16,
                                letterSpacing: -0.1,
                                height: 1.1,
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
                const SizedBox(height: 12),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: StoreProductsPage(
                      key,
                      widget.places[key]['categories'].keys.toList()..sort(),
                      widget.places[key]['products'],
                      widget.places[key]['noticeTitle'],
                      widget.places[key]['noticeDesc'],
                      setFeaturedProductCallback: setFeaturedProduct,
                      addProductCallback: addProduct,
                      editProductCallback: editProduct,
                      deleteProductCallback: deleteProduct),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
