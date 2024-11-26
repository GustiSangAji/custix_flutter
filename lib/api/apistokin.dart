import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:custix/model/stockin.dart';

class ApiStokin {
  static const String baseUrl = 'http://192.168.2.101:8000/api';

  // Get data stock-in
  Future<List<StockIn>> getStockIns({
    int page = 1,
    int perPage = 10,
    required String token,
  }) async {
    try {
      // Log informasi request
      print('Request URL: $baseUrl/stockin');
      print('Headers: Authorization: Bearer $token');

      // Kirim permintaan ke API
      final response = await http.post(
        Uri.parse('$baseUrl/stockin'),
        headers: {
          'Authorization': 'Bearer $token', // Header otorisasi
          'Accept': 'application/json', // Header format respons
        },
      );

      // Log respons API
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parsing data jika respons berhasil
        List<dynamic> data = json.decode(response.body)['data'];
        return data.map((item) => StockIn.fromJson(item)).toList();
      } else {
        // Jika respons gagal, lemparkan exception dengan informasi tambahan
        throw Exception(
          'Failed to load stockins. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      // Tangkap dan log error
      print('Error in getStockIns: $e');
      rethrow; // Rethrow untuk ditangani di luar
    }
  }

  // Create new stock-in
  Future<StockIn> createStockIn(StockIn stockIn,
      {required String token}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/stockin/store'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: json.encode(stockIn.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Periksa apakah respons memiliki data yang diharapkan
        if (responseData['success'] == true &&
            responseData['stockin'] != null) {
          return StockIn.fromJson(responseData['stockin']);
        } else {
          throw Exception(
            'Unexpected API response: ${response.body}',
          );
        }
      } else {
        throw Exception(
          'Failed to create stockin. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error in createStockIn: $e');
      rethrow;
    }
  }

  // Get stock-in by UUID
  Future<StockIn> fetchStockInByUuid(String uuid,
      {required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stockin/$uuid'),
        headers: {
          'Authorization': 'Bearer $token', // Header otorisasi
          'Accept': 'application/json', // Header format respons
        },
      );

      if (response.statusCode == 200) {
        print(
            'Data received for stockin: ${response.body}'); // Log data yang diterima
        return StockIn.fromJson(json.decode(response.body)['stockin']);
      } else {
        print(
            'Failed to load stockin: ${response.body}'); // Log error response body
        throw Exception('Failed to load stockin');
      }
    } catch (e) {
      print(
          'Error in fetchStockInByUuid: $e'); // Log error jika terjadi exception
      rethrow;
    }
  }

  // Delete stock-in
  Future<void> deleteStockIn(String uuid, {required String token}) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'http://192.168.2.101:8000/api/stockin/$uuid'), // Pastikan URL ini benar
        headers: {
          'Authorization': 'Bearer $token', // Header otorisasi
          'Accept': 'application/json', // Header format respons
        },
      );

      // Log request URL dan status code
      print('Request URL: http://192.168.2.101:8000/api/stockin/$uuid');
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Stockin berhasil dihapus');
      } else {
        print('Failed to delete stockin: ${response.body}');
        throw Exception('Failed to delete stockin');
      }
    } catch (e) {
      print('Error in deleteStockIn: $e');
      rethrow;
    }
  }
}
