import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart'; // นำเข้า AuthService เพื่อดึง Token

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List cars = [];
  final authService = AuthService(); // สร้าง Instance ของ AuthService

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  Future<void> fetchCars() async {
    try {
      final token = await authService.getToken(); // ดึง Token ที่บันทึกไว้
      print("Token: $token");
      final url = Uri.parse('http://127.0.0.1:8090/api/collections/cars/records');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          cars = json.decode(response.body)['items'];
        });
        print("Fetched cars: $cars");
      } else {
        print('Failed to fetch cars: ${response.body}');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch car data. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error fetching cars: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred while fetching car data. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // ฟังก์ชันอัปเดตสถานะของรถ
  Future<void> updateCarStatus(String carId, String status) async {
  final token = await authService.getToken(); // ดึง Token ที่บันทึกไว้
  final url = Uri.parse('http://127.0.0.1:8090/api/collections/cars/records/$carId');
  final response = await http.patch(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'status': status}),
  );

  if (response.statusCode == 200) {
    print('Car status updated successfully!');
    fetchCars(); // โหลดข้อมูลใหม่หลังจากอัปเดต
  } else {
    print('Failed to update car status: ${response.body}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Failed to update car status. Please try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}


  // ฟังก์ชันลบข้อมูลรถ
  Future<void> deleteCar(String carId) async {
    final token = await authService.getToken(); // ดึง Token ที่บันทึกไว้
    final url = Uri.parse('http://127.0.0.1:8090/api/collections/cars/records/$carId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      print('Car deleted successfully!');
      fetchCars(); // โหลดข้อมูลใหม่หลังจากลบ
    } else {
      print('Failed to delete car: ${response.body}');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to delete car. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
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
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: cars.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${car['name']} - ${car['licensePlate_cars']}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        DropdownButton<String>(
                          value: car['status'], // ค่าปัจจุบันของสถานะ (เป็น String)
                          items: [
                            DropdownMenuItem(
                              value: 'กำลังดำเนินการ',
                              child: Text('กำลังดำเนินการ'),
                            ),
                            DropdownMenuItem(
                              value: 'ผ่าน',
                              child: Text('ผ่าน'),
                            ),
                            DropdownMenuItem(
                              value: 'ไม่ผ่าน',
                              child: Text('ไม่ผ่าน'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              updateCarStatus(car['id'], value); // ปรับใช้สถานะใหม่
                            }
                          },
                        ),

                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteCar(car['id']); // เรียกฟังก์ชันลบ
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
