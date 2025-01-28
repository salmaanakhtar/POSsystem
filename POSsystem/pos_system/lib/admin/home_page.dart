import 'package:flutter/material.dart';
import 'dart:io';
import '../db_helper.dart';
import 'create_product.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    var data = await DbHelper().getProducts();
    setState(() {
      products = data;
    });
  }

  void addProduct(Map<String, String> product, File? image) async {
    await DbHelper().insertProduct(product, image);
    _loadProducts();
  }

  void editProduct(int index, Map<String, String> product) async {
    await DbHelper().updateProduct(products[index]['_id'].toString(), product);
    _loadProducts();
  }

  void deleteProduct(int index) async {
    await DbHelper().deleteProduct(products[index]['_id'].toString());
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateProductPage()),
                  );
                  if (result != null) {
                    final data = result as Map<String, dynamic>;
                    addProduct(data['product'] as Map<String, String>, data['image'] as File?);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0)
                ),
                child: const Text('Add Product', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Price 1')),
                    DataColumn(label: Text('Price 2')),
                    DataColumn(label: Text('Price 3')),
                    DataColumn(label: Text('Description')),
                  ],
                  rows: products.map((product) {
                    return DataRow(cells: [
                      DataCell(Text(product['name'])),
                      DataCell(Text(product['price1'])),
                      DataCell(Text(product['price2'])),
                      DataCell(Text(product['price3'])),
                      DataCell(Text(product['description'])),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}