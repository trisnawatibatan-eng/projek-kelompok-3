import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edukasi_screen.dart'; // Pastikan file ini diimport

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBA7),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifikasi Pasien',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                _buildSectionHeader('Hari Ini'),
                
                // 1. NOTIFIKASI JADWAL -> Klik akan balik ke Dashboard Tab Janji Temu (Index 2)
                _buildNotificationItem(
                  context: context,
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                  category: 'Jadwal',
                  title: 'Ingat: Jadwal Terapi Besok',
                  desc: 'Jadwal Anda dengan Ftr. Siti Nurhaliza besok pukul 10:00 WIB. Klik untuk detail.',
                  time: '10:30',
                  isUnread: true,
                  onTap: () => Navigator.pop(context, 2), // Kirim index 2 ke Dashboard
                ),

                // 2. NOTIFIKASI MEDIS -> Klik akan balik ke Dashboard Tab Laporan (Index 3)
                _buildNotificationItem(
                  context: context,
                  icon: Icons.assignment_turned_in_outlined,
                  color: Colors.teal,
                  category: 'Medis',
                  title: 'Laporan Baru Tersedia',
                  desc: 'Fisioterapis telah mengunggah laporan hasil terapi sesi terbaru. Klik untuk melihat.',
                  time: '08:15',
                  isUnread: true,
                  onTap: () => Navigator.pop(context, 3), // Kirim index 3 ke Dashboard
                ),
                
                const SizedBox(height: 20),
                _buildSectionHeader('Kemarin'),

                // 3. NOTIFIKASI EDUKASI (Ganti dari Pembayaran) -> Klik buka EdukasiScreen
                _buildNotificationItem(
                  context: context,
                  icon: Icons.lightbulb_outline, // Ikon Edukasi
                  color: Colors.orange,
                  category: 'Edukasi',
                  title: 'Tips Edukasi Baru',
                  desc: 'Baru! "Teknik Pernapasan untuk Nyeri Punggung" telah tersedia. Yuk baca!',
                  time: 'Kemarin, 09:00',
                  isUnread: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EdukasiScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14, 
          fontWeight: FontWeight.bold, 
          color: Colors.grey.shade700
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Row(
        children: [
          _buildChip('Semua', true),
          const SizedBox(width: 10),
          _buildChip('Jadwal', false),
          const SizedBox(width: 10),
          _buildChip('Medis', false),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00BBA7) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // WIDGET ITEM YANG BISA DIKLIK
  Widget _buildNotificationItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String category,
    required String title,
    required String desc,
    required String time,
    required bool isUnread,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap, // Fungsi klik aktif di sini
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isUnread ? const Color(0xFFF0F9F8) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread ? const Color(0xFF00BBA7).withOpacity(0.3) : Colors.grey.shade100
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1), 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200, 
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text(
                            category, 
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54)
                          ),
                        ),
                        Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title, 
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc, 
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54, height: 1.4)
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