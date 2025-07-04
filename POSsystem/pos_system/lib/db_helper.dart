import 'package:http/http.dart' as http;
import 'dart:convert';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  final String baseUrl = 'https://possystembackend.vercel.app';

  Future<void> insertProduct(Map<String, String> product) async {
    print(product); // Add this before insertProduct
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to insert product');
    }
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> updateProduct(String id, Map<String, String> product) async {
    print(product); // Add this before updateProduct
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update product');
    }
  }

  Future<void> deleteProduct(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }

  Future<Map<String, dynamic>> saveCustomer(String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/customers'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to save customer');
    }
  }

  Future<List<Map<String, dynamic>>> getCustomers() async {
    final response = await http.get(Uri.parse('$baseUrl/customers'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load customers');
    }
  }

  Future<void> saveSalesOrder({
    required String customerId,
    required String customerName,
    required List<Map<String, dynamic>> items,
    required String paymentType,
    required String total,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/salesorders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customerId': customerId,
        'customerName': customerName,
        'items': items,
        'paymentType': paymentType,
        'total': total,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save sales order');
    }
  }
}
