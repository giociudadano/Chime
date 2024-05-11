/*
  [Title]
  ProductPage

  [Description]
  Displays information about a product, its image, price, and description.
  Contains options to modify quantity to be ordered and to add the product to cart or favorites.
  Visited when clicking on a ProductCard from ProductsPage.
*/

part of '../../main.dart';

// The 'Product' page displays additional information about a product.
// This page is visited when the user clicks on a product from the 'Products' page.
// ignore: must_be_immutable
class ProductsMorePage extends StatefulWidget {
  // Variables for product information.
  String productID, placeID;
  Map product, place;

  ProductsMorePage(this.productID, this.product, this.placeID, this.place,
      {super.key, this.setFavoriteProductCallback});
  final Function(bool state)? setFavoriteProductCallback;

  @override
  State<ProductsMorePage> createState() => _ProductsMorePageState();
}

class _ProductsMorePageState extends State<ProductsMorePage> {
  StreamSubscription? cartListener;
  int cartItems = 0;
  int itemQuantity = 1;
  bool isInCart = false;

  List variants = [];
  int selectedVariantIndex = 0;

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
          "price": variants[selectedVariantIndex]['price'],
          "isLimited": variants[selectedVariantIndex]['isLimited'] ?? false,
          if (variants[selectedVariantIndex]['isLimited'] ?? false)
            "ordersRemaining": variants[selectedVariantIndex]
                ['ordersRemaining'],
          if (selectedVariantIndex != 0)
            "variant": variants[selectedVariantIndex]['name']
        }
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              isInCart
                  ? "${widget.product['productName']} updated in cart!"
                  : "${widget.product['productName']} added to cart!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontFamily: 'Source Sans 3',
                fontVariations: const [
                  FontVariation('wght', 400),
                ],
              )),
          ),
          backgroundColor: MaterialColors.getSurfaceContainerHighest(
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
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Options",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 20,
                                  letterSpacing: -0.3),
                            ),
                            IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 24,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          ]),
                      const SizedBox(height: 20),
                      Text(
                        "Variant",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontFamily: 'Manrope',
                          fontVariations: const [
                            FontVariation('wght', 700),
                          ],
                          fontSize: 16,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 52,
                        child: DropdownButtonFormField(
                          iconSize: 0,
                          isExpanded: true,
                          elevation: 1,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                  width: 1,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline), //<-- SEE HERE
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                  width: 1,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline), //<-- SEE HERE
                            ),
                          ),
                          value: selectedVariantIndex,
                          items: List.generate(
                            variants.length,
                            (index) => DropdownMenuItem(
                              value: index,
                              child: Text(
                                "${variants[index]['name']} (₱${variants[index]['price'].toString()})",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontFamily: 'Source Sans 3',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                  ],
                                  fontSize: 16,
                                  height: 1,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              onTap: () {
                                selectedVariantIndex = index;
                                setState(() {});
                              },
                            ),
                          ),
                          onChanged: (value) {
                            value = value;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              "Quantity",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 16,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          Row(children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(0),
                                  border: Border.all(
                                      width: 1,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant)),
                              width: 28,
                              height: 28,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.remove,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: 16,
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
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(0),
                                  border: Border.symmetric(
                                            horizontal: BorderSide(
                                              width: 1,
                                              color: Theme.of(context).colorScheme.outlineVariant
                                            ),
                                            vertical: BorderSide.none,
                                          ),),
                              width: 40,
                              height: 28,
                              child: Center(
                                child: Text(itemQuantity.toString(),
                                    style: const TextStyle(
                                        fontFamily: 'Source Sans 3',
                                        fontVariations: [
                                          FontVariation('wght', 400),
                                        ],
                                        fontSize: 16,
                                        letterSpacing: -0.3),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(0),
                                  border: Border.all(
                                      width: 1,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant)),
                              width: 28,
                              height: 28,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.add,
                                  color: Theme.of(context).colorScheme.outline,
                                  size: 16,
                                ),
                                onPressed: () {
                                  // If product is not limited or it is and the current > remaining
                                  if (variants[selectedVariantIndex]
                                          ['isLimited'] ==
                                      false) {
                                    setState(() {
                                      itemQuantity += 1;
                                    });
                                  } else {
                                    if (itemQuantity <=
                                        variants[selectedVariantIndex]
                                                ['ordersRemaining'] -
                                            1) {
                                      setState(() {
                                        itemQuantity += 1;
                                      });
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 30),

                            // If the product is limited, show the number of stocks.
                            if (variants[selectedVariantIndex]['isLimited'] ??
                                false)
                              Row(children: [
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    "Stock",
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      fontFamily: 'Manrope',
                                      fontVariations: const [
                                        FontVariation('wght', 700),
                                      ],
                                      fontSize: 16,
                                      height: 1,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${variants[selectedVariantIndex]['ordersRemaining']}",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontFamily: 'Source Sans 3',
                                    fontVariations: const [
                                      FontVariation('wght', 400),
                                    ],
                                    fontSize: 16,
                                    letterSpacing: -0.3,
                                    height: 1,
                                  ),
                                ),
                              ]),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 50),
                      Row(
                        children: [
                          // If the product is accepting pre-orders, add a pre-order button.
                          if (widget.product['isAcceptPreorders'] ?? false)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    //TODO: Create functionality to accept pre-orders.
                                    throw UnimplementedError();
                                  },
                                  style: ButtonStyle(
                                    elevation:
                                        const MaterialStatePropertyAll(0),
                                    backgroundColor: MaterialStatePropertyAll(
                                        MaterialColors
                                            .getSurfaceContainerLowest(
                                                darkMode)),
                                    shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: ChimeColors.getGreen300(),
                                      ),
                                    )),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      "Pre-order",
                                      style: TextStyle(
                                        color: ChimeColors.getGreen800(),
                                        fontFamily: 'Manrope',
                                        fontVariations: const [
                                          FontVariation('wght', 700),
                                        ],
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                addToCart();
                                Navigator.pop(context);
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      Theme.of(context).colorScheme.primary),
                                  shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide.none,
                                  ))),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  "Add to Cart",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontFamily: 'Manrope',
                                    fontVariations: const [
                                      FontVariation('wght', 700),
                                    ],
                                    fontSize: 14,
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
    variants.add({
      "name": widget.product['variantName'] ?? widget.product['productName'],
      "price": widget.product['productPrice'],
      "isLimited": widget.product['isLimited'],
      "ordersRemaining": widget.product['ordersRemaining'],
    });
    variants.addAll(widget.product['variants'] ?? []);
    addCartListener();
  }

  @override
  void dispose() {
    cartListener!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 6, 6),
            child: Ink(
              decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.35),
                shape: const CircleBorder(),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.outline),
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
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.35),
                  shape: const CircleBorder(),
                ),
                child: Stack(children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart_outlined,
                        color: Theme.of(context).colorScheme.primary),
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
            ),
          ]),
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: SizedBox(
        height: 50,
        child: FittedBox(
          child: FloatingActionButton.extended(
              onPressed: () {
                _showOrderOptions();
                //addToCart();
              },
              icon: Icon(Icons.shopping_cart_outlined,
                  color: Theme.of(context).colorScheme.onPrimary, size: 24),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              label: Text(
                  isInCart
                      ? "Update Cart"
                      : AppLocalizations.of(context)!.addToCart,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontFamily: 'Manrope',
                    fontVariations: const [
                      FontVariation('wght', 700),
                    ],
                    fontSize: 16,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 16,
                                  letterSpacing: -0.3,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "₱${widget.product['productPrice'].toString()}",
                              maxLines: 1,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 20,
                                  letterSpacing: -0.3,
                                  height: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
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
                                      color:
                                          widget.product['isFavorited'] ?? false
                                              ? Theme.of(context).colorScheme.error
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                    ),
                                    onPressed: () {
                                      setFavoriteProduct(
                                          widget.product['isFavorited'] ??
                                              false);
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${widget.product['usersFavorited'] != null ? widget.product['usersFavorited'].length : 0}",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontFamily: 'Source Sans 3',
                                      fontVariations: const [
                                        FontVariation('wght', 400),
                                      ],
                                      fontSize: 16,
                                      letterSpacing: -0.3,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.only(left: 15),
                            //   child: IconButton(
                            //     constraints: const BoxConstraints(),
                            //     padding: EdgeInsets.zero,
                            //     icon: Icon(
                            //       Icons.ios_share,
                            //       size: 24,
                            //       color: Theme.of(context)
                            //           .colorScheme
                            //           .onSurfaceVariant,
                            //     ),
                            //     onPressed: () {
                            //       //TODO: Add functionality to share product.
                            //     },
                            //   ),
                            // ),
                            // Padding(
                            //   padding: const EdgeInsets.only(left: 15),
                            //   child: IconButton(
                            //     constraints: const BoxConstraints(),
                            //     padding: EdgeInsets.zero,
                            //     icon: Icon(
                            //       Icons.more_vert,
                            //       size: 24,
                            //       color: Theme.of(context)
                            //           .colorScheme
                            //           .onSurfaceVariant,
                            //     ),
                            //     onPressed: () {
                            //       //TODO: Add functionality to do additional options to the product.
                            //     },
                            //   ),
                            // ),
                          ])
                    ]),
                const SizedBox(height: 20),

                // // If accepting pre-orders, display pre-orders available.
                // if (widget.product['isAcceptPreorders'] ?? false)
                //   Column(children: [
                //     Row(
                //       children: [
                //         Icon(
                //           Icons.schedule,
                //           size: 16,
                //           color: ChimeColors.getGreen800(),
                //         ),
                //         const SizedBox(width: 10),
                //         Text(
                //           "Pre-Orders Available",
                //           style: TextStyle(
                //             color: ChimeColors.getGreen800(),
                //             fontFamily: 'Source Sans 3',
                //             fontVariations: const [
                //               FontVariation('wght', 400),
                //             ],
                //             fontSize: 14,
                //             letterSpacing: -0.3,
                //             height: 1,
                //           ),
                //         ),
                //       ],
                //     ),
                //     const SizedBox(height: 10),
                //   ]),

                // If the product is limited, displays the number of stocks remaining.
                if (widget.product['isLimited'] ?? false)
                  Column(children: [
                    Row(children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "Stock",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 14,
                            letterSpacing: -0.3,
                            height: 1,
                          ),
                        ),
                      ),
                      Text(
                        "${widget.product['ordersRemaining']}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: 'Source Sans 3',
                          fontVariations: const [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3,
                          height: 1,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                  ]),

                // If there is a description, display the description.
                if (widget.product['productDesc'] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Description",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontFamily: 'Manrope',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 16,
                              letterSpacing: -0.3,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.product['productDesc'],
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 16,
                              letterSpacing: -0.1,
                              height: 1.2,
                            ),
                          ),
                        ]),
                  ),

                if (widget.product['variants'] != null &&
                    widget.product['variants'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Variants",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontFamily: 'Manrope',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 16,
                              letterSpacing: -0.3,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InlineChoice<int>.single(
                            clearable: false,
                            value: selectedVariantIndex,
                            onChanged: (value) {
                              setState(() {
                                selectedVariantIndex = value ?? 0;
                              });
                            },
                            itemCount: variants.length,
                            itemBuilder: (selection, i) {
                              return ChoiceChip(
                                selected: selection.selected(i),
                                onSelected: selection.onSelected(i),
                                label: Text(
                                  variants[i]['name'],
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontFamily: 'Source Sans 3',
                                    fontVariations: const [
                                      FontVariation('wght', 400),
                                    ],
                                    fontSize: 16,
                                    letterSpacing: -0.3,
                                    height: 1,
                                  ),
                                ),
                              );
                            },
                            listBuilder: ChoiceList.createScrollable(
                              spacing: 10,
                            ),
                          )
                        ]),
                  ),

                const SizedBox(height: 10),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  shape: RoundedRectangleBorder(
                      side: BorderSide.none,
                      borderRadius: BorderRadius.circular(12.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 50,
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
                                      size: 24,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant),
                                ),
                                fadeInCurve: Curves.easeIn,
                                fadeOutCurve: Curves.easeOut,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sold by',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontFamily: 'Source Sans 3',
                                    fontVariations: const [
                                      FontVariation('wght', 400),
                                    ],
                                    fontSize: 16,
                                    letterSpacing: -0.1,
                                    height: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Text(
                                widget.place['placeName'],
                                maxLines: 1,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontFamily: 'Manrope',
                                    fontVariations: const [
                                      FontVariation('wght', 700),
                                    ],
                                    fontSize: 16,
                                    letterSpacing: -0.3,
                                    height: 1,
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
