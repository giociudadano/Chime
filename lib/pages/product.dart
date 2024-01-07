/*
  [Title]
  ProductPage

  [Description]
  Displays information about a product, its image, price, and description.
  Contains options to modify quantity to be ordered and to add the product to cart or favorites.
  Visited when clicking on a ProductCard from ProductsPage.
*/

part of main;

// The 'Product' page displays additional information about a product.
// This page is visited when the user clicks on a product from the 'Products' page.
// ignore: must_be_immutable
class ProductPage extends StatefulWidget {
  // Variables for product information.
  String productID, placeID;
  Map product, place;

  ProductPage(this.productID, this.product, this.placeID, this.place,
      {super.key, this.setFavoriteProductCallback});
  final Function(bool state)? setFavoriteProductCallback;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  StreamSubscription? cartListener;
  int cartItems = 0;
  int itemQuantity = 1;
  bool isInCart = false;

  String? variant = 'Regular';

  // Sets the product as a favorite/unfavorite.
  void setFavoriteProduct(bool isFavorited) {
    try {
      widget.setFavoriteProductCallback!(isFavorited);
      if (mounted) {
        setState(() {
          widget.product['isFavorited'] = !isFavorited;
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
          .set({
        widget.productID: {
          "name": widget.product['productName'],
          "quantity": itemQuantity,
          "price": widget.product['productPrice'],
        }
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isInCart
                  ? "${widget.product['productName']} updated in cart!"
                  : "${widget.product['productName']} added to cart!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontFamily: 'Bahnschrift',
                fontVariations: const [
                  FontVariation('wght', 350),
                  FontVariation('wdth', 100),
                ],
              )),
          backgroundColor: MaterialColors.getSurfaceContainer(
              Theme.of(context).brightness == Brightness.dark),
        ),
      );
    } catch (e) {
      return;
    }
  }

  // Adds a listener that detects if an item is added to cart.
  // Used in displaying the number of current items in cart.
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
        isInCart = false;
        var cartItems = 0;
        for (var place in snapshot.docs) {
          if (place.id == widget.placeID) {
            isInCart = true;
          }
          cartItems += place.data().length;
        }
        setState(() {
          this.cartItems = cartItems;
        });
      });
    });
  }

  Future _showOrderOptions() async {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet(
      elevation: 0,
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Buying options",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontFamily: 'Bahnschrift',
                              fontVariations: const [
                                FontVariation('wght', 700),
                                FontVariation('wdth', 100),
                              ],
                              fontSize: 20,
                              letterSpacing: -0.3),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Choose Variant",
                        maxLines: 3,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: 'Bahnschrift',
                            fontVariations: const [
                              FontVariation('wght', 650),
                              FontVariation('wdth', 100),
                            ],
                            fontSize: 14.5,
                            letterSpacing: -0.3,
                            height: 1.3,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        height: 50,
                        child: DropdownButtonFormField(
                          isExpanded: true,
                          elevation: 1,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                  width: 3,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary), //<-- SEE HERE
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                  width: 3,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary), //<-- SEE HERE
                            ),
                          ),
                          value: variant,
                          items: [
                            DropdownMenuItem(
                              value: 'Regular',
                              child: Text(
                                "Regular (₱${widget.product['productPrice'].toString()})",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontFamily: 'Bahnschrift',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                    FontVariation('wdth', 100),
                                  ],
                                  fontSize: 15,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              onTap: () {
                                variant = "Regular";
                              },
                            ),
                          ],
                          onChanged: (value) {
                            value = value;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Set Quantity",
                            maxLines: 3,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Bahnschrift',
                                fontVariations: const [
                                  FontVariation('wght', 650),
                                  FontVariation('wdth', 100),
                                ],
                                fontSize: 14.5,
                                letterSpacing: -0.3,
                                height: 1.3,
                                overflow: TextOverflow.ellipsis),
                          ),
                          Row(children: [
                            Container(
                              color: MaterialColors.getSurfaceContainerLow(
                                  darkMode),
                              width: 32,
                              height: 32,
                              child: IconButton(
                                icon: Icon(
                                  Icons.remove,
                                  color: Theme.of(context).colorScheme.outline,
                                  size: 18,
                                ),
                                onPressed: () {
                                  if (itemQuantity > 1) {
                                    setState(() {
                                      itemQuantity -= 1;
                                    });
                                  }
                                },
                              ),
                            ),
                            Container(
                              color: MaterialColors.getSurfaceContainerLow(
                                  darkMode),
                              width: 40,
                              height: 32,
                              child: Center(
                                child: Text(itemQuantity.toString(),
                                    style: const TextStyle(
                                        fontFamily: 'Bahnschrift',
                                        fontVariations: [
                                          FontVariation('wght', 500),
                                          FontVariation('wdth', 100),
                                        ],
                                        fontSize: 16,
                                        letterSpacing: -0.3),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                            Container(
                              color: MaterialColors.getSurfaceContainerLow(
                                  darkMode),
                              width: 32,
                              height: 32,
                              child: IconButton(
                                icon: Icon(
                                  Icons.add,
                                  color: Theme.of(context).colorScheme.outline,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    itemQuantity += 1;
                                  });
                                },
                              ),
                            )
                          ]),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                addToCart();
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
                                  "Add to Cart",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
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
                      if (widget.product['isAcceptPreorders'] ?? false)
                        const SizedBox(height: 10),
                      if (widget.product['isAcceptPreorders'] ?? false)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      MaterialColors.getSurfaceContainerLow(
                                          darkMode)),
                                  foregroundColor: MaterialStatePropertyAll(
                                      MaterialColors.getSurfaceContainerLow(
                                          darkMode)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    "Pre-Order",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
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
                    ]),
              );
            }),
          ],
        );
      },
    );
  }

  // Initializes page. Retrieves and sets the product information and image first to retrieve the place ID. Place ID is
  // then used to retrieve and set the place information and image.
  @override
  void initState() {
    super.initState();
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
                _showOrderOptions();
                //addToCart();
              },
              icon: Icon(Icons.shopping_cart_outlined,
                  color: Theme.of(context).colorScheme.onPrimary),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              label: Text(
                  isInCart
                      ? "Update cart"
                      : AppLocalizations.of(context)!.addToCart,
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
                imageUrl: widget.product['productImageURL'] ?? '',
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product['productName'],
                              maxLines: 2,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
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
                              "₱${widget.product['productPrice'].toString()}",
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                widget.product['isFavorited'] ?? false
                                    ? Icons.favorite_outlined
                                    : Icons.favorite_outline,
                                size: 24,
                                color: widget.product['isFavorited'] ?? false
                                    ? Colors.redAccent
                                    : Theme.of(context).colorScheme.outline,
                              ),
                              onPressed: () {
                                setFavoriteProduct(
                                    widget.product['isFavorited'] ?? false);
                              },
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "${widget.product['usersFavorited'] != null ? widget.product['usersFavorited'].length : 0}",
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
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.ios_share,
                            size: 24,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          onPressed: () {
                            //TODO: Add functionality to share product.
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.more_vert,
                            size: 24,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          onPressed: () {
                            //TODO: Add functionality to do additional options to the product.
                          },
                        ),
                      ),
                    ]),
                const SizedBox(height: 10),
                Text(
                  widget.product['isLimited'] ?? false
                      ? "${widget.product['ordersRemaining']} orders remaining"
                      : "Available",
                  maxLines: 1,
                  style: TextStyle(
                      color: widget.product['isLimited'] ?? false
                          ? Colors.amber[darkMode ? 400 : 900]
                          : Theme.of(context).colorScheme.primary,
                      fontFamily: 'Bahnschrift',
                      fontVariations: const [
                        FontVariation('wght', 600),
                        FontVariation('wdth', 400),
                      ],
                      fontSize: 13.5,
                      letterSpacing: -0.5,
                      height: 1.1,
                      overflow: TextOverflow.ellipsis),
                ),
                if (widget.product['isAcceptPreorders'] ?? false)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pre-orders available",
                        maxLines: 1,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontFamily: 'Bahnschrift',
                            fontVariations: const [
                              FontVariation('wght', 600),
                              FontVariation('wdth', 100),
                            ],
                            fontSize: 13.5,
                            letterSpacing: -0.3,
                            height: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 5),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.help,
                          size: 13,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        onPressed: () {
                          //TODO: Add pop-up to explain preorders.
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                Divider(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 10),
                Text(
                  "Description",
                  maxLines: 3,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontFamily: 'Bahnschrift',
                      fontVariations: const [
                        FontVariation('wght', 650),
                        FontVariation('wdth', 100),
                      ],
                      fontSize: 14,
                      letterSpacing: -0.3,
                      height: 1.3,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.product['productDesc'] ?? 'No added description',
                  maxLines: 3,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontFamily: 'Bahnschrift',
                      fontVariations: const [
                        FontVariation('wght', 350),
                        FontVariation('wdth', 100),
                      ],
                      fontSize: 13.5,
                      letterSpacing: -0.5,
                      height: 1.1,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      //<-- SEE HERE
                      side: BorderSide(
                        color:
                            MaterialColors.getSurfaceContainerHighest(darkMode),
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
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
                                    color:
                                        Theme.of(context).colorScheme.outline,
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          )
        ],
      ),
    );
  }
}
