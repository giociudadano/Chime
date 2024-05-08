part of '../../main.dart';

// ignore: must_be_immutable
class StoreCategoriesMorePage extends StatefulWidget {
  StoreCategoriesMorePage(this.placeID, this.categoryName, this.categories,
      this.products, this.productIDsInCategory,
      {super.key,
      this.renameCategoryCallback,
      this.deleteCategoryCallback,
      this.setFeaturedProductCallback,
      this.editProductCallback,
      this.editProductsInCategoryCallback});

  String placeID, categoryName;
  List categories, productIDsInCategory;
  Map products;

  final Function(String oldName, String newName)? renameCategoryCallback;
  final Function(String name)? deleteCategoryCallback;
  final Function(String productID, bool state)? setFeaturedProductCallback;
  final Function(String placeID, String productID, List addedCategories,
      List removedCategories)? editProductCallback;
  final Function(String categoryName, List oldProducts, List newProducts)?
      editProductsInCategoryCallback;

  @override
  State<StoreCategoriesMorePage> createState() => _StoreCategoriesMoreState();
}

class _StoreCategoriesMoreState extends State<StoreCategoriesMorePage> {
  GlobalKey? dropdownButtonKey = GlobalKey();

  List multipleSelected = [];
  void setMultipleSelected(List value) {
    setState(() => multipleSelected = value);
  }

