part of main;

/* Defines the model of a place in PlacesPage.
   Populates the 'distance' field using the passed device position coordinates by calculating the distance of
   the device from the place of the product.
*/
class PlaceModel {
  String id;
  String placeName = "";
  String placeTagline = "";
  GeoPoint placePosition = const GeoPoint(0, 0);
  Position devicePosition;
  double distance = 0;

  PlaceModel(this.id, data, this.devicePosition) {
    placeName = data["placeName"];
    placeTagline = data["placeTagline"];
    placePosition = data["placePosition"];
    getDistance();
  }

  // Calculates and sets the distance of the device from the place. Used to populate the 'distance' field.
  void getDistance() {
    distance = Geolocator.distanceBetween(
        devicePosition.latitude,
        devicePosition.longitude,
        placePosition.latitude,
        placePosition.longitude);
  }
}
