import 'dart:convert';
import 'package:custix/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.2.152:8000/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json', // Menambahkan header JSON
      },
      body: jsonEncode({
        // Mengonversi body ke format JSON
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(json);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', authResponse.token);
      await prefs.setBool('isLoggedIn', true); // simpan status login

      return authResponse.status;
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Login failed: ${errorResponse['message']}');
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // hapus token
    await prefs.setBool('isLoggedIn', false); // ubah status login
  }

  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
