part of main;

// ignore: must_be_immutable
class StoreCategoriesPage extends StatefulWidget {
  StoreCategoriesPage(this.placeID, this.categories, {super.key});

  String placeID = '';
  Map categories;

  @override
  State<StoreCategoriesPage> createState() => _StoreCategoriesPageState();
}

class _StoreCategoriesPageState extends State<StoreCategoriesPage> {
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
            title: const Text(
              "Add a new category",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Bahnschrift',
                  fontVariations: [
                    FontVariation('wght', 700),
                    FontVariation('wdth', 100),
                  ],
                  fontSize: 20,
                  letterSpacing: -0.3),
            ),
            content: Form(
              key: formAddCategoryKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                      hintText: "Name",
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.outline),
                      filled: true,
                      fillColor:
                          MaterialColors.getSurfaceContainerLowest(darkMode),
                      isDense: true,
                    ),
                    style: const TextStyle(
                        fontFamily: 'Bahnschrift',
                        fontVariations: [
                          FontVariation('wght', 300),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14),
                    validator: (String? value) {
                      return _verifyNameField(value);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formAddCategoryKey.currentState!.validate()) {
                              addCategory(inputAddCategoryName.text);
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                Theme.of(context).colorScheme.primary),
                            foregroundColor: MaterialStatePropertyAll(
                                Theme.of(context).colorScheme.onPrimary),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontFamily: 'Bahnschrift',
                                fontVariations: const [
                                  FontVariation('wght', 600),
                                  FontVariation('wdth', 100),
                                ],
                                fontSize: 15,
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
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List categoryKeys = widget.categories.keys.toList()..sort();
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        floatingActionButton: FloatingActionButton.small(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.create_new_folder_outlined,
            color: MaterialColors.getSurfaceContainerLowest(darkMode),
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
                itemCount: widget.categories.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        //<-- SEE HERE
                        side: BorderSide(
                          color: MaterialColors.getSurfaceContainerHighest(
                              darkMode),
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: InkWell(
                      onTap: () {
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => StoreCategoriesMorePage(
                                  categoryKeys[index],
                                  widget.categories.keys.toList(),
                                  widget.categories[categoryKeys[index]],
                                  renameCategoryCallback: renameCategory,
                                  deleteCategoryCallback: deleteCategory,
                                  setFeaturedProductCallback:
                                      setFeaturedProduct),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  categoryKeys[index],
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontFamily: 'Bahnschrift',
                                    fontVariations: const [
                                      FontVariation('wght', 650),
                                      FontVariation('wdth', 100),
                                    ],
                                    fontSize: 15,
                                    letterSpacing: -0.3,
                                    height: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  widget.categories[categoryKeys[index]].length
                                      .toString(),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    fontFamily: 'Bahnschrift',
                                    fontVariations: const [
                                      FontVariation('wght', 500),
                                      FontVariation('wdth', 100),
                                    ],
                                    fontSize: 15,
                                    letterSpacing: -0.3,
                                    height: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
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
