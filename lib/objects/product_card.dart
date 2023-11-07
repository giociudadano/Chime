/*
  [Title]
  ProductCard

  [Description]
  A ProductCard is an object that contains the product's id, name, price, and the place it belongs to.
  May be tapped to direct the user to a ProductPage of that product. 
  Created when visiting ProductsPage. Each product in the database has its own ProductsPage.
*/

part of main;

// ignore: must_be_immutable
class ProductCard extends StatefulWidget {
  String productID;
  Map product;

  ProductCard(this.productID, this.product, {super.key});

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
      } else {
        db.collection("users").doc(uid).update({
          "favoriteProducts": FieldValue.arrayUnion([widget.productID])
        });
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
      color: MaterialColors.getSurfaceContainerLow(darkMode),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
      child: InkWell(
        onTap: () {
          if (context.mounted) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProductPage(widget.productID)));
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
                    )),
                Positioned(
                    right: 5,
                    top: 5,
                    child: IconButton(
                      icon: Icon(
                        widget.product['isFavorited'] ?? false
                            ? Icons.favorite_outlined
                            : Icons.favorite_outline,
                        size: 24,
                        color: widget.product['isFavorited'] ?? false
                            ? Colors.redAccent
                            : Colors.white,
                      ),
                      onPressed: () {
                        setFavoriteProduct(
                            widget.product['isFavorited'] ?? false);
                      },
                    ))
              ]),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 25,
                      child: Text(
                        widget.product['productName'],
                        maxLines: 2,
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontFamily: 'Bahnschrift',
                            fontVariations: const [
                              FontVariation('wght', 550),
                              FontVariation('wdth', 100),
                            ],
                            fontSize: 13,
                            letterSpacing: -0.3,
                            height: 0.85,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    Text(
                      '₱${widget.product['productPrice']}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontFamily: 'Bahnschrift',
                          fontVariations: const [
                            FontVariation('wght', 700),
                            FontVariation('wdth', 100),
                          ],
                          fontSize: 24,
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
