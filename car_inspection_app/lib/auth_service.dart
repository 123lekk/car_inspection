import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart'; // นำเข้า package สำหรับ decode JWT Token

class AuthService {
  final _storage = FlutterSecureStorage();

  // บันทึก Token หลังจากล็อกอินสำเร็จ
  Future<void> saveToken(String token) async {
    await _storage.write(key: "auth_token", value: token);
  }

  // ดึง Token สำหรับการใช้งานในฟังก์ชันอื่น ๆ
  Future<String?> getToken() async {
    return await _storage.read(key: "auth_token");
  }

  // ลบ Token เมื่อผู้ใช้ล็อกเอาท์
  Future<void> deleteToken() async {
    await _storage.delete(key: "auth_token");
  }

  // ดึง user_id จาก Token ที่บันทึกไว้
  Future<String?> getCurrentUserId() async {
    final token = await getToken(); // ดึง Token จาก Secure Storage
    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = Jwt.parseJwt(token); // Decode JWT Token
        return decodedToken["id"]; // ดึงค่า user_id จาก Token
      } catch (e) {
        print("Failed to decode JWT Token: $e");
        return null;
      }
    }
    return null;
  }

  // ตรวจสอบว่ามีการล็อกอินหรือยัง โดยเช็คว่ามี Token หรือไม่
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
