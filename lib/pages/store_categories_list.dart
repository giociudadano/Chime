part of main;

// ignore: must_be_immutable
class StoreCategoriesListPage extends StatefulWidget {
  StoreCategoriesListPage(this.categoryName, this.productIDs, {super.key});

  String categoryName;
  List productIDs;

  @override
  State<StoreCategoriesListPage> createState() =>
      _StoreCategoriesListPageState();
}

class _StoreCategoriesListPageState extends State<StoreCategoriesListPage> {
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
          ),
        ),
        body: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Hello!')));
  }
}
