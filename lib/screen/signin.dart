import 'package:flutter/material.dart';
import 'package:custix/api/auth.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepository = AuthRepository();
      bool loginSuccess = await authRepository.login(
        _emailController.text,
        _passwordController.text,
      );

      if (loginSuccess) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorSnackbar(
            'Login gagal. Periksa kembali email dan password Anda.');
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 16, 20),
      appBar: AppBar(
        title: Text(""),
        backgroundColor: const Color.fromARGB(255, 15, 16, 20),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 25.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Image.asset(
                'assets/images/custiket.png',
                height: 200,
              ),
              SizedBox(height: 30),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                        color: const Color.fromARGB(255, 21, 23, 28)),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 21, 23, 28)),
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              _isLoading
                  ? CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _login();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor:
                              const Color.fromARGB(255, 0, 106, 230),
                          foregroundColor:
                              const Color.fromARGB(255, 255, 255, 255),
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text(
                  "Belum punya akun? Daftar di sini",
                  style: TextStyle(color: Color.fromARGB(255, 0, 106, 230)),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
