import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/fisiocare_logo.dart';
import 'booking_screen.dart';
import 'janji_temu_screen.dart';
import 'laporan_screen.dart';
import 'profil_screen.dart';
import 'edukasi_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // Fungsi untuk mengubah tab aktif (Bottom Navigation)
  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _HomeTab(onPesanSekarang: () => _changeTab(1)), // Index 1: Pemesanan
      const BookingScreen(),
      const JanjiTemuScreen(),
      const LaporanScreen(),
      const ProfilScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _changeTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00BBA7),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Pemesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Janji Temu'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Laporan'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final VoidCallback onPesanSekarang;

  const _HomeTab({required this.onPesanSekarang});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildOrderCard(),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Jadwal Terapi'),
                const SizedBox(height: 12),
                _buildJadwalCard(),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Promo Spesial'),
                const SizedBox(height: 12),
                _buildPromoList(),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Edukasi', isEdukasi: true),
                const SizedBox(height: 12),
                _buildEdukasiList(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00BBA7), Color(0xFF019283)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 35, height: 35, child: FisioCareLogoWidget()),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FisioCare', style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Your Physio Partner', style: GoogleFonts.inter(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text('${getGreeting()},', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                Text('Budi Santoso 👋', style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Row(
            children: [
              _buildHeaderIcon(Icons.chat_bubble_outline, '1'),
              const SizedBox(width: 10),
              _buildHeaderIcon(Icons.notifications_none, '5'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, String count) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Color(0xFFFF5252), shape: BoxShape.circle),
            child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }

  Widget _buildOrderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pesan Home Care', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Dapatkan layanan fisioterapi profesional di rumah Anda', style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onPesanSekarang, 
              icon: const Icon(Icons.calendar_month, size: 18, color: Colors.white),
              label: const Text('Pesan Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BBA7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildJadwalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00BBA7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text('Besok, 25 Mar 2026', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(8)),
                child: const Text('Menunggu Pembayaran', style: TextStyle(color: Color(0xFF0F172B), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              CircleAvatar(radius: 25, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ftr. Siti Nurhaliza S.Tr.Kes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 4),
                  Text('Fisioterapis Terampil', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.access_time, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text('10:00 - 11:00', style: TextStyle(color: Colors.white, fontSize: 13)),
              SizedBox(width: 20),
              Icon(Icons.timer_outlined, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text('60 menit', style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {bool isEdukasi = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        InkWell(
          onTap: () {
            if (isEdukasi) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EdukasiScreen()));
            }
          },
          child: Text(
            'Lihat Semua →',
            style: GoogleFonts.inter(color: const Color(0xFF00BBA7), fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoList() {
    return SizedBox(
      height: 170,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildPromoCard('Diskon Sesi Pertama', '20%', 'FISIO2026', const Color(0xFF00BBA7)),
          _buildPromoCard('Paket Hemat 5 Sesi', '15%', 'HEMAT5', const Color(0xFF019283)),
        ],
      ),
    );
  }

  Widget _buildPromoCard(String title, String diskon, String kode, Color color) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, height: 1.2))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(6)),
                child: Text(diskon, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
              )
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
            child: Text('Kode: $kode', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildEdukasiList() {
    final items = [
      {'cat': 'FISIOTERAPI', 'title': 'Pentingnya Fisioterapi Setelah Operasi Lutut', 'icon': Icons.healing, 'color': Colors.teal},
      {'cat': 'NUTRISI', 'title': 'Suplemen yang Baik untuk Kesehatan Sendi', 'icon': Icons.restaurant, 'color': Colors.orange},
      {'cat': 'LATIHAN', 'title': '5 Gerakan Penguatan Otot Core untuk Pemula', 'icon': Icons.fitness_center, 'color': Colors.blue},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: (items[index]['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(items[index]['icon'] as IconData, color: items[index]['color'] as Color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(items[index]['cat'] as String, style: TextStyle(color: items[index]['color'] as Color, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(items[index]['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Selamat pagi';
    } else if (hour < 15) {
      return 'Selamat siang';
    } else if (hour < 18) {
      return 'Selamat sore';
    } else {
      return 'Selamat malam';
    }
  }
}