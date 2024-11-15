import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:custix/api/auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Step 1: Kirim OTP ke email
  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    try {
      final authRepository = AuthRepository();
      bool otpSent = await authRepository.sendOtp(
        _emailController.text,
        _nameController.text,
      );

      if (otpSent) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      } else {
        setState(() => _errorMessage = 'Gagal mengirim OTP. Coba lagi.');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Step 2: Verifikasi OTP
  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    try {
      final authRepository = AuthRepository();
      bool otpVerified = await authRepository.verifyOtp(
        _emailController.text,
        _otpController.text,
      );

      if (otpVerified) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      } else {
        setState(() => _errorMessage = 'Kode OTP salah');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Step 3: Registrasi akhir dengan password
  Future<void> _completeRegistration() async {
    setState(() => _isLoading = true);
    try {
      final authRepository = AuthRepository();
      bool registered = await authRepository.register(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        otp: _otpController.text,
      );

      if (registered) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => _errorMessage = 'Gagal registrasi');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registrasi")),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildStep1(),
          _buildStep2(),
          _buildStep3(),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return _buildPage(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Image.asset(
              'assets/images/custiket.png',
              height: 100,
            ),
          ),
        ),
        _buildHeader("Buat Akun"),
        _buildTextField("Nama", _nameController),
        _buildTextField("Email", _emailController, TextInputType.emailAddress),
        _buildTextField("Nomor Telepon", _phoneController, TextInputType.phone),
        _buildActionButton("Kirim OTP", _sendOtp),
      ],
    );
  }

  Widget _buildStep2() {
    return _buildPage(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Image.asset(
              'assets/images/custiket.png',
              height: 100,
            ),
          ),
        ),
        Pinput(
          controller: _otpController,
          length: 6,
          showCursor: true,
          onCompleted: (pin) => _verifyOtp(),
          defaultPinTheme: PinTheme(
            width: 56,
            height: 56,
            textStyle: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 16),
        _buildActionButton("Verifikasi OTP", _verifyOtp),
      ],
    );
  }

  Widget _buildStep3() {
    return _buildPage(
      children: [
        _buildHeader("Setel Password"),
        _buildTextField(
            "Password", _passwordController, TextInputType.text, true),
        _buildTextField("Konfirmasi Password", _confirmPasswordController,
            TextInputType.text, true),
        _buildActionButton("Selesaikan Registrasi", _completeRegistration),
      ],
    );
  }

  Widget _buildPage({required List<Widget> children}) {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage != null) ...[
            Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 8),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, [
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  ]) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Text(
                label,
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}