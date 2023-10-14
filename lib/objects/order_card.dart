/*
  [Title]
  OrderCard

  [Description]
  An OrderCard is an object containing a place name, a list of order items from that place, and a checkout button.
  
  Created when visiting the CartPage. Each place in the cart has its own OrderCard.
*/

part of main;

// ignore: must_be_immutable
class OrderCard extends StatefulWidget {
  OrderCard(this.order, {super.key});

  Map order;

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(children: [
              Row(children: [
                Text(widget.order['createdAt'].toDate().toString())
              ]),
              Row(children: [
                Column(children: [
                  Text(widget.order['placeID']),
                  Text("${widget.order['items'].length} items"),
                ]),
                Text("Price"),
              ]),
              Text("Address"),
            ])));
  }
}
