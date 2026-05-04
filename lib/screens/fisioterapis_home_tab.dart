import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/fisiocare_logo.dart';
import '../screens/chat_screen.dart';
import '../screens/notifikasi_screen.dart';

class FisioterapisHomeTab extends StatelessWidget {
  const FisioterapisHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: _content(),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      height: 200,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00BBA7), Color(0xFF009689)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FisioCareLogoSmall(),
              const Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    _circleIcon(Icons.chat_bubble_outline),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: _badge("2"),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotifikasiScreen(),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    _circleIcon(Icons.notifications_none),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: _badge("3"),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Selamat datang,',
              style: GoogleFonts.inter(color: Colors.white70)),
          Text(
            'Ftr. Siti Nurhaliza\nS.Tr.Kes',
            style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _coloredBookingCard(),
            const SizedBox(height: 12),
            _paymentCard(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pasien Hari Ini",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "6 Pasien",
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _statusCard(
                        "Selesai", "2", Colors.green, Icons.check_circle)),
                const SizedBox(width: 10),
                Expanded(
                    child: _statusCard(
                        "Berlangsung", "1", Colors.blue, Icons.show_chart)),
                const SizedBox(width: 10),
                Expanded(
                    child: _statusCard(
                        "Mendatang", "3", Colors.orange, Icons.access_time)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Edukasi",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Lihat Semua",
                  style: TextStyle(color: Colors.teal),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _educationCard(
              "Latihan Peregangan Bahu",
              "Pelajari gerakan sederhana untuk mengurangi nyeri bahu",
              Icons.accessibility_new,
            ),
            const SizedBox(height: 10),
            _educationCard(
              "Terapi Nyeri Punggung",
              "Tips fisioterapi untuk mengurangi nyeri punggung",
              Icons.self_improvement,
            ),
          ],
        ),
      ),
    );
  }

  Widget _coloredBookingCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_today,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("3 Permintaan Booking",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text("Menunggu konfirmasi Anda",
                    style: TextStyle(fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Text("3",
                style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _paymentCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFB2EDE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Rp",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "Riwayat Pembayaran",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(title, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _educationCard(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFB2EDE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.teal),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14)
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return CircleAvatar(
      backgroundColor: Colors.white24,
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _badge(String text, {Color color = Colors.red}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child:
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }
}
