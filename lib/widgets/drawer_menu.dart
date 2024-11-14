import 'package:flutter/material.dart';
import 'package:custix/api/auth.dart'; // Pastikan Anda sudah memiliki file auth.dart untuk autentikasi
import 'package:custix/screen/ticket_list.dart'; // Pastikan file ticket_list sudah benar

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  // Fungsi logout
  void _logout(BuildContext context) {
    print('Logout clicked');
    Navigator.pushReplacementNamed(context, '/signin');
  }

  // Mendapatkan token, misalnya dari SharedPreferences atau penyimpanan lainnya
  Future<String?> getToken() async {
    // Mengambil token dari AuthRepository
    String? token = await AuthRepository().getToken();
    return token; // Mengembalikan token yang diperoleh
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("User Name"),
            accountEmail: const Text("user@example.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text("U", style: TextStyle(fontSize: 24.0)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              // Tambahkan logika navigasi jika perlu
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.category),
            title: const Text('Product'),
            children: [
              ListTile(
                title: const Text('Add Product'),
                onTap: () async {
                  // Mendapatkan token sebelum mengarahkan ke ticket_list
                  String? token = await getToken();

                  // Pastikan token tidak null, jika null beri nilai default atau tangani error
                  if (token != null) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketList(
                            token: token), // Kirim token jika tidak null
                      ),
                    );
                  } else {
                    // Tangani kasus token null, misalnya, tampilkan pesan error
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Token tidak ditemukan"),
                    ));
                  }
                },
              ),
              ListTile(
                title: const Text('Manage Products'),
                onTap: () {
                  Navigator.pop(context);
                  // Tambahkan logika navigasi jika perlu
                },
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              _logout(context); // Panggil fungsi logout
            },
          ),
        ],
      ),
    );
  }
}
