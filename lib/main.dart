import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:custix/screen/signin.dart' as signin_screen;
import 'package:custix/screen/signup.dart' as signup_screen;
import 'package:custix/screen/loading.dart' as loading;
import 'package:custix/screen/Dashboard/Laporan/Laporan.dart';
import 'package:custix/screen/Dashboard/Tiket/add_tiket.dart';
import 'package:custix/screen/Dashboard/dashboard.dart';
import 'package:custix/screen/Dashboard/Tiket/ticket_list.dart';
import 'package:custix/screen/Dashboard/Stockin/stockin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:custix/screen/onboarding_screen.dart'; // Import onboarding screen
import 'screen/nav_bar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custix',
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // SplashScreen di awal aplikasi
      routes: {
        '/': (context) => loading.SplashScreen(), // Splash Screen
        '/onboarding': (context) => OnboardingScreen(), // Onboarding
        '/home': (context) => BottomNavBar(), // Halaman Home
        '/signin': (context) => signin_screen.SignInScreen(), // Halaman login
        '/signup': (context) => signup_screen.RegisterScreen(),
        '/dashboard': (context) => Dashboard(),
        '/add_tiket': (context) => add_Tiket(),
        '/ticket_list': (context) => TicketList(),
        '/Laporan': (context) => LaporanScreen(),
        '/Stockin': (context) => Stockin(),
      },
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<bool> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isOnboardingDone') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkOnboardingStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Navigasi berdasarkan status onboarding setelah splash screen selesai
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final isOnboardingDone = snapshot.data!;
          if (isOnboardingDone) {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            Navigator.pushReplacementNamed(context, '/onboarding');
          }
        });

        // Tampilkan splash screen selama snapshot selesai
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
