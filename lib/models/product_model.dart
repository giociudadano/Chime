part of main;

/* Defines the model of a product in ShopPage.
   Populates the 'distance' field using the passed device position coordinates by calculating the distance of
   the device from the place of the product.
*/
class ProductModel {
  String id;
  String productName = "", placeName = "";
  int productPrice = 0;
  GeoPoint placePosition = const GeoPoint(0, 0);
  Position devicePosition;
  double distance = 0;

  ProductModel(this.id, data, this.devicePosition) {
    productName = data["productName"];
    placeName = data["placeName"];
    productPrice = data["productPrice"];
    placePosition = data["placePosition"];
    getDistance();
  }

  // Calculates and sets the distance of the device from the product. Used to populate the 'distance' field.
  void getDistance() {
    distance = Geolocator.distanceBetween(
        devicePosition.latitude,
        devicePosition.longitude,
        placePosition.latitude,
        placePosition.longitude);
  }
}
