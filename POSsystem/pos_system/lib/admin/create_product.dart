// filepath: /c:/Users/akhta/Documents/GitHub/POSsystem/POSsystem/pos_system/lib/admin/create_product.dart
import 'package:flutter/material.dart';

class CreateProductPage extends StatefulWidget {
  final Map<String, String>? product;

  const CreateProductPage({super.key, this.product});

  @override
  _CreateProductPageState createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceLocalController = TextEditingController();
  final TextEditingController _priceAwayController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['name']!;
      _priceLocalController.text = widget.product!['priceLocal']!;
      _priceAwayController.text = widget.product!['priceAway']!;
      _descriptionController.text = widget.product!['description']!;
    }
  }

  void _submit() {
    final product = {
      'name': _nameController.text,
      'priceLocal': _priceLocalController.text,
      'priceAway': _priceAwayController.text,
      'description': _descriptionController.text,
    };
    Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _priceLocalController,
              decoration: const InputDecoration(labelText: 'Local Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _priceAwayController,
              decoration: const InputDecoration(labelText: 'Away Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Product Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}