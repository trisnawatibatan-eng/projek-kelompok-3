import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// HANYA mengimport file yang terlihat di VS Code Anda
import 'booking_screen.dart'; 
import 'janji_temu_screen.dart'; 
import 'laporan_screen.dart';
import 'profile_screen.dart';
import 'edukasi_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // List ini hanya menggunakan class dari file yang ada di VS Code Anda
  late final List<Widget> _pages = [
    _buildHomeContent(),       // Beranda (Isi konten dashboard ini sendiri)
    const BookingScreen(),     // Sesuai booking_screen.dart
    const JanjiTemuScreen(),   // Sesuai janji_temu_screen.dart
    const LaporanScreen(),     // Sesuai laporan_screen.dart
    const ProfileScreen(),     // Sesuai profile_screen.dart
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- BOTTOM NAVIGATION BAR (Sesuai Label di Gambar Anda) ---
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      selectedItemColor: const Color(0xFF00BBA7),
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined), 
          activeIcon: Icon(Icons.home), 
          label: 'Beranda'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border), 
          activeIcon: Icon(Icons.favorite), 
          label: 'Pemesanan'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined), 
          activeIcon: Icon(Icons.calendar_today), 
          label: 'Janji Temu'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined), 
          activeIcon: Icon(Icons.assignment), 
          label: 'Laporan'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline), 
          activeIcon: Icon(Icons.person), 
          label: 'Profil'
        ),
      ],
    );
  }

  // --- ISI KONTEN BERANDA (HOME) ---
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainPromoCard(),
                const SizedBox(height: 25),
                Text('Jadwal Terapi Terdekat', 
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildScheduleCard(),
                const SizedBox(height: 25),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Edukasi', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () {
                        // Navigasi ke edukasi_screen.dart
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const EdukasiScreen()));
                      },
                      child: Text('Lihat Semua →', 
                          style: GoogleFonts.inter(color: const Color(0xFF00BBA7), fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildEdukasiItem(
                  icon: Icons.air,
                  color: Colors.green,
                  title: 'Teknik Pernapasan untuk Nyeri Punggung',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET KOMPONEN ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF00BBA7),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selamat pagi,', style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
              Text('Pasien 👋', style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.notifications_none, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildMainPromoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pesan Home Care', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _onItemTapped(1), 
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BBA7), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              child: const Text('Pesan Sekarang', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF00BBA7), borderRadius: BorderRadius.circular(20)),
      child: const Row(
        children: [
          CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
          SizedBox(width: 15),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Ftr. Siti Nurhaliza', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text('Besok, 10:00 WIB', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ],
      ),
    );
  }

  Widget _buildEdukasiItem({required IconData icon, required Color color, required String title}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100)
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}