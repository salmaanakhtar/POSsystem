import 'package:flutter/material.dart';
import 'package:pos_system/customer/home_page.dart';
import '../db_helper.dart';

class CustomerInfoPage extends StatefulWidget {
  @override
  _CustomerInfoPageState createState() => _CustomerInfoPageState();
}

class _CustomerInfoPageState extends State<CustomerInfoPage> {
  String? location;
  final TextEditingController nameController = TextEditingController();
  List<String> customerNames = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final customers = await DbHelper().getCustomers();
    setState(() {
      customerNames = customers.map((c) => c['name'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Customer Info', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                return customerNames.where((String option) {
                  return option
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                nameController.text = selection;
              },
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onEditingComplete) {
                // Keep controllers in sync
                textEditingController.text = nameController.text;
                textEditingController.selection = TextSelection.fromPosition(
                  TextPosition(offset: textEditingController.text.length),
                );
                textEditingController.addListener(() {
                  nameController.text = textEditingController.text;
                });
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: location,
              decoration: const InputDecoration(
                labelText: 'Location',
                labelStyle: TextStyle(color: Colors.black),
              ),
              items: const [
                DropdownMenuItem(value: 'Durban', child: Text('Durban')),
                DropdownMenuItem(
                    value: 'Johannesburg', child: Text('Johannesburg')),
              ],
              onChanged: (val) => setState(() => location = val),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (location != null && nameController.text.isNotEmpty) {
                  try {
                    print('Saving customer...');
                    final customer =
                        await DbHelper().saveCustomer(nameController.text);
                    print('Customer saved: $customer');
                    if (customer['name'] != null && customer['_id'] != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerHomePage(
                            title: 'Customer Home',
                            location: location!,
                            customerName: customer['name'],
                            customerId: customer['_id'],
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to save customer.')),
                      );
                    }
                  } catch (e) {
                    print('Error saving customer: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
