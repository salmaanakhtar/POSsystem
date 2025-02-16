import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'cart_page.dart';
import '../db_helper.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key, required this.title});

  final String title;

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  Map<int, String> selectedPrices = {};
  Map<int, int> quantities = {};
  Map<String, Uint8List> imageCache = {};
  List<Map<String, dynamic>> cartItems = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    searchController.addListener(_filterProducts);
  }

  Future<void> _loadProducts() async {
    var data = await DbHelper().getProducts();
    for (var product in data) {
      _loadImage(product['imageId']);
    }
    setState(() {
      products = data;
      filteredProducts = data;
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

  void _filterProducts() {
    setState(() {
      filteredProducts = products
          .where((product) =>
              product['name'].toLowerCase().contains(searchController.text.toLowerCase()) ||
              product['description'].toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _addToCart(int index) {
    if (quantities[index] != null && quantities[index]! > 0) {
      final product = filteredProducts[index];
      final cartItem = {
        'productId': product['_id'],
        'name': product['name'],
        'quantity': quantities[index]!,
        'price': selectedPrices[index]!,
        'price1': product['price1'],
        'price2': product['price2'],
        'price3': product['price3'],
      };
      setState(() {
        cartItems.add(cartItem);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to cart')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quantity must be greater than 0')),
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage(cartItems: cartItems)),
              );
            },
          ),
        ],
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
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            selectedPrices[index] ??= product['price1'];
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
                                        ? Image.memory(imageCache[product['imageId']]!, width: 120, height: 120) // Slightly bigger image
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
                                          onPressed: () => _addToCart(index),
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
          ),
        ],
      ),
    );
  }
}