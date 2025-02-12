import 'package:flutter/material.dart';
import '../db_helper.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key, required this.title});

  final String title;

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  List<Map<String, dynamic>> products = [];
  Map<int, String> selectedPrices = {};
  Map<int, int> quantities = {};
  Map<String, Uint8List> imageCache = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    var data = await DbHelper().getProducts();
    for (var product in data) {
      _loadImage(product['imageId']);
    }
    setState(() {
      products = data;
    });
  }

  Future<void> _loadImage(String imageId) async {
    if (!imageCache.containsKey(imageId)) {
      final response = await http.get(Uri.parse('https://possystembackend.vercel.app/image/$imageId'));
      if (response.statusCode == 200) {
        setState(() {
          imageCache[imageId] = response.bodyBytes;
        });
      } else {
        throw Exception('Failed to load image');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'lib/assets/images/Yabil.png', // Path to your background image
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: products.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        color: Colors.white.withOpacity(0.1), // White translucent background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              imageCache.containsKey(product['imageId'])
                                  ? Image.memory(imageCache[product['imageId']]!, width: 240, height: 240) // Slightly bigger image
                                  : const Center(child: CircularProgressIndicator()),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      product['name'],
                                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      product['description'],
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  DropdownButton<String>(
                                    value: selectedPrices[index],
                                    hint: const Text('Select Price', style: TextStyle(color: Colors.white)),
                                    dropdownColor: Colors.black,
                                    items: [
                                      DropdownMenuItem(
                                        value: product['price1'],
                                        child: Text('Price 1: ${product['price1']}', style: const TextStyle(color: Colors.white)),
                                      ),
                                      DropdownMenuItem(
                                        value: product['price2'],
                                        child: Text('Price 2: ${product['price2']}', style: const TextStyle(color: Colors.white)),
                                      ),
                                      DropdownMenuItem(
                                        value: product['price3'],
                                        child: Text('Price 3: ${product['price3']}', style: const TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedPrices[index] = value!;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
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
                                        setState(() {
                                          quantities[index] = int.tryParse(value) ?? 0;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Add to cart logic here
                                    },
                                    child: const Text('Add to Cart'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}