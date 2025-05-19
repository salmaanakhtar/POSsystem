import 'package:flutter/material.dart';
import 'sales_order_page.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  CartPage({required this.cartItems});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void _updateQuantity(int index, int quantity) {
    setState(() {
      widget.cartItems[index]['quantity'] = quantity;
    });
  }

  void _updatePrice(int index, String price) {
    setState(() {
      widget.cartItems[index]['price'] = price;
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
        title: const Text('Cart', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'lib/assets/images/Yabil.png', // Use your background image path
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
          ),
          widget.cartItems.isEmpty
              ? const Center(
                  child: Text('Your cart is empty',
                      style: TextStyle(color: Colors.white)),
                )
              : ListView.builder(
                  itemCount: widget.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = widget.cartItems[index];
                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Price',
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      double? newPrice = double.tryParse(value);
                                      if (newPrice != null) {
                                        setState(() {
                                          widget.cartItems[index]['price'] =
                                              value;
                                        });
                                      }
                                    },
                                    controller: TextEditingController(
                                      text: widget.cartItems[index]['price']
                                          .toString(),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Quantity',
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      int newQuantity =
                                          int.tryParse(value) ?? 0;
                                      if (newQuantity > 0) {
                                        _updateQuantity(index, newQuantity);
                                      }
                                    },
                                    controller: TextEditingController(
                                        text: item['quantity'].toString()),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white),
                                  onPressed: () => _removeFromCart(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
      // Add this after your ListView.builder
      bottomNavigationBar: widget.cartItems.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(0), // No extra padding
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E8B57), // Steel Green
                  shape: const RoundedRectangleBorder(), // No border radius
                  elevation: 0, // No shadow
                  minimumSize:
                      const Size.fromHeight(56), // Full width, tall button
                ),
                onPressed: () async {
                  // Wait for result from SalesOrderPage
                  final cleared = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SalesOrderPage(cartItems: widget.cartItems),
                    ),
                  );
                  // If PDF was saved, clear the cart
                  if (cleared == true) {
                    setState(() {
                      widget.cartItems.clear();
                    });
                  }
                },
                child: const Text(
                  'Proceed to Sales Order',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            )
          : null,
    );
  }
}
