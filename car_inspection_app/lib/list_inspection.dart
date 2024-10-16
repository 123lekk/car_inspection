import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ListInspectionPage extends StatefulWidget {
  @override
  _ListInspectionPageState createState() => _ListInspectionPageState();
}

class _ListInspectionPageState extends State<ListInspectionPage> {
  List userCars = []; // เก็บข้อมูลรถของผู้ใช้

  @override
  void initState() {
    super.initState();
    fetchUserCars(); // ดึงข้อมูลรถเมื่อหน้าจอถูกเปิด
  }

  // ฟังก์ชันดึงข้อมูลรถของผู้ใช้
  Future<void> fetchUserCars() async {
    final token = await AuthService().getToken(); // ดึง Token
    final userId = await AuthService().getCurrentUserId(); // ดึง user_id ของผู้ใช้ปัจจุบัน
    final url = Uri.parse(
        'http://127.0.0.1:8090/api/collections/cars/records?filter=user_id="$userId"');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userCars = json.decode(response.body)['items'];
      });
      print("Fetched user's cars: $userCars");
    } else {
      print('Failed to fetch user cars: ${response.body}');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch car data. Please try again later.'),
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
      appBar: AppBar(title: Text('Your Inspections')),
      body: userCars.isEmpty
          ? Center(child: Text('No cars found.'))
          : ListView.builder(
              itemCount: userCars.length,
              itemBuilder: (context, index) {
                final car = userCars[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${car['name']}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('License Plate: ${car['licensePlate_cars']}'),
                            Text('Status: ${car['status']}'),
                          ],
                        ),
                        // เพิ่มปุ่มจัดการอื่นๆ ตามต้องการ
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // กดเพื่อแก้ไข หรือทำอย่างอื่น
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
