import 'package:flutter/material.dart';
import 'create_product.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, String>> products = [];

  void addProduct(Map<String, String> product) {
    setState(() {
      products.add(product);
    });
  }

  void editProduct(int index, Map<String, String> product) {
    setState(() {
      products[index] = product;
    });
  }

  void deleteProduct(int index) {
    setState(() {
      products.removeAt(index);
    });
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
                    addProduct(result);
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
                    DataColumn(label: Text('Price Local')),
                    DataColumn(label: Text('Price Away')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Edit')),
                    DataColumn(label: Text('Delete')),
                  ],
                  rows: products
                      .asMap()
                      .entries
                      .map(
                        (entry) => DataRow(
                          cells: [
                            DataCell(Text(entry.value['name']!)),
                            DataCell(Text(entry.value['priceLocal']!)),
                            DataCell(Text(entry.value['priceAway']!)),
                            DataCell(Text(entry.value['description']!)),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateProductPage(product: entry.value),
                                    ),
                                  );
                                  if (result != null) {
                                    editProduct(entry.key, result);
                                  }
                                },
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  deleteProduct(entry.key);
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}