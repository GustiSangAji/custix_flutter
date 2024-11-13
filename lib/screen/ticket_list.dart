import 'package:flutter/material.dart';
import 'add_tiket.dart';

class ticket_list extends StatelessWidget {
  const ticket_list({Key? key}) : super(key: key);

  void _navigateToAddTicket(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => add_tiket()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tiket'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddTicket(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Contoh data tiket, ganti dengan data dari API atau database
          ListTile(
            title: Text('Tiket 1'),
            subtitle: Text('Deskripsi tiket 1'),
          ),
          ListTile(
            title: Text('Tiket 2'),
            subtitle: Text('Deskripsi tiket 2'),
          ),
          // Tambahkan item tiket lainnya sesuai data yang tersedia
        ],
      ),
    );
  }
}
