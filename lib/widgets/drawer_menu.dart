import 'package:flutter/material.dart';
import 'package:custix/api/auth.dart';
import 'package:custix/screen/ticket_list.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  // Fungsi logout
  void _logout(BuildContext context) {
    print('Logout clicked');
    Navigator.pushReplacementNamed(context, '/signin');
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
              // Add navigation logic if needed
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.category),
            title: const Text('Product'),
            children: [
              ListTile(
                title: const Text('Add Product'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ticket_list()),
                  );
                },
              ),
              ListTile(
                title: const Text('Manage Products'),
                onTap: () {
                  Navigator.pop(context);
                  // Add navigation logic if needed
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
