import 'package:flutter/material.dart';
//import 'package:custix/api/auth.dart';

class HomeScreen extends StatefulWidget {
 // final AuthRepository _AuthRepository = AuthRepository();

  HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _logout(BuildContext context) async {
    var _AuthRepository;
    await _AuthRepository.logout();
    Navigator.pushReplacementNamed(context, '/signin');
  }

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        print('Profile clicked');
        break;
      case 'settings':
        print('Settings clicked');
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
          height: 40,
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _onMenuSelected(context, value),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 'profile', child: Text('Profile')),
                PopupMenuItem(value: 'settings', child: Text('Settings')),
                PopupMenuItem(value: 'logout', child: Text('Logout')),
              ];
            },
          ),
        ],
      ),
    );
  }
}