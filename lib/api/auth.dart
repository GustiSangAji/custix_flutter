import 'dart:convert';
import 'package:custix/model/user.dart'; // Gantilah dengan model yang sesuai
import 'package:custix/model/DashboardData.dart'; // Pastikan Anda memiliki model DashboardData
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  // Fungsi untuk mendapatkan token
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Mengambil token dari SharedPreferences
  }

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.2.101:8000/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(json);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', authResponse.token);
      await prefs.setBool('isLoggedIn', true);

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

  Future<DashboardData> fetchDashboard() async {
    final token = await getToken(); // Menggunakan metode getToken
    if (token == null || token.isEmpty) {
      throw Exception('Token is missing or expired.');
    }

    final response = await http.get(
      Uri.parse('http://192.168.2.100:8000/api/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DashboardData.fromJson(
          data); // Parsing data ke dalam objek DashboardData
    } else {
      throw Exception('Failed to load dashboard: ${response.body}');
    }
  }
}
