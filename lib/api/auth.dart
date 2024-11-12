import 'dart:convert';
import 'package:custix/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.2.140:8000/api/auth/login'),
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

  Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.2.140:8000/api/auth/register'), // Sesuaikan URL
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(json);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', authResponse.token);
      await prefs.setBool('isLoggedIn', true);

      return true;
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Signup failed: ${errorResponse['message']}');
    }
  }

  Future<bool> verifyOtp(String otp) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Mendapatkan token autentikasi

    final response = await http.post(
      Uri.parse('http://192.168.2.40:8000/api/auth/register/get/email/otp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'otp': otp, // Mengirimkan OTP untuk verifikasi
      }),
    );

    if (response.statusCode == 200) {
      prefs.setBool('isOtpRequired',
          false); // Jika OTP valid, setel status OTP tidak diperlukan lagi
      return true;
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Verifikasi OTP gagal: ${errorResponse['message']}');
    }
  }
}

