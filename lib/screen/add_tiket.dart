import 'dart:io';
import 'package:flutter/material.dart';
import 'package:custix/api/api_service.dart';
import 'package:custix/model/ticket_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:custix/api/auth.dart';

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
  File? _imageFile;
  File? _bannerFile;
  String? _imageUrl;
  String? _bannerUrl;
  DateTime? _datetime;
  DateTime? _expiryDate;
  String? _statusTiket = 'Tersedia';

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
      final response = await ApiService()
          .fetchTicketByUuid(uuid: uuid, token: await _getToken() ?? '');
      final ticket = response['tiket'];

      setState(() {
        _kodeTiketController.text = ticket['kode_tiket'] ?? '';
        _nameController.text = ticket['name'] ?? '';
        _placeController.text = ticket['place'] ?? '';
        _quantityController.text = ticket['quantity']?.toString() ?? '0';
        _priceController.text = ticket['price']?.toString() ?? '0.0';
        _descriptionController.text = ticket['description'] ?? '';
        _datetime = ticket['datetime'] != null
            ? DateTime.parse(ticket['datetime'])
            : null;
        _expiryDate = ticket['expiry_date'] != null
            ? DateTime.parse(ticket['expiry_date'])
            : null;
        _statusTiket =
            ticket['status'] == 'available' ? 'Tersedia' : 'Tidak Tersedia';
        _imageUrl = ticket['image'] != null
            ? 'http://192.168.2.140:8000/storage/${ticket['image']}'
            : null;
        _bannerUrl = ticket['banner'] != null
            ? 'http://192.168.2.140:8000/storage/${ticket['banner']}'
            : null;
      });
    } catch (e) {
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
                  child: Text(
                    isBanner ? 'Pilih Banner' : 'Pilih Gambar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
    );
  }

  void _submit() async {
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
      id: 0,
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
      if (widget.selectedId == null) {
        await ApiService().createTicket(ticketData.toJson());
      } else {
        final token = await _getToken();
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

            // Input Tempat
            TextFormField(
              controller: _placeController,
              decoration: InputDecoration(labelText: 'Tempat'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tempat wajib diisi';
                }
                return null;
              },
            ),

            // Input Deskripsi
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

            // Input Jumlah
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

            // Input Harga
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

            // Dropdown Status Tiket
            DropdownButtonFormField<String>(
              value: _statusTiket,
              decoration: InputDecoration(labelText: 'Status Tiket'),
              items: ['Tersedia', 'Tidak Tersedia'].map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _statusTiket = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Status wajib diisi';
                }
                return null;
              },
            ),

            // Pilih Tanggal Event
            ListTile(
              title: Text('Tanggal dan Waktu Event'),
              subtitle: Text(_datetime == null
                  ? 'Pilih tanggal'
                  : '${_datetime!.toLocal()}'.split(' ')[0]),
              onTap: () => _pickDate(),
            ),

            // Pilih Tanggal Kadaluarsa
            ListTile(
              title: Text('Tanggal Kadaluarsa'),
              subtitle: Text(_expiryDate == null
                  ? 'Pilih tanggal'
                  : '${_expiryDate!.toLocal()}'.split(' ')[0]),
              onTap: () => _pickDate(isExpiryDate: true),
            ),

            // Gambar Tiket dan Banner
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickImage(false),
                    child: _buildImageContainer(_imageUrl, _imageFile, false),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickImage(true),
                    child: _buildImageContainer(_bannerUrl, _bannerFile, true),
                  ),
                ),
              ],
            ),

            // Tombol Simpan
            SizedBox(height: 16),
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
