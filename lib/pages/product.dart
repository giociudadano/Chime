part of main;

// The 'Product' page displays additional information about a product.
// This page is visited when the user clicks on a product from the 'Products' page.
// ignore: must_be_immutable
class ProductPage extends StatefulWidget {
  String productID;
  String productName = '',
      productDesc = '',
      productImageURL = '',
      placeID = '',
      placeName = '',
      placeImageURL = '';
  int productPrice = 0;
  ProductPage(this.productID, {super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // Retrieves and sets product information from FirebaseDB given the product ID of the page.
  getProductInfo() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection("products")
        .doc(widget.productID)
        .get()
        .then((document) {
      if (document.exists) {
        setState(() {
          widget.productName = document.data()!['productName'] ?? '';
          widget.productDesc = document.data()!['productDesc'] ?? '';
          widget.productPrice = document.data()!['productPrice'] ?? 0;
          widget.placeID = document.data()!['placeID'] ?? '';
        });
      }
    });
  }

  // Retrieves and sets the product image from FirebaseStorage given the product ID of the page.
  getProductImageURL() async {
    await getProductInfo();
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

  // Retrieves and sets the place information given the place ID of the page.
  // Place ID is retrieved when obtaining product information.
  getPlaceInfo() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("places").doc(widget.placeID).get().then((document) {
      if (document.exists) {
        setState(() {
          widget.placeName = document.data()!['placeName'] ?? '';
        });
      }
    });
  }

  // Retrieves and sets the place image given the place ID of the page.
  // Place ID is retrieved when obtaining product information.
  getPlaceImageURL() async {
    await getProductInfo();
    String url = '';
    String ref = "places/${widget.placeID}.jpg";
    try {
      url = await FirebaseStorage.instance.ref(ref).getDownloadURL();
    } catch (e) {
      //
    } finally {
      if (mounted) {
        setState(() {
          widget.placeImageURL = url;
        });
      }
    }
  }

  // Initializes page. Retrieves and sets the product information and image first to retrieve the place ID. Place ID is
  // then used to retrieve and set the place information and image.
  @override
  void initState() {
    super.initState();

    void initProduct() async {
      await getProductInfo();
      await getProductImageURL();
      await getPlaceInfo();
      await getPlaceImageURL();
    }

    initProduct();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.outline),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
      body: ListView(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 300,
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
                      color: Theme.of(context).colorScheme.outlineVariant),
                ),
                fadeInCurve: Curves.easeIn,
                fadeOutCurve: Curves.easeOut,
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.productName,
                                maxLines: 2,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
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
                                "₱${widget.productPrice.toString()}",
                                maxLines: 2,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
                            child: IconButton(
                              icon: Icon(
                                Icons.favorite_outline,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              onPressed: () {
                                //TODO - Favorite/Unfavorite Product Functionality
                              },
                            ))
                      ]),
                  const SizedBox(height: 20),
                  widget.productDesc != ''
                      ? Text(
                          widget.productDesc,
                          maxLines: 3,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontFamily: 'Bahnschrift',
                              fontVariations: const [
                                FontVariation('wght', 300),
                                FontVariation('wdth', 100),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.3,
                              height: 0.9,
                              overflow: TextOverflow.ellipsis),
                        )
                      : const SizedBox.shrink(),
                  if (widget.productDesc != '') const SizedBox(height: 20),
                  Card(
                    color: MaterialColors.getSurfaceContainerLow(darkMode),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 0,
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: SizedBox(
                      height: 70,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 70,
                            child: FittedBox(
                              clipBehavior: Clip.hardEdge,
                              fit: BoxFit.cover,
                              child: CachedNetworkImage(
                                imageUrl: widget.placeImageURL,
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
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      child: Text(
                                    AppLocalizations.of(context)!.productSoldBy,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        fontFamily: 'Bahnschrift',
                                        fontVariations: const [
                                          FontVariation('wght', 500),
                                          FontVariation('wdth', 100),
                                        ],
                                        height: 0.9,
                                        fontSize: 13,
                                        letterSpacing: -0.3,
                                        overflow: TextOverflow.ellipsis),
                                  )),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    child: Text(
                                      widget.placeName,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontFamily: 'Bahnschrift',
                                          fontVariations: const [
                                            FontVariation('wght', 700),
                                            FontVariation('wdth', 100),
                                          ],
                                          fontSize: 15,
                                          letterSpacing: -0.3,
                                          height: 0.9,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ))
        ],
      ),
    );
  }
}
