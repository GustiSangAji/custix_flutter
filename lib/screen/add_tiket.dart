import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class add_tiket extends StatefulWidget {
  final String? selectedProductId; // ID Produk untuk edit (null untuk tambah)

  const add_tiket({Key? key, this.selectedProductId}) : super(key: key);

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<add_tiket> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk setiap input
  final TextEditingController kodeTiketController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  DateTime? datetime;
  DateTime? expiryDate;
  String status = 'available';
  XFile? image;
  XFile? banner;

  // Fungsi pemilihan tanggal
  Future<void> _selectDate(BuildContext context, bool isExpiryDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isExpiryDate) {
          expiryDate = picked;
        } else {
          datetime = picked;
        }
      });
    }
  }

  // Fungsi pemilihan gambar
  Future<void> _pickImage(bool isBanner) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (isBanner) {
        banner = pickedFile;
      } else {
        image = pickedFile;
      }
    });
  }

  // Fungsi submit form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Handle data submit sesuai kebutuhan Anda (API call atau lainnya)
      print("Kode Tiket: ${kodeTiketController.text}");
      print("Nama: ${nameController.text}");
      print("Tempat: ${placeController.text}");
      print("Tanggal & Waktu: ${datetime?.toIso8601String()}");
      print("Masa Berlaku: ${expiryDate?.toIso8601String()}");
      print("Status: $status");
      print("Jumlah: ${quantityController.text}");
      print("Harga: ${priceController.text}");
      print("Deskripsi: ${descriptionController.text}");
      print("Image Path: ${image?.path}");
      print("Banner Path: ${banner?.path}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.selectedProductId == null ? 'Tambah Produk' : 'Edit Produk'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: kodeTiketController,
                decoration: InputDecoration(labelText: 'ID Tiket'),
                validator: (value) {
                  return value == null || value.isEmpty
                      ? 'ID Tiket harus diisi'
                      : null;
                },
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama Tiket'),
                validator: (value) {
                  return value == null || value.isEmpty
                      ? 'Nama harus diisi'
                      : null;
                },
              ),
              TextFormField(
                controller: placeController,
                decoration: InputDecoration(labelText: 'Tempat'),
                validator: (value) {
                  return value == null || value.isEmpty
                      ? 'Tempat harus diisi'
                      : null;
                },
              ),
              ListTile(
                title: Text(
                    'Tanggal & Waktu: ${datetime != null ? DateFormat('yyyy-MM-dd').format(datetime!) : 'Pilih Tanggal'}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              ListTile(
                title: Text(
                    'Masa Berlaku: ${expiryDate != null ? DateFormat('yyyy-MM-dd').format(expiryDate!) : 'Pilih Tanggal'}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              DropdownButtonFormField<String>(
                value: status,
                items: ['available', 'unavailable']
                    .map((status) =>
                        DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => setState(() => status = value!),
                decoration: InputDecoration(labelText: 'Status'),
              ),
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  return value == null || value.isEmpty
                      ? 'Jumlah harus diisi'
                      : null;
                },
              ),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  return value == null || value.isEmpty
                      ? 'Harga harus diisi'
                      : null;
                },
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
              ),
              ListTile(
                leading: image != null
                    ? Image.file(File(image!.path), width: 50, height: 50)
                    : Icon(Icons.image),
                title: Text('Pilih Gambar'),
                onTap: () => _pickImage(false),
              ),
              ListTile(
                leading: banner != null
                    ? Image.file(File(banner!.path), width: 50, height: 50)
                    : Icon(Icons.image),
                title: Text('Pilih Banner'),
                onTap: () => _pickImage(true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
