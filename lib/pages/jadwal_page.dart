import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final Map<String, String> prayerTimes = {
    'Subuh': '04:30 AM',
    'Dzuhur': '12:00 PM',
    'Ashar': '03:30 PM',
    'Magrib': '06:00 PM',
    'Isya': '07:30 PM',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Menggunakan SafeArea untuk melindungi konten
        child: Column(
          children: [
            _buildTimeCard(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 14 / 2,
                    ),
                    children: [
                      _buildPrayerCard(
                          'Subuh', Icons.wb_sunny, prayerTimes['Subuh']!),
                      _buildPrayerCard(
                          'Dzuhur', Icons.brightness_5, prayerTimes['Dzuhur']!),
                      _buildPrayerCard(
                          'Ashar', Icons.brightness_6, prayerTimes['Ashar']!),
                      _buildPrayerCard(
                          'Magrib', Icons.brightness_4, prayerTimes['Magrib']!),
                      _buildPrayerCard(
                          'Isya', Icons.brightness_3, prayerTimes['Isya']!),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard() {
    String greeting = _getGreetingMessage();
    String day = _getGreetingDay();
    String nearestPrayer = _getNearestPrayer();

    return Card(
      color: Color.fromRGBO(150, 124, 85, 100),
      elevation: 4,
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Jadwal Shalat Daerah Bandung',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Selamat $greeting, apakah Anda sudah shalat $day?',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'pagi';
    } else if (hour >= 12 && hour < 15) {
      return 'siang';
    } else if (hour >= 15 && hour < 18) {
      return 'sore';
    } else {
      return 'malam';
    }
  }

  String _getGreetingDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Subuh';
    } else if (hour >= 12 && hour < 15) {
      return 'Dzuhur';
    } else if (hour >= 15 && hour < 18) {
      return 'Ashar';
    } else if (hour >= 18 && hour < 19) {
      return 'Maghrib';
    } else {
      return 'Isya';
    }
  }

  String _getNearestPrayer() {
    final now = DateTime.now();
    final DateFormat dateFormat = DateFormat('hh:mm a');

    List<MapEntry<String, DateTime>> parsedPrayerTimes = prayerTimes.entries
        .map((entry) => MapEntry(entry.key, dateFormat.parse(entry.value)))
        .toList();

    String nearestPrayer = 'Isya';
    Duration closestDifference = Duration(hours: 24);

    for (var entry in parsedPrayerTimes) {
      final prayerTime = entry.value;
      final difference = prayerTime.difference(now);

      if ((difference.inMinutes >= -60 && difference.inMinutes <= 0) ||
          difference.inMinutes > 0) {
        if (difference.abs() < closestDifference) {
          closestDifference = difference.abs();
          nearestPrayer = entry.key;
        }
      }
    }

    return nearestPrayer;
  }

  Widget _buildPrayerCard(String title, IconData icon, String time) {
    return Container(
      height: 41, // Tinggi card diatur menjadi 41px
      child: Card(
        color: Colors.grey[300],
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 8.0), // Padding untuk horizontal
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Menyebar konten dengan rata
            children: [
              Icon(
                icon,
                size: 24.0, // Sesuaikan ukuran ikon
                color: Color.fromRGBO(
                    150, 124, 85, 100), // Anda dapat menyesuaikan warna ikon
              ),
              SizedBox(width: 8), // Ruang antara ikon dan teks
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8), // Ruang antara teks dan waktu
              Text(
                time,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
