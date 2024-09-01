import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Email dan password harus diisi');
      return;
    }

    try {
      // Mendapatkan CSRF token
      final csrfResponse = await http.get(
        Uri.parse('https://salimapi.admfirst.my.id/sanctum/csrf-cookie'),
      );

      if (csrfResponse.statusCode == 204) {
        // Ekstrak seluruh cookie
        final cookies = csrfResponse.headers['set-cookie'];
        final csrfToken = cookies
            ?.split(';')
            .firstWhere((cookie) => cookie.startsWith('XSRF-TOKEN='))
            .split('=')
            .last;

        // Melanjutkan login
        final response = await http.post(
          Uri.parse('https://salimapi.admfirst.my.id/api/mobile/login'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': csrfToken ?? '',
            'Cookie': cookies ?? '',
          },
          body: json.encode({
            'email': _emailController.text.trim(),
            'password': _passwordController.text.trim(),
            'remember_me': _rememberMe,
          }),
        );

        if (response.statusCode == 200) {
          // Login berhasil
          final data = json.decode(response.body);
          print('Berhasil login: $data');
          Navigator.pushNamed(context, '/main');
        } else {
          // Login gagal
          _showError('Gagal login: ${response.statusCode}\n${response.body}');
        }
      } else {
        _showError('Gagal mendapatkan CSRF token');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // Tambahkan widget ini
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushNamed(context, '/landing');
                },
              ),
              SizedBox(height: 40),
              Text(
                'Selamat datang kembali',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(150, 124, 85, 100),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Login ke akun anda',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Color(0xFF8D9F91),
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  prefixIcon:
                      Icon(Icons.email_outlined, color: Color(0xFFEBC5B7)),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password Anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  prefixIcon:
                      Icon(Icons.lock_outline, color: Color(0xFFEBC5B7)),
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),
              Text(
                '(Akun Tamu, Email: akuntamusalmanitb@gmail.com, Password: 12345678)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF8D9F91),
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _login(); // Panggil fungsi login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(150, 124, 85, 100),
                    padding:
                        EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Masuk',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Baru di sini?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color.fromRGBO(150, 124, 85, 100),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        'Daftar',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color.fromRGBO(150, 124, 85, 100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
