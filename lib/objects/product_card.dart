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
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: MaterialColors.getSurfaceContainerLowest(darkMode),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
      shape: RoundedRectangleBorder(
          side: BorderSide(
            color: MaterialColors.getSurfaceContainerHighest(darkMode),
          ),
          borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: () {
          if (context.mounted) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProductPage(widget.productID,
                    widget.product, widget.placeID, widget.place,
                    setFavoriteProductCallback: setFavoriteProduct)));
          }
        },
        child: SizedBox(
          height: 195,
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
                                Theme.of(context).colorScheme.outlineVariant),
                      ),
                      fadeInCurve: Curves.easeIn,
                      fadeOutCurve: Curves.easeOut,
                    ),
                  ),
                ),
                if (widget.product['isFeatured'] ?? false)
                  Positioned(
                    left: 7,
                    top: 0,
                    child: Icon(Icons.bookmark,
                        size: 30, color: Colors.orange[700]),
                  ),
                if (widget.product['isFeatured'] ?? false)
                  const Positioned(
                    left: 7,
                    top: -5,
                    child: Icon(Icons.bookmark,
                        size: 30, color: Colors.orangeAccent),
                  ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Container(
                      height: 30,
                      width: 30,
                      color: (widget.product['productImageURL'] == null)
                          ? Colors.transparent
                          : const Color.fromARGB(120, 0, 0, 0),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          widget.product['isFavorited'] ?? false
                              ? Icons.favorite_outlined
                              : Icons.favorite_outline,
                          size: 22,
                          color: widget.product['isFavorited'] ?? false
                              ? Colors.redAccent
                              : (widget.product['productImageURL'] == null)
                                  ? Theme.of(context).colorScheme.outline
                                  : Colors.white,
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
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 15,
                      child: Text(
                        widget.product['productName'],
                        maxLines: 1,
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontFamily: 'Plus Jakarta Sans',
                            fontVariations: const [
                              FontVariation('wght', 700),
                            ],
                            fontSize: 12,
                            letterSpacing: -0.3,
                            height: 0.85,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    Text(
                      '₱${widget.product['productPrice']}',
                      style: TextStyle(
                          color: ChimeColors.getGreen800(),
                          fontFamily: 'Plus Jakarta Sans',
                          fontVariations: const [
                            FontVariation('wght', 700),
                          ],
                          fontSize: 16,
                          height: 0.85,
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
