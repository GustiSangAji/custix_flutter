import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:custix/api/apistokin.dart';
import 'package:custix/model/stockin.dart';
import 'package:custix/api/auth.dart';

class Formstokin extends StatefulWidget {
  const Formstokin({Key? key}) : super(key: key);

  @override
  _FormStockInState createState() => _FormStockInState();
}

class _FormStockInState extends State<Formstokin> {
  final _formKey = GlobalKey<FormState>();
  final _kodeTiketController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _deskripsiController = TextEditingController();
  DateTime? _selectedDateTime;

  bool _isLoading = false;
  String? _token; // Token untuk autentikasi

  @override
  void initState() {
    super.initState();
    _getToken(); // Memuat token saat halaman dimuat
  }

  Future<void> _getToken() async {
    try {
      AuthRepository authRepository = AuthRepository();
      String? token = await authRepository.getToken();
      if (token == null || token.isEmpty) {
        log('Token kosong atau null!');
      } else {
        log('Token berhasil diambil: $token');
        setState(() {
          _token = token;
        });
      }
    } catch (e) {
      log('Error saat mengambil token: $e');
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi token
    if (_token == null || _token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Token kosong, silakan login kembali.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final stockIn = StockIn(
      kodeTiket: _kodeTiketController.text,
      jumlah: int.parse(_jumlahController.text),
      deskripsi: _deskripsiController.text,
      datetime: _selectedDateTime ?? DateTime.now(),
      uuid: '',
    );

    try {
      // Memanggil API untuk membuat stock-in
      await ApiStokin().createStockIn(stockIn, token: _token!);

      // Notifikasi dan log sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok masuk berhasil dibuat!')),
      );
      log('Stok masuk berhasil dibuat: ${stockIn.toJson()}');

      // Kembali ke halaman sebelumnya
      Navigator.pop(context, true);
    } catch (e) {
      // Tangani error dan tampilkan pesan
      log('Error saat membuat stok masuk: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat stok masuk: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Stok Masuk',
            style:
                TextStyle(color: Colors.white)), // Membuat judul menjadi putih
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        iconTheme: const IconThemeData(
            color: Colors.white), // Membuat ikon back menjadi putih
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _kodeTiketController,
                      label: 'Kode Tiket',
                      hintText: 'Masukkan kode tiket',
                      icon: Icons.confirmation_number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kode Tiket wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _jumlahController,
                      label: 'Jumlah Tiket',
                      hintText: 'Masukkan jumlah tiket',
                      icon: Icons.production_quantity_limits,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah Tiket wajib diisi';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Jumlah harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _deskripsiController,
                      label: 'Deskripsi',
                      hintText: 'Masukkan deskripsi tiket',
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickDateTime,
                      child: AbsorbPointer(
                        child: _buildInputField(
                          controller: TextEditingController(
                            text: _selectedDateTime != null
                                ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} ${_selectedDateTime!.hour}:${_selectedDateTime!.minute}'
                                : 'Pilih Tanggal & Jam',
                          ),
                          label: 'Tanggal & Jam',
                          hintText: 'Pilih Tanggal & Jam',
                          icon: Icons.calendar_today,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal & Jam wajib dipilih';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    int? maxLines,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)), // Rounded corners
      ),
      validator: validator,
    );
  }
}
