import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateProductPage extends StatefulWidget {
  final Map<String, String>? product;

  const CreateProductPage({super.key, this.product});

  @override
  _CreateProductPageState createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _price1Controller = TextEditingController();
  final TextEditingController _price2Controller = TextEditingController();
  final TextEditingController _price3Controller = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['name']!;
      _price1Controller.text = widget.product!['price1']!;
      _price2Controller.text = widget.product!['price2']!;
      _price3Controller.text = widget.product!['price3']!;
      _descriptionController.text = widget.product!['description']!;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    final request = http.MultipartRequest('POST', Uri.parse('https://possystembackend.vercel.app/upload'));
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);
      return jsonResponse['id'];
    } else {
      return null;
    }
  }

  Future<Map<String, String>> _submit() async {
    String? imageId;
    if (_image != null) {
      imageId = await _uploadImage(_image!);
    }

    final product = {
      'name': _nameController.text,
      'price1': _price1Controller.text,
      'price2': _price2Controller.text,
      'price3': _price3Controller.text,
      'description': _descriptionController.text,
      'imageId': imageId ?? '',
    };

    return product;
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
              controller: _price1Controller,
              decoration: const InputDecoration(labelText: 'Price 1'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _price2Controller,
              decoration: const InputDecoration(labelText: 'Price 2'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _price3Controller,
              decoration: const InputDecoration(labelText: 'Price 3'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Product Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final product = await _submit();
                Navigator.pop(context, product);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}