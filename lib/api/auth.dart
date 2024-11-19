import 'dart:convert';
//import 'package:custix/model/user.dart'; // Gantilah dengan model yang sesuai
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
  final String baseUrl = 'http://192.168.2.101:8000/api/auth';

  // Fungsi untuk mendapatkan token
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Mengambil token dari SharedPreferences
  }

  // Fungsi login
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
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

  // Fungsi untuk mengirim OTP
  Future<bool> sendOtp(String email, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/get/email/otp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'nama': name,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Failed to send OTP: ${errorResponse['message']}');
    }
  }

  // Fungsi untuk verifikasi OTP
  Future<bool> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/check/email/otp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception('OTP verification failed: ${errorResponse['message']}');
    }
  }

  // Fungsi untuk registrasi lengkap dengan password
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'nama': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': confirmPassword,
        'otp_email': otp,
      }),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final token = json['token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setBool('isLoggedIn', true);

      return true;
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Registration failed: ${errorResponse['message']}');
    }
  }

  // Fungsi untuk mengambil data dashboard
  Future<DashboardData> fetchDashboard() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token is missing or expired.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DashboardData.fromJson(data);
    } else {
      throw Exception('Failed to load dashboard: ${response.body}');
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
}
