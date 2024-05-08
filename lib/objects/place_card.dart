/*
  [Title]
  PlaceCard

  [Description]
  A PlaceCard is an object that contains the place's id, image URL, name, and description.
  May be tapped on to direct the user to a PlacePage of that place.
  Created when visiting PlacesPage. Each place in the database has its own PlaceCard.
*/

part of '../main.dart';

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

  final Function(String placeID, bool state)? setFavoritePlaceCallback;

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  void setFavoritePlace(String placeID, bool state) {
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
      widget.place['isFavorited'] = state;
      if (widget.setFavoritePlaceCallback != null) {
        widget.setFavoritePlaceCallback!(widget.placeID, state);
      }
    } catch (e) {
      return;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Card(
      color: Theme.of(context).colorScheme.surface,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
      child: InkWell(
        onTap: () {
          if (context.mounted) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PlacesMorePage(
                    widget.placeID, widget.place,
                    setFavoritePlaceCallback: setFavoritePlace)));
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
                    height: 60,
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
                                  Theme.of(context).colorScheme.outline),
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
                                fontFamily: 'Manrope',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 16,
                                letterSpacing: -0.3,//14,
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
                                color: Theme.of(context).colorScheme.secondary,
                                fontFamily: 'Source Sans 3',
                                fontVariations: const [
                                  FontVariation('wght', 400),
                                ],
                                fontSize: 14,
                                letterSpacing: -0.1,
                                overflow: TextOverflow.ellipsis,
                                height: 1, //0.85
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
                      widget.place['isFavorited'] ?? false
                          ? Icons.favorite_outlined
                          : Icons.favorite_outline,
                      size: 24,
                      color: widget.place['isFavorited'] ?? false
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.outline,
                    ),
                    onPressed: () {
                      setFavoritePlace(widget.placeID,
                          !(widget.place['isFavorited'] ?? false));
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
