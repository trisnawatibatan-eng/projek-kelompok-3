import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/fisiocare_logo.dart';
import 'login_screen.dart';
import 'notifikasi_screen.dart';
import 'catatan_pendapatan_screen.dart';

class FisioterapisDashboardScreen extends StatefulWidget {
  const FisioterapisDashboardScreen({super.key});

  @override
  State<FisioterapisDashboardScreen> createState() => _FisioterapisDashboardScreenState();
}

class _FisioterapisDashboardScreenState extends State<FisioterapisDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    const _PasienTab(),
    const _PendapatanTab(),
    const _ProfilTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFE2E8F0), width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 65,
          child: Row(
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Beranda'),
              _buildNavItem(1, Icons.people_outline, Icons.people, 'Pasien'),
              _buildNavItem(2, Icons.calendar_today_outlined, Icons.calendar_today, 'Jadwal'),
              _buildNavItem(3, Icons.person_outline, Icons.person, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 24,
                color: isActive ? AppColors.primary : const Color(0xFF62748E),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isActive ? AppColors.primary : const Color(0xFF62748E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Home Tab ───────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Stack(
        children: [
          _header(context),
          _content(),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      height: 260,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 20),
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
              Stack(
                children: [
                  _circleIcon(Icons.notifications),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: _badge("3"),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          Text('Selamat datang,', style: GoogleFonts.inter(color: Colors.white70)),
          Text('Ftr. Siti Nurhaliza\nS.Tr.Kes',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Fisioterapi Neuro', style: GoogleFonts.inter(color: Colors.white70)),
        ],
      ),
    );
  }

Widget _content() {
  return SingleChildScrollView(
    child: Container(
      margin: const EdgeInsets.only(top: 200),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _card(
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 6),
                Text('4.9 (127 ulasan)',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                const Spacer(),
                _button('Lihat Ulasan')
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _miniCard("Hari Ini", "6", Icons.calendar_today)),
              const SizedBox(width: 10),
              Expanded(child: _miniCard("Jadwal", "8", Icons.calendar_today)),
            ],
          ),

          const SizedBox(height: 12),

          _coloredCard(
            Colors.orange.shade100,
            "3 Permintaan Booking",
            "Menunggu konfirmasi Anda",
            "3",
            Colors.red,
          ),

          const SizedBox(height: 12),

          _coloredCard(
            Colors.blue.shade100,
            "3 Permintaan Reschedule",
            "Pasien ingin ubah jadwal",
            "3",
            Colors.blue,
          ),

          const SizedBox(height: 16),

          _card(
            child: Column(
              children: [
                Row(
                  children: [
                    Text("Pasien Hari Ini",
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    _badge("6 Pasien", color: AppColors.primary)
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _status("2", "Selesai", Colors.green),
                    _status("1", "Berlangsung", Colors.blue),
                    _status("3", "Mendatang", Colors.orange),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  // ===== helper =====

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)],
      ),
      child: child,
    );
  }

  Widget _miniCard(String title, String value, IconData icon) {
    return _card(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: GoogleFonts.inter(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _coloredCard(Color bg, String title, String sub, String count, Color badgeColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          const Icon(Icons.calendar_today),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                Text(sub, style: GoogleFonts.inter(fontSize: 11)),
              ],
            ),
          ),
          _badge(count, color: badgeColor)
        ],
      ),
    );
  }

  Widget _status(String value, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Text(value, style: TextStyle(color: color))),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 11))
      ],
    );
  }

  Widget _button(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: GoogleFonts.inter(fontSize: 11)),
    );
  }

  Widget _circleIcon(IconData icon) {
    return CircleAvatar(backgroundColor: Colors.white24, child: Icon(icon, color: Colors.white));
  }

  Widget _badge(String text, {Color color = Colors.red}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }
}

// ─── Pasien Tab ─────────────────────────────────────────────────────────────

class _PasienTab extends StatelessWidget {
  const _PasienTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('Daftar Pasien', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFDDD6FE), Color(0xFFB2EDE7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(child: Text('👤', style: TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pasien ${index + 1}',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryText),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sesi ke-${(index + 1) * 5}',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.lightText),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Pendapatan Tab ─────────────────────────────────────────────────────────

class _PendapatanTab extends StatefulWidget {
  const _PendapatanTab();

  @override
  State<_PendapatanTab> createState() => _PendapatanTabState();
}

class _PendapatanTabState extends State<_PendapatanTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('Pendapatan', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.lightText,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(child: Text('Semua', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                Tab(child: Text('Pending', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                Tab(child: Text('Dibayar', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendapatanList('semua'),
          _buildPendapatanList('pending'),
          _buildPendapatanList('dibayar'),
        ],
      ),
    );
  }

  Widget _buildPendapatanList(String filter) {
    final List<Map<String, dynamic>> items = [
      {
        'pasien': 'Budi Santoso',
        'jenis': 'Fisioterapi Lumbal',
        'tanggal': '25 Mar 2026',
        'nominal': 'Rp 150.000',
        'status': 'Dibayar',
        'statusColor': const Color(0xFFD1FAE5),
        'statusTextColor': const Color(0xFF065F46),
      },
      {
        'pasien': 'Ahmad Rizki',
        'jenis': 'Terapi Bahu',
        'tanggal': '24 Mar 2026',
        'nominal': 'Rp 130.000',
        'status': 'Pending',
        'statusColor': const Color(0xFFFEF3C7),
        'statusTextColor': const Color(0xFF92400E),
      },
      {
        'pasien': 'Siti Nurhaliza',
        'jenis': 'Fisioterapi Lutut',
        'tanggal': '23 Mar 2026',
        'nominal': 'Rp 160.000',
        'status': 'Dibayar',
        'statusColor': const Color(0xFFD1FAE5),
        'statusTextColor': const Color(0xFF065F46),
      },
    ];

    List<Map<String, dynamic>> filtered = items;
    if (filter == 'pending') {
      filtered = items.where((item) => item['status'] == 'Pending').toList();
    } else if (filter == 'dibayar') {
      filtered = items.where((item) => item['status'] == 'Dibayar').toList();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Pendapatan',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightText),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp 3.450.000',
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                'Bulan ini',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.lightText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...filtered.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['pasien'],
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryText),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['jenis'],
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['tanggal'],
                          style: GoogleFonts.inter(fontSize: 10, color: AppColors.lightText),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item['nominal'],
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryText),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item['statusColor'],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['status'],
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: item['statusTextColor'],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

// ─── Profil Tab ──────────────────────────────────────────────────────────────

class _ProfilTab extends StatelessWidget {
  const _ProfilTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00BBA7), Color(0xFF009689)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Center(child: Text('👩‍⚕️', style: TextStyle(fontSize: 40))),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ftr. Siti Nurhaliza S.Tr.Kes',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Spesialis Fisioterapi Tulang Belakang',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileItem(Icons.email, 'Email', 'siti.nurhaliza@fisiocare.com'),
                  const SizedBox(height: 12),
                  _buildProfileItem(Icons.phone, 'Telepon', '+62 812-3456-7890'),
                  const SizedBox(height: 12),
                  _buildProfileItem(Icons.location_on, 'Lokasi', 'Jakarta, Indonesia'),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorRed,
                      ),
                      child: Text(
                        'Keluar',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 10, color: AppColors.lightText),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
