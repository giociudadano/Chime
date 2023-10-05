part of main;

// ignore: must_be_immutable
class ProductCard extends StatefulWidget {
  ProductCard(
      {super.key,
      required this.productID,
      required this.productName,
      required this.placeName,
      required this.productPrice});
  String productName, productImageURL = '', placeName, productID;
  int productPrice;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
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

  @override
  void initState() {
    super.initState();
    getProductImageURL();
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
          height: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: 200,
                  height: 120,
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
                            color:
                                Theme.of(context).colorScheme.outlineVariant),
                      ),
                      fadeInCurve: Curves.easeIn,
                      fadeOutCurve: Curves.easeOut,
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 25,
                      child: Text(
                        widget.productName,
                        maxLines: 2,
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
                    Text(
                      widget.placeName,
                      maxLines: 1,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontFamily: 'Bahnschrift',
                          fontVariations: const [
                            FontVariation('wght', 400),
                            FontVariation('wdth', 100),
                          ],
                          fontSize: 11,
                          letterSpacing: -0.3,
                          overflow: TextOverflow.ellipsis),
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
