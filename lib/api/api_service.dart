import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:custix/model/ticket_model.dart'; // Pastikan model ticket_model.dart sudah sesuai
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.2.101:8000/api';

  // Mendapatkan daftar tiket
  Future<List<dynamic>> fetchTickets(String s, {String? token}) async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.2.101:8000/api/tiket'), // Sesuaikan URL API Anda
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Status Response: ${response.statusCode}');
    print('Headers Response: ${response.headers}');
    print('Body Response: ${response.body}');

    if (response.statusCode == 200) {
      // Parsing JSON jika respons berhasil
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load tickets');
    }
  }

  // Mendapatkan tiket berdasarkan UUID
  Future<Ticket> fetchTicketById(String uuid) async {
    final response = await http.get(Uri.parse('$baseUrl/tiket/$uuid'));
    if (response.statusCode == 200) {
      return Ticket.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to load ticket with UUID $uuid: ${response.statusCode}');
      throw Exception('Gagal memuat data tiket');
    }
  }

  // Menambah atau memperbarui tiket
  Future<void> saveTicket(Map<String, dynamic> data, {String? uuid}) async {
    final url = uuid != null ? '$baseUrl/tiket/$uuid' : '$baseUrl/tiket/store';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Ticket saved successfully');
    } else {
      print('Failed to save ticket: ${response.statusCode}');
      throw Exception('Gagal menyimpan data tiket');
    }
  }

  // Menghapus tiket
  Future<void> deleteTicket(String uuid) async {
    final response = await http.delete(Uri.parse('$baseUrl/tiket/$uuid'));
    if (response.statusCode == 200) {
      print('Ticket deleted successfully');
    } else {
      print('Failed to delete ticket: ${response.statusCode}');
      throw Exception('Gagal menghapus tiket');
    }
  }
}
