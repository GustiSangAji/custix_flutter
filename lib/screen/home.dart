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

  // Fungsi untuk menangani pemilihan menu
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
      case 'dashboard':
        print('Dashboard clicked');
        // Navigasi ke halaman dashboard
        Navigator.pushNamed(context, '/dashboard');
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
            // Pass context ke _onMenuSelected
            onSelected: (value) => _onMenuSelected(context, value),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: const Text('Profile'),
                ),
                PopupMenuItem<String>(
                  value: 'dashboard',
                  child: const Text('Dashboard'),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: const Text('Settings'),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: const Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Center(
        child: const Text("Selamat Datang di Halaman Utama!"),
      ),
    );
  }
}
