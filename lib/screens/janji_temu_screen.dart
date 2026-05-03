import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JanjiTemuScreen extends StatelessWidget {
  const JanjiTemuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00BBA7),
        title: Text(
          'Janji Temu',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Konten header atau filter bisa diletakkan di sini
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Sesi yang telah dibuat'),
                  const SizedBox(height: 16),
                  _buildJadwalUtamaCard(), // Kartu seperti gambar kedua
                  const SizedBox(height: 24),
                  _buildSectionHeader('Riwayat'),
                  const SizedBox(height: 12),
                  _buildRiwayatCard('Terapi Bahu Kanan', '28 Mar', 'Dr. Rizky • Klinik FisioCare', 'Menunggu'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Janji Temu',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Semua →',
              style: GoogleFonts.inter(color: const Color(0xFF00BBA7), fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
        Text(
          subtitle,
          style: GoogleFonts.inter(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildJadwalUtamaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF019283), // Warna hijau toska gelap sesuai gambar
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Besok, 25 Mar 2026',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700), // Label kuning "Terkonfirmasi"
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Terkonfirmasi',
                  style: TextStyle(color: Color(0xFF0F172B), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ftr. Siti Nurhaliza S.Tr.Kes',
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Spesialis Fisioterapi Tulang Belakang',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.access_time, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text('10:00 - 11:00', style: TextStyle(color: Colors.white, fontSize: 13)),
              SizedBox(width: 16),
              Icon(Icons.location_on_outlined, color: Colors.redAccent, size: 16),
              SizedBox(width: 6),
              Text('Home Visit', style: TextStyle(color: Colors.white, fontSize: 13)),
              SizedBox(width: 16),
              Icon(Icons.timer_outlined, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text('60 menit', style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(String title, String date, String clinic, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Text(date.split(' ')[0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00BBA7))),
                Text(date.split(' ')[1].toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00BBA7))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(clinic, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: TextStyle(color: Colors.blue.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}