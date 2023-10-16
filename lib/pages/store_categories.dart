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
  @override
  void initState() {
    print(widget.categories);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        floatingActionButton: FloatingActionButton.small(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.create_new_folder_outlined,
            color: MaterialColors.getSurfaceContainerLowest(darkMode),
          ),
          onPressed: () {
            // Add function to add a new category.
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
                  String key = widget.categories.keys.elementAt(index);
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
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => StoreCategoriesListPage(
                                  key, widget.categories[key])));
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
                                  key,
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
                                  widget.categories[key].length.toString(),
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
