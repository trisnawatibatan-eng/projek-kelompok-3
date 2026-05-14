import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  bool isDownloaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A79D),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Laporan Medis',
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Riwayat pemeriksaan dan terapi',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profil Pasien
            _buildPatientHeader(),

            const SizedBox(height: 10),

            // Judul Bagian Catatan Terapi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment_outlined, color: Color(0xFF00A79D), size: 22),
                      const SizedBox(width: 8),
                      Text('Catatan Terapi', 
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  _buildChip('1 Pertemuan'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card Utama Laporan Medis
            _buildMedicalReportCard(),

            const SizedBox(height: 20),

            // Notifikasi Download Berhasil
            if (isDownloaded)
              _buildDownloadToast(),

            const SizedBox(height: 100), // Ruang untuk Navbar
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Stack(
      children: [
        Container(height: 40, color: const Color(0xFF00A79D)),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFFE0F2F1),
                child: Icon(Icons.person_outline, color: Color(0xFF00A79D), size: 30),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Budi Santoso', 
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('ID FSC-2026-01', 
                    style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalReportCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00A79D).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Sub-Header Hijau
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2F1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildSmallBadge('Pertemuan #1'),
                    const SizedBox(width: 8),
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text('29 Maret 2026', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => isDownloaded = true);
                    
                    // Munculkan Snack Bar Feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('File Berhasil di unduh!'),
                        backgroundColor: const Color(0xFF00A79D),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );

                    // Hilangkan toast setelah 3 detik
                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted) setState(() => isDownloaded = false);
                    });
                  },
                  child: const Icon(Icons.file_download_outlined, color: Color(0xFF00A79D)),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(radius: 12, backgroundColor: Color(0xFF00A79D), child: Text('SN', style: TextStyle(fontSize: 10, color: Colors.white))),
                    const SizedBox(width: 8),
                    Text('Ftr. Siti Nurhaliza S.Tr.Kes', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const Divider(height: 30),
                _buildSessionInfo(),
                const SizedBox(height: 20),
                _buildTextSection('Keluhan:', 'Nyeri bahu kanan saat digerakkan, kaku pada pagi hari'),
                _buildTextSection('Diagnosa:', 'Passive ROM shoulder, Strengthening exercises dengan resistance band, Gait training dengan walker 15 menit'),
                
                Row(
                  children: [
                    _buildDataPoint('Skala Nyeri:', '5/10', isBold: true, valueColor: Colors.orange),
                    const SizedBox(width: 40),
                    _buildDataPoint('Tekanan Darah:', '120/80', isBold: false),
                  ],
                ),

                _buildTextSection('Perencanaan Tindakan:', 'Pasien kooperatif, menunjukkan peningkatan ROM shoulder. Masih memerlukan bantuan walker untuk berjalan.'),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Evaluasi Terapi', style: GoogleFonts.inter(color: const Color(0xFF00A79D), fontWeight: FontWeight.bold, fontSize: 12)),
                      const Text('Progres baik, lanjutkan program. Tambahkan ice therapy post-exercise.', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),

                const SizedBox(height: 15),
                _buildTextSection('Rekomendasi Latihan:', '1. Latihan bahu 2x sehari\n2. Gunakan resistance band ring\n3. Hindari mengangkat beban berat'),
              ],
            ),
          ),
          _buildNextAppointment(),
        ],
      ),
    );
  }

  Widget _buildSessionInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(radius: 15, backgroundColor: Color(0xFFE0F2F1), child: Text('1', style: TextStyle(color: Color(0xFF00A79D), fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pertemuan 1', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            const Text('29 Maret 2026', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Text('08:00 - 09:00 (60 menit)', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        )
      ],
    );
  }

  Widget _buildTextSection(String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDataPoint(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: GoogleFonts.inter(
          fontSize: 14, 
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: valueColor ?? Colors.black87
        )),
      ],
    );
  }

  Widget _buildNextAppointment() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        border: Border.all(color: const Color(0xFF00A79D).withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.event, size: 18, color: Color(0xFF00A79D)),
              const SizedBox(width: 8),
              Text('Terapi Berikutnya:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          Text('30 Maret 2026', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF00A79D))),
        ],
      ),
    );
  }

  Widget _buildDownloadToast() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
      ),
      child: Row(
        children: const [
          Icon(Icons.check_circle, color: Colors.black),
          SizedBox(width: 12),
          Text('File Berhasil di unduh!', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00A79D)),
      ),
      child: Text(label, style: const TextStyle(color: Color(0xFF00A79D), fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSmallBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFF00A79D), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}