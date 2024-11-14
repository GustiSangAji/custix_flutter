import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:custix/api/api_service.dart';
import 'package:custix/model/ticket_model.dart';
import 'package:custix/api/auth.dart';
import 'package:image_picker/image_picker.dart';

class add_Tiket extends StatefulWidget {
  final String? selectedId;
  const add_Tiket({Key? key, this.selectedId}) : super(key: key);

  @override
  _AddTiketPageState createState() => _AddTiketPageState();
}

class _AddTiketPageState extends State<add_Tiket> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _kodeTiketController;
  late TextEditingController _nameController;
  late TextEditingController _placeController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _datetimeController;
  late TextEditingController _expiryDateController;
  String _status = 'available';
  DateTime? _datetime;
  DateTime? _expiryDate;
  String? _imageFile;
  String? _bannerFile;
  final ImagePicker _picker = ImagePicker();
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _kodeTiketController = TextEditingController();
    _nameController = TextEditingController();
    _placeController = TextEditingController();
    _quantityController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
    _datetimeController = TextEditingController();
    _expiryDateController = TextEditingController();

    if (widget.selectedId != null) {
      _getTicketData();
    }
  }

  // Fungsi untuk mendapatkan token dari AuthRepository
  Future<String?> _getToken() async {
    AuthRepository authRepository = AuthRepository();
    return await authRepository.getToken();
  }

  // Fungsi untuk mengambil data tiket berdasarkan UUID
  void _getTicketData() async {
    if (widget.selectedId != null) {
      try {
        String? token = await _getToken();
        if (token == null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Token tidak ditemukan')));
          return;
        }

        var ticketDataJson = await apiService.fetchTicketByUuid(
          uuid: widget.selectedId!,
          token: token,
        );

        Ticket ticketData =
            Ticket.fromJson(ticketDataJson as Map<String, dynamic>);

        setState(() {
          _kodeTiketController.text = ticketData.kodeTiket;
          _nameController.text = ticketData.name;
          _placeController.text = ticketData.place;
          _quantityController.text = ticketData.quantity.toString();
          _priceController.text = ticketData.price.toString();
          _descriptionController.text = ticketData.description;
          _status = ticketData.status;
          _datetime = ticketData.datetime;
          _expiryDate = ticketData.expiryDate;
          _imageFile = ticketData.image;
          _bannerFile = ticketData.banner;
          if (_datetime != null) {
            _datetimeController.text =
                DateFormat('yyyy-MM-dd HH:mm').format(_datetime!);
          }
          if (_expiryDate != null) {
            _expiryDateController.text =
                DateFormat('yyyy-MM-dd').format(_expiryDate!);
          }
        });
      } catch (e) {
        debugPrint("Error loading ticket data: $e");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading ticket data')));
      }
    }
  }

  // Fungsi submit data tiket
  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final ticketData = Ticket(
        uuid: widget.selectedId ?? '',
        kodeTiket: _kodeTiketController.text,
        name: _nameController.text,
        place: _placeController.text,
        quantity: int.parse(_quantityController.text),
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        status: _status,
        datetime: _datetime!,
        expiryDate: _expiryDate!,
        image: _imageFile ?? '',
        banner: _bannerFile ?? '',
      );

      try {
        String? token = await _getToken();
        if (token != null) {
          await apiService.saveTicketWithToken(ticketData.toJson(), token,
              uuid: widget.selectedId);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Data berhasil disimpan')));
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Token tidak ditemukan')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error saving ticket')));
      }
    }
  }

  // Pilih gambar
  Future<void> _pickImage(bool isBanner) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isBanner) {
          _bannerFile = pickedFile.path;
        } else {
          _imageFile = pickedFile.path;
        }
      });
    }
  }

  // Widget gambar dengan tampilan placeholder
  Widget _buildImageContainer(String? filePath, bool isBanner) {
    return GestureDetector(
      onTap: () => _pickImage(isBanner),
      child: Container(
        height: 200,
        color: Colors.grey[200],
        child: filePath == null
            ? Icon(Icons.add_a_photo)
            : Image.file(File(filePath)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedId != null ? 'Edit Tiket' : 'Tambah Tiket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _datetimeController,
                      decoration:
                          InputDecoration(labelText: 'Tanggal dan Waktu'),
                      readOnly: true,
                      onTap: () => _selectDate(context, _datetimeController),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () => _selectTime(context),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryDateController,
                      decoration:
                          InputDecoration(labelText: 'Tanggal Kadaluarsa'),
                      readOnly: true,
                      onTap: () => _selectDate(context, _expiryDateController,
                          isExpiry: true),
                    ),
                  ),
                ],
              ),
              _buildImageContainer(_imageFile, false),
              _buildImageContainer(_bannerFile, true),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.selectedId != null ? 'Simpan' : 'Tambah'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi memilih tanggal
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller,
      {bool isExpiry = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isExpiry) {
          _expiryDate = picked;
        } else {
          _datetime = picked;
        }
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Fungsi memilih waktu
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && _datetime != null) {
      setState(() {
        _datetime = DateTime(
          _datetime!.year,
          _datetime!.month,
          _datetime!.day,
          picked.hour,
          picked.minute,
        );
        _datetimeController.text =
            DateFormat('yyyy-MM-dd HH:mm').format(_datetime!);
      });
    }
  }
}
