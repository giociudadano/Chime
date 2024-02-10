part of '../main.dart';

// ignore: must_be_immutable
class PlaceCategoryPage extends StatefulWidget {
  PlaceCategoryPage(this.placeID, this.place, this.categoryName, this.products,
      this.productIDsInCategory,
      {super.key});

  String placeID, categoryName;
  Map products, place;
  List productIDsInCategory;
  @override
  State<PlaceCategoryPage> createState() => _PlaceCategoryPageState();
}

class _PlaceCategoryPageState extends State<PlaceCategoryPage> {
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
              padding: const EdgeInsets.only(right: 40),
              child: Text(
                widget.categoryName,
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
            child: GridView.builder(
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
                return ProductCard(
                    key, widget.products[key], widget.placeID, widget.place);
              },
            )));
  }
}
