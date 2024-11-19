import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:custix/api/api_service.dart';
import 'package:custix/model/ticket_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:custix/api/auth.dart';
import 'package:intl/intl.dart';

class add_Tiket extends StatefulWidget {
  final String? selectedId;

  const add_Tiket({Key? key, this.selectedId}) : super(key: key);

  @override
  _AddTiketPageState createState() => _AddTiketPageState();
}

class _AddTiketPageState extends State<add_Tiket> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _kodeTiketController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Tambahan untuk gambar dan banner
  File? _imageFile;
  File? _bannerFile;
  String? _imageUrl;
  String? _bannerUrl;

  // Tambahan untuk tanggal dan waktu
  DateTime? _datetime;
  DateTime? _expiryDate;
  String? _statusTiket = 'Tersedia';
  TimeOfDay? _timeOfDay;

  @override
  void initState() {
    super.initState();
    if (widget.selectedId != null) {
      _fetchTicketData(widget.selectedId!);
    }
  }

  Future<String?> _getToken() async {
    AuthRepository authRepository = AuthRepository();
    return await authRepository.getToken();
  }

  Future<void> _fetchTicketData(String uuid) async {
    try {
      // Mengambil data tiket menggunakan ApiService
      final response = await ApiService().fetchTicketByUuid(
        uuid: uuid,
        token: await _getToken() ?? '',
      );

      // Mengambil tiket dari response
      final ticket = response['tiket'];

      // Memperbarui state dengan data tiket yang diterima
      setState(() {
        _kodeTiketController.text = ticket['kode_tiket'] ?? '';
        _nameController.text = ticket['name'] ?? '';
        _placeController.text = ticket['place'] ?? '';
        _quantityController.text = ticket['quantity']?.toString() ?? '0';
        _priceController.text = ticket['price']?.toString() ?? '0.0';
        _descriptionController.text = ticket['description'] ?? '';

        // Mengonversi tanggal ke DateTime jika tersedia
        _datetime = ticket['datetime'] != null
            ? DateTime.parse(ticket['datetime'])
            : null;
        _expiryDate = ticket['expiry_date'] != null
            ? DateTime.parse(ticket['expiry_date'])
            : null;

        // Mengatur status tiket berdasarkan kondisi
        _statusTiket =
            ticket['status'] == 'available' ? 'Tersedia' : 'Tidak Tersedia';

        // Mengambil URL gambar dan banner jika ada
        _imageUrl = ticket['image'] != null
            ? 'http://192.168.2.101:8000/storage/${ticket['image']}'
            : null;

        _bannerUrl = ticket['banner'] != null
            ? 'http://192.168.2.101:8000/storage/${ticket['banner']}'
            : null;
      });
    } catch (e) {
      // Menangani error dengan menampilkan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data tiket: $e')),
      );
    }
  }

  Future<void> _pickImage(bool isBanner) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isBanner) {
          _bannerFile = File(pickedFile.path);
          _bannerUrl = null;
        } else {
          _imageFile = File(pickedFile.path);
          _imageUrl = null;
        }
      });
    }
  }

  Future<void> _pickDate({bool isExpiryDate = false}) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isExpiryDate) {
          _expiryDate = pickedDate;
        } else {
          _datetime = pickedDate;
        }
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _timeOfDay = pickedTime;
        if (_datetime != null) {
          _datetime = DateTime(
            _datetime!.year,
            _datetime!.month,
            _datetime!.day,
            _timeOfDay!.hour,
            _timeOfDay!.minute,
          );
        }
      });
    }
  }

  Future<void> _pickExpiryDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _expiryDate) {
      setState(() {
        _expiryDate = pickedDate;
      });
    }
  }

  Widget _buildImageContainer(String? url, File? file, bool isBanner) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: url != null
          ? Image.network(url, fit: BoxFit.cover) // Tampilkan gambar dari URL
          : file != null
              ? Image.file(file, fit: BoxFit.cover) // Tampilkan file lokal
              : Center(
                  child: Icon(
                    isBanner ? Icons.image : Icons.photo,
                    color: Colors.grey,
                    size: 50,
                  ),
                ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageFile == null && _imageUrl == null ||
        _bannerFile == null && _bannerUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gambar dan banner wajib dipilih')),
      );
      return;
    }

    final ticketData = Ticket(
      uuid: widget.selectedId ?? '',
      kodeTiket: _kodeTiketController.text,
      name: _nameController.text,
      place: _placeController.text,
      quantity: int.tryParse(_quantityController.text) ?? 0,
      price: double.tryParse(_priceController.text) ?? 0.0,
      description: _descriptionController.text,
      status: _statusTiket == 'Tersedia' ? 'available' : 'unavailable',
      datetime: _datetime ?? DateTime.now(),
      expiryDate: _expiryDate ?? DateTime.now(),
      image: _imageFile?.path ?? '',
      banner: _bannerFile?.path ?? '',
    );

    try {
      final token = await _getToken();
      debugPrint('Token: $token'); // Tambahkan ini untuk debugging

      if (token == null || token.isEmpty) {
        throw Exception('Token is required');
      }

      if (widget.selectedId == null) {
        await ApiService().createTicket(ticketData.toJson(), token: token);
      } else {
        await ApiService().updateTicket(widget.selectedId!, ticketData.toJson(),
            token: token);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tiket berhasil disimpan')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan tiket: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedId == null ? 'Tambah Tiket' : 'Edit Tiket'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Input Kode Tiket
            TextFormField(
              controller: _kodeTiketController,
              decoration: InputDecoration(labelText: 'Kode Tiket'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kode Tiket wajib diisi';
                }
                return null;
              },
            ),

            // Input Nama Tiket
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nama Tiket'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama Tiket wajib diisi';
                }
                return null;
              },
            ),

            // Input Tempat Konser
            TextFormField(
              controller: _placeController,
              decoration: InputDecoration(labelText: 'Tempat Konser'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tempat Konser wajib diisi';
                }
                return null;
              },
            ),

            // Input Deskripsi Tiket
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Deskripsi Tiket'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Deskripsi wajib diisi';
                }
                return null;
              },
            ),

            DropdownButton<String>(
              value: _statusTiket,
              items: <String>['Tersedia', 'Tidak Tersedia']
                  .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _statusTiket = value;
                });
              },
            ),
            // Input Harga
            // Jumlah Tiket
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Jumlah'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah wajib diisi';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harga wajib diisi';
                }
                return null;
              },
            ),

            // Input Tanggal dan Waktu
            TextFormField(
              controller: TextEditingController(
                text: _datetime == null
                    ? 'Pilih Tanggal dan Waktu'
                    : '${DateFormat('dd MMM yyyy').format(_datetime!)} - ${_timeOfDay?.format(context)}',
              ),
              decoration: InputDecoration(
                labelText: 'Tanggal dan Waktu',
                suffixIcon:
                    Icon(Icons.calendar_today), // Pindahkan ikon ke kanan
              ),
              readOnly: true, // Membuat field hanya bisa dibaca
              onTap: () async {
                // Tanggal dan Waktu dipilih bersama-sama
                await _pickDate(); // Ambil tanggal
                await _pickTime(); // Ambil waktu
                setState(() {}); // Memperbarui tampilan setelah memilih
              },
            ),
