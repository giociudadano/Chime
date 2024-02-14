part of '../main.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with TickerProviderStateMixin {
  StreamSubscription? placesListener;
  late TabController tabController;
  Map places = {};

  void editStore(String placeID, String? placeImageURL, Map data) async {
    if (placeImageURL != null) {
      await CachedNetworkImage.evictFromCache(placeImageURL);
      if (placeImageURL == '') {
        places[placeID]['placeImageURL'] = null;
      } else {
        places[placeID]['placeImageURL'] = placeImageURL;
      }
    }
    if (mounted) {
      setState(() {
        places[placeID]['placeName'] = data['placeName'];
        places[placeID]['placeTagline'] = data['placeTagline'];
        places[placeID]['deliveryPrice'] = data['deliveryPrice'];
        places[placeID]['phoneNumber'] = data['phoneNumber'];
      });
    }
  }

  // Adds a place listener
  void addPlacesListener() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;

    placesListener =
        db.collection("users").doc(uid).snapshots().listen((event) async {
      db.collection("users").doc(uid).get().then((document) {
        List placeIDs = document.data()!['places'];
        for (String placeID in placeIDs) {
          db.collection("places").doc(placeID).get().then((document) {
            if (mounted) {
              setState(() {
                places[placeID] = document.data()!;
              });
            }
          }).then((res) {
            String key = places.keys.elementAt(0);
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
          places[key]["placeImageURL"] = url;
        });
      }
    } catch (e) {
      //
    }
  }

  void setFeaturedProduct(String placeID, String productID, bool state) {
    if (state) {
      (places[placeID]['categories']['Featured']).insert(0, productID);
    } else {
      (places[placeID]['categories']['Featured']).remove(productID);
    }
  }

  void editProduct(String placeID, String productID, List addedCategories,
      List removedCategories) {
    for (String addedCategory in addedCategories) {
      (places[placeID]['categories'][addedCategory]).add(productID);
    }
    for (String removedCategory in removedCategories) {
      (places[placeID]['categories'][removedCategory]).remove(productID);
    }
  }

  void addProduct(String placeID, String productID, List categories) {
    places[placeID]['products'].add(productID);
    for (String category in categories) {
      places[placeID]['categories'][category].add(productID);
    }
  }

  void deleteProduct(String placeID, String productID, List categories) {
    places[placeID]['products'].remove(productID);
    for (String category in categories) {
      places[placeID]['categories'][category].remove(productID);
    }
  }

  void _showQRCode() async {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    String key = places.keys.elementAt(0);
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
                  data: key,
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
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    if (places.isEmpty) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 150, width: 150, child: Placeholder()),
              const SizedBox(height: 20),
              Text(
                "Meow-hoo!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontVariations: const [
                      FontVariation('wght', 700),
                    ],
                    color: ChimeColors.getGreen800(),
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
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 14,
                    letterSpacing: -0.3),
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
                            MaterialStatePropertyAll(ChimeColors.getGreen200()),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Create",
                          style: TextStyle(
                            color: ChimeColors.getGreen800(),
                            fontFamily: 'Plus Jakarta Sans',
                            fontVariations: const [
                              FontVariation('wght', 700),
                            ],
                            fontSize: 15,
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
    String key = places.keys.elementAt(0);
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: MaterialColors.getSurfaceContainerLow(darkMode),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 75,
                        height: 75,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: FittedBox(
                            clipBehavior: Clip.hardEdge,
                            fit: BoxFit.cover,
                            child: CachedNetworkImage(
                              imageUrl: places[key]["placeImageURL"] ?? '',
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
                              places[key]["placeName"],
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
                            const SizedBox(height: 7),
                            Text(
                              places[key]["placeTagline"] ?? '',
                              maxLines: 2,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontFamily: 'Bahnschrift',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                    FontVariation('wdth', 100),
                                  ],
                                  fontSize: 13.5,
                                  letterSpacing: -0.3,
                                  height: 0.85,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTapDown: (TapDownDetails details) {},
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
                            if (context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => StoreEditPage(
                                        key, places[key],
                                        editStoreCallback: editStore)),
                              );
                            }
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
                            Icons.edit,
                            size: 20,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          label: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Edit Store",
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
          Expanded(
            child: Column(
              children: [
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
                              backgroundColor: MaterialStatePropertyAll(
                                  tabController.index == 0
                                      ? MaterialColors.getSurfaceContainerLow(
                                          darkMode)
                                      : MaterialColors
                                          .getSurfaceContainerLowest(darkMode)),
                            ),
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  "Products",
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
                              backgroundColor: MaterialStatePropertyAll(
                                  tabController.index == 1
                                      ? MaterialColors.getSurfaceContainerLow(
                                          darkMode)
                                      : MaterialColors
                                          .getSurfaceContainerLowest(darkMode)),
                            ),
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
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
                        const SizedBox(width: 10),
                        Opacity(
                          opacity: tabController.index == 2 ? 1 : 0.5,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  tabController.index == 2
                                      ? MaterialColors.getSurfaceContainerLow(
                                          darkMode)
                                      : MaterialColors
                                          .getSurfaceContainerLowest(darkMode)),
                            ),
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  "Orders",
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
                              tabController.animateTo(2);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      StoreProductsPage(
                          key,
                          places[key]['categories'].keys.toList()..sort(),
                          places[key]['products'],
                          places[key]['noticeTitle'],
                          places[key]['noticeDesc'],
                          setFeaturedProductCallback: setFeaturedProduct,
                          addProductCallback: addProduct,
                          editProductCallback: editProduct,
                          deleteProductCallback: deleteProduct),
                      StoreCategoriesPage(key, places[key]['categories'],
                          places[key]['products']),
                      StoreOrdersPage(key),
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
