import 'dart:io';
import 'package:flutter/material.dart';
import 'package:custix/api/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:custix/api/auth.dart';
import 'package:intl/intl.dart';

class add_Tiket extends StatefulWidget {
  final String? selectedId;

  const add_Tiket({super.key, this.selectedId});

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
      final response = await ApiService().fetchTicketByUuid(
        uuid: uuid,
        token: await _getToken() ?? '',
      );

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
            ? 'http://192.168.2.101:8000/storage/${ticket['image']}'
            : null;

        _bannerUrl = ticket['banner'] != null
            ? 'http://192.168.2.101:8000/storage/${ticket['banner']}'
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
      final fileExtension = pickedFile.path.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png'].contains(fileExtension)) {
        setState(() {
          if (isBanner) {
            _bannerFile = File(pickedFile.path);
            _bannerUrl = null; // Reset URL jika file dipilih
          } else {
            _imageFile = File(pickedFile.path);
            _imageUrl = null; // Reset URL jika file dipilih
          }

          bool isValidImage(File file) {
            final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];
            final fileExtension = file.path.split('.').last.toLowerCase();
            return imageExtensions.contains(fileExtension);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File yang dipilih bukan gambar yang valid!')),
        );
      }
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
        _datetime = DateTime(
          _datetime!.year,
          _datetime!.month,
          _datetime!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Widget _buildImageContainer(String? url, File? file, bool isBanner) {
    return GestureDetector(
      onTap: () => _pickImage(isBanner),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade100,
        ),
        child: url != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                ),
              )
            : file != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      file,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Icon(
                      isBanner ? Icons.image : Icons.photo,
                      color: Colors.grey,
                      size: 50,
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
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  // Fungsi untuk mengirimkan data tiket
  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final token = await _getToken();
        if (token == null || token.isEmpty) {
          throw Exception('Token tidak valid');
        }

        // Siapkan data form
        Map<String, dynamic> formData = {
          'kode_tiket': _kodeTiketController.text,
          'name': _nameController.text,
          'place': _placeController.text,
          'quantity': int.tryParse(_quantityController.text) ?? 0,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'description': _descriptionController.text,
          'status': _statusTiket == 'Tersedia' ? 'available' : 'unavailable',
          'datetime':
              _datetime?.toIso8601String() ?? DateTime.now().toIso8601String(),
          'expiry_date': _expiryDate?.toIso8601String() ??
              DateTime.now().toIso8601String(),
          'image_url': _imageUrl, // URL gambar yang diambil dari server
          'banner_url': _bannerUrl, // URL banner yang diambil dari server
        };

        // Tentukan apakah membuat atau memperbarui tiket
        if (widget.selectedId == null) {
          await ApiService().createTicket(formData, token: token);
        } else {
          await ApiService()
              .updateTicket(widget.selectedId!, formData, token: token);
        }

        // Notifikasi sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tiket berhasil disimpan')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        // Tangani error saat submit
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan tiket: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap periksa form yang belum lengkap')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedId == null ? 'Tambah Tiket' : 'Edit Tiket'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Form(
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
                    return 'Kode tiket tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildInputField(
                controller: _nameController,
                label: 'Nama Tiket',
                hintText: 'Masukkan nama tiket',
                icon: Icons.event_seat,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tiket tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildInputField(
                controller: _placeController,
                label: 'Tempat',
                hintText: 'Masukkan tempat acara',
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tempat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildInputField(
                controller: _quantityController,
                label: 'Jumlah Tiket',
                hintText: 'Masukkan jumlah tiket',
                icon: Icons.production_quantity_limits,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tiket tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildInputField(
                controller: _priceController,
                label: 'Harga Tiket',
                hintText: 'Masukkan harga tiket',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tiket tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildInputField(
                controller: _descriptionController,
                label: 'Deskripsi',
                hintText: 'Masukkan deskripsi tiket',
                icon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildDateInput(
                label: 'Tanggal/Waktu Acara',
                hintText: _datetime != null
                    ? DateFormat('dd/MM/yyyy HH:mm').format(_datetime!)
                    : 'Pilih Tanggal/Waktu',
                onTap: _pickDate,
              ),
              SizedBox(height: 16),
              _buildDateInput(
                label: 'Tanggal Kedaluwarsa',
                hintText: _expiryDate != null
                    ? DateFormat('dd/MM/yyyy').format(_expiryDate!)
                    : 'Pilih Tanggal Kedaluwarsa',
                onTap: () => _pickDate(isExpiryDate: true),
              ),
              SizedBox(height: 16),
              _buildDropdownInput(
                label: 'Status Tiket',
                value: _statusTiket,
                items: [
                  'Tersedia',
                  'Tidak Tersedia',
                ],
                onChanged: (value) {
                  setState(() {
                    _statusTiket = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Unggah Gambar Tiket',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => _pickImage(false),
                  child: _buildImageContainer(_imageUrl, _imageFile, false),
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Unggah Banner Tiket',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => _pickImage(true),
                  child: _buildImageContainer(_bannerUrl, _bannerFile, true),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.selectedId == null
                    ? 'Tambah Tiket'
                    : 'Update Tiket'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateInput({
    required String label,
    required String hintText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: _buildInputField(
          controller: TextEditingController(text: hintText),
          label: label,
          hintText: hintText,
          icon: Icons.calendar_today,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Tanggal tidak boleh kosong';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildDropdownInput({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(border: InputBorder.none),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }
}
