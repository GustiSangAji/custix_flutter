import 'package:flutter/material.dart';
import 'package:custix/api/auth.dart';

class HomeScreen extends StatelessWidget {
  final AuthRepository _authRepository = AuthRepository();

  HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await _authRepository.logout();
    Navigator.pushReplacementNamed(
        context, '/signin'); // Kembali ke halaman login
  }

  // Tambahkan BuildContext pada parameter _onMenuSelected
  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        print('Profile clicked');
        // Navigasi ke halaman profile
        break;
      case 'settings':
        print('Settings clicked');
        // Navigasi ke halaman settings
        break;
      case 'logout':
        print('Logout clicked');
        _logout(context);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/custiket.png', // Ganti dengan path ke logo Anda
          height: 70,
        ),
        actions: [
          PopupMenuButton<String>(
            // Pass context to _onMenuSelected
            onSelected: (value) => _onMenuSelected(context, value),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Text('Profile'),
                ),
                PopupMenuItem<String>(
                  value: 'dashboard',
                  child: Text('Dashboard'),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Text('Settings'),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Center(
        child: Text("Selamat Datang di Halaman Utama!"),
      ),
    );
  }
}
