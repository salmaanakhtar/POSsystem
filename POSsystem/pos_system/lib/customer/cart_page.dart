import 'package:flutter/material.dart';

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
        title: const Text('Cart', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: widget.cartItems.isEmpty
          ? const Center(
              child: Text('Your cart is empty', style: TextStyle(color: Colors.white)),
            )
          : ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                return Card(
                  color: Colors.white.withOpacity(0.1), // White translucent background
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
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              DropdownButton<String>(
                                value: item['price'],
                                hint: const Text('Select Price', style: TextStyle(color: Colors.white)),
                                dropdownColor: Colors.black,
                                items: [
                                  DropdownMenuItem(
                                    value: item['price1'],
                                    child: Text('Price 1: ${item['price1']}', style: const TextStyle(color: Colors.white)),
                                  ),
                                  DropdownMenuItem(
                                    value: item['price2'],
                                    child: Text('Price 2: ${item['price2']}', style: const TextStyle(color: Colors.white)),
                                  ),
                                  DropdownMenuItem(
                                    value: item['price3'],
                                    child: Text('Price 3: ${item['price3']}', style: const TextStyle(color: Colors.white)),
                                  ),
                                ],
                                onChanged: (value) {
                                  _updatePrice(index, value!);
                                },
                              ),
                              const SizedBox(height: 5),
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Quantity',
                                  labelStyle: TextStyle(color: Colors.white),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  int newQuantity = int.tryParse(value) ?? 0;
                                  if (newQuantity > 0) {
                                    _updateQuantity(index, newQuantity);
                                  }
                                },
                                controller: TextEditingController(text: item['quantity'].toString()),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white),
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
    );
  }
}