part of main;

// The 'Product' page displays additional information about a product.
// This page is visited when the user clicks on a product from the 'Products' page.
class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: Theme.of(context).colorScheme.outline),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
