part of main;

/* Defines the model of a place in PlacesPage.
   Populates the 'distance' field using the passed device position coordinates by calculating the distance of
   the device from the place of the product.
*/
class PlaceModel {
  // Passed properties
  String placeID;
  String placeName = "";
  String? placeTagline;

  PlaceModel(this.placeID, data) {
    placeName = data["placeName"];
    placeTagline = data["placeTagline"];
  }
}
