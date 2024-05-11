/*
  [Title]
  HomePage

  [Description]
  Container for all tab pages. Visited when the user logs in.
*/

part of '../main.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  HomePage({super.key});
  String profilePictureURL = '';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String? appMode;

  // Variables for listeners and controllers.
  StreamSubscription? cartListener;
  late TabController tabController;
  Map user = {};

  // Variables for personal data.
  int cartItems = 0;
  bool ownedStores = false;
  Map places = {};
  String key = '';

  void logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "There was an error logging out your account. Please try again later.",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 14,
                fontFamily: 'Source Sans 3',
                fontVariations: const [
                  FontVariation('wght', 400),
                ],
              )),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      return;
    }
  }

  void updateNavigationBar(bool newState) {
    setState(() {
      ownedStores = newState;
    });
  }

  void loadAppMode() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    setState(() {
      appMode = sharedPreferences.getString('appMode') ?? 'Buy';
    });
  }

  void getProfilePictureURL() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String url = '';
    String ref = "profilePictures/$uid.png";
    try {
      url = await FirebaseStorage.instance.ref(ref).getDownloadURL();
    } catch (e) {
      //
    } finally {
      if (mounted) {
        setState(() {
          widget.profilePictureURL = url;
        });
      }
    }
  }

  // Adds a cart listener that updates the number of items bubble when the cart
  //  recieves an update.
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
          this.cartItems = cartItems;
        });
      });
    });
  }

  @override
  void initState() {
    tabController = TabController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
    tabController.addListener(() {
      setState(() {});
    });
    loadAppMode();
    getUserInfo();
    getPlaces();
    getProfilePictureURL();
    addCartListener();
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    cartListener!.cancel();
    super.dispose();
  }

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

  void getUserInfo() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    String uid = FirebaseAuth.instance.currentUser!.uid;
    db.collection("users").doc(uid).get().then((snapshot) {
      user = snapshot.data()!;
      String? email = FirebaseAuth.instance.currentUser!.email;
      user['email'] = email;
    });
  }

  void getPlaces() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;

    db.collection("users").doc(uid).get().then((document) {
      List placeIDs = document.data()!['places'];
      if (placeIDs.isNotEmpty) {
        ownedStores = true;
      }
      for (String placeID in placeIDs) {
        db.collection("places").doc(placeID).get().then((document) {
          if (mounted) {
            setState(() {
              places[placeID] = document.data()!;
            });
          }
        }).then((res) {
          key = places.keys.elementAt(0);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0))),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 15,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: Theme.of(context).colorScheme.onSurface),
                      onPressed: () {
                        scaffoldKey.currentState?.openEndDrawer();
                      },
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                "Your Profile",
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontFamily: 'Manrope',
                                    fontVariations: const [
                                      FontVariation('wght', 700),
                                    ],
                                    fontSize: 20,
                                    letterSpacing: -0.3),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        foregroundImage: NetworkImage(widget.profilePictureURL),
                      ),
                      const SizedBox(height: 8),
                      if (user['displayName'] != null)
                        Text(
                          user['displayName'],
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Manrope',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 16,
                              letterSpacing: -0.3),
                        ),
                      if (user['email'] != null)
                        Text(
                          user['email'] ?? '',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              height: 1,
                              letterSpacing: -0.1),
                        ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                                color: Theme.of(context).colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: Theme.of(context).colorScheme.outlineVariant,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appMode == "Buy"
                                              ? "Want to earn?"
                                              : "Want to order food?",
                                          style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontFamily: 'Manrope',
                                              fontVariations: const [
                                                FontVariation('wght', 700)
                                              ],
                                              fontSize: 16,
                                              letterSpacing: -0.3),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          appMode == "Buy"
                                              ? "You can also sell food with Chime and start an online business. It only takes a few steps to get started."
                                              : "Chime allows you to see the fun places and food in Miagao and order conveniently online.",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline,
                                              fontFamily: 'Source Sans 3',
                                              fontVariations: const [
                                                FontVariation('wght', 400),
                                              ],
                                              fontSize: 14,
                                              height: 1.1,
                                              letterSpacing: -0.3),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  final SharedPreferences
                                                      prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  if (appMode == 'Buy') {
                                                    prefs
                                                        .setString(
                                                            'appMode', 'Sell')
                                                        .then((value) {
                                                      if (mounted) {
                                                        setState(() {
                                                          appMode = 'Sell';
                                                        });
                                                      }
                                                    });
                                                  } else {
                                                    prefs
                                                        .setString(
                                                            'appMode', 'Buy')
                                                        .then((value) {
                                                      if (mounted) {
                                                        setState(() {
                                                          appMode = 'Buy';
                                                        });
                                                      }
                                                    });
                                                  }
                                                },
                                                style: ButtonStyle(
                                                  shadowColor: const MaterialStatePropertyAll(Colors.transparent),
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                            Theme.of(context).colorScheme.primary),
                                                    shape: MaterialStatePropertyAll(
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      side: BorderSide.none,
                                                    ))),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        appMode == "Buy"
                                                            ? Icons.sell
                                                            : Icons.local_mall,
                                                        size: 20,
                                                        color: Theme.of(context).colorScheme.onPrimary,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        appMode == "Buy"
                                                            ? "Start Selling"
                                                            : "Start Buying",
                                                        style: TextStyle(
                                                          color: Theme.of(context).colorScheme.onPrimary,
                                                          fontFamily:
                                                              'Manrope',
                                                          fontVariations: const [
                                                            FontVariation(
                                                                'wght', 700),
                                                          ],
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ]),
                                )),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          logoutUser();
                        },
                        style: ButtonStyle(
                          elevation: const MaterialStatePropertyAll(0),
                          backgroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.surface),
                          shape:
                              MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide.none,
                          )),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout,
                                size: 24,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Logout",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: (appMode == 'Sell' && !ownedStores)
          ? const SizedBox.shrink()
          : BottomNavigationBar(
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Card(
                        elevation: 0,
                        color:
                            Theme.of(context).colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: Column(
                            children: [
                              Icon(Icons.local_mall,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: 24),
                              Text(
                                (appMode == 'Buy') ? "Places" : "Store",
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontVariations: [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 14,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    activeIcon: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: Column(
                            children: [
                              Icon(Icons.local_mall,
                                  size: 24, color: Theme.of(context).colorScheme.onSecondaryContainer),
                              Text(
                                (appMode == 'Buy') ? "Places" : "Store",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 14,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    label: ''),
                BottomNavigationBarItem(
                    icon: Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Column(
                          children: [
                            Icon(
                                (appMode == 'Buy')
                                    ? Icons.fastfood
                                    : Icons.category,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 24),
                            Text(
                              (appMode == 'Buy') ? "Foods" : "Categories",
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontVariations: [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 14,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    activeIcon: Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: Column(
                          children: [
                            Icon(
                                (appMode == 'Buy')
                                    ? Icons.fastfood
                                    : Icons.category,
                                size: 24,
                                color: Theme.of(context).colorScheme.onSecondaryContainer),
                            Text(
                              (appMode == 'Buy') ? "Foods" : "Categories",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 14,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    label: ''),
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Card(
                        elevation: 0,
                        color:
                            Theme.of(context).colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: Column(
                            children: [
                              Icon(Icons.receipt,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: 24),
                              const Text(
                                "Orders",
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontVariations: [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 14,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    activeIcon: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Column(
                            children: [
                              Icon(Icons.receipt,
                                  size: 24, color: Theme.of(context).colorScheme.onSecondaryContainer),
                              Text(
                                "Orders",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 14,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    label: ''),
              ],
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedFontSize: 4,
              unselectedFontSize: 4,
              currentIndex: tabController.index,
              onTap: (int i) {
                if (mounted) {
                  setState(() {
                    tabController.index = i;
                  });
                }
              }),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      foregroundImage: NetworkImage(widget.profilePictureURL),
                    ),
                    onPressed: () {
                      scaffoldKey.currentState?.openDrawer();
                    }),
                (appMode == 'Buy')
                    ? Stack(children: [
                        IconButton(
                          icon: Icon(
                            Icons.shopping_cart_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const CartPage()));
                          },
                        ),
                        if (cartItems != 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: CircleAvatar(
                                radius: 10,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: Text(
                                  cartItems.toString(),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontFamily: 'Bahnschrift',
                                      fontVariations: const [
                                        FontVariation('wght', 700),
                                        FontVariation('wdth', 100),
                                      ],
                                      fontSize: 14,
                                      letterSpacing: -0.3),
                                )),
                          )
                      ])
                    : IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 24,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
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
                      ),
              ],
            ),
          ),
          if (appMode == 'Buy')
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: const [
                  PlacesPage(),
                  ProductsPage(),
                  OrdersPage(),
                ],
              ),
            ),
          if (appMode == 'Sell')
            Expanded(
              child: (ownedStores)
                  ? TabBarView(controller: tabController, children: [
                      StorePage(places),
                      (places[key] == null)
                          ? const SizedBox.shrink()
                          : StoreCategoriesPage(key, places[key]['categories'],
                              places[key]['products'] ?? []),
                      StoreOrdersPage(key),
                    ])
                  : StorePage(places,
                      updateNavigationBarCallback: updateNavigationBar),
            ),
        ]),
      ),
    );
  }
}
