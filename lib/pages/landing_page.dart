import 'package:flutter/material.dart';
import 'login_page.dart'; // Impor halaman Login
import 'register_page.dart'; // Impor halaman Register

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background putih
          Container(
            color: Colors.white,
          ),
          // Gambar wave di bagian atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/bg.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          // Konten lainnya di bawah gambar wave
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  top:
                      450.0), // Mengatur padding atas agar konten agak ke bawah
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Teks di kiri
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0), // Atur jarak horizontal
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assalamualaikum,',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 26.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(150, 124, 85,
                                100), // Warna teks hijau sesuai gambar
                          ),
                        ),
                        SizedBox(
                            height:
                                4), // Mengurangi jarak antara teks "Hello!" dan "Let's get started."
                        Text(
                          "Selamat Datang di, aplikasi Masjid Salman ITB",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18.0,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                      height: 20), // Mengurangi jarak antara teks dan tombol
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.8, // Lebar tombol 80% dari layar
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(150, 124, 85,
                                  100), // Warna hijau sesuai gambar
                              padding: EdgeInsets.symmetric(
                                  vertical: 15), // Mengatur tinggi tombol
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Masuk',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height:
                                15), // Mengatur jarak antara tombol Sign in dan Create an account
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.8, // Lebar tombol 80% dari layar
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 255, 255,
                                  255), // Warna pink sesuai gambar
                              padding: EdgeInsets.symmetric(
                                  vertical: 15), // Mengatur tinggi tombol
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(
                                  color: Color.fromRGBO(150, 124, 85, 100),
                                ), // Warna border hijau
                              ),
                            ),
                            child: Text(
                              'Daftar',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18.0,
                                color: Color.fromRGBO(150, 124, 85,
                                    100), // Warna teks hijau sesuai gambar
                              ),
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
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LandingPage(),
    routes: {
      '/login': (context) => LoginPage(), // Pastikan halaman login sudah dibuat
      '/register': (context) =>
          RegisterPage(), // Pastikan halaman register sudah dibuat
    },
  ));
}
