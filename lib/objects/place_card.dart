/*
  [Title]
  PlaceCard

  [Description]
  A PlaceCard is an object that contains the place's id, image URL, name, and description.
  May be tapped on to direct the user to a PlacePage of that place.
  Created when visiting PlacesPage. Each place in the database has its own PlaceCard.
*/

part of main;

// ignore: must_be_immutable
class PlaceCard extends StatefulWidget {
  PlaceCard({
    super.key,
    required this.placeID,
    required this.placeName,
    required this.placeTagline,
  });
  String placeName, placeTagline, placeImageURL = ' ', placeID;

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  // Fetches and sets the product's image.
  void getPlaceImageURL() async {
    String url = '';
    String ref = "places/${widget.placeID}.jpg";
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
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
      child: InkWell(
        onTap: () {
          if (context.mounted) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PlacePage(widget.placeID)));
          }
        },
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
      ),
    );
  }
}