  Future<dynamic> showAddProductsForm(BuildContext context) {
    final GlobalKey<FormState> formAddProductsKey = GlobalKey<FormState>();

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
            backgroundColor: Theme.of(context).colorScheme.surface,
            content: Form(
              key: formAddProductsKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Products in Category",
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    width: double.maxFinite,
                    child: ListView(children: [
                      InlineChoice(
                        multiple: true,
                        clearable: true,
                        value: multipleSelected,
                        onChanged: setMultipleSelected,
                        itemCount: widget.products.length,
                        itemBuilder: (selection, i) {
                          String key = widget.products.keys.elementAt(i);
                          return ChoiceChip(
                            selected: selection.selected(key),
                            onSelected: selection.onSelected(key),
                            label: Text(widget.products[key]['productName'],
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontFamily: 'Source Sans 3',
                                    fontVariations: const [
                                      FontVariation('wght', 400),
                                    ],
                                    fontSize: 16,
                                    letterSpacing: -0.1)),
                          );
                        },
                        listBuilder: ChoiceList.createWrapped(
                          spacing: 10,
                          runSpacing: 10,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 0,
                          ),
                        ),
                      ),
                    ]),
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
                                Theme.of(context).colorScheme.surface),
                            shape:
                                MaterialStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            )),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            editProductsInCategory(multipleSelected);
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Theme.of(context).colorScheme.primary),
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
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 16,
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
  }

  Future<dynamic> showRenameCategoryForm(BuildContext context) {
    final GlobalKey<FormState> formRenameCategoryKey = GlobalKey<FormState>();
    final inputRenameCategoryName = TextEditingController();

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
            backgroundColor: Theme.of(context).colorScheme.surface,
            content: Form(
              key: formRenameCategoryKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rename Category",
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Category Name",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Source Sans 3',
                          fontVariations: const [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 16,
                          letterSpacing: -0.1),
                    ),
                  ),
                  TextFormField(
                    controller: inputRenameCategoryName,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
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
                      hintText: "Meal Set or Group",
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          letterSpacing: -0.1),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      isDense: true,
                    ),
                    style: const TextStyle(
                        fontFamily: 'Source Sans 3',
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 14),
                    validator: (String? value) {
                      return _verifyNameField(value);
                    },
                  ),
                  const SizedBox(height: 48),
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
                                Theme.of(context).colorScheme.surface),
                            shape:
                                MaterialStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            )),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formRenameCategoryKey.currentState!
                                .validate()) {
                              renameCategory(inputRenameCategoryName.text);
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Theme.of(context).colorScheme.primary),
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
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 16,
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
  }

  // Checks if the name field is empty and returns an error if so.
  String? _verifyNameField(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a name";
    } else if (widget.categories.contains(value)) {
      return "Category already exists";
    }
    return null;
  }

  void renameCategory(String name) {
    widget.renameCategoryCallback!(widget.categoryName, name);
    if (mounted) {
      setState(() {
        widget.categories.remove(widget.categoryName);
        widget.categories.add(name);
        widget.categoryName = name;
      });
    }
    Navigator.pop(context);
  }

  void deleteCategory() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Category',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontVariations: const [
                FontVariation('wght', 700),
              ],
              fontSize: 16,
              letterSpacing: -0.3,
            )),
        content:
            const Text('No worries, all your products will remain intact.'),
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
              widget.deleteCategoryCallback!(widget.categoryName);
              Navigator.pop(context, 'OK');
              final snackBar = SnackBar(
                content: const Text('Category has been deleted.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontVariations: const [
                        FontVariation('wght', 700),
                      ],
                      fontSize: 16,
                      letterSpacing: -0.3,
                    )),
              );
              // Find the ScaffoldMessenger in the widget tree
              // and use it to show a SnackBar.
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
    );
  }

  void showDropdown() {
    GestureDetector? detector;
    void searchForGestureDetector(BuildContext? element) {
      element?.visitChildElements((element) {
        if (element.widget is GestureDetector) {
          detector = element.widget as GestureDetector?;
        } else {
          searchForGestureDetector(element);
        }
      });
    }

    searchForGestureDetector(dropdownButtonKey?.currentContext);
    assert(detector != null);

    detector?.onTap?.call();
  }

  void editProduct(String productID, List categories, List addedCategories,
      List removedCategories) {
    // 1. Special condition for 'Featured' category
    if (addedCategories.remove('Featured')) {
      setFeaturedProduct(productID, true);
      categories.remove('Featured');
    } else if (removedCategories.remove('Featured')) {
      setFeaturedProduct(productID, false);
      categories.remove('Featured');
    }

    // 2. Special condition for removing same category as active page
    if (removedCategories.contains(widget.categoryName)) {
      setState(() {
        widget.productIDsInCategory.remove(productID);
      });
    }

    widget.editProductCallback!(
        widget.placeID, productID, addedCategories, removedCategories);
  }

  void setFeaturedProduct(String productID, bool state) {
    if (state) {
      widget.products[productID]['categories'].add('Featured');
    } else {
      widget.products[productID]['categories'].remove('Featured');
    }
    widget.setFeaturedProductCallback!(productID, state);
    if (mounted) {
      setState(() {});
    }
  }

  void editProductsInCategory(List editedProducts) {
    FirebaseFirestore db = FirebaseFirestore.instance;

    // 1. Write to database all added products in category
    List oldProducts = widget.productIDsInCategory;
    Set addedProducts = editedProducts.toSet().difference(oldProducts.toSet());
    for (String productID in addedProducts) {
      db.collection("products").doc(productID).update({
        "categories": FieldValue.arrayUnion([widget.categoryName])
      });
      db.collection("places").doc(widget.placeID).update({
        "categories.${widget.categoryName}": FieldValue.arrayUnion([productID])
      });
      widget.products[productID]['categories'].add(widget.categoryName);
    }

    // 2. Write to database all removed products in category
    Set removedProducts =
        oldProducts.toSet().difference(editedProducts.toSet());
    for (String productID in removedProducts) {
      db.collection("products").doc(productID).update({
        "categories": FieldValue.arrayRemove([widget.categoryName])
      });
      db.collection("places").doc(widget.placeID).update({
        "categories.${widget.categoryName}": FieldValue.arrayRemove([productID])
      });
      widget.products[productID]['categories'].remove(widget.categoryName);
    }

    // 3. Update products to display
    setState(() {
      widget.productIDsInCategory = editedProducts;
    });
    widget.editProductsInCategoryCallback!(
        widget.categoryName, addedProducts.toList(), removedProducts.toList());

    Navigator.pop(context);
  }

  @override
  void initState() {
    widget.productIDsInCategory = widget.productIDsInCategory
      ..sort((a, b) => (widget.products[a]['productName'])
          .compareTo(widget.products[b]['productName']));
    multipleSelected = widget.productIDsInCategory;
    super.initState;
  }

  @override
  Widget build(BuildContext context) {
    final dropdown = DropdownButton<int>(
      key: dropdownButtonKey,
      items: [
        DropdownMenuItem(
          value: 1,
          child: Text('Rename Category',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontFamily: 'Source Sans 3',
                  fontVariations: const [
                    FontVariation('wght', 400),
                  ],
                  fontSize: 16,
                  letterSpacing: -0.1)),
        ),
        DropdownMenuItem(
          value: 2,
          child: Text('Delete Category',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontFamily: 'Source Sans 3',
                  fontVariations: const [
                    FontVariation('wght', 400),
                  ],
                  fontSize: 16,
                  letterSpacing: -0.1)),
        ),
      ],
      onChanged: (int? value) {
        switch (value) {
          case 1:
            showRenameCategoryForm(context);
            break;
          case 2:
            deleteCategory();
            break;
        }
      },
    );

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            showAddProductsForm(context);
          },
        ),
        appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Center(
              child: Text(
                widget.categoryName,
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
            actions: [
              Offstage(child: dropdown),
              widget.categoryName == 'Menu of the Day'
                  ? const SizedBox(width: 60)
                  : Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () {
                            showDropdown();
                          }))
            ]),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(children: [
              GridView.builder(
                key: UniqueKey(),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    mainAxisExtent: 205,
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 0),
                itemCount: widget.productIDsInCategory.length,
                itemBuilder: (context, index) {
                  String key = widget.productIDsInCategory[index];
                  return ProductCardEditable(
                      key, widget.categories..sort(), widget.products[key],
                      setFeaturedProductCallback: setFeaturedProduct,
                      editProductCallback: editProduct);
                },
              ),
            ])));
  }
}
