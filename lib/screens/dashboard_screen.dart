import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import file sesuai struktur folder Anda
import 'booking_screen.dart'; 
import 'janji_temu_screen.dart'; 
import 'laporan_screen.dart';
import 'profile_screen.dart';
import 'edukasi_screen.dart';
<<<<<<< Updated upstream
import 'notifikasi_screen.dart'; 
=======
import 'detail_artikel_screen.dart'; // Import halaman detail
import 'booking_screen.dart';
import 'login_screen.dart';
>>>>>>> Stashed changes
import 'chat_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
<<<<<<< Updated upstream
  int _selectedIndex = 0;

  // Menggunakan getter untuk daftar halaman agar sinkron dengan context
  List<Widget> get _pages => [
    _buildHomeContent(),       // Index 0: Beranda
    BookingScreen(),     // Index 1: Pemesanan
    JanjiTemuScreen(),   // Index 2: Janji Temu
    LaporanScreen(),     // Index 3: Laporan
    ProfileScreen(),     // Index 4: Profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
=======
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _patientData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
        return;
      }

      final data = await _supabase
          .from('patients')
          .select('full_name, gender')
          .eq('id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _patientData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String get _firstName {
    final fullName = _patientData?['full_name'] as String?;
    if (fullName == null || fullName.isEmpty) return 'Pasien';
    return fullName.split(' ').first;
>>>>>>> Stashed changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< Updated upstream
      backgroundColor: Colors.white,
      // Menggunakan IndexedStack agar state tiap halaman terjaga (tidak reload)
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
=======
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00BBA7)),
            )
          : _buildHomeContent(),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
>>>>>>> Stashed changes
    );
  }

  // --- BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      selectedItemColor: const Color(0xFF00BBA7),
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
      unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Pemesanan'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Janji Temu'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Laporan'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }

  // --- ISI KONTEN BERANDA ---
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
<<<<<<< Updated upstream
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
=======
          Transform.translate(
            offset: const Offset(0, -30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainPromoCard(),
                  const SizedBox(height: 25),
                  Text(
                    'Jadwal Terapi',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildScheduleCard(),
                  const SizedBox(height: 25),
                  _buildEdukasiHeader(),
                  const SizedBox(height: 15),
                  _buildEdukasiItem(Icons.air, Colors.green, 'PERNAPASAN',
                      'Teknik Pernapasan untuk Nyeri Punggung', '28 Mei 2025'),
                  _buildEdukasiItem(Icons.restaurant, Colors.orange, 'NUTRISI',
                      'Suplemen yang Baik untuk Kesehatan Sendi', '24 Mei 2025'),
                  _buildEdukasiItem(Icons.fitness_center, Colors.blue, 'LATIHAN',
                      '5 Gerakan Penguatan Otot Core untuk Pemula', '20 Mei 2025'),
                  _buildEdukasiItem(Icons.psychology, Colors.purple, 'MENTAL',
                      'Mengelola Stres Saat Proses Pemulihan', '18 Mei 2025'),
                  const SizedBox(height: 20),
                ],
              ),
>>>>>>> Stashed changes
            ),
          ),
        ],
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 60),
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
<<<<<<< Updated upstream
              Text('Selamat pagi,', style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
              Text('Budi Santoso 👋', style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
=======
              Row(
                children: [
                  const Text('FisioCare',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  const SizedBox(width: 8),
                  Text('Your Physio Partner',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 10)),
                ],
              ),
              const SizedBox(height: 15),
              Text('$_greeting,',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
              Text('$_firstName 👋',
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
>>>>>>> Stashed changes
            ],
          ),
          Row(
            children: [
<<<<<<< Updated upstream
              _buildHeaderIconButton(
                icon: Icons.chat_bubble_outline, 
                count: '5', 
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const ChatListScreen())
                  );
                }, 
              ),
              const SizedBox(width: 12),
              _buildHeaderIconButton(
                icon: Icons.notifications_none, 
                count: '3', 
                onTap: () async {
                  final targetTab = await Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => NotifikasiScreen())
                  );
                  
                  if (!mounted) return;
                  if (targetTab != null && targetTab is int) {
                    _onItemTapped(targetTab);
                  }
                }
              ),
=======
              _buildIconButton(
                  Icons.chat_bubble_outline,
                  true,
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ChatListScreen()))),
              const SizedBox(width: 10),
              _buildIconButton(
                  Icons.notifications_none,
                  true,
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const NotifikasiScreen()))),
>>>>>>> Stashed changes
            ],
          ),
        ],
      ),
    );
  }

<<<<<<< Updated upstream
  Widget _buildHeaderIconButton({required IconData icon, required String count, required VoidCallback onTap}) {
=======
  Widget _buildIconButton(IconData icon, bool showDot, VoidCallback onTap) {
>>>>>>> Stashed changes
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
<<<<<<< Updated upstream
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ),
=======
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
                color: Colors.white24, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          if (showDot)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: const Text('1',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              ),
            )
>>>>>>> Stashed changes
        ],
      ),
    );
  }

  Widget _buildMainPromoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
<<<<<<< Updated upstream
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)]
=======
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
>>>>>>> Stashed changes
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< Updated upstream
          const Text('Pesan Home Care', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _onItemTapped(1), 
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BBA7), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
=======
          const Text('Pesan Home Care',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Dapatkan layanan fisioterapi profesional di rumah Anda',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const BookingScreen())),
              icon: const Icon(Icons.calendar_today, size: 18, color: Colors.white),
              label: const Text('Pesan Sekarang',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BBA7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
>>>>>>> Stashed changes
                elevation: 0,
              ),
              child: const Text('Pesan Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
<<<<<<< Updated upstream
    return InkWell(
      onTap: () => _onItemTapped(2), 
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF00BBA7), 
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFF00BBA7).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
        ),
        child: Row(
          children: [
            const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text('Ftr. Siti Nurhaliza', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('Besok, 10:00 WIB', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                ]
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
=======
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('Besok, 25 Mar 2026',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFFEBB1B),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('Menunggu Pembayaran',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(
                  radius: 20, backgroundColor: Colors.white, child: Text('👩‍⚕️')),
              const SizedBox(width: 15),
              const Expanded(
                child: Text('Ftr. Siti Nurhaliza S.Tr.Kes',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 25),
          const Row(
            children: [
              Icon(Icons.access_time, color: Colors.white70, size: 16),
              SizedBox(width: 6),
              Text('10:00-11:00',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
              SizedBox(width: 15),
              Icon(Icons.circle, color: Colors.white70, size: 6),
              SizedBox(width: 6),
              Text('60 menit',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ],
>>>>>>> Stashed changes
      ),
    );
  }

<<<<<<< Updated upstream
  Widget _buildEdukasiItem({required IconData icon, required Color color, required String title}) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const EdukasiScreen()));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100)
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            const Icon(Icons.chevron_right, color: Colors.grey),
=======
  Widget _buildEdukasiHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Edukasi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const EdukasiScreen())),
          child: const Text('Lihat Semua →',
              style: TextStyle(
                  color: Color(0xFF00BBA7),
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildEdukasiItem(
      IconData icon, Color color, String category, String title, String date) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailArtikelScreen(
              title: title,
              tag: category,
              icon: icon,
              color: color,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category,
                      style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(date,
                      style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
>>>>>>> Stashed changes
          ],
        ),
      ),
    );
  }
}