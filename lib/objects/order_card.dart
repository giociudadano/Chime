part of main;

// ignore: must_be_immutable
class OrderCard extends StatefulWidget {
  OrderCard({super.key, required this.placeID, required this.order});
  String placeID = '', placeName = '';
  Map order = {};

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  // Retrieves and sets the place information given the place ID of the page.
  // Place ID is retrieved when obtaining product information.
  Future getPlaceName() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection("places")
        .doc(widget.placeID)
        .get()
        .then((document) async {
      if (document.exists) {
        setState(() {
          widget.placeName = document.data()!['placeName'] ?? '';
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getPlaceName();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
        color: MaterialColors.getSurfaceContainerLow(darkMode),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.placeName,
                maxLines: 1,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Bahnschrift',
                    fontVariations: const [
                      FontVariation('wght', 700),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 16,
                    letterSpacing: -0.3,
                    height: 0.85,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(height: 15),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                key: UniqueKey(),
                shrinkWrap: true,
                itemCount: widget.order.length,
                itemBuilder: (BuildContext context, int index) {
                  String key = widget.order.keys.elementAt(index);
                  return OrderItemCard(
                      placeID: widget.placeID,
                      productID: key,
                      quantity: widget.order[key]);
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        //TODO: Add functionality to checkout items.
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Theme.of(context).colorScheme.primary),
                        foregroundColor: MaterialStatePropertyAll(
                            Theme.of(context).colorScheme.onPrimary),
                      ),
                      child: Text(
                        "Checkout",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontFamily: 'Bahnschrift',
                          fontVariations: const [
                            FontVariation('wght', 500),
                            FontVariation('wdth', 100),
                          ],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
