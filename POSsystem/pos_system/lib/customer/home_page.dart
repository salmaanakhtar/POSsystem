import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'cart_page.dart';
import '../db_helper.dart';
import '../login_page.dart'; // Make sure this import is correct

class CustomerHomePage extends StatefulWidget {
  final String title;
  final String location;
  final String customerName;
  final String customerId; // <-- Add this

  const CustomerHomePage({
    super.key,
    required this.title,
    required this.location,
    required this.customerName,
    required this.customerId, // <-- Add this
  });

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
    // Only include active products
    data = data.where((product) => product['active'] != false).toList();
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
      final response = await http
          .get(Uri.parse('https://possystembackend.vercel.app/image/$imageId'));
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
              product['name']
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              product['description']
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _addToCart(int index) {
    if (quantities[index] != null && quantities[index]! > 0) {
      final product = filteredProducts[index];
      final price = widget.location == 'Johannesburg'
          ? (product['price2'] != null &&
                  product['price2'].toString().isNotEmpty
              ? product['price2']
              : product['price'])
          : product['price'];
      final cartItem = {
        'productId': product['_id'],
        'name': product['name'],
        'quantity': quantities[index]!,
        'price': price ?? '0',
        'description': product['description'], // <-- Add this
        'price2': product['price2'], // <-- Add this
        'location': widget.location, // <-- Add this
      };
      setState(() {
        cartItems.add(cartItem);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to cart'),
          backgroundColor: Color(0xFF2E8B57),
        ),
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

  int extractTotalUnits(String description) {
    // Find all numbers in the description
    final regex = RegExp(r'(\d+)');
    final matches = regex.allMatches(description).toList();

    if (matches.isNotEmpty) {
      // Use the last number as the unit count
      return int.tryParse(matches.last.group(1)!) ?? 1;
    }
    return 1;
  }

  String getUnitPrice(Map<String, dynamic> product, String location) {
    final description = product['description'] ?? '';
    final totalUnits = extractTotalUnits(description);

    final price = location == 'Johannesburg'
        ? (product['price2'] != null && product['price2'].toString().isNotEmpty
            ? double.tryParse(product['price2'].toString()) ?? 0
            : double.tryParse(product['price'].toString()) ?? 0)
        : double.tryParse(product['price'].toString()) ?? 0;

    if (totalUnits > 0 && price > 0) {
      final unitPrice = price / totalUnits;
      return 'R ${unitPrice.toStringAsFixed(2)}';
    } else {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(
                    cartItems: cartItems,
                    customerName: widget.customerName,
                    customerId: widget.customerId, // <-- Add this
                  ),
                ),
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

                            return Card(
                              color: Colors.white.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        if (imageCache
                                            .containsKey(product['imageId'])) {
                                          showDialog(
                                            context: context,
                                            builder: (_) => Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: InteractiveViewer(
                                                child: Image.memory(
                                                  imageCache[
                                                      product['imageId']]!,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: imageCache
                                              .containsKey(product['imageId'])
                                          ? Image.memory(
                                              imageCache[product['imageId']]!,
                                              width: 240,
                                              height: 240,
                                            )
                                          : const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            product['name'],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            product['description'],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'Unit Price: ${getUnitPrice(product, widget.location)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          'Price: R ${widget.location == 'Johannesburg' ? (product['price2'] != null && product['price2'].toString().isNotEmpty ? product['price2'] : product['price']) : product['price'] ?? 'N/A'}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: 100,
                                          child: TextField(
                                            decoration: const InputDecoration(
                                              labelText: 'Quantity',
                                              labelStyle: TextStyle(
                                                  color: Colors.white),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            style: const TextStyle(
                                                color: Colors.white),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              setState(() {
                                                quantities[index] =
                                                    int.tryParse(value) ?? 0;
                                              });
                                            },
                                            onEditingComplete: () {
                                              _addToCart(index);
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
