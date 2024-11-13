import 'package:custix/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:custix/screen/loading.dart' as loading_screen;
import 'package:custix/screen/signin.dart' as signin_screen;
import 'package:custix/screen/dashboard.dart';
import 'package:custix/screen/add_tiket.dart';
import 'package:custix/screen/ticket_list.dart';

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
        '/home': (context) => HomeScreen(),
        '/signin': (context) => signin_screen.SignInScreen(), // Halaman login
        '/dashboard': (context) => Dashboard(), // Rute untuk Dashboard
        '/add_tiket': (context) => add_tiket(),
        '/ticket_list': (context) => ticket_list()
      },
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color.fromARGB(255, 2, 80, 191),
          onPrimary: Color.fromARGB(255, 15, 16, 20),
          secondary: Colors.grey,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Color.fromARGB(255, 15, 16, 20),
          onSurface: Colors.white,
        ),
        useMaterial3: true,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Image.asset(
          'assets/images/custiket.png', // Pastikan path gambar benar
          fit: BoxFit.cover,
          height: 100,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                    context, '/dashboard'); // Navigasi ke Dashboard
              },
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
