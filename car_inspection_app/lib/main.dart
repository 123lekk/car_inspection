import 'package:flutter/material.dart';
import 'login.dart'; 
import 'car_inspection.dart'; 
import 'admin_dashboard.dart'; 
import 'register.dart'; // เพิ่มหน้า Register
import 'list_inspection.dart'; // นำเข้า ListInspectionPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Inspection App',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(), // เพิ่ม Route สำหรับหน้า Register
        '/car_inspection': (context) => CarInspectionPage(),
        '/admin_dashboard': (context) => AdminDashboard(),
        '/list_inspection': (context) => ListInspectionPage(),
      },
    );
  }
}
