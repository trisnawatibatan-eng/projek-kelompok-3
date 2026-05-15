import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_nav_bar.dart';

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  // Fungsi untuk menampilkan notifikasi unduh
  void _prosesUnduh(BuildContext context) {
    // Simulasi proses unduh
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text("File laporan telah berhasil diunduh!"),
          ],
        ),
        backgroundColor: const Color(0xFF00BBA7),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER & PROFIL PASIEN ---
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 60),
                  decoration: const BoxDecoration(color: Color(0xFF00BBA7)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Laporan Medis', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Riwayat pemeriksaan dan terapi', style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -40,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 30, backgroundColor: Color(0xFFE0F2F1), child: Icon(Icons.person, color: Color(0xFF00BBA7), size: 35)),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Budi Santoso', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('ID: FSC-2026-01', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 60),

            // --- KONTEN LAPORAN ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.description_outlined, color: Color(0xFF00BBA7)),
                          const SizedBox(width: 8),
                          Text("Catatan Terapi", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFE0F7F4), borderRadius: BorderRadius.circular(20)),
                        child: Text("1 Pertemuan", style: GoogleFonts.inter(color: Color(0xFF00BBA7), fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Card Laporan Utama
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      children: [
                        // Header Card dengan Tombol Unduh
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0F7F4),
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text("Pertemuan #1", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text("28 Maret 2026", style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                              // Tombol Unduh
                              GestureDetector(
                                onTap: () => _prosesUnduh(context),
                                child: const Icon(Icons.file_download_outlined, color: Color(0xFF00BBA7), size: 24),
                              ),
                            ],
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Ftr. Siti Nurhaliza S.Tr.Kes", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                              const Divider(height: 25),
                              
                              _buildInfoDetail("Pertemuan 1", "29 Maret 2026 • 08:00 - 09:00"),
                              _buildTextSection("Keluhan:", "Nyeri bahu kanan saat digerakkan, kaku pada pagi hari"),
                              _buildTextSection("Diagnosis:", "Passive ROM shoulder, Strengthening exercises dengan resistance band, Gait training dengan walker 15 menit"),
                              
                              Row(
                                children: [
                                  _buildSmallStat("Skala Nyeri:", "5/10", isYellow: true),
                                  _buildSmallStat("Tekanan Darah:", "120/80", isYellow: false),
                                ],
                              ),
                              
                              const SizedBox(height: 15),
                              _buildTextSection("Perencanaan Tindakan:", "Pasien kooperatif, menunjukkan peningkatan ROM shoulder."),
                              
                              // Evaluasi
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1FAF9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFB2DFDB)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Evaluasi Terapi", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Color(0xFF00796B), fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text("Progress baik, lanjutkan program. Tambahkan ice therapy.", style: GoogleFonts.inter(fontSize: 11)),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),
                              
                              // --- BAGIAN REKOMENDASI LATIHAN (DIJAMIN TIDAK HILANG) ---
                              Text("Rekomendasi Latihan", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 8),
                              Text(
                                "1. Latihan bahu 2x sehari\n2. Gunakan resistance band ring\n3. Hindari mengangkat beban berat", 
                                style: GoogleFonts.inter(fontSize: 12, height: 1.6, color: Colors.black87)
                              ),

                              const SizedBox(height: 20),
                              
                              // Info Terapi Berikutnya
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5FDFB),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF00BBA7).withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Terapi Berikutnya:", style: GoogleFonts.inter(fontSize: 12, color: Color(0xFF00796B))),
                                    Text("30 Maret 2026", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Color(0xFF00796B))),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildInfoDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Color(0xFF00BBA7)),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
          const Spacer(),
          Text(value, style: GoogleFonts.inter(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTextSection(String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(content, style: GoogleFonts.inter(fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildSmallStat(String label, String value, {required bool isYellow}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isYellow ? const Color(0xFFFFF9C4) : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: isYellow ? Colors.orange[800] : Colors.black)),
          ),
        ],
      ),
    );
  }
}
