part of main;

/* Defines the model of a product in ProductsPage.
   Populates the 'distance' field using the passed device position coordinates by calculating the distance of
   the device from the place of the product.
*/
// ignore: must_be_immutable
class ProductModel {
  // Passed Properties
  String productID;
  String placeID = "";
  String productName = "";
  int productPrice = 0;
  Position? devicePosition;

  // Populated Properties
  String placeName = "";
  GeoPoint placePosition = const GeoPoint(0, 0);
  double distance = 0;

  ProductModel(this.productID, data, {this.devicePosition}) {
    productName = data["productName"];
    placeID = data["placeID"];
    productPrice = data["productPrice"];
  }

  getPlaceName() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("places").doc(placeID).get().then((document) {
      if (document.exists) {
        placeName = document.data()!['placeName'];
      }
    });
  }

  getPlaceLocation() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("places").doc(placeID).get().then((document) {
      if (document.exists) {
        placePosition = document.data()!['placePosition'];
        distance = Geolocator.distanceBetween(
            devicePosition!.latitude,
            devicePosition!.longitude,
            placePosition.latitude,
            placePosition.longitude);
      }
    });
  }
}
