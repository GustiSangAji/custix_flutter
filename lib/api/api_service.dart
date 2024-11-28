import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; // Pastikan Flutter diimpor agar debugPrint tersedia
//import 'package:custix/model/ticket_model.dart'; // Pastikan model ticket_model.dart sudah sesuai
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.2.153:8000/api';

  // Mendapatkan token dari SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Menyimpan token ke SharedPreferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Mendapatkan daftar tiket
  Future<List<Map<String, dynamic>>> fetchTickets({String? token}) async {
    try {
      token ??= await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Token is required');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/tiket'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception('Failed to load tickets: Invalid data format');
        }
      } else {
        throw Exception('Failed to load tickets: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching tickets: $e');
      throw Exception('Error fetching tickets: $e');
    }
  }

  // Menambahkan metode createTicket di ApiService
  Future<void> createTicket(Map<String, dynamic> ticketData,
      {String? token}) async {
    try {
      token ??= await getToken(); // Mendapatkan token

      if (token == null || token.isEmpty) {
        throw Exception('Token is required');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/tiket/store'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(ticketData), // Menyertakan data tiket
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Ticket created successfully');
      } else {
        throw Exception('Failed to create ticket: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error creating ticket: $e');
      throw Exception('Error creating ticket: $e');
    }
  }

  // Menambahkan metode updateTicket di ApiService
  Future<void> updateTicket(String uuid, Map<String, dynamic> ticketData,
      {String? token}) async {
    try {
      token ??= await getToken(); // Mendapatkan token jika belum ada

      if (token == null || token.isEmpty) {
        throw Exception('Token is required');
      }

      final response = await http.put(
        Uri.parse(
            '$baseUrl/tiket/$uuid'), // URL untuk mengupdate tiket berdasarkan UUID
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization':
              'Bearer $token', // Menyertakan token untuk autentikasi
        },
        body: jsonEncode(ticketData), // Mengirimkan data tiket untuk update
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Ticket updated successfully');
      } else {
        throw Exception('Failed to update ticket: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error updating ticket: $e');
      throw Exception('Error updating ticket: $e');
    }
  }

  // Mendapatkan tiket berdasarkan UUID
  Future<Map<String, dynamic>> fetchTicketByUuid({
    required String uuid,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tiket/$uuid'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch ticket: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching ticket: $e');
    }
  }

  // Menyimpan atau memperbarui tiket
  Future<void> saveTicket(
    Map<String, dynamic> data, {
    String? uuid,
    String? token,
  }) async {
    try {
      token ??= await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Token is required');
      }

      final url =
          uuid != null ? '$baseUrl/tiket/$uuid' : '$baseUrl/tiket/store';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      debugPrint('Saving ticket to URL: $url');
      debugPrint('Request Data: $data');
      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Ticket saved successfully');
      } else {
        throw Exception('Failed to save ticket: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error saving ticket: $e');
      throw Exception('Error saving ticket: $e');
    }
  }

  // Menghapus tiket
  Future<void> deleteTicket(String uuid, {String? token}) async {
    try {
      token ??= await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Token is required');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/tiket/$uuid'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Deleting ticket with UUID: $uuid');
      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('Ticket deleted successfully');
      } else {
        throw Exception('Failed to delete ticket: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error deleting ticket: $e');
      throw Exception('Error deleting ticket: $e');
    }
  }
}
