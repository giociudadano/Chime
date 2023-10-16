part of main;

// ignore: must_be_immutable
class StoreCategoriesListPage extends StatefulWidget {
  StoreCategoriesListPage(this.categoryName, this.categories, this.productIDs,
      {super.key, this.renameCategoryCallback, this.deleteCategoryCallback});

  String categoryName;
  List productIDs, categories;

  final Function(String oldName, String newName)? renameCategoryCallback;
  final Function(String name)? deleteCategoryCallback;

  @override
  State<StoreCategoriesListPage> createState() =>
      _StoreCategoriesListPageState();
}

class _StoreCategoriesListPageState extends State<StoreCategoriesListPage> {
  GlobalKey? dropdownButtonKey = GlobalKey();

  Future<dynamic> showRenameCategoryForm(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
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
            backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
            title: const Text(
              "Rename category",
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
              key: formRenameCategoryKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: inputRenameCategoryName,
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
                            if (formRenameCategoryKey.currentState!
                                .validate()) {
                              renameCategory(inputRenameCategoryName.text);
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
    widget.deleteCategoryCallback!(widget.categoryName);
    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    final dropdown = DropdownButton<int>(
      key: dropdownButtonKey,
      items: [
        DropdownMenuItem(
          value: 1,
          child: Text('Rename Category',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: 'Bahnschrift',
                  fontVariations: const [
                    FontVariation('wght', 450),
                    FontVariation('wdth', 100),
                  ],
                  fontSize: 14,
                  letterSpacing: -0.3)),
        ),
        DropdownMenuItem(
          value: 2,
          child: Text('Delete Category',
              style: TextStyle(
                  color: Colors.red[darkMode ? 200 : 900],
                  fontFamily: 'Bahnschrift',
                  fontVariations: const [
                    FontVariation('wght', 450),
                    FontVariation('wdth', 100),
                  ],
                  fontSize: 14,
                  letterSpacing: -0.3)),
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
              child: Text(
                widget.categoryName,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Bahnschrift',
                    fontVariations: const [
                      FontVariation('wght', 700),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 20,
                    letterSpacing: -0.3),
              ),
            ),
            actions: [
              Offstage(child: dropdown),
              widget.categoryName == 'Featured'
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
        body: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Hello!')));
  }
}
