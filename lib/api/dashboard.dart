import 'dart:convert';
import 'package:custix/model/DashboardData.dart';
import 'package:http/http.dart' as http;

class DashboardRepository {
  // Fungsi untuk mengambil data dashboard
  Future<DashboardData> fetchDashboardData(String token) async {
    final response = await http.get(
      Uri.parse('http://192.168.2.152:8000/api/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Menggunakan token untuk autentikasi
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
