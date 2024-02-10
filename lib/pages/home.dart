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
  // Variables for listeners and controllers.
  StreamSubscription? cartListener;
  late TabController tabController;

  // Variables for personal data.
  int cartItems = 0;

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

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          elevation: 0,
          items: [
            BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Card(
                    elevation: 0,
                    color: MaterialColors.getSurfaceContainerLowest(darkMode),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 8),
                      child: Column(
                        children: [
                          Icon(Icons.local_mall,
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 24),
                          Text(
                            "Places",
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
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
                  padding: EdgeInsets.only(left: 20),
                  child: Card(
                    elevation: 0,
                    color: ChimeColors.getGreen200(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 8),
                      child: Column(
                        children: [
                          Icon(Icons.local_mall,
                              size: 24, color: ChimeColors.getGreen800()),
                          Text(
                            "Places",
                            style: TextStyle(
                              color: ChimeColors.getGreen800(),
                              fontFamily: 'Plus Jakarta Sans',
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
                  color: MaterialColors.getSurfaceContainerLowest(darkMode),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                    child: Column(
                      children: [
                        Icon(Icons.fastfood,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 24),
                        Text(
                          "Foods",
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
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
                  color: ChimeColors.getGreen200(),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                    child: Column(
                      children: [
                        Icon(Icons.fastfood,
                            size: 24, color: ChimeColors.getGreen800()),
                        Text(
                          "Foods",
                          style: TextStyle(
                            color: ChimeColors.getGreen800(),
                            fontFamily: 'Plus Jakarta Sans',
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
                    color: MaterialColors.getSurfaceContainerLowest(darkMode),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 8),
                      child: Column(
                        children: [
                          Icon(Icons.receipt,
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 24),
                          Text(
                            "Orders",
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
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
                  padding: EdgeInsets.only(right: 20),
                  child: Card(
                    elevation: 0,
                    color: ChimeColors.getGreen200(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 8),
                      child: Column(
                        children: [
                          Icon(Icons.receipt,
                              size: 24, color: ChimeColors.getGreen800()),
                          Text(
                            "Orders",
                            style: TextStyle(
                              color: ChimeColors.getGreen800(),
                              fontFamily: 'Plus Jakarta Sans',
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
          currentIndex: tabController.index,
          onTap: (int i) {
            setState(() {
              tabController.index = i;
            });
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
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundImage: NetworkImage(widget.profilePictureURL),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const ProfilePage()));
                    }),
                Stack(children: [
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
                ])
              ],
            ),
          ),
          const SizedBox(height: 20),
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
        ]),
      ),
    );
  }
}
