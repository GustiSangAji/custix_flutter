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
        title: Text(
          widget.selectedId == null ? 'Tambah Tiket' : 'Edit Tiket',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade200, // Latar belakang modern
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.9), Colors.grey.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Form
              Center(
                child: Text(
                  widget.selectedId == null ? 'Tambah Tiket' : 'Edit Tiket',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Input Fields
              _buildInputField(
                controller: _kodeTiketController,
                label: 'Kode Tiket',
                hintText: 'Masukkan kode tiket',
                icon: Icons.confirmation_number_outlined,
                validator: (value) => value == null || value.isEmpty
                    ? 'Kode Tiket wajib diisi'
                    : null,
              ),

              SizedBox(height: 16),

              _buildInputField(
                controller: _nameController,
                label: 'Nama Tiket',
                hintText: 'Masukkan nama tiket',
                icon: Icons.event_seat_outlined,
                validator: (value) => value == null || value.isEmpty
                    ? 'Nama Tiket wajib diisi'
                    : null,
              ),

              SizedBox(height: 16),

              _buildInputField(
                controller: _placeController,
                label: 'Tempat Konser',
                hintText: 'Masukkan tempat konser',
                icon: Icons.place_outlined,
                validator: (value) => value == null || value.isEmpty
                    ? 'Tempat Konser wajib diisi'
                    : null,
              ),

              SizedBox(height: 16),

              _buildInputField(
                controller: _descriptionController,
                label: 'Deskripsi Tiket',
                hintText: 'Masukkan deskripsi tiket',
                icon: Icons.description_outlined,
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Deskripsi wajib diisi'
                    : null,
              ),

              SizedBox(height: 16),

              // Status Tiket
              Text('Status Tiket',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
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
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),

              SizedBox(height: 16),

              _buildInputField(
                controller: _quantityController,
                label: 'Jumlah Tiket',
                hintText: 'Masukkan jumlah tiket',
                icon: Icons.format_list_numbered_outlined,
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Jumlah wajib diisi'
                    : null,
              ),

              SizedBox(height: 16),

              _buildInputField(
                controller: _priceController,
                label: 'Harga Tiket',
                hintText: 'Masukkan harga tiket',
                icon: Icons.attach_money_outlined,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Harga wajib diisi' : null,
              ),

              SizedBox(height: 16),

              // Tanggal dan Waktu
              _buildDateField(
                label: 'Tanggal dan Waktu',
                value: _datetime == null
                    ? 'Pilih Tanggal dan Waktu'
                    : '${DateFormat('dd MMM yyyy').format(_datetime!)} - ${_timeOfDay?.format(context)}',
                icon: Icons.calendar_today_outlined,
                onTap: () async {
                  await _pickDate();
                  await _pickTime();
                  setState(() {});
                },
              ),

              SizedBox(height: 16),

              // Tanggal Kadaluarsa
              _buildDateField(
                label: 'Tanggal Kadaluarsa',
                value: _expiryDate == null
                    ? 'Pilih Tanggal Kadaluarsa'
                    : DateFormat('dd MMM yyyy').format(_expiryDate!),
                icon: Icons.event_busy_outlined,
                onTap: () async {
                  await _pickExpiryDate();
                  setState(() {});
                },
              ),

              SizedBox(height: 16),

              // Gambar Tiket dan Banner
              Text('Gambar Tiket',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _pickImage(false),
                child: _buildImageContainer(_imageUrl, _imageFile, false),
              ),

              SizedBox(height: 16),

              Text('Banner Tiket',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _pickImage(true),
                child: _buildImageContainer(_bannerUrl, _bannerFile, true),
              ),

              SizedBox(height: 24),

              // Tombol Submit
              Center(
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text(
                    widget.selectedId == null
                        ? 'Tambah Tiket'
                        : 'Perbarui Tiket',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Widget untuk input field
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon, color: Colors.blueAccent) : null,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

// Widget untuk input tanggal
  Widget _buildDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            if (icon != null) Icon(icon, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }
}
