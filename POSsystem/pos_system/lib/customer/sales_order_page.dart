import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../db_helper.dart';

class SalesOrderPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final String customerName;
  final String customerId; // <-- Add this

  const SalesOrderPage({
    super.key,
    required this.cartItems,
    required this.customerName,
    required this.customerId, // <-- Add this
  });

  @override
  State<SalesOrderPage> createState() => _SalesOrderPageState();
}

class _SalesOrderPageState extends State<SalesOrderPage> {
  late final TextEditingController customerController;
  String paymentType = 'Cash on delivery';

  @override
  void initState() {
    super.initState();
    customerController = TextEditingController(text: widget.customerName);
  }

  double get orderTotal {
    double total = 0;
    for (var item in widget.cartItems) {
      final price = double.tryParse(item['price'].toString()) ?? 0;
      final qty = item['quantity'] ?? 0;
      total += price * qty;
    }
    return total;
  }

  Future<void> _savePdfAndClearCart() async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd-MM-yyyy').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Yabil Distributors',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text(dateStr, style: pw.TextStyle(fontSize: 14)),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text('Customer: ${customerController.text}',
                style: pw.TextStyle(fontSize: 16)),
            pw.Text('Payment Type: $paymentType',
                style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Product', 'Qty', 'Unit Price', 'Total'],
              data: widget.cartItems.map((item) {
                final price = double.tryParse(item['price'].toString()) ?? 0;
                final qty = item['quantity'] ?? 0;
                final total = price * qty;
                return [
                  item['name'] ?? '',
                  qty.toString(),
                  'R ${price.toStringAsFixed(2)}',
                  'R ${total.toStringAsFixed(2)}',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Order Total: R ${orderTotal.toStringAsFixed(2)}',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );

    // Save PDF to device
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'sales_order_${dateStr}.pdf',
    );

    // Save sales order to database
    await DbHelper().saveSalesOrder(
      customerId: widget.customerId,
      customerName: widget.customerName,
      items: widget.cartItems,
      paymentType: paymentType,
      total: orderTotal.toStringAsFixed(2),
    );

    // Pop and signal to clear the cart
    if (mounted) Navigator.pop(context, true);
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
    final String dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Order', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.black.withOpacity(1),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and Banner
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(width: 1), // To push date to right
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          dateStr,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: Colors.white.withOpacity(0.2),
                    child: const Center(
                      child: Text(
                        'Yabil Distributors',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Customer Name Field
                  TextField(
                    controller:
                        TextEditingController(text: customerController.text),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Payment Type Dropdown
                  Row(
                    children: [
                      const Text(
                        'Payment Type:',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: paymentType,
                        dropdownColor: Colors.black,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        items: const [
                          DropdownMenuItem(
                            value: 'COD',
                            child: Text('COD (Cash On Delivery)',
                                style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: 'Account',
                            child: Text('Account',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            paymentType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Table
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            MaterialStateProperty.all(Colors.white24),
                        dataRowColor: MaterialStateProperty.all(Colors.white10),
                        columns: const [
                          DataColumn(
                              label: Text('Product',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('Description',
                                  style:
                                      TextStyle(color: Colors.white))), // NEW
                          DataColumn(
                              label: Text('Qty',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('Price',
                                  style:
                                      TextStyle(color: Colors.white))), // NEW
                          DataColumn(
                              label: Text('Unit Price',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('Total',
                                  style: TextStyle(color: Colors.white))),
                        ],
                        rows: widget.cartItems.map((item) {
                          final price =
                              double.tryParse(item['price'].toString()) ?? 0;
                          final qty = item['quantity'] ?? 0;
                          final total = price * qty;
                          final description = item['description'] ?? '';
                          final location = item['location'] ?? '';
                          return DataRow(
                            cells: [
                              DataCell(Text(item['name'] ?? '',
                                  style: const TextStyle(color: Colors.white))),
                              DataCell(Text(description,
                                  style: const TextStyle(
                                      color: Colors.white))), // NEW
                              DataCell(Text(qty.toString(),
                                  style: const TextStyle(color: Colors.white))),
                              DataCell(Text('R ${price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.white))), // NEW
                              DataCell(Text(
                                  getUnitPrice(item, item['location'] ?? ""),
                                  style: const TextStyle(color: Colors.white))),
                              DataCell(Text('R ${total.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Order Total: R ${orderTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                      height: 80), // Add space for the floating total
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E8B57),
                ),
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text('Save PDF',
                    style: TextStyle(color: Colors.white)),
                onPressed: _savePdfAndClearCart,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
