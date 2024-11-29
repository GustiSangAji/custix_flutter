import 'dart:convert';
import 'package:http/http.dart' as http;

class TicketRepository {
  final String baseUrl = "http://192.168.2.140:8000/api"; // URL backend Anda

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

  Future<void> createOrder(
    int ticketId,
    String ticketName,
    double totalPrice,
    int quantity,
  ) async {
    final url =
        'http://192.168.2.140:8000/api/store'; // Ganti dengan URL endpoint yang sesuai
    final token =
        'YOUR_AUTHORIZATION_TOKEN'; // Jika menggunakan autentikasi Bearer

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Jika menggunakan token autentikasi
      },
      body: json.encode({
        'jumlah_pemesanan': quantity,
        'product': {
          'id': ticketId,
          'nama_tiket': ticketName,
          'total_harga': totalPrice,
        },
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      // Menampilkan atau memproses data keranjang yang baru dibuat
      print('Order ID: ${data['cart']['order_id']}');
      // Lanjutkan dengan proses checkout
    } else {
      // Menangani error jika gagal membuat order
      final error = json.decode(response.body);
      print('Error: ${error['message']}');
    }
  }

  Future<void> checkout(String orderId) async {
    final response = await http.post(
      Uri.parse('http://192.168.2.140:8000/api/payment/$orderId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer YOUR_ACCESS_TOKEN', // Jika Anda menggunakan token autentikasi
      },  
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Mengakses snap_token dengan benar
      final snapToken = data['snap_token'];

      if (snapToken != null) {
        // Lanjutkan dengan WebView untuk pembayaran menggunakan snapToken
        print('Snap Token: $snapToken');
        // Misalnya, lanjutkan ke halaman pembayaran
      } else {
        print('Snap token tidak ditemukan dalam respons');
      }
    } else {
      // Tangani error jika checkout gagal
      print('Gagal checkout');
    }
  }
}
