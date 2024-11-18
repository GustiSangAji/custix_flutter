import 'package:flutter/material.dart';
import 'package:custix/screen/loading.dart' as loading_screen;
import 'package:custix/screen/signin.dart' as signin_screen;
import 'package:custix/screen/signup.dart' as signup_screen;
import 'package:custix/screen/dashboard.dart';
import 'package:custix/screen/add_tiket.dart';
import 'package:custix/screen/ticket_list.dart'; // Pastikan file ini diimpor
import 'package:google_fonts/google_fonts.dart';
import 'screen/nav_bar_screen.dart';

void main() {
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
        '/': (context) => loading_screen.SplashScreen(), // Splash Screen
        '/home': (context) =>
            BottomNavBar(), // Navigasi ke BottomNavBar setelah splash screen
        '/signin': (context) => signin_screen.SignInScreen(), // Halaman login
        '/dashboard': (context) => Dashboard(), // Rute untuk Dashboard
        '/add_tiket': (context) => add_Tiket(),
        '/ticket_list': (context) =>
            TicketList(), // Ganti dengan widget yang benar
        '/signup': (context) => signup_screen.RegisterScreen(),
      },
      theme: ThemeData(
        textTheme: GoogleFonts.mulishTextTheme(),
        useMaterial3: true,
      ),
    );
  }
}