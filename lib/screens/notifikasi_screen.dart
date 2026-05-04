import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688),
        title: const Text("Notifikasi"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _notifCard(
            color: Colors.orange.shade100,
            title: "Jadwal Terapi Akan Dimulai",
            subtitle: "Dengan pasien Ahmad Rizki besok pukul 10:00",
            time: "5 menit lalu",
          ),
          const SizedBox(height: 10),

          _notifCard(
            color: Colors.green.shade100,
            title: "Pembayaran Diterima",
            subtitle: "Pasien Budi Santoso telah membayar terapi",
            time: "1 jam lalu",
          ),
          const SizedBox(height: 10),

          _notifCard(
            color: Colors.blue.shade100,
            title: "Pasien Baru",
            subtitle: "Ahmad Rizki booking terapi besok",
            time: "2 jam lalu",
          ),
        ],
      ),
    );
  }

  Widget _notifCard({
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications, color: Colors.black54),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}