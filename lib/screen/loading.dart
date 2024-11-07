import 'package:flutter/material.dart';
import 'package:custix/api/auth.dart';

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
    _checkLoginStatus();
    _animateLogo();
  }

  // Fungsi untuk menambahkan animasi fade-in pada logo
  Future<void> _animateLogo() async {
    await Future.delayed(
        Duration(milliseconds: 500)); // Tunggu sebentar sebelum animasi dimulai
    setState(() {
      _isVisible = true; // Menampilkan logo dengan animasi fade-in
    });

    // Menunggu beberapa detik untuk animasi selesai, kemudian arahkan ke halaman login dengan animasi
    await Future.delayed(Duration(seconds: 3));

    // Setelah animasi selesai, arahkan ke halaman login
    bool isLoggedIn = await _authRepository.checkLoginStatus();

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(
          context, '/home'); // Halaman utama jika sudah login
    } else {
      Navigator.pushReplacementNamed(
          context, '/signin'); // Halaman login jika belum login
    }
  }

  Future<void> _checkLoginStatus() async {
    bool isLoggedIn = await _authRepository.checkLoginStatus();

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Halaman login akan muncul setelah animasi selesai
      // Tapi sudah diatur untuk muncul dalam _animateLogo()
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0, // Membuat logo muncul dengan fade-in
          duration: Duration(seconds: 2), // Durasi animasi
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/cuslogo.png', // Path ke logo Anda
                height: 100, // Ukuran logo
                width: 100, // Ukuran logo
              ),
              SizedBox(
                  height:
                      20), // Memberikan jarak antara logo dan loading spinner
              CircularProgressIndicator(), // Spinner untuk menunjukkan loading
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
