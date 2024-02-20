part of '../main.dart';

// ignore: must_be_immutable
class StoreProductsPage extends StatefulWidget {
  StoreProductsPage(this.placeID, this.categories, this.productIDs,
      this.noticeTitle, this.noticeDesc,
      {super.key,
      this.setFeaturedProductCallback,
      this.addProductCallback,
      this.editProductCallback,
      this.deleteProductCallback});

  String placeID;
  String? noticeTitle, noticeDesc;
  List productIDs;
  List categories;

  final Function(String placeID, String productID, bool state)?
      setFeaturedProductCallback;
  final Function(String placeID, String productID, List categories)?
      addProductCallback;
  final Function(String placeID, String productID, List addedCategories,
      List removedCategories)? editProductCallback;
  final Function(String placeID, String productID, List categories)?
      deleteProductCallback;

  @override
  State<StoreProductsPage> createState() => _StoreProductsPageState();
}

class _StoreProductsPageState extends State<StoreProductsPage> {
  Map productsFeatured = {};
  Map products = {};

  void initProducts() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    for (String productID in widget.productIDs) {
      db.collection("products").doc(productID).get().then((document) async {
        List categories = document.data()!['categories'] ?? [];
        if (categories.contains('Featured')) {
          productsFeatured[productID] = document.data()!;
        } else {
          products[productID] = document.data()!;
        }
        setProductImageURL(productID, categories.contains('Featured'));
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void setProductImageURL(String productID, bool isFeatured) async {
    String ref = "products/$productID.jpg";
    try {
      String url = await FirebaseStorage.instance.ref(ref).getDownloadURL();
      setState(() {
        if (isFeatured) {
          productsFeatured[productID]['productImageURL'] = url;
        } else {
          products[productID]['productImageURL'] = url;
        }
      });
    } catch (e) {
      return;
    }
  }

  void setFeaturedProduct(String productID, bool state) {
    if (state) {
      productsFeatured[productID] = products.remove(productID);
      productsFeatured[productID]['categories'].add('Featured');
    } else {
      products[productID] = productsFeatured.remove(productID);
      products[productID]['categories'].remove('Featured');
    }
    widget.setFeaturedProductCallback!(widget.placeID, productID, state);
    if (mounted) {
      setState(() {});
    }
  }

  void addProduct(String productID, String? productImageURL, Map data) {
    widget.addProductCallback!(widget.placeID, productID, data['categories']);
    if (mounted) {
      setState(() {
        if (data['categories'].contains('Featured')) {
          productsFeatured[productID] = data;
          if (productImageURL != null) {
            productsFeatured[productID]['productImageURL'] = productImageURL;
          }
        } else {
          products[productID] = data;
          if (productImageURL != null) {
            products[productID]['productImageURL'] = productImageURL;
          }
        }
      });
    }
  }

  void editProduct(String productID, List categories, List addedCategories,
      List removedCategories) {
    if (addedCategories.remove('Featured')) {
      setFeaturedProduct(productID, true);
      categories.remove('Featured');
    } else if (removedCategories.remove('Featured')) {
      setFeaturedProduct(productID, false);
      categories.remove('Featured');
    }
    widget.editProductCallback!(
        widget.placeID, productID, addedCategories, removedCategories);
  }

  void deleteProduct(String productID, List categories) {
    products.remove(productID);
    productsFeatured.remove(productID);
    widget.deleteProductCallback!(widget.placeID, productID, categories);
    if (mounted) {
      setState(() {});
    }
  }

  Future showEditNoticeForm(BuildContext context) async {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    // Variables for controllers.
    final GlobalKey<FormState> formEditNoticeKey = GlobalKey<FormState>();
    final inputEditNoticeTitle =
        TextEditingController(text: widget.noticeTitle);
    final inputEditNoticeDesc = TextEditingController(text: widget.noticeDesc);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          elevation: 0,
          backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
          content: Form(
            key: formEditNoticeKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Edit Notice",
                      style: TextStyle(
                          color: ChimeColors.getGreen800(),
                          fontFamily: 'Plus Jakarta Sans',
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
                  ],
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Notice Title",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Source Sans 3',
                        fontVariations: const [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3),
                  ),
                ),
                TextFormField(
                  controller: inputEditNoticeTitle,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: "Title",
                    hintStyle:
                        TextStyle(color: Theme.of(context).colorScheme.outline),
                    filled: true,
                    fillColor:
                        MaterialColors.getSurfaceContainerLowest(darkMode),
                    isDense: true,
                  ),
                  style: const TextStyle(
                      fontFamily: 'Source Sans 3',
                      fontVariations: [
                        FontVariation('wght', 400),
                      ],
                      fontSize: 14,
                      letterSpacing: -0.3),
                ),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Description",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Source Sans 3',
                        fontVariations: const [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3),
                  ),
                ),
                TextFormField(
                  controller: inputEditNoticeDesc,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: "Description",
                    hintStyle:
                        TextStyle(color: Theme.of(context).colorScheme.outline),
                    filled: true,
                    fillColor:
                        MaterialColors.getSurfaceContainerLowest(darkMode),
                    isDense: true,
                  ),
                  style: const TextStyle(
                      fontFamily: 'Source Sans 3',
                      fontVariations: [
                        FontVariation('wght', 400),
                      ],
                      fontSize: 14,
                      height: 1.2,
                      letterSpacing: -0.3),
                  minLines: 5,
                  maxLines: 5,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                          elevation: const MaterialStatePropertyAll(0),
                          backgroundColor: MaterialStatePropertyAll(
                              MaterialColors.getSurfaceContainerLowest(
                                  darkMode)),
                          shape:
                              MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: ChimeColors.getGreen300(),
                            ),
                          )),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: ChimeColors.getGreen800(),
                              fontFamily: 'Plus Jakarta Sans',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formEditNoticeKey.currentState!.validate()) {
                            {
                              editNotice(
                                  widget.placeID,
                                  inputEditNoticeTitle.text,
                                  inputEditNoticeDesc.text);
                            }
                          }
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                ChimeColors.getGreen200()),
                            shape:
                                MaterialStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide.none,
                            ))),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Save",
                            style: TextStyle(
                              color: ChimeColors.getGreen800(),
                              fontFamily: 'Plus Jakarta Sans',
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
              ],
            ),
          ),
        );
      },
    );
  }

  void editNotice(String placeID, String title, String desc) {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      Map<String, dynamic> data = {
        "noticeTitle": title.isEmpty ? null : title,
        "noticeDesc": desc.isEmpty ? null : desc,
      };
      db.collection("places").doc(placeID).update(data);
      if (mounted) {
        setState(() {
          widget.noticeTitle = title.isEmpty ? null : title;
          widget.noticeDesc = desc.isEmpty ? null : desc;
        });
      }
      Navigator.pop(context);
    } catch (e) {
      return;
    }
  }

  void _showQRCode() async {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          elevation: 0,
          backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: QrImageView(
                  data: widget.placeID,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Here's your code",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Bahnschrift',
                    fontVariations: const [
                      FontVariation('wght', 700),
                      FontVariation('wdth', 100),
                    ],
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                    letterSpacing: -0.3),
              ),
              const SizedBox(height: 10),
              Text(
                "Scanning this QR Code will redirect a friend to this place. Share it or save it for later!",
                maxLines: 3,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontFamily: 'Bahnschrift',
                    fontVariations: const [
                      FontVariation('wght', 400),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 13,
                    letterSpacing: -0.3,
                    height: 1.1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    initProducts();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    Map productsSorted = Map.fromEntries(products.entries.toList()
      ..sort((a, b) => (a.value['productName'].toLowerCase())
          .compareTo(b.value['productName'].toLowerCase())));
    Map productsFeaturedSorted = Map.fromEntries(
        productsFeatured.entries.toList()
          ..sort((a, b) => (a.value['productName'].toLowerCase())
              .compareTo(b.value['productName'].toLowerCase())));

    return Scaffold(
      backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: null,
            backgroundColor: ChimeColors.getGreen800(),
            label: Text(
              "Share QR",
              style: TextStyle(
                color: MaterialColors.getSurfaceContainerLowest(darkMode),
                fontFamily: 'Plus Jakarta Sans',
                fontVariations: const [
                  FontVariation('wght', 700),
                ],
                fontSize: 14,
                letterSpacing: -0.3,
              ),
            ),
            icon: Icon(
              Icons.qr_code_scanner,
              color: MaterialColors.getSurfaceContainerLowest(darkMode),
              size: 24,
            ),
            onPressed: () {
              _showQRCode();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: ChimeColors.getGreen800(),
              child: Icon(
                Icons.add,
                color: MaterialColors.getSurfaceContainerLowest(darkMode),
                size: 24,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => StoreProductsAddPage(
                          widget.placeID, widget.categories,
                          addProductCallback: addProduct)),
                );
              },
            ),
          ),
        ],
      ),
      body: (products.isEmpty && productsFeatured.isEmpty)
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        //<-- SEE HERE
                        side: BorderSide(
                          color: MaterialColors.getSurfaceContainerHighest(
                              darkMode),
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.noticeTitle ??
                                ((widget.noticeDesc == null)
                                    ? 'Add a notice'
                                    : 'Notice'),
                            style: TextStyle(
                              color: ChimeColors.getGreen800(),
                              fontFamily: 'Plus Jakarta Sans',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 15,
                              letterSpacing: -0.3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!(widget.noticeTitle != null &&
                              widget.noticeDesc == null))
                            const SizedBox(height: 10),
                          if (!(widget.noticeTitle != null &&
                              widget.noticeDesc == null))
                            Text(
                              widget.noticeDesc ??
                                  'This box will appear at the top of your products list when users visit your page. Add information such as delivery details, closing times, and more.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontFamily: 'Source Sans 3',
                                fontVariations: const [
                                  FontVariation('wght', 400),
                                ],
                                fontSize: 12,
                                letterSpacing: -0.3,
                                height: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 5,
                            ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    showEditNoticeForm(context);
                                  },
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          ChimeColors.getGreen200()),
                                      shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide.none,
                                      ))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.edit_outlined,
                                          size: 16,
                                          color: ChimeColors.getGreen800(),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Edit Notice",
                                          style: TextStyle(
                                            color: ChimeColors.getGreen800(),
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontVariations: const [
                                              FontVariation('wght', 700),
                                            ],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  if (productsFeatured.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Featured",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontVariations: const [
                                        FontVariation('wght', 700),
                                      ],
                                      fontSize: 15,
                                      letterSpacing: -0.5),
                                ),
                              ]),
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                            key: UniqueKey(),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                    mainAxisExtent: 205,
                                    maxCrossAxisExtent: 200,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 0),
                            itemCount: productsFeatured.length,
                            itemBuilder: (context, index) {
                              String key =
                                  productsFeaturedSorted.keys.elementAt(index);
                              return ProductCardEditable(
                                  key, widget.categories, productsFeatured[key],
                                  setFeaturedProductCallback:
                                      setFeaturedProduct,
                                  editProductCallback: editProduct,
                                  deleteProductCallback: deleteProduct);
                            }),
                        const SizedBox(height: 25),
                      ],
                    ),
                  if (products.isNotEmpty)
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "All Posts",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontVariations: const [
                                          FontVariation('wght', 700),
                                        ],
                                        fontSize: 15,
                                        letterSpacing: -0.5),
                                  ),
                                ]),
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            key: UniqueKey(),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                    mainAxisExtent: 205,
                                    maxCrossAxisExtent: 200,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 0),
                            itemCount: products.length,
                            itemBuilder: (BuildContext context, int index) {
                              String key = productsSorted.keys.elementAt(index);
                              return ProductCardEditable(
                                  key, widget.categories, products[key],
                                  setFeaturedProductCallback:
                                      setFeaturedProduct,
                                  editProductCallback: editProduct,
                                  deleteProductCallback: deleteProduct);
                            },
                          ),
                        ])
                ],
              ),
            ),
    );
  }
}
