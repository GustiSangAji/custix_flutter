import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.2.101:8000/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {'Accept': 'application/json'},
      validateStatus: (status) {
        // Menganggap status 500 sebagai valid
        return status != null && status < 500;
      },
    ),
  );

  // Fungsi untuk mengambil user_uuid dan token dari SharedPreferences
  Future<Map<String, String?>> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_uuid'); // Ambil UUID pengguna
    String? token =
        prefs.getString('token'); // Ambil token dari SharedPreferences
    return {'user_id': userId, 'token': token};
  }

  // Method untuk menangani error Dio
  void _handleDioError(DioException error) {
    String errorMessage = 'Terjadi kesalahan. Silakan coba lagi nanti.';

    if (error.response != null) {
      // Response error dari server
      errorMessage = 'Server Error: ${error.response?.statusCode}';
    } else {
      // Error lain yang tidak berhubungan dengan response
      errorMessage = error.message ?? errorMessage;
    }

    // Menampilkan pesan error menggunakan toast atau dialog
    Fluttertoast.showToast(msg: errorMessage);
  }

  // Fungsi untuk mendapatkan status waiting room
  Future<Map<String, dynamic>> getWaitingRoomStatus(String ticketId) async {
    try {
      final userData = await _getUserData();
      final userId = userData['user_id'];
      final token = userData['token'];

      if (userId == null || token == null) {
        Fluttertoast.showToast(msg: 'Anda harus login terlebih dahulu.');
        return {'accessGranted': false, 'queuePosition': null};
      }

      final response = await _dio.get(
        '/waiting-room-status',
        queryParameters: {'ticket_id': ticketId, 'user_id': userId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization':
                'Bearer $token', // Menggunakan token untuk autentikasi
          },
        ),
      );

      // Menambahkan log untuk mengecek response dari server
      print('Response Data: ${response.data}');
      if (response.data is Map<String, dynamic>) {
        // Jika data berupa map, cek akses dan posisi antrian
        print('Access Granted: ${response.data['accessGranted']}');
        print('Queue Position: ${response.data['queuePosition']}');
      }

      return response.data;
    } on DioException catch (e) {
      print('Error during API call: $e');
      _handleDioError(e);
      return {'accessGranted': false, 'queuePosition': null};
    }
  }

  // Fungsi lainnya (grantAccess, removeAccess, dll) tetap menggunakan user_uuid dan token
  Future<bool> grantAccess(String ticketId) async {
    try {
      final userData = await _getUserData();
      final userId = userData['user_id'];
      final token = userData['token'];

      if (userId == null || token == null) {
        Fluttertoast.showToast(msg: 'Anda harus login terlebih dahulu.');
        return false;
      }

      final response = await _dio.post(
        '/grant-access',
        data: {'user_id': userId, 'ticket_id': ticketId, 'active': true},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization':
                'Bearer $token', // Menggunakan token untuk autentikasi
          },
        ),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      _logDioError(e); // Menambahkan log error
      String message = 'Terjadi kesalahan, silakan coba lagi.';
      if (e.type == DioExceptionType.connectionTimeout) {
        message = 'Koneksi timeout, periksa jaringan Anda.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        message = 'Server tidak merespons, coba beberapa saat lagi.';
      } else if (e.response != null) {
        message = e.response?.data['message'] ??
            'Terjadi kesalahan (${e.response?.statusCode}).';
      }
      Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG);
      return false;
    }
  }

  // Fungsi untuk menangani error dari Dio
  void _logDioError(DioException error) {
    // Menambahkan log error dan stack trace
    String message = 'Terjadi kesalahan, silakan coba lagi.';
    if (error.type == DioExceptionType.connectionTimeout) {
      message = 'Koneksi timeout, periksa jaringan Anda.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      message = 'Server tidak merespons, coba beberapa saat lagi.';
    } else if (error.response != null) {
      message = error.response?.data['message'] ??
          'Terjadi kesalahan (${error.response?.statusCode}).';
    }
    print("DioError: $message"); // Log pesan kesalahan
    print("Error Type: ${error.type}"); // Menampilkan jenis kesalahan
    print(
        "Error StackTrace: ${error.stackTrace}"); // Menampilkan stack trace error
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG);
  }

  // Fungsi untuk menghapus akses dari ticket_access
  Future<bool> removeAccess(String userId, String ticketId) async {
    try {
      final userData = await _getUserData();
      final token = userData['token'];

      final response = await _dio.post(
        '/remove-access',
        data: {'user_id': userId, 'ticket_id': ticketId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization':
                'Bearer $token', // Menggunakan token untuk autentikasi
          },
        ),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      _logDioError(e); // Menambahkan log error
      return false;
    }
  }

  // Fungsi untuk terminate akses berdasarkan ID
  Future<bool> terminateAccess(String userId, String ticketId) async {
    try {
      final userData = await _getUserData();
      final token = userData['token'];

      final response = await _dio.post(
        '/api/remove-access/$userId',
        data: {'ticket_id': ticketId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization':
                'Bearer $token', // Menggunakan token untuk autentikasi
          },
        ),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      _logDioError(e); // Menambahkan log error
      return false;
    }
  }

  // Fungsi untuk clear queue
  Future<bool> clearQueue(String userId, String ticketId) async {
    try {
      final userData = await _getUserData();
      final token = userData['token'];

      final response = await _dio.post(
        '/clear-access',
        data: {'user_id': userId, 'ticket_id': ticketId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization':
                'Bearer $token', // Menggunakan token untuk autentikasi
          },
        ),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      _logDioError(e); // Menambahkan log error
      return false;
    }
  }
}
