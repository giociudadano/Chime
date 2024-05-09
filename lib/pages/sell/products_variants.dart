part of '../../main.dart';

// ignore: must_be_immutable
class StoreProductsVariantsPage extends StatefulWidget {
  StoreProductsVariantsPage(this.productID, this.product,
      {super.key,
      this.editDefaultProductVariantCallback,
      this.editProductVariantCallback});

  String productID;
  Map product;

  final Function(String price, bool isLimited, String ordersRemaining)?
      editDefaultProductVariantCallback;

  final Function(List data)? editProductVariantCallback;

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

  final GlobalKey<FormState> _formEditVariantKey = GlobalKey<FormState>();
  final _inputEditVariantName = TextEditingController();
  final _inputEditVariantPrice = TextEditingController();
  final _inputEditVariantStocks = TextEditingController();

  final GlobalKey<FormState> _formAddVariantKey = GlobalKey<FormState>();
  final _inputAddVariantName = TextEditingController();
  final _inputAddVariantPrice = TextEditingController();
  final _inputAddVariantStocks = TextEditingController();

  Future showEditDefaultVariantForm(BuildContext context) async {
    _inputEditDefaultVariantName.text =
        widget.product['variantName'] ?? widget.product['productName'];
    _inputEditDefaultVariantPrice.text =
        widget.product['productPrice'].toString();
    _inputEditDefaultVariantStocks.text =
        widget.product['ordersRemaining'].toString();
    bool isLimited = widget.product['isLimited'] ?? false;

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
              backgroundColor: Theme.of(context).colorScheme.surface,
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
                                color: Theme.of(context).colorScheme.primary,
                                fontFamily: 'Manrope',
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
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ]),
                    const SizedBox(height: 15),
                    Text.rich(
                      TextSpan(text: "Variant Name", children: [
                        TextSpan(
                            text: "*",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary))
                      ]),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Source Sans 3',
                          fontVariations: const [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 16,
                          letterSpacing: -0.3),
                    ),
                    TextFormField(
                      controller: _inputEditDefaultVariantName,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        hintText: "Variant Name",
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Source Sans 3',
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.1,
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Name cannot be blank';
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Limit Orders',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontFamily: 'Source Sans 3',
                                    fontVariations: const [
                                      FontVariation('wght', 400),
                                    ],
                                    fontSize: 16,
                                    height: 1,
                                    letterSpacing: -0.1),
                                textAlign: TextAlign.left,
                              ),
                              Transform.scale(
                                scale: 0.75,
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
                            ]),
                        Visibility(
                          visible: isLimited,
                          child: TextFormField(
                            enabled: isLimited,
                            keyboardType: TextInputType.number,
                            controller: _inputEditDefaultVariantPrice,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              errorMaxLines: 3,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              hintText: "0",
                              hintStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.outline),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              isDense: true,
                            ),
                            style: const TextStyle(
                              fontFamily: 'Source Sans 3',
                              fontVariations: [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.1,
                            ),
                            minLines: 1,
                            maxLines: 1,
                            validator: (String? value) {
                              return verifyInteger(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    // Column(
                    //   children: [
                    //     Text(
                    //       "Limit Orders",
                    //       style: TextStyle(
                    //           color: Theme.of(context).colorScheme.onSurface,
                    //           fontFamily: 'Source Sans 3',
                    //           fontVariations: const [
                    //             FontVariation('wght', 400),
                    //           ],
                    //           fontSize: 16,
                    //           letterSpacing: -0.3),
                    //     ),
                    //     Row(children: [
                    //       Transform.scale(
                    //         scale: 0.6,
                    //         child: Switch(
                    //           value: isLimited,
                    //           onChanged: (bool value) {
                    //             if (mounted) {
                    //               setState(() {
                    //                 isLimited = value;
                    //               });
                    //             }
                    //           },
                    //         ),
                    //       ),
                    //       SizedBox(
                    //         width: 80,
                    //         child: TextFormField(
                    //           enabled: isLimited,
                    //           controller: _inputEditDefaultVariantStocks,
                    //           decoration: InputDecoration(
                    //             enabledBorder: OutlineInputBorder(
                    //               borderSide: BorderSide(
                    //                 color:
                    //                     Theme.of(context).colorScheme.outline,
                    //                 width: 0.5,
                    //               ),
                    //               borderRadius: BorderRadius.circular(8.0),
                    //             ),
                    //             border: OutlineInputBorder(
                    //               borderSide: BorderSide(
                    //                 color:
                    //                     Theme.of(context).colorScheme.outline,
                    //                 width: 0.5,
                    //               ),
                    //               borderRadius: BorderRadius.circular(8.0),
                    //             ),
                    //             hintText: "0",
                    //             hintStyle: TextStyle(
                    //                 color:
                    //                     Theme.of(context).colorScheme.outline),
                    //             filled: true,
                    //             fillColor:
                    //                 MaterialColors.getSurfaceContainerLowest(
                    //                     darkMode),
                    //             isDense: true,
                    //           ),
                    //           style: const TextStyle(
                    //             fontFamily: 'Source Sans 3',
                    //             fontVariations: [
                    //               FontVariation('wght', 400),
                    //             ],
                    //             fontSize: 14,
                    //             letterSpacing: -0.3,
                    //           ),
                    //           minLines: 1,
                    //           maxLines: 1,
                    //           validator: (String? value) {
                    //             return verifyInteger(value);
                    //           },
                    //         ),
                    //       ),
                    //     ]),
                    //   ],
                    // ),
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
                                  Theme.of(context).colorScheme.surface),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              )),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 14,
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
                                    Theme.of(context).colorScheme.primary),
                                shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide.none,
                                ))),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "Save",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontFamily: 'Manrope',
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

  String? verifyInteger(String? value) {
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

  Future showEditVariantForm(BuildContext context, int index) async {
    _inputEditVariantName.text = widget.product['variants'][index]['name'];
    _inputEditVariantPrice.text =
        widget.product['variants'][index]['price'].toString();
    _inputEditVariantStocks.text =
        widget.product['variants'][index]['ordersRemaining'].toString();
    bool isLimited = widget.product['variants'][index]['isLimited'] ?? false;

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(20),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0),
                ),
              ),
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              content: Form(
                key: _formEditVariantKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Edit Variant",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontFamily: 'Manrope',
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
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ]),
                    const SizedBox(height: 15),
                    Text.rich(
                      TextSpan(text: "Variant Name", children: [
                        TextSpan(
                            text: "*",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary))
                      ]),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Source Sans 3',
                          fontVariations: const [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 16,
                          letterSpacing: -0.1),
                    ),
                    TextFormField(
                      controller: _inputEditVariantName,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        hintText: "Variant Name",
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Source Sans 3',
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 16,
                        letterSpacing: -0.1,
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Name cannot be blank';
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Price",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 16,
                              letterSpacing: -0.1),
                        ),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            controller: _inputEditVariantPrice,
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
                              prefixIcon: Padding(
                                padding: const EdgeInsets.fromLTRB(15, 8, 0, 0),
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
                                      letterSpacing: -0.1),
                                ),
                              ),
                              hintText: "0",
                              hintStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.outline),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              isDense: true,
                            ),
                            style: const TextStyle(
                              fontFamily: 'Source Sans 3',
                              fontVariations: [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.1,
                            ),
                            minLines: 1,
                            maxLines: 1,
                            validator: (String? value) {
                              return verifyInteger(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Limit Orders',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontFamily: 'Source Sans 3',
                                    fontVariations: const [
                                      FontVariation('wght', 400),
                                    ],
                                    fontSize: 16,
                                    height: 1,
                                    letterSpacing: -0.1),
                                textAlign: TextAlign.left,
                              ),
                              Transform.scale(
                                scale: 0.75,
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
                            ]),
                        Visibility(
                          visible: isLimited,
                          child: TextFormField(
                            enabled: isLimited,
                            keyboardType: TextInputType.number,
                            controller: _inputEditVariantStocks,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              errorMaxLines: 3,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              hintText: "0",
                              hintStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.outline),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              isDense: true,
                            ),
                            style: const TextStyle(
                              fontFamily: 'Source Sans 3',
                              fontVariations: [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.1,
                            ),
                            minLines: 1,
                            maxLines: 1,
                            validator: (String? value) {
                              return verifyInteger(value);
                            },
                          ),
                        ),
                      ],
                    ),

                    // Column(
                    //   children: [
                    //     Text(
                    //       "Has Limited Stocks",
                    //       style: TextStyle(
                    //           color: Theme.of(context).colorScheme.onSurface,
                    //           fontFamily: 'Source Sans 3',
                    //           fontVariations: const [
                    //             FontVariation('wght', 400),
                    //           ],
                    //           fontSize: 14,
                    //           letterSpacing: -0.3),
                    //     ),
                    //     Row(children: [
                    //       Transform.scale(
                    //         scale: 0.6,
                    //         child: Switch(
                    //           value: isLimited,
                    //           onChanged: (bool value) {
                    //             if (mounted) {
                    //               setState(() {
                    //                 isLimited = value;
                    //               });
                    //             }
                    //           },
                    //         ),
                    //       ),
                    //       SizedBox(
                    //         width: 80,
                    //         child: TextFormField(
                    //           enabled: isLimited,
                    //           controller: _inputEditVariantStocks,
                    //           decoration: InputDecoration(
                    //             enabledBorder: OutlineInputBorder(
                    //               borderSide: BorderSide(
                    //                 color:
                    //                     Theme.of(context).colorScheme.outline,
                    //                 width: 0.5,
                    //               ),
                    //               borderRadius: BorderRadius.circular(8.0),
                    //             ),
                    //             border: OutlineInputBorder(
                    //               borderSide: BorderSide(
                    //                 color:
                    //                     Theme.of(context).colorScheme.outline,
                    //                 width: 0.5,
                    //               ),
                    //               borderRadius: BorderRadius.circular(8.0),
                    //             ),
                    //             hintText: "0",
                    //             hintStyle: TextStyle(
                    //                 color:
                    //                     Theme.of(context).colorScheme.outline),
                    //             filled: true,
                    //             fillColor:
                    //                 MaterialColors.getSurfaceContainerLowest(
                    //                     darkMode),
                    //             isDense: true,
                    //           ),
                    //           style: const TextStyle(
                    //             fontFamily: 'Source Sans 3',
                    //             fontVariations: [
                    //               FontVariation('wght', 400),
                    //             ],
                    //             fontSize: 14,
                    //             letterSpacing: -0.3,
                    //           ),
                    //           minLines: 1,
                    //           maxLines: 1,
                    //           validator: (String? value) {
                    //             return verifyInteger(value);
                    //           },
                    //         ),
                    //       ),
                    //     ]),
                    //   ],
                    // ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              deleteProductVariant(index);
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Theme.of(context).colorScheme.surface),
                                shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.error),
                                ))),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formEditVariantKey.currentState!
                                  .validate()) {
                                {
                                  updateProductVariant(
                                      index,
                                      _inputEditVariantName.text,
                                      _inputEditVariantPrice.text,
                                      isLimited,
                                      _inputEditVariantStocks.text);
                                  Navigator.pop(context);
                                }
                              }
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Theme.of(context).colorScheme.primary),
                                shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide.none,
                                ))),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "Save",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontFamily: 'Manrope',
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

  Future showAddVariantForm(BuildContext context) async {
    bool isLimited = false;

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
                key: _formAddVariantKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add Variant",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontFamily: 'Manrope',
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
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ]),
                    const SizedBox(height: 15),
                    Text.rich(
                      TextSpan(text: "Variant Name", children: [
                        TextSpan(
                            text: "*",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary))
                      ]),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Source Sans 3',
                          fontVariations: const [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 16,
                          letterSpacing: -0.1),
                    ),
                    TextFormField(
                      controller: _inputAddVariantName,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        hintText: "Variant Name",
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Source Sans 3',
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.1,
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Name cannot be blank';
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Price",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Source Sans 3',
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 16,
                              letterSpacing: -0.1),
                        ),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            controller: _inputAddVariantPrice,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.fromLTRB(15, 8, 0, 0),
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
                                      letterSpacing: -0.1),
                                ),
                              ),
                              hintText: "0",
                              hintStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.outline),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              isDense: true,
                            ),
                            style: const TextStyle(
                              fontFamily: 'Source Sans 3',
                              fontVariations: [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.1,
                            ),
                            minLines: 1,
                            maxLines: 1,
                            validator: (String? value) {
                              return verifyInteger(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Limit Orders',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontFamily: 'Source Sans 3',
                                    fontVariations: const [
                                      FontVariation('wght', 400),
                                    ],
                                    fontSize: 16,
                                    height: 1,
                                    letterSpacing: -0.1),
                                textAlign: TextAlign.left,
                              ),
                              Transform.scale(
                                scale: 0.75,
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
                            ]),
                        Visibility(
                          visible: isLimited,
                          child: TextFormField(
                            enabled: isLimited,
                            keyboardType: TextInputType.number,
                            controller: _inputAddVariantStocks,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              errorMaxLines: 3,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              hintText: "0",
                              hintStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.outline),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              isDense: true,
                            ),
                            style: const TextStyle(
                              fontFamily: 'Source Sans 3',
                              fontVariations: [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 14,
                              letterSpacing: -0.1,
                            ),
                            minLines: 1,
                            maxLines: 1,
                            validator: (String? value) {
                              return verifyInteger(value);
                            },
                          ),
                        ),
                      ],
                    ),

                    // Column(
                    //   children: [
                    //     Text(
                    //       "Has Limited Stocks",
                    //       style: TextStyle(
                    //           color: Theme.of(context).colorScheme.onSurface,
                    //           fontFamily: 'Source Sans 3',
                    //           fontVariations: const [
                    //             FontVariation('wght', 400),
                    //           ],
                    //           fontSize: 14,
                    //           letterSpacing: -0.3),
                    //     ),
                    //     Row(children: [
                    //       Transform.scale(
                    //         scale: 0.6,
                    //         child: Switch(
                    //           value: isLimited,
                    //           onChanged: (bool value) {
                    //             if (mounted) {
                    //               setState(() {
                    //                 isLimited = value;
                    //               });
                    //             }
                    //           },
                    //         ),
                    //       ),
                    //       SizedBox(
                    //         width: 80,
                    //         child: TextFormField(
                    //           enabled: isLimited,
                    //           controller: _inputAddVariantStocks,
                    //           decoration: InputDecoration(
                    //             enabledBorder: OutlineInputBorder(
                    //               borderSide: BorderSide(
                    //                 color: Theme.of(context)
                    //                     .colorScheme
                    //                     .outlineVariant,
                    //                 width: 1,
                    //               ),
                    //               borderRadius: BorderRadius.circular(8.0),
                    //             ),
                    //             border: OutlineInputBorder(
                    //               borderSide: BorderSide(
                    //                 color: Theme.of(context)
                    //                     .colorScheme
                    //                     .outlineVariant,
                    //                 width: 1,
                    //               ),
                    //               borderRadius: BorderRadius.circular(8.0),
                    //             ),
                    //             hintText: "0",
                    //             hintStyle: TextStyle(
                    //                 color:
                    //                     Theme.of(context).colorScheme.outline),
                    //             filled: true,
                    //             fillColor:
                    //                 Theme.of(context).colorScheme.surface,
                    //             isDense: true,
                    //           ),
                    //           style: const TextStyle(
                    //             fontFamily: 'Source Sans 3',
                    //             fontVariations: [
                    //               FontVariation('wght', 400),
                    //             ],
                    //             fontSize: 14,
                    //             letterSpacing: -0.1,
                    //           ),
                    //           minLines: 1,
                    //           maxLines: 1,
                    //           validator: (String? value) {
                    //             return verifyInteger(value);
                    //           },
                    //         ),
                    //       ),
                    //     ]),
                    //   ],
                    // ),
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
                                  Theme.of(context).colorScheme.surface),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              )),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formAddVariantKey.currentState!.validate()) {
                                {
                                  addProductVariant(
                                      _inputAddVariantName.text,
                                      _inputAddVariantPrice.text,
                                      isLimited,
                                      _inputAddVariantStocks.text);
                                  Navigator.pop(context);
                                }
                              }
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Theme.of(context).colorScheme.primary),
                                shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide.none,
                                ))),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "Save",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontFamily: 'Manrope',
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

  void addProductVariant(
      String name, String price, bool isLimited, String ordersRemaining) {
    // 1. Write default variant to database
    FirebaseFirestore db = FirebaseFirestore.instance;
    Map<String, dynamic> data = {
      "name": name,
      "price": price == '' ? 0 : int.parse(price),
      "isLimited": isLimited,
      "ordersRemaining": ordersRemaining == '' ? 0 : int.parse(ordersRemaining),
    };
    db.collection("products").doc(widget.productID).update({
      'variants': FieldValue.arrayUnion([data])
    });

    // 2. Update variants screen
    if (mounted) {
      setState(() {
        if (widget.product['variants'] == null ||
            widget.product['variants'].isEmpty) {
          widget.product['variants'] = [];
        }
        widget.product['variants'].add(data);
      });
      if (widget.editProductVariantCallback != null) {
        widget.editProductVariantCallback!(widget.product['variants']);
      }
    }
  }

  void updateProductVariant(int index, String name, String price,
      bool isLimited, String ordersRemaining) {
    // 1. Write variants screen
    FirebaseFirestore db = FirebaseFirestore.instance;
    Map<String, dynamic> data = {
      "name": name,
      "price": price == '' ? 0 : int.parse(price),
      "isLimited": isLimited,
      "ordersRemaining": ordersRemaining == '' ? 0 : int.parse(ordersRemaining),
    };
    if (mounted) {
      setState(() {
        widget.product['variants'][index] = data;
      });
      if (widget.editProductVariantCallback != null) {
        widget.editProductVariantCallback!(widget.product['variants']);
      }
    }
    // 2. Write to database
    db
        .collection("products")
        .doc(widget.productID)
        .update({'variants': widget.product['variants']});
  }

  void deleteProductVariant(int index) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    if (mounted) {
      setState(() {
        widget.product['variants'].removeAt(index);
      });
    }
    if (widget.editProductVariantCallback != null) {
      widget.editProductVariantCallback!(widget.product['variants']);
    }
    db
        .collection("products")
        .doc(widget.productID)
        .update({'variants': widget.product['variants']});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        onPressed: () {
          showAddVariantForm(context);
        },
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                  fontFamily: 'Manrope',
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
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
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
                                    "${widget.product['variantName'] ?? widget.product['productName']} (Default)",
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        fontFamily: 'Manrope',
                                        fontVariations: const [
                                          FontVariation('wght', 700),
                                        ],
                                        fontSize: 16,
                                        letterSpacing: -0.3,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  Icon(
                                    Icons.edit,
                                    size: 18,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ],
                              ),
                              Text(
                                "₱${widget.product['productPrice'].toString()}",
                                maxLines: 1,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontFamily: 'Manrope',
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
                                      fontSize: 16,
                                      letterSpacing: -0.1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                            ]),
                      ),
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.product['variants'] == null
                    ? 0
                    : widget.product['variants'].length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        showEditVariantForm(context, index);
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
                                        widget.product['variants'][index]
                                            ['name'],
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                            fontFamily: 'Manrope',
                                            fontVariations: const [
                                              FontVariation('wght', 700),
                                            ],
                                            fontSize: 16,
                                            letterSpacing: -0.3,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "₱${widget.product['variants'][index]['price'].toString()}",
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        fontFamily: 'Manrope',
                                        fontVariations: const [
                                          FontVariation('wght', 700),
                                        ],
                                        fontSize: 16,
                                        letterSpacing: -0.3,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  if (widget.product['variants'][index]
                                      ['isLimited'])
                                    Text(
                                      "Orders: ${widget.product['variants'][index]['ordersRemaining'].toString()}",
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
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
                  );
                },
              ),
            ],
          )),
    );
  }
}
