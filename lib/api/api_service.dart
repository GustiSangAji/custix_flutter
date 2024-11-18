import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; // Pastikan Flutter diimpor agar debugPrint tersedia
import 'package:custix/model/ticket_model.dart'; // Pastikan model ticket_model.dart sudah sesuai
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.2.101:8000/api';

  // Mendapatkan token dari shared preferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Mengambil token yang disimpan
  }

  // Menyimpan token ke shared preferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token); // Menyimpan token
  }

// Mendapatkan daftar tiket
  Future<List<Map<String, dynamic>>> fetchTickets(String s,
      {String? token}) async {
    try {
      // Jika token tidak disertakan, ambil token dari shared preferences
      token ??= await _getToken();

      // Pastikan token ada
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

      debugPrint('Status Response: ${response.statusCode}');
      debugPrint('Headers Response: ${response.headers}');
      debugPrint('Body Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // Mengembalikan list tiket
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception('Failed to load tickets: Data is null or invalid');
        }
      } else {
        throw Exception('Failed to load tickets: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching tickets: $e');
      throw Exception('Error fetching tickets: $e');
    }
  }

  // Mendapatkan tiket berdasarkan UUID
  Future<Map<String, dynamic>> fetchTicketByUuid({
    required String uuid,
    required String token,
  }) async {
    try {
      // Pastikan token ada
      if (token.isEmpty) {
        throw Exception('Token is required');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/tiket/$uuid'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Status Response: ${response.statusCode}');
      debugPrint('Headers Response: ${response.headers}');
      debugPrint('Body Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['tiket'] != null) {
          return data['tiket'];
        } else {
          throw Exception('Failed to fetch ticket: Invalid data or not found');
        }
      } else {
        throw Exception('Failed to fetch ticket: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error occurred while fetching ticket: $e');
      throw Exception('Error occurred while fetching ticket: $e');
    }
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    debugPrint(
        "Token: $token"); // Debug untuk memastikan token diambil dengan benar
    return token;
  }

  // Fungsi saveTicketWithToken
  Future<void> saveTicketWithToken(
      Map<String, dynamic> ticketData, String token,
      {String? uuid}) async {
    final url = Uri.parse('$baseUrl/tiket/$uuid');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(ticketData),
    );

    debugPrint('Saving ticket with data: $ticketData');
    debugPrint('Status Response: ${response.statusCode}');
    debugPrint('Body Response: ${response.body}');

    if (response.statusCode == 200) {
      debugPrint('Ticket saved successfully');
    } else {
      debugPrint('Failed to save ticket');
      throw Exception('Failed to save ticket');
    }
  }

  // Menyimpan atau memperbarui tiket
  Future<void> saveTicket(Map<String, dynamic> data,
      {String? uuid, String? token}) async {
    // Jika token tidak diberikan, ambil dari shared preferences
    token ??= await getToken();
    final url = uuid != null ? '$baseUrl/tiket/$uuid' : '$baseUrl/tiket/store';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    debugPrint('Saving ticket to $url with data: $data');
    debugPrint('Status Response: ${response.statusCode}');
    debugPrint('Body Response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('Ticket saved successfully');
    } else {
      debugPrint('Failed to save ticket: ${response.statusCode}');
      throw Exception('Gagal menyimpan data tiket');
    }
  }

  // Menghapus tiket
  Future<void> deleteTicket(String uuid, {String? token}) async {
    token ??= await getToken(); // Ambil token jika tidak diberikan
    final response = await http.delete(
      Uri.parse('$baseUrl/tiket/$uuid'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('Deleting ticket with UUID: $uuid');
    debugPrint('Status Response: ${response.statusCode}');
    debugPrint('Body Response: ${response.body}');

    if (response.statusCode == 200) {
      debugPrint('Ticket deleted successfully');
    } else {
      debugPrint('Failed to delete ticket: ${response.statusCode}');
      throw Exception('Gagal menghapus tiket');
    }
  }
}
