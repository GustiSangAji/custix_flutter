import 'dart:developer';
import 'package:custix/screen/Dashboard/Stockin/formstokin.dart';
import 'package:flutter/material.dart';
import 'package:custix/api/apistokin.dart';
import 'package:custix/api/auth.dart';
import 'package:custix/model/stockin.dart';
import 'package:intl/intl.dart';

class Stockin extends StatefulWidget {
  const Stockin({super.key});

  @override
  _StockinPageState createState() => _StockinPageState();
}

class _StockinPageState extends State<Stockin> {
  bool _isLoading = true;
  List<StockIn> _stockInList = [];

  @override
  void initState() {
    super.initState();
    getStockIns();
  }

  Future<String?> _getToken() async {
    try {
      AuthRepository authRepository = AuthRepository();
      return await authRepository.getToken();
    } catch (e) {
      log('Error saat mengambil token: $e');
      return null;
    }
  }

  Future<void> getStockIns() async {
    try {
      String? token = await _getToken();
      if (token == null || token.isEmpty)
        throw Exception('Token tidak ditemukan');
      List<StockIn> stockInList = await ApiStokin().getStockIns(token: token);

      setState(() {
        _stockInList = stockInList;
        _isLoading = false;
      });
    } catch (e) {
      log('Error saat memuat stok masuk: $e');
      _showSnackbar('Gagal memuat stok masuk.');
    }
  }

  Future<void> deleteStockIn(String uuid) async {
    try {
      String? token = await _getToken();
      if (token == null || token.isEmpty)
        throw Exception('Token tidak ditemukan');
      await ApiStokin().deleteStockIn(uuid, token: token);

      setState(() {
        _stockInList.removeWhere((stockIn) => stockIn.uuid == uuid);
      });

      _showSnackbar('Stok masuk berhasil dihapus.');
    } catch (e) {
      log('Error saat menghapus stok masuk: $e');
      _showSnackbar('Gagal menghapus stok masuk.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Colors.white), // Tombol back putih
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tambah Stok Masuk',
          style: TextStyle(color: Colors.white), // Judul putih
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _stockInList.isEmpty
              ? Center(child: Text('Belum ada data stok masuk.'))
              : ListView.builder(
                  itemCount: _stockInList.length,
                  itemBuilder: (context, index) {
                    final stockIn = _stockInList[index];

                    return Dismissible(
                      key: Key(stockIn.uuid),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        deleteStockIn(stockIn.uuid);
                      },
                      child: Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        elevation: 5, // Elevated card for better look
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Rounded corners
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              stockIn.kodeTiket[0],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            'Kode: ${stockIn.kodeTiket}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Jumlah: ${stockIn.jumlah}'),
                              Text(
                                  'Tanggal: ${DateFormat.yMMMEd().format(stockIn.datetime)}'),
                              Text('Deskripsi: ${stockIn.deskripsi}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // Konfirmasi sebelum menghapus
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Konfirmasi'),
                                    content: Text(
                                        'Apakah Anda yakin ingin menghapus stok ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          deleteStockIn(stockIn.uuid);
                                        },
                                        child: Text('Hapus'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 16, right: 16),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Formstokin()),
            ).then((_) => getStockIns());
          },
          backgroundColor: Colors.blueAccent,
          label: Text(
            'Tambah Stok',
            style: TextStyle(color: Colors.white),
          ),
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