// Input Tanggal Kadaluarsa
            TextFormField(
              controller: TextEditingController(
                text: _expiryDate == null
                    ? 'Pilih Tanggal Kadaluarsa'
                    : DateFormat('dd MMM yyyy').format(_expiryDate!),
              ),
              decoration: InputDecoration(
                labelText: 'Tanggal Kadaluarsa',
                suffixIcon:
                    Icon(Icons.calendar_today), // Pindahkan ikon ke kanan
              ),
              readOnly: true, // Membuat field hanya bisa dibaca
              onTap: () async {
                // Pilih tanggal kadaluarsa
                await _pickExpiryDate();
                setState(() {}); // Memperbarui tampilan setelah memilih
              },
            ),

// Memberi jarak antar elemen
            SizedBox(height: 20), // Anda bisa menyesuaikan jaraknya

// Gambar Tiket dan Banner
            GestureDetector(
              onTap: () => _pickImage(false),
              child: Container(
                padding: EdgeInsets.all(8), // Memberi jarak di dalam border
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.grey, width: 2), // Memberi border
                  borderRadius: BorderRadius.circular(
                      8), // Membuat sudut border melengkung
                ),
                child: _buildImageContainer(_imageUrl, _imageFile, false),
              ),
            ),

            SizedBox(height: 20), // Memberi jarak antar gambar tiket dan banner
            GestureDetector(
              onTap: () => _pickImage(true),
              child: Container(
                padding: EdgeInsets.all(8), // Memberi jarak di dalam border
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.grey, width: 2), // Memberi border
                  borderRadius: BorderRadius.circular(
                      8), // Membuat sudut border melengkung
                ),
                child: _buildImageContainer(_bannerUrl, _bannerFile, true),
              ),
            ),

            // Status Tiket

            // Tombol Submit
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(widget.selectedId == null
                  ? 'Tambah Tiket'
                  : 'Perbarui Tiket'),
            ),
          ],
        ),
      ),
    );
  }
}
