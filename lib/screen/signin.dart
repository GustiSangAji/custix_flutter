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
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = colorScheme.onSurface;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Padding(
            padding: EdgeInsets.only(bottom: 300),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                image: DecorationImage(
                  image: AssetImage('assets/images/backgroundkonser1.jpg'),
                  fit: BoxFit.cover,
                  opacity: 0.9, // Menyesuaikan transparansi gambar
                ),
              ),
            ),
          ),

          // Logo di atas
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 50.0), // Jarak dari atas layar
              child: Image.asset(
                'assets/images/custiket.png',
                height: 100,
              ),
            ),
          ),

          // Form Login
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 65.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(45),
                      topLeft: Radius.circular(45),
                    ),
                  ),
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),

                        // Email TextField
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: textColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide:
                                  BorderSide(color: textColor, width: 1.5),
                            ),
                            filled: true,
                            fillColor: colorScheme.surface,
                            prefixIcon: Icon(Icons.email, color: textColor),
                          ),
                          style: TextStyle(color: textColor),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),

                        // Password TextField
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(color: textColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide:
                                  BorderSide(color: textColor, width: 1.5),
                            ),
                            filled: true,
                            fillColor: colorScheme.surface,
                            prefixIcon: Icon(Icons.lock, color: textColor),
                          ),
                          style: TextStyle(color: textColor),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),

                        // Login Button
                        _isLoading
                            ? CircularProgressIndicator()
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      _login();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                  ),
                                  child: Text(
                                    "Login",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                        SizedBox(height: 50),

                        // Sign Up Redirect
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text(
                            "Belum punya akun? Daftar di sini",
                            style: TextStyle(
                                color: colorScheme.primary, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 0), // Jarak ke bagian bawah layar
            ],
          ),
        ],
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
  