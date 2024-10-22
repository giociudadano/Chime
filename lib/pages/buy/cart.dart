/*
  [Title]
  CartPage

  [Description]
  Displays information about the cart.
  Creates a list of OrderCards for each place in the cart the user is ordering from.
  Each OrderCard contains a list of OrderItemCards for each product the user is ordering from that place.
*/

part of '../../main.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _scrollController = ScrollController();
  Map orders = {};

  // Fetches the user's cart.
  void getCart() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    db.collection("users").doc(uid).collection("cart").get().then((snapshot) {
      for (var place in snapshot.docs) {
        orders[place.id] = place.data();
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  // Shows a reminder when clicking on the 'information' button at the upper right of the screen.
  Future showReminder(BuildContext context) async {
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
          title: Text(
            "Reminder",
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "By default, delivery address is expected to be within the locality. However, you may contact the seller for special requests.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontFamily: 'Bahnschrift',
                      fontVariations: const [
                        FontVariation('wght', 400),
                        FontVariation('wdth', 100),
                      ],
                      fontSize: 14,
                      height: 1.1,
                      letterSpacing: -0.3),
                ),
              ),
              const SizedBox(height: 20),
              ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Theme.of(context).colorScheme.primary),
                        foregroundColor: MaterialStatePropertyAll(
                            Theme.of(context).colorScheme.onPrimary),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "I understand",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontFamily: 'Bahnschrift',
                            fontVariations: const [
                              FontVariation('wght', 600),
                              FontVariation('wdth', 100),
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
        );
      },
    );
  }

  @override
  void initState() {
    getCart();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 50),
          child: Center(
            child: Text(
              "My Cart",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'Manrope',
                  fontVariations: const [
                    FontVariation('wght', 700),
                  ],
                  fontSize: 20,
                  letterSpacing: -0.3),
            ),
          ),
        ),
      ),
      body: orders.isNotEmpty
          ? ListView(
              controller: _scrollController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      key: UniqueKey(),
                      shrinkWrap: true,
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        String key = orders.keys.elementAt(index);
                        return CartCard(key, orders[key]);
                      }),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon(
                  //   Icons.shopping_cart_outlined,
                  //   color: Theme.of(context).colorScheme.outline,
                  //   size: 40,
                  // ),
                  const SizedBox(
                            height: 240,
                            width: 240,
                            child: Image(image: AssetImage('lib/assets/images/Empty.png')),
                          ),
                          const SizedBox(height: 20),
                  Text(
                    "You have an empty cart. \n Check out the stores and order some food!",
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
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
    );
  }
}
