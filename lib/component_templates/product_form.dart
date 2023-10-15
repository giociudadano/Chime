/*
  [Title]
  ProductForm

  [Description]
  A product form allows users to publish their own products. It contains 
  product name, tag, price, quantity, and description

  Created when user selects the create a product floating button in their storepage
*/
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

List<DropdownMenuItem<String>> get dropdownItems {
  List<DropdownMenuItem<String>> menuItems = [
    const DropdownMenuItem(value: "Featured", child: Text("Featured")),
    const DropdownMenuItem(value: "Regular", child: Text("Regular")),
    const DropdownMenuItem(value: "Budget", child: Text("Budget")),
    const DropdownMenuItem(value: "Beverages", child: Text("Beverages")),
    const DropdownMenuItem(
        value: "Snacks and Desserts", child: Text("Snacks and Desserts")),
  ];
  return menuItems;
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Product Form';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: const MyCustomForm(),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  State<MyCustomForm> createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {
  String selectedValue = "Featured";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // textfield for product name
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                const Align(
                    alignment: Alignment.topLeft, child: Text('Product Name')),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Strawberry shortcake',
                  ),
                ),
              ],
            ),
          ),

          // dropdown for product tag
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                const Align(alignment: Alignment.topLeft, child: Text('Tag')),
                const SizedBox(height: 10),
                DropdownButtonFormField(
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(),
                      border: OutlineInputBorder(),
                    ),
                    value: selectedValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue!;
                      });
                    },
                    items: dropdownItems)
              ],
            ),
          ),

          // int field for product price
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                const Align(alignment: Alignment.topLeft, child: Text('Price')),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: SizedBox(
                        width: 10,
                        height: 10,
                        child: Center(
                            child: Text(
                          '₱',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 174, 174, 174),
                          ),
                        ))),
                    border: OutlineInputBorder(),
                    hintText: '30',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ],
            ),
          ),

          // int field for product quantity
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                const Align(
                    alignment: Alignment.topLeft, child: Text('Quantity')),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '10',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ],
            ),
          ),

          // textfield for product description
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                const Align(
                    alignment: Alignment.topLeft, child: Text('Description')),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText:
                        'A dessert with a crumbly scone-like texture served with whipped cream.',
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLength: 250,
                  maxLines: 4,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                // button to submit product
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                // spacer
                const SizedBox(
                  height: 10,
                ),

                // button to delete product
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Delete Product',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
