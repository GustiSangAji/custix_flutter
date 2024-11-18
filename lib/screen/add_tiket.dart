import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:custix/api/api_service.dart';
import 'package:custix/model/ticket_model.dart';
import 'package:custix/api/auth.dart';
import 'package:image_picker/image_picker.dart';

// Widget untuk menambah tiket
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
  String _status = 'available'; // Default value
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

        print("Fetching ticket data for UUID: ${widget.selectedId}"); // Log

        var ticketDataJson = await apiService.fetchTicketByUuid(
          uuid: widget.selectedId!,
          token: token,
        );

        if (ticketDataJson == null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Tiket tidak ditemukan')));
          return;
        }

        Ticket ticketData =
            Ticket.fromJson(ticketDataJson as Map<String, dynamic>);

        setState(() {
          print("Ticket data fetched: ${ticketData.toJson()}"); // Log
          _kodeTiketController.text = ticketData.kodeTiket;
          _nameController.text = ticketData.name;
          _placeController.text = ticketData.place;
          _quantityController.text = ticketData.quantity.toString();
          _priceController.text = ticketData.price.toString();
          _descriptionController.text = ticketData.description;

          // Assign the status from ticket data.
          _status = ticketData.status ??
              'available'; // Default to 'available' if status is null

          _datetime = ticketData.datetime;
          _expiryDate = ticketData.expiryDate;
          _imageFile = ticketData.image; // Path relative to image
          _bannerFile = ticketData.banner; // Path relative to banner

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
          print("Saving ticket data: ${ticketData.toJson()}"); // Log
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

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller,
      {bool isExpiry = false}) async {
    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      initialDate = DateFormat('yyyy-MM-dd').parse(controller.text);
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != initialDate) {
      setState(() {
        if (isExpiry) {
          // Jika ini untuk tanggal kadaluarsa
          _expiryDate = pickedDate;
          controller.text = DateFormat('yyyy-MM-dd').format(_expiryDate!);
        } else {
          // Jika ini untuk tanggal dan waktu
          _datetime = pickedDate;
          controller.text = DateFormat('yyyy-MM-dd').format(_datetime!);
        }
      });
    }
  }

  // Fungsi untuk memilih waktu
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (_datetimeController.text.isNotEmpty) {
      final parts = _datetimeController.text.split(' ');
      final timeParts = parts[1].split(':');
      initialTime = TimeOfDay(
          hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null && pickedTime != initialTime) {
      setState(() {
        _datetime = DateTime(
          _datetime?.year ?? DateTime.now().year,
          _datetime?.month ?? DateTime.now().month,
          _datetime?.day ?? DateTime.now().day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _datetimeController.text = pickedTime.format(context);
      });
    }
  }

  final String baseUrl = 'http://192.168.2.101:8000';
  Widget _buildImageContainer(String? filePath, bool isBanner) {
    String? imageUrl = filePath != null
        ? Uri.parse('$baseUrl/${filePath.replaceFirst(RegExp(r'^/'), '')}')
            .toString()
        : null;

    return GestureDetector(
      onTap: () {
        // Logic untuk memilih gambar dapat ditambahkan di sini
      },
      child: Container(
        height: 200,
        color: Colors.grey[200],
        child: imageUrl == null
            ? Icon(Icons.add_a_photo,
                size: 50,
                color: Colors.grey) // Placeholder icon jika gambar kosong
            : Image.network(
                imageUrl, // Menggunakan URL untuk gambar
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.error), // Menampilkan error jika gambar gagal dimuat
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var _statusTiket;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedId != null ? 'Edit Tiket' : 'Tambah Tiket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi wajib diisi';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, _datetimeController),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _datetimeController,
                          decoration:
                              InputDecoration(labelText: 'Tanggal & Waktu'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal & Waktu wajib diisi';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectTime(context),
                  ),
                ],
              ),
              // New status field for Available / Not Available
              DropdownButtonFormField<String>(
                value: _statusTiket, // Menggunakan variabel yang dideklarasikan
                decoration: InputDecoration(labelText: 'Status Tiket'),
                items: ['Tersedia', 'Tidak Tersedia'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _statusTiket =
                        value; // Menyimpan nilai yang dipilih ke variabel
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Status wajib diisi';
                  }
                  return null;
                },
              ),

              // Expiry date field (date picker for expiration)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, _expiryDateController),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _expiryDateController,
                          decoration:
                              InputDecoration(labelText: 'Tanggal Kadaluarsa'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal Kadaluarsa wajib diisi';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () =>
                        _selectDate(context, _expiryDateController),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                "Gambar Tiket",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildImageContainer(_imageFile, false), // Tiket Image
              SizedBox(height: 10),
              Text(
                "Banner Tiket",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildImageContainer(_bannerFile, true), // Banner Image
              SizedBox(height: 20),
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
}
