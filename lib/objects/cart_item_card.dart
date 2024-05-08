/*
  [Title]
  OrderItemCard

  [Description]
  An OrderItemCard is an object containing a product's URL, name, price, and quantity to be ordered.
  Contains additional options to modify quantity and remove from cart.
  Image may be tapped to view the ProductPage of that product.
  Created when OrderCard is called. Each product belonging to a place has its own OrderItemCard.
*/

part of '../main.dart';

// ignore: must_be_immutable
class CartItemCard extends StatefulWidget {
  CartItemCard(this.placeID, this.productID, this.item,
      {super.key, this.deleteFrame, this.updateTotal});
  String placeID, productID;
  Map item;
  bool isVisible = true;

  // Variable callbacks used in updating OrderCard.
  final VoidCallback? deleteFrame;
  final Function(int delta)? updateTotal;

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
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
          widget.item['productImageURL'] = url;
        });
      }
    }
  }

  Future getProduct(String productID) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Map product = {};
    await db.collection("products").doc(productID).get().then((document) async {
      product = document.data()!;
      product['productImageURL'] = widget.item['productImageURL'];
    });
    return product;
  }

  Future getPlace(String placeID) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Map place = {};
    await db.collection("places").doc(placeID).get().then((document) async {
      place = document.data()!;
    });
    return place;
  }

  // Updates the item's quantity in database when the amount is modified.
  // Uses a debounce variable to prevent successive calls.
  void setProductQuantityAtDatabase() {
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
            .update({"${widget.productID}.quantity": widget.item['quantity']});
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
    widget.updateTotal!(-(widget.item['price'] * widget.item['quantity']));
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
        widget.deleteFrame!();
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
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVisible) {
      return Card(
        color: Theme.of(context).colorScheme.surface,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    onPressed: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Remove this item',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 16,
                              letterSpacing: -0.3,
                            )),
                        content: const Text(
                            'You can add it again later if you change your mind.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'Cancel');
                            },
                            child: const Text('Cancel',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 16,
                                  letterSpacing: -0.3,
                                )),
                          ),
                          TextButton(
                            onPressed: () {
                              removeProductFromCart();
                              Navigator.pop(context, 'OK');
                              final snackBar = SnackBar(
                                content: const Text(
                                    'Item has been removed from cart.'),
                              );

                              // Find the ScaffoldMessenger in the widget tree
                              // and use it to show a SnackBar.
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                            child: const Text('OK',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 16,
                                  letterSpacing: -0.3,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () async {
                            Map product = await getProduct(widget.productID);
                            Map place = await getPlace(widget.placeID);
                            if (context.mounted) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ProductsMorePage(
                                      widget.productID,
                                      product,
                                      widget.placeID,
                                      place)));
                            }
                          },
                          child: SizedBox(
                              width: 85,
                              height: 85,
                              child: FittedBox(
                                clipBehavior: Clip.hardEdge,
                                fit: BoxFit.cover,
                                child: CachedNetworkImage(
                                  imageUrl:
                                      widget.item['productImageURL'] ?? '',
                                  placeholder: (context, url) => const Padding(
                                    padding: EdgeInsets.all(40.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => Padding(
                                    padding: const EdgeInsets.all(40.0),
                                    child: Icon(Icons.local_mall_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant),
                                  ),
                                  fadeInCurve: Curves.easeIn,
                                  fadeOutCurve: Curves.easeOut,
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item['name'],
                          maxLines: 2,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 16,
                            letterSpacing: -0.1,
                          ),
                        ),
                        Text(
                          '₱${widget.item['price']}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontFamily: 'Manrope',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 16,
                              letterSpacing: -0.3),
                        ),
                        if (widget.item['variant'] != null)
                          Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                "Variant: ${widget.item['variant']}",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontFamily: 'Source Sans 3',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                  ],
                                  fontSize: 14,
                                  height: 0.85,
                                  letterSpacing: -0.1,
                                ),
                              )),
                        const SizedBox(height: 10),
                        Row(
                          children: [
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
                                  color: Theme.of(context).colorScheme.outline,
                                  size: 16,
                                ),
                                onPressed: () {
                                  if (widget.item['quantity'] > 1) {
                                    setProductQuantityAtDatabase();
                                    widget.updateTotal!(-widget.item['price']);
                                    setState(() {
                                      widget.item['quantity'] -= 1;
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant),
                                  vertical: BorderSide.none,
                                ),
                              ),
                              width: 40,
                              height: 28,
                              child: Center(
                                child: Text(widget.item['quantity'].toString(),
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
                                  if (widget.item['quantity'] <=
                                      (widget.item['ordersRemaining'] != null
                                          ? widget.item['ordersRemaining'] - 1
                                          : 99)) {
                                    setProductQuantityAtDatabase();
                                    widget.updateTotal!(widget.item['price']);
                                    setState(() {
                                      widget.item['quantity'] += 1;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 15),
                            if (widget.item['isLimited'] ?? false)
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      child: Text(
                                        "Stock",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontFamily: 'Source Sans 3',
                                          fontVariations: const [
                                            FontVariation('wght', 400),
                                          ],
                                          fontSize: 14,
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "${widget.item['ordersRemaining']}",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontFamily: 'Source Sans 3',
                                        fontVariations: const [
                                          FontVariation('wght', 400),
                                        ],
                                        fontSize: 14,
                                        // height: 1.7,
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                  ]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
