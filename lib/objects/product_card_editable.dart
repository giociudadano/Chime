part of main;

// ignore: must_be_immutable
class ProductCardEditable extends StatefulWidget {
  ProductCardEditable(this.productID, this.product,
      {super.key, this.setFeaturedProductCallback, this.deleteProductCallback});

  String productID;
  Map product = {};

  final Function(String productID, bool state)? setFeaturedProductCallback;
  final Function(String productID)? deleteProductCallback;

  @override
  State<ProductCardEditable> createState() => _ProductCardEditableState();
}

class _ProductCardEditableState extends State<ProductCardEditable> {
  bool isFeatured = false;

  void setFeaturedProduct(String productID) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("products").doc(productID).update({
      "categories": isFeatured
          ? FieldValue.arrayRemove(['Featured'])
          : FieldValue.arrayUnion(['Featured'])
    });
    db.collection("places").doc(widget.product['placeID']).update({
      "categories.Featured": isFeatured
          ? FieldValue.arrayRemove([productID])
          : FieldValue.arrayUnion([productID])
    });
    widget.setFeaturedProductCallback!(productID, !isFeatured);
  }

  void editProduct(String name, String price) {
    widget.product['productName'] = name;
    widget.product['productPrice'] = int.parse(price);
    if (mounted) {
      setState(() {});
    }
  }

  void deleteProduct(String productID) {
    widget.deleteProductCallback!(productID);
  }

  @override
  void initState() {
    List categories = widget.product['categories'] ?? [];
    isFeatured = categories.contains('Featured');
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
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => StoreProductsEditPage(
                      widget.productID, widget.product,
                      editProductCallback: editProduct,
                      deleteProductCallback: deleteProduct)),
            );
          }
        },
        child: SizedBox(
          height: 220,
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
                        isFeatured ? Icons.bookmark : Icons.bookmark_outline,
                        size: 30,
                        color: isFeatured ? Colors.orangeAccent : Colors.white,
                      ),
                      onPressed: () {
                        setFeaturedProduct(widget.productID);
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
