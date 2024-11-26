import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:custix/api/apilapor.dart'; // Pastikan path import benar
import 'package:custix/api/auth.dart';
import 'package:custix/model/Laporan.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'package:custix/widgets/drawer_menu.dart'; // Import DrawerMenu widget

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanScreen> {
  bool _isLoading = true;
  List<Laporan> _laporanList = [];

  @override
  void initState() {
    super.initState();
    _loadLaporan();
  }

  // Mengambil token dari SharedPreferences
  Future<String?> _getToken() async {
    try {
      AuthRepository authRepository = AuthRepository();
      String? token = await authRepository.getToken();
      log('Token berhasil diambil: $token'); // Log token
      return token;
    } catch (e) {
      log('Error saat mengambil token: $e'); // Log error saat mengambil token
      return null;
    }
  }

  // Memuat daftar laporan
  Future<List<Laporan>> _loadLaporan() async {
    try {
      log('Memulai proses memuat laporan...');
      String? token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan');
      }

      log('Token yang digunakan: $token');

      List<Laporan> laporanList = await ApiService().getLaporan(token: token);
      log('Laporan berhasil dimuat: ${laporanList.length} item');

      return laporanList;
    } catch (e) {
      log('Error saat memuat laporan: $e');
      _showErrorDialog('Gagal memuat laporan. Silakan coba lagi.');
      return [];
    }
  }

  // Fungsi untuk mengunduh laporan Excel
  Future<void> _downloadExcel() async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception('Token tidak ditemukan');
      await ApiService().downloadExcel(token: token);
      _showMessageDialog('Excel berhasil diunduh!');
    } catch (e) {
      log('Error saat mengunduh Excel: $e');
      _showErrorDialog('Gagal mengunduh Excel. Silakan coba lagi.');
    }
  }

  // Fungsi untuk mengunduh laporan PDF
  Future<void> _downloadPDF() async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception('Token tidak ditemukan');
      await ApiService().downloadPdf(token: token);
      _showMessageDialog('PDF berhasil diunduh!');
    } catch (e) {
      log('Error saat mengunduh PDF: $e');
      _showErrorDialog('Gagal mengunduh PDF. Silakan coba lagi.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showMessageDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Info'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk format harga menjadi format rupiah
  String formatRupiah(double harga) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return format.format(harga);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laporan Tiket',
          style: TextStyle(
            color: Colors.white, // Mengubah warna teks menjadi putih
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.menu, // Ikon garis tiga untuk menu drawer
                color: Colors.white, // Mengubah warna ikon menjadi putih
              ),
              onPressed: () {
                Scaffold.of(context)
                    .openDrawer(); // Membuka drawer saat ditekan
              },
            );
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.download, // Ikon download
              color: Colors.white, // Mengubah warna ikon menjadi putih
            ),
            onSelected: (value) {
              if (value == 'excel') {
                _downloadExcel(); // Panggil fungsi untuk unduh Excel
              } else if (value == 'pdf') {
                _downloadPDF(); // Panggil fungsi untuk unduh PDF
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'excel',
                child: Text('Download Excel'),
              ),
              PopupMenuItem(
                value: 'pdf',
                child: Text('Download PDF'),
              ),
            ],
          ),
        ],
      ),

      drawer: DrawerMenu(), // Menu drawer yang sudah disesuaikan
      body: FutureBuilder<List<Laporan>>(
        future: _loadLaporan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat laporan.'));
          }

          final laporanList = snapshot.data ?? [];

          return ListView.builder(
            itemCount: laporanList.length,
            itemBuilder: (context, index) {
              final laporan = laporanList[index];
              String status = laporan.status.toLowerCase() == 'paid'
                  ? 'Paid'
                  : 'Unpaid'; // Menentukan status pembayaran

              // Menentukan warna berdasarkan status
              Color statusColor = status == 'Paid'
                  ? Colors.green.withOpacity(1)
                  : Colors.red.withOpacity(1);

              // Ikon berdasarkan status
              Icon statusIcon = status == 'Paid'
                  ? Icon(Icons.check_circle, color: Colors.green, size: 18)
                  : Icon(Icons.cancel, color: Colors.red, size: 18);

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    laporan.ticketName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tempat: ${laporan.ticketPlace}',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tanggal: ${laporan.ticketDatetime}',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Jumlah: ${laporan.jumlahPemesanan}',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              statusIcon,
                              SizedBox(width: 4),
                              Text(
                                'Status: $status',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Text(
                    formatRupiah(laporan.totalHarga), // Memformat harga
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
