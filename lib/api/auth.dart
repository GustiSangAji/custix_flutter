import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final String baseUrl =
      'http://192.168.2.153:8000/api/auth'; // Sesuaikan alamat URL backend Anda

  // Fungsi untuk login
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
      final token = json['token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setBool('isLoggedIn', true);

      return true;
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Login failed: ${errorResponse['message']}');
    }
  }

  // Fungsi untuk logout
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.setBool('isLoggedIn', false);
  }

  // Fungsi untuk mengecek status login
  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Fungsi untuk mengirim OTP ke email saat registrasi
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
