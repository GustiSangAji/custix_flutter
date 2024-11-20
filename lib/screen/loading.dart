import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import Lottie
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animateLogo(); // Menambahkan animasi logo dan pengecekan onboarding
  }

  // Fungsi untuk menambahkan animasi fade-in pada logo
  Future<void> _animateLogo() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isVisible = true;
    });

    // Menunggu beberapa detik untuk animasi selesai
    await Future.delayed(const Duration(milliseconds: 4500));

    // Mengecek apakah onboarding sudah selesai
    final prefs = await SharedPreferences.getInstance();
    bool isOnboardingDone = prefs.getBool('isOnboardingDone') ?? false;

    if (isOnboardingDone) {
      // Navigasi langsung ke halaman home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Jika onboarding belum selesai, arahkan ke halaman onboarding
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: const Duration(seconds: 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animation/cusloading1.json', // Path ke file Lottie
                height: 250,
                width: 250,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
