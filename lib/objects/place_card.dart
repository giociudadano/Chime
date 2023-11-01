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
  PlaceCard(
    this.placeID,
    this.place, {
    super.key,
    this.setFavoritePlaceCallback,
  });
  String placeID;
  Map place;
  bool isFavorited = false;

  final Function(String placeID, bool state)? setFavoritePlaceCallback;

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  void setFavoritePlace(bool state) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      if (state) {
        db.collection("users").doc(uid).update({
          "favoritePlaces": FieldValue.arrayUnion([widget.placeID])
        });
      } else {
        db.collection("users").doc(uid).update({
          "favoritePlaces": FieldValue.arrayRemove([widget.placeID])
        });
      }
      widget.isFavorited = state;
      if (widget.setFavoritePlaceCallback != null) {
        widget.setFavoritePlaceCallback!(widget.placeID, state);
      }
    } catch (e) {
      return;
    }
  }

  @override
  void initState() {
    if (widget.place['isFavorited'] != null) {
      widget.isFavorited = widget.place['isFavorited'];
    }
    super.initState();
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SizedBox(
                    width: 60,
                    child: FittedBox(
                      clipBehavior: Clip.hardEdge,
                      fit: BoxFit.cover,
                      child: CachedNetworkImage(
                        imageUrl: widget.place['placeImageURL'] ?? '',
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Icon(Icons.storefront_outlined,
                              color:
                                  Theme.of(context).colorScheme.outlineVariant),
                        ),
                        fadeInCurve: Curves.easeIn,
                        fadeOutCurve: Curves.easeOut,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          child: Text(
                            widget.place['placeName'],
                            maxLines: 1,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontFamily: 'Bahnschrift',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                  FontVariation('wdth', 100),
                                ],
                                fontSize: 15,
                                letterSpacing: -0.3,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        if (widget.place['placeTagline'] != null)
                          SizedBox(
                            width: 200,
                            child: Text(
                              widget.place['placeTagline'],
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      widget.isFavorited
                          ? Icons.favorite_outlined
                          : Icons.favorite_outline,
                      size: 20,
                      color: widget.isFavorited
                          ? Colors.redAccent
                          : Theme.of(context).colorScheme.outline,
                    ),
                    onPressed: () {
                      setFavoritePlace(!widget.isFavorited);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
