import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _register() async {
    // Validasi sederhana sebelum mengirim permintaan
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Semua field harus diisi');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Password dan konfirmasi password tidak cocok');
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

        // Melanjutkan pendaftaran
        final response = await http.post(
          Uri.parse('https://salimapi.admfirst.my.id/api/mobile/register'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': csrfToken ?? '',
            'Cookie': cookies ?? '',
          },
          body: json.encode({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text.trim(),
            'password_confirmation': _confirmPasswordController.text.trim(),
          }),
        );

        if (response.statusCode == 201) {
          // Pendaftaran berhasil
          final data = json.decode(response.body);
          print('Berhasil mendaftar: $data');

          // Navigasi ke halaman login
          Navigator.pushNamed(context, '/login');
        } else {
          // Pendaftaran gagal
          _showError(
              'Gagal mendaftar: ${response.statusCode}\n${response.body}');
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
                  Navigator.pop(context); // Kembali ke halaman sebelumnya
                },
              ),
              SizedBox(height: 40),
              Text(
                'Buat akun baru',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(150, 124, 85, 100),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Daftar untuk memulai',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Color(0xFF8D9F91),
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  prefixIcon:
                      Icon(Icons.person_outline, color: Color(0xFFEBC5B7)),
                ),
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  prefixIcon:
                      Icon(Icons.lock_outline, color: Color(0xFFEBC5B7)),
                ),
                obscureText: true,
              ),
              SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _register(); // Panggil fungsi pendaftaran
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
                    'Daftar',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18.0,
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
                      'Sudah punya akun?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color.fromRGBO(150, 124, 85, 100),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigasi ke halaman login
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        'Masuk',
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
