import 'package:flutter/material.dart';
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

  void addProduct(Map<String, String> product) async {
    await DbHelper().insertProduct(product);
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

  Future<void> _confirmDelete(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to delete this product?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                deleteProduct(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                    MaterialPageRoute(
                        builder: (context) => const CreateProductPage()),
                  );
                  if (result != null) {
                    addProduct(result as Map<String, String>);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0)),
                child: const Text('Add Product',
                    style:
                        TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
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
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: products.map((product) {
                    final index = products.indexOf(product);
                    return DataRow(cells: [
                      DataCell(Text(product['name'])),
                      DataCell(Text(product['price1'])),
                      DataCell(Text(product['price2'])),
                      DataCell(Text(product['price3'])),
                      DataCell(Text(product['description'])),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateProductPage(
                                    product: {
                                      'name': product['name'],
                                      'price1': product['price1'],
                                      'price2': product['price2'],
                                      'price3': product['price3'],
                                      'description': product['description'],
                                      'imageId': product['imageId'],
                                    },
                                  ),
                                ),
                              );
                              if (result != null) {
                                editProduct(index, result as Map<String, String>);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _confirmDelete(index);
                            },
                          ),
                        ],
                      )),
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