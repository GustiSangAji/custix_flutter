import 'dart:convert';
import 'package:http/http.dart' as http;

class TicketRepository {
  final String baseUrl = "http://192.168.2.154:8000/api"; // URL backend Anda

  Future<List<dynamic>> getTickets() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tickets'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']; // Ambil key 'data' yang berisi daftar tiket
    } else {
      throw Exception('Gagal mengambil data tiket');
    }
  }

  /// Fungsi untuk mencari tiket berdasarkan query
  Future<List<dynamic>> searchTickets(String query) async {
    final response = await http.post(
      Uri.parse(
          '$baseUrl/tickets/search?query=$query'), // Endpoint pencarian tiket
      headers: {'Accept': 'application/json'}, // Header yang diperlukan
      body: json.encode({'query': query}), // Data query yang dikirim
    );

    // Cek status response
    if (response.statusCode == 200) {
      return json.decode(response.body); // Decode JSON jika berhasil
    } else {
      throw Exception('Gagal mengambil data tiket'); // Lempar error jika gagal
    }
  }
}
