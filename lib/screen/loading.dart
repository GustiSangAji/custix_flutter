import 'package:flutter/material.dart';
import 'package:custix/api/auth.dart';
import 'package:lottie/lottie.dart'; // Import Lottie

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final AuthRepository _authRepository = AuthRepository();
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animateLogo();  // Cukup panggil animateLogo untuk memeriksa login dan animasi
  }

  // Fungsi untuk menambahkan animasi fade-in pada logo
  Future<void> _animateLogo() async {
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _isVisible = true;
    });

    // Menunggu beberapa detik untuk animasi selesai, kemudian arahkan ke halaman login
    await Future.delayed(Duration(milliseconds: 4500));

    bool isLoggedIn = await _authRepository.checkLoginStatus();

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  Future<void> _checkLoginStatus() async {
    bool isLoggedIn = await _authRepository.checkLoginStatus();

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: Duration(seconds: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animation/cusloading1.json', // Path ke file Lottie
                height: 250,
                width: 250,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Halaman Login (SignInScreen)
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(child: Text("Halaman Login")),
    );
  }
}
