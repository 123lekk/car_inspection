import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'list_inspection.dart'; // นำเข้า ListInspectionPage

class CarInspectionPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController licensePlateController = TextEditingController();

  Future<void> submitCarInspection(BuildContext context) async {
    final token = await AuthService().getToken(); // ดึง Token ที่บันทึกไว้
    final userId = await AuthService().getCurrentUserId(); // ดึง user_id ของผู้ใช้ปัจจุบัน
    final url = Uri.parse('http://127.0.0.1:8090/api/collections/cars/records');
    
    // พิมพ์ค่าที่จะส่งออกมาดูก่อน
    print("User ID: $userId");
    print("Car Name: ${nameController.text}");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token' // เพิ่ม Header Authentication
      },
      body: jsonEncode({
        'user_id': userId, // เพิ่มฟิลด์ user_id ที่ดึงมาจาก AuthService
        'name': nameController.text,
        'color_cars': colorController.text,
        'brand_cars': brandController.text,
        'model_cars': modelController.text,
        'type_cars': typeController.text,
        'licensePlate_cars': licensePlateController.text,
        'status': 'กำลังดำเนินการ', // ค่าเริ่มต้นเป็น "กำลังดำเนินการ"
      }),
    );

    // ตรวจสอบสถานะการตอบสนองและพิมพ์ออกมา
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) { // เพิ่มเช็คที่ยืดหยุ่นขึ้น
      print('Car inspection submitted successfully!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ListInspectionPage()), // นำทางไปยังหน้า ListInspectionPage
      );
    } else {
      print('Failed to submit car inspection: ${response.body}');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to submit car inspection: ${response.body}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Car Inspection')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: colorController, decoration: InputDecoration(labelText: 'Color')),
            TextField(controller: brandController, decoration: InputDecoration(labelText: 'Brand')),
            TextField(controller: modelController, decoration: InputDecoration(labelText: 'Model')),
            TextField(controller: typeController, decoration: InputDecoration(labelText: 'Type')),
            TextField(controller: licensePlateController, decoration: InputDecoration(labelText: 'License Plate')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                submitCarInspection(context);
              },
              child: Text('Submit Inspection'),
            ),
          ],
        ),
      ),
    );
  }
}
