part of '../../main.dart';

// ignore: must_be_immutable
class StoreProductsVariantsPage extends StatefulWidget {
  StoreProductsVariantsPage(this.productID, this.product,
      {super.key, this.editDefaultProductVariantCallback});

  String productID;
  Map product;

  final Function(String price, bool isLimited, String ordersRemaining)?
      editDefaultProductVariantCallback;

  @override
  State<StoreProductsVariantsPage> createState() =>
      _StoreProductsVariantsPageState();
}

class _StoreProductsVariantsPageState extends State<StoreProductsVariantsPage> {
  final GlobalKey<FormState> _formEditDefaultVariantKey =
      GlobalKey<FormState>();
  final _inputEditDefaultVariantName = TextEditingController();
  final _inputEditDefaultVariantPrice = TextEditingController();
  final _inputEditDefaultVariantStocks = TextEditingController();

  Future showEditDefaultVariantForm(BuildContext context) async {
    _inputEditDefaultVariantName.text =
        widget.product['variantName'] ?? widget.product['productName'];
    _inputEditDefaultVariantPrice.text =
        widget.product['productPrice'].toString();
    _inputEditDefaultVariantStocks.text =
        widget.product['ordersRemaining'].toString();
    bool isLimited = widget.product['isLimited'] ?? false;

    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(20),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              elevation: 0,
              backgroundColor:
                  MaterialColors.getSurfaceContainerLowest(darkMode),
              content: Form(
                key: _formEditDefaultVariantKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Edit Default Variant",
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
                        ]),
                    const SizedBox(height: 15),
                    Text(
                      "Variant Name",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Source Sans 3',
                          fontVariations: const [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3),
                    ),
                    TextFormField(
                      controller: _inputEditDefaultVariantName,
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
                        hintText: "Variant Name",
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
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
                        letterSpacing: -0.3,
                      ),
                      validator: (String? value) {
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Price",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Source Sans 3',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                  ],
                                  fontSize: 14,
                                  letterSpacing: -0.3),
                            ),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                controller: _inputEditDefaultVariantPrice,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      width: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      width: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  prefixIcon: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 8, 0, 0),
                                    child: Text(
                                      "₱",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontFamily: 'Source Sans 3',
                                          fontVariations: const [
                                            FontVariation('wght', 400),
                                          ],
                                          fontSize: 16,
                                          letterSpacing: -0.3),
                                    ),
                                  ),
                                  hintText: "Price",
                                  hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                  filled: true,
                                  fillColor:
                                      MaterialColors.getSurfaceContainerLowest(
                                          darkMode),
                                  isDense: true,
                                ),
                                style: const TextStyle(
                                  fontFamily: 'Source Sans 3',
                                  fontVariations: [
                                    FontVariation('wght', 400),
                                  ],
                                  fontSize: 14,
                                  letterSpacing: -0.3,
                                ),
                                minLines: 1,
                                maxLines: 1,
                                validator: (String? value) {
                                  return _verifyProductPriceField(value);
                                },
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Has Limited Stocks",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Source Sans 3',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                  ],
                                  fontSize: 14,
                                  letterSpacing: -0.3),
                            ),
                            Row(children: [
                              Transform.scale(
                                scale: 0.6,
                                child: Switch(
                                  value: isLimited,
                                  onChanged: (bool value) {
                                    if (mounted) {
                                      setState(() {
                                        isLimited = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  enabled: isLimited,
                                  controller: _inputEditDefaultVariantStocks,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        width: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        width: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: "Stocks",
                                    hintStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline),
                                    filled: true,
                                    fillColor: MaterialColors
                                        .getSurfaceContainerLowest(darkMode),
                                    isDense: true,
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'Source Sans 3',
                                    fontVariations: [
                                      FontVariation('wght', 400),
                                    ],
                                    fontSize: 14,
                                    letterSpacing: -0.3,
                                  ),
                                  minLines: 1,
                                  maxLines: 1,
                                  validator: (String? value) {
                                    return _verifyProductPriceField(value);
                                  },
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (mounted) {
                                Navigator.pop(context);
                              }
                            },
                            style: ButtonStyle(
                              elevation: const MaterialStatePropertyAll(0),
                              backgroundColor: MaterialStatePropertyAll(
                                  MaterialColors.getSurfaceContainerLowest(
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
                              if (_formEditDefaultVariantKey.currentState!
                                  .validate()) {
                                {
                                  editDefaultProductVariant(
                                      _inputEditDefaultVariantName.text,
                                      _inputEditDefaultVariantPrice.text,
                                      isLimited,
                                      _inputEditDefaultVariantStocks.text);
                                  Navigator.pop(context);
                                }
                              }
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
          });
        });
  }

  void editDefaultProductVariant(
      String name, String price, bool isLimited, String ordersRemaining) {
    // 1. Write default variant to database
    FirebaseFirestore db = FirebaseFirestore.instance;
    Map<String, dynamic> data = {
      "variantName": name,
      "productPrice": int.parse(price),
      "isLimited": isLimited,
      "ordersRemaining": int.parse(ordersRemaining),
    };
    db.collection("products").doc(widget.productID).update(data);
    // 2. Update edit product screen
    if (widget.editDefaultProductVariantCallback != null) {
      widget.editDefaultProductVariantCallback!(
          price, isLimited, ordersRemaining);
    }
    // 3. Update variants screen
    if (mounted) {
      setState(() {
        widget.product['variantName'] = name;
        widget.product['productPrice'] = int.parse(price);
        widget.product['isLimited'] = isLimited;
        widget.product['ordersRemaining'] = int.parse(ordersRemaining);
      });
    }
  }

  String? _verifyProductPriceField(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      int.parse(value);
      return null;
    } on FormatException {
      return 'Please enter a whole number';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 50),
            child: Text(
              "Variants",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'Plus Jakarta Sans',
                  fontVariations: const [
                    FontVariation('wght', 700),
                  ],
                  fontSize: 20,
                  letterSpacing: -0.3),
            ),
          ),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              Card(
                elevation: 0,
                color: MaterialColors.getSurfaceContainerLowest(darkMode),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: MaterialColors.getSurfaceContainerHighest(darkMode),
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: InkWell(
                  onTap: () {
                    showEditDefaultVariantForm(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.product['variantName'] ??
                                        widget.product['productName'],
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontVariations: const [
                                          FontVariation('wght', 700),
                                        ],
                                        fontSize: 14,
                                        letterSpacing: -0.3,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  Icon(
                                    Icons.edit,
                                    size: 18,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ],
                              ),
                              Text(
                                "₱${widget.product['productPrice'].toString()}",
                                maxLines: 1,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontVariations: const [
                                      FontVariation('wght', 700),
                                    ],
                                    fontSize: 14,
                                    letterSpacing: -0.3,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              if (widget.product['isLimited'])
                                Text(
                                  "Orders: ${widget.product['ordersRemaining'].toString()}",
                                  maxLines: 1,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      fontFamily: 'Source Sans 3',
                                      fontVariations: const [
                                        FontVariation('wght', 400),
                                      ],
                                      fontSize: 14,
                                      letterSpacing: -0.3,
                                      overflow: TextOverflow.ellipsis),
                                ),
                            ]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
