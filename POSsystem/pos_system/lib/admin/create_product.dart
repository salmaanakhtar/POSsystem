import 'dart:io';
import 'dart:typed_data';
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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _price2Controller = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  Uint8List? _networkImageBytes;
  String? _currentImageId;
  String _selectedCategory = 'drinks'; // Default

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['name']!;
      _priceController.text = widget.product!['price']!;
      _price2Controller.text = widget.product!['price2'] ?? '';
      _descriptionController.text = widget.product!['description']!;
      _currentImageId = widget.product!['imageId'];
      _selectedCategory =
          widget.product!['category'] ?? 'drinks'; // <-- Add this
      if (_currentImageId != null && _currentImageId!.isNotEmpty) {
        _loadNetworkImage(_currentImageId!);
      }
    }
  }

  Future<void> _loadNetworkImage(String imageId) async {
    try {
      final response = await http
          .get(Uri.parse('https://possystembackend.vercel.app/image/$imageId'));
      if (response.statusCode == 200) {
        setState(() {
          _networkImageBytes = response.bodyBytes;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    final request = http.MultipartRequest(
        'POST', Uri.parse('https://possystembackend.vercel.app/upload'));
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
    String? imageId = _currentImageId;
    if (_image != null) {
      imageId = await _uploadImage(_image!);
    }

    final product = {
      'name': _nameController.text,
      'price': _priceController.text,
      'price2': _price2Controller.text,
      'description': _descriptionController.text,
      'imageId': imageId ?? '',
      'category': _selectedCategory, // <-- Add this
    };

    return product;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Create Product', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
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
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _price2Controller,
                    decoration: const InputDecoration(
                      labelText: 'Price 2',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Product Description',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'drinks', child: Text('Drinks')),
                      DropdownMenuItem(value: 'sweets', child: Text('Sweets')),
                      DropdownMenuItem(
                          value: 'chocolates', child: Text('Chocolates')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedCategory = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_networkImageBytes != null && _image == null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Image.memory(_networkImageBytes!, height: 100),
                    ),
                  if (_image != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Image.file(_image!, height: 100),
                    ),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                        widget.product == null ? 'Pick Image' : 'Change Image'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_image == null && widget.product == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please pick an image')),
                          );
                          return;
                        }
                        final product = await _submit();
                        Navigator.pop(context, product);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
