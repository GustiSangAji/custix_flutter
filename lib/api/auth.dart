import 'dart:convert';
import 'package:custix/model/user.dart'; // Gantilah dengan model yang sesuai
import 'package:custix/model/DashboardData.dart'; // Pastikan Anda memiliki model DashboardData
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Model untuk menangani response login
class AuthResponse {
  final String token;
  final bool status;

  AuthResponse({required this.token, required this.status});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      status: json['status'],
    );
  }
}

class AuthRepository {
  // Fungsi untuk mendapatkan token
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Mengambil token dari SharedPreferences
  }

  // Fungsi login
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
      await prefs.setString('token', authResponse.token); // Menyimpan token
      await prefs.setBool('isLoggedIn', true); // Menyimpan status login

      return authResponse.status; // Mengembalikan status login
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Login failed: ${errorResponse['message']}');
    }
  }

  // Fungsi logout
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Menghapus token
    await prefs.setBool('isLoggedIn', false); // Mengubah status login
  }

  // Fungsi untuk mengecek status login
  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false; // Mengembalikan status login
  }

  // Fungsi untuk mengambil data dashboard
  Future<DashboardData> fetchDashboard() async {
    final token = await getToken(); // Menggunakan metode getToken
    if (token == null || token.isEmpty) {
      throw Exception('Token is missing or expired.');
    }

    final response = await http.get(
      Uri.parse('http://192.168.2.101:8000/api/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Menambahkan token di header
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
