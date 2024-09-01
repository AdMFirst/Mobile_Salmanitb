import 'package:flutter/material.dart';
import 'package:salmanitb/pages/splash_screen.dart' as salmanSplash;
import 'package:salmanitb/pages/landing_page.dart' as salmanLanding;
import 'package:salmanitb/pages/login_page.dart'; // Import LoginPage (assuming no conflicts)
import 'package:salmanitb/pages/register_page.dart'; // Import RegisterPage (assuming no conflicts)

import 'package:salmanitb/pages/main_page.dart'; // Import InformasiPage (for usage in MainPage)
import 'package:salmanitb/pages/jadwal_page.dart'; // Import InformasiPage (for usage in MainPage)
import 'package:salmanitb/pages/informasi_page.dart'; // Import InformasiPage (for usage in MainPage)

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Splash Screen sebagai halaman pertama
      routes: {
        '/': (context) => salmanSplash.SplashScreen(), // Halaman Splash Screen
        '/landing': (context) => salmanLanding.LandingPage(), // Halaman Landing
        '/login': (context) => LoginPage(), // Halaman Login
        '/register': (context) => RegisterPage(), // Halaman Daftar
        '/main': (context) => MainPage(), // Halaman Daftar
        '/informasi': (context) => InformasiPage(), // Halaman Daftar
      },
    );
  }
}
