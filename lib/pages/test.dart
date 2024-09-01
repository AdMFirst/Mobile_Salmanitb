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
  String jumlahRealisasi = 'Memuat data...';
  String totalNilaiSatuan = 'Memuat data...';
  List<String> programKegiatanNames = [];
  List<Map<String, dynamic>> pelaksanaanKegiatan =
      []; // Menyimpan pelaksanaan data

  final List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
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
                  'id_bidang': item['id_bidang'],
                  'id': item['id'],
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
            .toList();
        if (filteredProgramOptions.isEmpty) {
          filteredProgramOptions = ['tidak ada data'];
        }
      });
    } else {
      setState(() {
        filteredProgramOptions = ['tidak ada data'];
      });
    }
  }

  String get saldo {
    if (totalNilaiSatuan != 'Memuat data...' &&
        jumlahRealisasi != 'Memuat data...') {
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
        return 'Error';
      }
    } else {
      return 'Memuat data...';
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

            // Mengambil nama program kegiatan dari API
            if (data['pelaksanaans'] != null) {
              setState(() {
                programKegiatanNames = data['pelaksanaans']
                    .where((item) => item['program_kegiatan'] != null)
                    .map<String>(
                        (item) => item['program_kegiatan']['nama'].toString())
                    .toList();

                pelaksanaanKegiatan = data['pelaksanaans']
                    .map<Map<String, dynamic>>((item) => {
                          'id': item['program_kegiatan'] != null
                              ? item['program_kegiatan']['id']
                              : null,
                          'id_program_kegiatan_kpi':
                              item['id_program_kegiatan_kpi'],
                          'penjelasan': item['penjelasan'],
                        })
                    .toList();
              });
            } else {
              setState(() {
                programKegiatanNames = ['Tidak ada program kegiatan'];
                pelaksanaanKegiatan = [];
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
            jumlahRealisasi =
                'Gagal memuat data. Kode Status: ${response.statusCode}';
            totalNilaiSatuan =
                'Gagal memuat data. Kode Status: ${response.statusCode}';
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
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
                      hint: 'Program Kepustakaan',
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
                      hint: 'Januari',
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
                    ...programKegiatanNames.map((name) {
                      final kegiatan = pelaksanaanKegiatan.firstWhere(
                          (item) =>
                              item['id'] == programKegiatanNames.indexOf(name),
                          orElse: () => {});
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.black,
                                fontSize: 12,
                                letterSpacing: 0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8), // Spasi antara teks dan button
                            if (kegiatan.isNotEmpty &&
                                kegiatan['id'] ==
                                    kegiatan[
                                        'id_program_kegiatan_kpi']) // Memastikan kondisi sesuai
                              Align(
                                alignment: AlignmentDirectional
                                    .center, // Ubah alignment sesuai kebutuhan
                                child: SizedBox(
                                  width:
                                      324, // Lebar button ditetapkan menjadi 324px
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Tambahkan aksi yang ingin dilakukan saat button ditekan
                                      print('Button ditekan!');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF967C55),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // Radius untuk sudut yang melengkung
                                      ),
                                    ),
                                    child: Text(
                                      kegiatan['penjelasan'] ??
                                          'Tekan Saya', // Tampilkan penjelasan dari API
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors
                                            .white, // Warna teks pada button
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
        value: value,
        hint: Text(hint, style: TextStyle(fontSize: 12)),
        isExpanded: true,
        icon: FaIcon(
          FontAwesomeIcons.caretDown,
          color: Colors.grey,
          size: 16.0,
        ),
        onChanged: onChanged,
        items: items.asMap().entries.map<DropdownMenuItem<String>>((entry) {
          int index = entry.key;
          String item = entry.value;
          Color color = index % 2 == 0 ? Colors.white : Colors.grey[300]!;
          return DropdownMenuItem<String>(
            value: item,
            child: Container(
              color: color,
              child: Text(
                item,
                style: TextStyle(fontSize: 12),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}
