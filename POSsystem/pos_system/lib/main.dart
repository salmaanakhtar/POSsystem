import 'package:flutter/material.dart';
import 'package:pos_system/admin/home_page.dart';
import 'login_page.dart';
import 'admin/home_page.dart';
import 'customer/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      routes: {
        '/home': (context) => const MyHomePage(title: 'Home'), // Define the /home route
        '/customer/home': (context) => const CustomerHomePage(title: 'Customer Home'), // Add this line
      },
    );
  }
}