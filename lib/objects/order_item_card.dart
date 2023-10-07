/*
  [Title]
  OrderItemCard

  [Description]
  An OrderItemCard is an object containing a product's URL, name, price, and quantity to be ordered.
  Contains additional options to modify quantity and remove from cart.
  Image may be tapped to view the ProductPage of that product.
  Created when OrderCard is called. Each product belonging to a place has its own OrderItemCard.
*/

part of main;

// ignore: must_be_immutable
class OrderItemCard extends StatefulWidget {
  OrderItemCard(this._deleteFrame,
      {super.key,
      required this.placeID,
      required this.productID,
      required this.quantity});
  String placeID, productID, productImageURL = '', productName = '';
  int quantity, productPrice = 0;
  bool isVisible = true;
  final VoidCallback _deleteFrame;

  @override
  State<OrderItemCard> createState() => _OrderItemCardState();
}

class _OrderItemCardState extends State<OrderItemCard> {
  // Variable for debouncing. Used when modifying item quantity to prevent numerous database calls.
  Timer? _debounce;

  // Fetches and sets the product's image.
  void getProductImageURL() async {
    String url = '';
    String ref = "products/${widget.productID}.jpg";
    try {
      url = await FirebaseStorage.instance.ref(ref).getDownloadURL();
    } catch (e) {
      //
    } finally {
      if (mounted) {
        setState(() {
          widget.productImageURL = url;
        });
      }
    }
  }

  // Fetches and gets the product name and price.
  void getProductInfo() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection("products")
        .doc(widget.productID)
        .get()
        .then((document) {
      if (document.exists) {
        if (mounted) {
          setState(() {
            widget.productName = document.data()!['productName'];
            widget.productPrice = document.data()!['productPrice'];
          });
        }
      }
    });
  }

  // Updates the item's quantity in database when the amount is modified.
  // Uses a debounce variable to prevent successive calls.
  void updateItemQuantityDebounce() {
    if (_debounce != null) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 800), () {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      try {
        FirebaseFirestore db = FirebaseFirestore.instance;
        db
            .collection("users")
            .doc(uid)
            .collection("cart")
            .doc(widget.placeID)
            .set({widget.productID: widget.quantity}, SetOptions(merge: true));
      } catch (e) {
        return;
      }
    });
  }

  // Removes the product from the database.
  // If the product is the last product from a place, the place collection from is also removed from the cart.
  void removeProductFromCart() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    db
        .collection("users")
        .doc(uid)
        .collection("cart")
        .doc(widget.placeID)
        .update({
      widget.productID: FieldValue.delete(),
    });

    setState(() {
      widget.isVisible = false;
    });

    db
        .collection("users")
        .doc(uid)
        .collection("cart")
        .doc(widget.placeID)
        .get()
        .then((snapshot) {
      if (snapshot.data()!.isEmpty) {
        widget._deleteFrame();
        db
            .collection("users")
            .doc(uid)
            .collection("cart")
            .doc(widget.placeID)
            .delete();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getProductImageURL();
    getProductInfo();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    if (widget.isVisible) {
      return Card(
        color: MaterialColors.getSurfaceContainerLowest(darkMode),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    if (context.mounted) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProductPage(widget.productID)));
                    }
                  },
                  child: SizedBox(
                      width: 80,
                      height: 80,
                      child: FittedBox(
                        clipBehavior: Clip.hardEdge,
                        fit: BoxFit.cover,
                        child: CachedNetworkImage(
                          imageUrl: widget.productImageURL,
                          placeholder: (context, url) => const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Icon(Icons.local_mall_outlined,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant),
                          ),
                          fadeInCurve: Curves.easeIn,
                          fadeOutCurve: Curves.easeOut,
                        ),
                      )),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      widget.productName,
                      maxLines: 2,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: 'Bahnschrift',
                          fontVariations: const [
                            FontVariation('wght', 500),
                            FontVariation('wdth', 100),
                          ],
                          fontSize: 13,
                          letterSpacing: -0.3,
                          height: 0.85,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text(
                      '₱${widget.productPrice}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontFamily: 'Bahnschrift',
                          fontVariations: const [
                            FontVariation('wght', 700),
                            FontVariation('wdth', 100),
                          ],
                          fontSize: 15,
                          letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          color:
                              MaterialColors.getSurfaceContainerLow(darkMode),
                          width: 32,
                          height: 32,
                          child: IconButton(
                            icon: Icon(
                              Icons.remove,
                              color: Theme.of(context).colorScheme.outline,
                              size: 18,
                            ),
                            onPressed: () {
                              if (widget.quantity > 1) {
                                updateItemQuantityDebounce();
                                setState(() {
                                  widget.quantity -= 1;
                                });
                              }
                            },
                          ),
                        ),
                        Container(
                          color:
                              MaterialColors.getSurfaceContainerLow(darkMode),
                          width: 40,
                          height: 32,
                          child: Center(
                            child: Text(widget.quantity.toString(),
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
                          color:
                              MaterialColors.getSurfaceContainerLow(darkMode),
                          width: 32,
                          height: 32,
                          child: IconButton(
                            icon: Icon(
                              Icons.add,
                              color: Theme.of(context).colorScheme.outline,
                              size: 18,
                            ),
                            onPressed: () {
                              updateItemQuantityDebounce();
                              setState(() {
                                widget.quantity += 1;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 25,
                width: 25,
                child: IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  onPressed: () {
                    removeProductFromCart();
                  },
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
