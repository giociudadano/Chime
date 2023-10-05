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

  ProductModel(this.productID, data) {
    productName = data["productName"];
    placeID = data["placeID"];
    productPrice = data["productPrice"];
  }
}
