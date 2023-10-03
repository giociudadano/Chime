part of main;

// ignore: must_be_immutable
class PlaceCard extends StatefulWidget {
  PlaceCard({
    super.key,
    required this.id,
    required this.placeName,
    required this.placeTagline,
  });
  String placeName, placeTagline, placeImageURL = ' ', id;

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  void getPlaceImageURL() async {
    String url = '';
    String ref = "places/${widget.id}.jpg";
    try {
      url = await FirebaseStorage.instance.ref(ref).getDownloadURL();
    } catch (e) {
      //
    } finally {
      if (mounted) {
        setState(() {
          widget.placeImageURL = url;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getPlaceImageURL();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: MaterialColors.getSurfaceContainerLow(darkMode),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(7, 0, 7, 15),
      child: SizedBox(
        height: 100,
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: FittedBox(
                clipBehavior: Clip.hardEdge,
                fit: BoxFit.cover,
                child: CachedNetworkImage(
                  imageUrl: widget.placeImageURL,
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Icon(Icons.storefront_outlined,
                        color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  fadeInCurve: Curves.easeIn,
                  fadeOutCurve: Curves.easeOut,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Text(
                        widget.placeName,
                        maxLines: 1,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: 'Bahnschrift',
                            fontVariations: const [
                              FontVariation('wght', 700),
                              FontVariation('wdth', 100),
                            ],
                            fontSize: 14,
                            letterSpacing: -0.3,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: Text(
                        widget.placeTagline,
                        maxLines: 2,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontFamily: 'Bahnschrift',
                          fontVariations: const [
                            FontVariation('wght', 400),
                            FontVariation('wdth', 100),
                          ],
                          fontSize: 12,
                          letterSpacing: -0.3,
                          overflow: TextOverflow.ellipsis,
                          height: 0.85,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
