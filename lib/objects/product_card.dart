/*
  [Title]
  ProductCard

  [Description]
  A ProductCard is an object that contains the product's id, name, price, and the place it belongs to.
  May be tapped to direct the user to a ProductPage of that product. 
  Created when visiting ProductsPage. Each product in the database has its own ProductsPage.
*/

part of '../main.dart';

// ignore: must_be_immutable
class ProductCard extends StatefulWidget {
  String productID, placeID;
  Map product, place;

  ProductCard(this.productID, this.product, this.placeID, this.place,
      {super.key, this.setFavoriteProductCallback});

  final Function(String productID, bool state)? setFavoriteProductCallback;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  void setFavoriteProduct(bool isFavorited) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      if (isFavorited) {
        db.collection("users").doc(uid).update({
          "favoriteProducts": FieldValue.arrayRemove([widget.productID])
        });
        db.collection("products").doc(widget.productID).update({
          "usersFavorited": FieldValue.arrayRemove([uid])
        });
        widget.product['usersFavorited'].remove(uid);
      } else {
        db.collection("users").doc(uid).update({
          "favoriteProducts": FieldValue.arrayUnion([widget.productID])
        });
        db.collection("products").doc(widget.productID).update({
          "usersFavorited": FieldValue.arrayUnion([uid])
        });
        widget.product['usersFavorited'].add(uid);
      }
      if (widget.setFavoriteProductCallback != null) {
        widget.setFavoriteProductCallback!(widget.productID, !isFavorited);
      }
      if (mounted) {
        setState(() {
          widget.product['isFavorited'] = !isFavorited;
        });
      }
    } catch (e) {
      return;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          if (context.mounted) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProductsMorePage(widget.productID,
                    widget.product, widget.placeID, widget.place,
                    setFavoriteProductCallback: setFavoriteProduct)));
          }
        },
        child: SizedBox(
          height: 196,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(children: [
                SizedBox(
                  width: 200,
                  height: 120,
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
                            color:
                                Theme.of(context).colorScheme.outline),
                      ),
                      fadeInCurve: Curves.easeIn,
                      fadeOutCurve: Curves.easeOut,
                    ),
                  ),
                ),
                if (widget.product['isFeatured'] ?? false)
                  Positioned(
                      left: 4,
                      top: 4,
                      child: Card(
                            elevation: 0,
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.85),
                        shape: RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: 
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                          child: 
                            Center(
                              child: Text(
                                "Featured",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                      
                        ),
                      )
                      ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: Container(
                      height: 32,
                      width: 32,
                      color: (widget.product['productImageURL'] == null)
                          ? Colors.transparent
                          : Theme.of(context).colorScheme.surfaceVariant.withOpacity(.85),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          widget.product['isFavorited'] ?? false
                              ? Icons.favorite_outlined
                              : Icons.favorite_outline,
                          size: 24,
                          color: widget.product['isFavorited'] ?? false
                              ? Theme.of(context).colorScheme.error
                              : (widget.product['productImageURL'] == null)
                                  ? Theme.of(context).colorScheme.outline
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                        ),
                        onPressed: () {
                          setFavoriteProduct(
                              widget.product['isFavorited'] ?? false);
                        },
                      ),
                    ),
                  ),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                      child: Text(
                        widget.product['productName'] ?? "",
                        maxLines: 1,
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontFamily: 'Manrope',
                            fontVariations: const [
                              FontVariation('wght', 700),
                            ],
                            fontSize: 14,
                            letterSpacing: -0.3,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    Text(
                      '₱${widget.product['productPrice'] ?? 0}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontFamily: 'Manrope',
                          fontVariations: const [
                            FontVariation('wght', 700),
                          ],
                          fontSize: 16,
                          letterSpacing: -0.3),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
