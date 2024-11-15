import 'package:flutter/material.dart';
import 'package:custix/screen/loading.dart' as loading_screen;
import 'package:custix/screen/signin.dart' as signin_screen;
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
      initialRoute: '/', // SplashScreen di awal aplikasi
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => loading_screen.SplashScreen(), // Splash Screen
        '/home': (context) => BottomNavBar(), // Navigasi ke BottomNavBar setelah splash screen
        '/signin': (context) => signin_screen.SignInScreen(), // Halaman login
      },
      theme: ThemeData(
        textTheme: GoogleFonts.mulishTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
    );
  }
}
