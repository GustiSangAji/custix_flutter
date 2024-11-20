import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; // Pastikan Flutter diimpor agar debugPrint tersedia
import 'package:custix/model/ticket_model.dart'; // Pastikan model ticket_model.dart sudah sesuai
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.2.101:8000/api';

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

  Future<Map<String, dynamic>> fetchTicketByUuid(
      {required String uuid, required String token}) async {
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

  Future<void> createTicket(Map<String, dynamic> ticketData,
      {String? token}) async {
    try {
      token ??= await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Token is required');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/tiket/store'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Pastikan token ada di header
        },
        body: jsonEncode(ticketData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Ticket created successfully');
      } else {
        throw Exception('Failed to create ticket: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating ticket: $e');
    }
  }

  // Update Tiket
  Future<void> updateTicket(String uuid, Map<String, dynamic> ticketData,
      {String? token}) async {
    try {
      token ??= await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Token is required');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/tiket/$uuid'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(ticketData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Ticket updated successfully');
      } else {
        throw Exception('Failed to update ticket: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating ticket: $e');
    }
  }

  // Delete Tiket
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

      if (response.statusCode == 200) {
        debugPrint('Ticket deleted successfully');
      } else {
        throw Exception('Failed to delete ticket: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting ticket: $e');
    }
  }
}
