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
  List<Map<String, dynamic>> filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  Future<void> _loadProducts() async {
    var data = await DbHelper().getProducts();
    setState(() {
      products = data;
      filteredProducts = data;
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products.where((product) {
        final name = product['name'].toLowerCase();
        return name.contains(query);
      }).toList();
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
          title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to delete this product?', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          backgroundColor: Colors.black,
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
        title: Text(widget.title, style: const TextStyle(color: Colors.white,)),
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
            color: Colors.black.withOpacity(0.75),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
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
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255)),
                    child: const Text('Add Product',
                        style:
                            TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
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
                        DataColumn(label: Text('Name', style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text('Price 1', style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text('Price 2', style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text('Price 3', style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text('Description', style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text('Actions', style: TextStyle(color: Colors.white))),
                      ],
                      rows: filteredProducts.map((product) {
                        final index = products.indexOf(product);
                        return DataRow(cells: [
                          DataCell(Text(product['name'], style: const TextStyle(color: Colors.white))),
                          DataCell(Text(product['price1'], style: const TextStyle(color: Colors.white))),
                          DataCell(Text(product['price2'], style: const TextStyle(color: Colors.white))),
                          DataCell(Text(product['price3'], style: const TextStyle(color: Colors.white))),
                          DataCell(Text(product['description'], style: const TextStyle(color: Colors.white))),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white),
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
                                icon: const Icon(Icons.delete, color: Colors.white),
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
        ],
      ),
    );
  }
}