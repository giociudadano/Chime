/*
  [Title]
  HomePage

  [Description]
  Container for all tab pages. Visited when the user logs in.
*/

part of main;

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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      icon: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        foregroundImage:
                            Image.network(widget.profilePictureURL).image,
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
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
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
                                  : MaterialColors.getSurfaceContainerLowest(
                                      darkMode)),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              "Places",
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
                                  : MaterialColors.getSurfaceContainerLowest(
                                      darkMode)),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
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
                                  : MaterialColors.getSurfaceContainerLowest(
                                      darkMode)),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              "My Orders",
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
                children: const [
                  PlacesPage(),
                  ProductsPage(),
                  OrdersPage(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
