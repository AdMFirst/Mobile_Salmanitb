import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class InformasiPage extends StatefulWidget {
  const InformasiPage({super.key});

  @override
  State<InformasiPage> createState() => _InformasiPageState();
}

class _InformasiPageState extends State<InformasiPage> {
  String? dropdownValue1;
  String? dropdownValue2;
  String? dropdownValue3;
  String? dropdownValue4;
  List<Map<String, dynamic>> programOptions = [];
  List<Map<String, dynamic>> bidangOptions = [];

  List<String> filteredProgramOptions = [];
  String jumlahRealisasi =
      'Pilih bidang, program, bulan, dan tahun terlebih dahulu';
  String totalNilaiSatuan =
      'Pilih bidang, program, bulan, dan tahun terlebih dahulu';
  List<Map<String, dynamic>> programKegiatanDetails = [];
  Map<String, bool> isCardVisible =
      {}; // State untuk mengontrol visibility dari card

  final List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agust',
    'Sept',
    'Okt',
    'Nov',
    'Des'
  ];

  final List<String> years =
      List.generate(4, (index) => (2024 - index).toString());

  @override
  void initState() {
    super.initState();
    fetchProgramOptions();
    fetchBidangOptions();
  }

  Future<void> fetchProgramOptions() async {
    final response = await http
        .get(Uri.parse('https://salimapi.admfirst.my.id/api/mobile/program'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        programOptions = data
            .map((item) => {
                  'id_bidang':
                      item['id_bidang'], // Mengonversi id_bidang menjadi String
                  'id': item['id'], // Mengonversi id menjadi String
                  'nama': item['nama']
                })
            .toList();
        filterProgramOptions();
      });
    } else {
      print('Failed to load program options');
    }
  }

  Future<void> fetchBidangOptions() async {
    final response = await http
        .get(Uri.parse('https://salimapi.admfirst.my.id/api/mobile/bidang'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        bidangOptions = data
            .map((item) => {'id': item['id'], 'nama': item['nama']})
            .toList();

        // Hilangkan duplikat pada bidangOptions
        bidangOptions = bidangOptions.toSet().toList();
      });
    } else {
      print('Failed to load bidang options');
    }
  }

  void filterProgramOptions() {
    if (dropdownValue4 != null) {
      final selectedBidang = bidangOptions
          .firstWhere((bidang) => bidang['nama'] == dropdownValue4);
      setState(() {
        filteredProgramOptions = programOptions
            .where((program) => program['id_bidang'] == selectedBidang['id'])
            .map((program) => program['nama'].toString())
            .toSet() // Menghilangkan duplikat dengan menggunakan Set
            .toList();
        if (filteredProgramOptions.isEmpty) {
          filteredProgramOptions = ['tidak ada data'];
        }
        // Reset dropdownValue1 jika program yang dipilih tidak ada di filteredProgramOptions
        if (!filteredProgramOptions.contains(dropdownValue1)) {
          dropdownValue1 = null;
        }
      });
    } else {
      setState(() {
        filteredProgramOptions = ['tidak ada data'];
        dropdownValue1 = null;
      });
    }
  }

  String get saldo {
    if (totalNilaiSatuan !=
            'Pilih bidang, program, bulan, dan tahun terlebih dahulu' &&
        jumlahRealisasi !=
            'Pilih bidang, program, bulan, dan tahun terlebih dahulu') {
      try {
        final plannedAmount = double.parse(
            totalNilaiSatuan.replaceAll('Rp ', '').replaceAll('.', ''));
        final usedAmount = double.parse(
            jumlahRealisasi.replaceAll('Rp ', '').replaceAll('.', ''));
        final calculatedSaldo = plannedAmount - usedAmount;

        final formattedSaldo = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        ).format(calculatedSaldo);

        return formattedSaldo;
      } catch (e) {
        return 'Tidak ada data';
      }
    } else {
      return 'Pilih bidang, program, bulan, dan tahun terlebih dahulu';
    }
  }

  Future<void> fetchLaporanData() async {
    if (dropdownValue1 != null &&
        dropdownValue2 != null &&
        dropdownValue3 != null) {
      try {
        final selectedProgram = programOptions
            .firstWhere((program) => program['nama'] == dropdownValue1);
        final response = await http.get(Uri.parse(
            'https://salimapi.admfirst.my.id/api/mobile/laporan?id_program=${selectedProgram['id']}&month=${months.indexOf(dropdownValue2!) + 1}&year=$dropdownValue3'));

        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          try {
            final data = json.decode(response.body);
            if (data['alokasi_danas'] != null &&
                data['alokasi_danas'].isNotEmpty) {
              double totalRealisasi = 0;
              double totalSatuan = 0;

              for (var item in data['alokasi_danas']) {
                totalRealisasi +=
                    double.parse(item['jumlah_realisasi'].toString());
                totalSatuan += double.parse(
                    item['item_kegiatan_r_k_a']['nilai_satuan'].toString());
              }

              final NumberFormat currencyFormat = NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              );

              setState(() {
                jumlahRealisasi = currencyFormat.format(totalRealisasi);
                totalNilaiSatuan = currencyFormat.format(totalSatuan);
              });
            } else {
              setState(() {
                jumlahRealisasi = 'Data tidak tersedia';
                totalNilaiSatuan = 'Data tidak tersedia';
              });
            }

            // Mengambil nama program kegiatan dan data terkait dari API
            if (data['pelaksanaans'] != null) {
              setState(() {
                programKegiatanDetails = data['pelaksanaans']
                    .where((item) => item['program_kegiatan'] != null)
                    .map<Map<String, dynamic>>((item) => {
                          'nama': item['program_kegiatan']['nama'].toString(),
                          'penjelasan': item['penjelasan']
                              ?.toString(), // Mengonversi ke String jika null
                          'id_program_kegiatan_kpi':
                              item['id_program_kegiatan_kpi'].toString(),
                          'id_program_kegiatan':
                              item['program_kegiatan']['id'].toString(),
                          'waktu': item['waktu']?.toString(),
                          'tempat': item['tempat']?.toString(),
                          'penyaluran': item['penyaluran']?.toString(),
                        })
                    .toList();

                // Inisialisasi visibility state
                programKegiatanDetails.forEach((kegiatan) {
                  isCardVisible[kegiatan['id_program_kegiatan']] = false;
                });
              });
            } else {
              setState(() {
                programKegiatanDetails = [];
              });
            }
          } catch (e) {
            setState(() {
              jumlahRealisasi = 'Error parsing JSON: ${e.toString()}';
              totalNilaiSatuan = 'Error parsing JSON: ${e.toString()}';
            });
          }
        } else {
          setState(() {
            jumlahRealisasi = 'Tidak ada data';
            totalNilaiSatuan = 'Tidak ada data';
          });
        }
      } catch (e) {
        setState(() {
          jumlahRealisasi = 'Error: ${e.toString()}';
          totalNilaiSatuan = 'Error: ${e.toString()}';
        });
      }
    } else {
      setState(() {
        jumlahRealisasi = 'Pilih program, bulan, dan tahun terlebih dahulu';
        totalNilaiSatuan = 'Pilih program, bulan, dan tahun terlebih dahulu';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            // Tambahkan SingleChildScrollView di sini
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 1),
                        child: Text(
                          'SI',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                          child: Text(
                            'Salman ITB',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFF908F8F),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildDropdown(
                        value: dropdownValue4,
                        hint: 'Bidang Pengkajian dan Penerbitan',
                        items: bidangOptions
                            .map((bidang) => bidang['nama'].toString())
                            .toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue4 = newValue;
                            dropdownValue1 = null;
                            filterProgramOptions();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _buildDropdown(
                        value: dropdownValue1,
                        hint: 'Pilih Program',
                        items: filteredProgramOptions,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue1 = newValue;
                            fetchLaporanData(); // Fetch data when program changes
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildDropdown(
                        value: dropdownValue2,
                        hint: 'Jan',
                        items: months,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue2 = newValue;
                            fetchLaporanData(); // Fetch data when month changes
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildDropdown(
                        value: dropdownValue3,
                        hint: '2024',
                        items: years,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue3 = newValue;
                            fetchLaporanData(); // Fetch data when year changes
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 14,
                ),
                Align(
                  alignment: AlignmentDirectional(-1, 0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 14),
                    child: Text(
                      'Laporan',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(-1, 0),
                  child: Container(
                    constraints: BoxConstraints(minHeight: 85, minWidth: 324),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Align(
                      alignment: AlignmentDirectional(-1, 0),
                      child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: Color(0xFF967C55),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0, 0),
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(21, 25, 21, 25),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Teks yang diambil dari API
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Align(
                                        alignment: AlignmentDirectional(-1, 0),
                                        child: Text(
                                          'Dana yang direncanakan',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            21, 0, 9, 0),
                                        child: Text(
                                          ':',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          totalNilaiSatuan, // Menampilkan total nilai_satuan
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Align(
                                        alignment: AlignmentDirectional(-1, 0),
                                        child: Text(
                                          'Dana yang digunakan',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            37, 0, 9, 0),
                                        child: Text(
                                          ':',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          jumlahRealisasi, // Menampilkan jumlah_realisasi
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Align(
                                        alignment: AlignmentDirectional(-1, 0),
                                        child: Text(
                                          'Saldo',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            120, 0, 9, 0),
                                        child: Text(
                                          ':',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          saldo, // Menampilkan hasil perhitungan saldo
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 14,
                ),
                Align(
                  alignment: AlignmentDirectional(-1, 0),
                  child: Text(
                    'Deskripsi Pelaksanaan Kegiatan',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.black,
                      fontSize: 12,
                      letterSpacing: 0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Align(
                  alignment: AlignmentDirectional(-1, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...programKegiatanDetails.map((kegiatan) {
                        final isIdMatched =
                            kegiatan['id_program_kegiatan_kpi'] ==
                                kegiatan['id_program_kegiatan'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kegiatan['nama'],
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.black,
                                  fontSize: 12,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              if (isIdMatched)
                                Align(
                                  alignment: AlignmentDirectional.center,
                                  child: SizedBox(
                                    width: 324,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          isCardVisible[kegiatan[
                                                  'id_program_kegiatan']] =
                                              !(isCardVisible[kegiatan[
                                                      'id_program_kegiatan']] ??
                                                  false);
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF967C55),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        kegiatan['penjelasan'] ?? 'Tekan Saya',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (isCardVisible[
                                      kegiatan['id_program_kegiatan']] ??
                                  false)
                                if (isIdMatched)
                                  Align(
                                    alignment: AlignmentDirectional.center,
                                    child: SizedBox(
                                      width:
                                          324, // Mengatur lebar card menjadi 324 piksel
                                      child: Card(
                                        color: Colors.white,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Waktu         : ${kegiatan['waktu'] ?? 'Tidak tersedia'}',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Tempat       : ${kegiatan['tempat'] ?? 'Tidak tersedia'}',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Penyaluran : ${kegiatan['penyaluran'] ?? 'Tidak tersedia'}',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildDropdown({
  required String? value,
  required String hint,
  required List<String> items,
  required void Function(String?) onChanged,
}) {
  return Container(
    height: 35,
    padding: EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(4),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: items.contains(value) ? value : null,
        hint: Text(hint, style: TextStyle(fontSize: 10)),
        isExpanded: true,
        icon: FaIcon(
          FontAwesomeIcons.caretDown,
          color: Colors.grey,
          size: 16.0,
        ),
        onChanged: onChanged,
        items:
            items.toSet().toList().map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(fontSize: 12),
            ),
          );
        }).toList(),
      ),
    ),
  );
}
