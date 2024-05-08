part of '../../main.dart';

// ignore: must_be_immutable
class StoreCategoriesPage extends StatefulWidget {
  StoreCategoriesPage(this.placeID, this.categories, this.productIDs,
      {super.key});

  String placeID = '';
  Map categories;
  List productIDs;

  @override
  State<StoreCategoriesPage> createState() => _StoreCategoriesPageState();
}

class _StoreCategoriesPageState extends State<StoreCategoriesPage> {
  Map products = {};

  void initProducts() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    for (String productID in widget.productIDs) {
      db.collection("products").doc(productID).get().then((document) async {
        products[productID] = document.data()!;
        setProductImageURL(productID);
      });
    }
  }

  void setProductImageURL(String productID) async {
    String ref = "products/$productID.jpg";
    try {
      String url = await FirebaseStorage.instance.ref(ref).getDownloadURL();
      if (mounted) {
        setState(() {
          products[productID]['productImageURL'] = url;
        });
      }
    } catch (e) {
      return;
    }
  }

  Future<dynamic> showAddCategoryForm(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    final GlobalKey<FormState> formAddCategoryKey = GlobalKey<FormState>();
    final inputAddCategoryName = TextEditingController();

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
              key: formAddCategoryKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Add New Category",
                        style: TextStyle(
                            color: ChimeColors.getGreen800(),
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
                      "Category Name",
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
                    controller: inputAddCategoryName,
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
                      hintText: "Category Name",
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          letterSpacing: -0.3),
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
                        fontSize: 14),
                    validator: (String? value) {
                      return _verifyNameField(value);
                    },
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
                                fontFamily: 'Manrope',
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
                            if (formAddCategoryKey.currentState!.validate()) {
                              addCategory(inputAddCategoryName.text);
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
  }

  // Checks if the name field is empty and returns an error if so.
  String? _verifyNameField(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a name";
    } else if (widget.categories[value] != null) {
      return "Category already exists";
    }
    return null;
  }

  void addCategory(String name) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("places")
        .doc(widget.placeID)
        .update({"categories.$name": []});
    if (mounted) {
      setState(() {
        widget.categories[name] = [];
      });
    }

    Navigator.pop(context);
  }

  void renameCategory(String oldName, String newName) {
    List data = widget.categories[oldName];
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("places").doc(widget.placeID).update({
      "categories.$oldName": FieldValue.delete(),
      "categories.$newName": data
    });
    if (mounted) {
      setState(() {
        widget.categories.remove(oldName);
        widget.categories[newName] = data;
      });
    }
  }

  void deleteCategory(String name) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("places")
        .doc(widget.placeID)
        .update({"categories.$name": FieldValue.delete()});
    if (mounted) {
      setState(() {
        widget.categories.remove(name);
      });
    }
  }

  void editProduct(String placeID, String productID, List addedCategories,
      List removedCategories) {
    for (String addedCategory in addedCategories) {
      (widget.categories[addedCategory]).add(productID);
    }
    for (String removedCategory in removedCategories) {
      (widget.categories[removedCategory]).remove(productID);
    }
    if (mounted) {
      setState(() {});
    }
  }

  void editProductsInCategory(
      String categoryName, List addedProducts, List removedProducts) {
    for (String addedProduct in addedProducts) {
      widget.categories[categoryName].add(addedProduct);
    }
    for (String removedProduct in removedProducts) {
      widget.categories[categoryName].remove(removedProduct);
    }
    if (mounted) {
      setState(() {});
    }
  }

  void setFeaturedProduct(String productID, bool state) {
    if (state) {
      widget.categories['Featured'].add(productID);
    } else {
      widget.categories['Featured'].remove(productID);
    }
    if (mounted) {
      setState(() {});
    }
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
    List categoryKeys = widget.categories.keys.toList()..sort();
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            showAddCategoryForm(context);
          },
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(children: [
              GridView.builder(
                key: UniqueKey(),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.categories.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: InkWell(
                      onTap: () {
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => StoreCategoriesMorePage(
                                  widget.placeID,
                                  categoryKeys[index],
                                  widget.categories.keys.toList(),
                                  products,
                                  widget.categories[categoryKeys[index]],
                                  renameCategoryCallback: renameCategory,
                                  deleteCategoryCallback: deleteCategory,
                                  setFeaturedProductCallback:
                                      setFeaturedProduct,
                                  editProductCallback: editProduct,
                                  editProductsInCategoryCallback:
                                      editProductsInCategory),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  categoryKeys[index],
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                    fontFamily: 'Manrope',
                                    fontVariations: const [
                                      FontVariation('wght', 700),
                                    ],
                                    fontSize: 14,
                                    letterSpacing: -0.3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "(${widget.categories[categoryKeys[index]].length.toString()})",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.outlineVariant,
                                    fontFamily: 'Source Sans 3',
                                    fontVariations: const [
                                      FontVariation('wght', 400),
                                    ],
                                    fontSize: 14,
                                    letterSpacing: -0.3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface,
                                size: 15)
                          ],
                        ),
                      ),
                    ),
                  );
                },
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    mainAxisExtent: 60,
                    maxCrossAxisExtent: 450,
                    childAspectRatio: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 0),
              ),
            ])));
  }
}
