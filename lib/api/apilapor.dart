import 'dart:convert';
import 'dart:developer';
import 'package:custix/model/Laporan.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ApiService {
  final String _baseUrl = 'http://192.168.2.101:8000/api/laporan';

  // Fungsi untuk mendapatkan laporan (sudah ada sebelumnya)
  Future<List<Laporan>> getLaporan({required String token}) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        List<dynamic> laporanData = responseBody['data'];
        return laporanData.map((e) => Laporan.fromJson(e)).toList();
      } else {
        throw Exception(
            'Failed to load laporan. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error saat mengambil laporan: $e');
      throw Exception('Gagal memuat laporan. Status Code: ${e.toString()}');
    }
  }

  // Fungsi untuk mengunduh laporan dalam format Excel menggunakan Firebase Storage
  Future<void> downloadExcel({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/export/excel'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (await _requestStoragePermission()) {
          // Inisialisasi Firebase Storage
          await Firebase.initializeApp();
          FirebaseStorage storage = FirebaseStorage.instance;

          // Mendapatkan file Excel dari Firebase Storage
          final reference = storage.ref('laporan/Laporan.xlsx');
          await _openFile(reference);
        } else {
          throw Exception('Izin penyimpanan ditolak.');
        }
      } else {
        throw Exception(
            'Failed to download Excel. Status: ${response.statusCode}');
      }
    } catch (e) {
      log('Error saat mengunduh Excel: $e');
      throw Exception('Gagal mengunduh laporan Excel.');
    }
  }

  // Fungsi untuk mengunduh laporan dalam format PDF menggunakan Firebase Storage
  Future<void> downloadPdf({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/pdf'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (await _requestStoragePermission()) {
          // Inisialisasi Firebase Storage
          await Firebase.initializeApp();
          FirebaseStorage storage = FirebaseStorage.instance;

          // Mendapatkan file PDF dari Firebase Storage
          final reference = storage.ref('laporan/Laporan.pdf');
          await _openFile(reference);
        } else {
          throw Exception('Izin penyimpanan ditolak.');
        }
      } else {
        throw Exception(
            'Failed to download PDF. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error saat mengunduh PDF: $e');
      throw Exception('Gagal mengunduh laporan PDF.');
    }
  }

  // Fungsi untuk membuka file tanpa menyimpannya secara lokal
  Future<void> _openFile(Reference reference) async {
    try {
      final fileUrl = await reference.getDownloadURL();
      if (await canLaunch(fileUrl)) {
        await launch(fileUrl); // Membuka file menggunakan aplikasi terkait
      } else {
        log('Tidak bisa membuka file PDF atau Excel');
        throw Exception('Tidak bisa membuka file.');
      }
    } catch (e) {
      log('Error saat membuka file: $e');
      throw Exception('Gagal membuka file.');
    }
  }

  // Fungsi untuk meminta izin penyimpanan
  Future<bool> _requestStoragePermission() async {
    PermissionStatus status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      return true;
    } else {
      log('Izin penyimpanan tidak diberikan.');
      return false;
    }
  }
}
