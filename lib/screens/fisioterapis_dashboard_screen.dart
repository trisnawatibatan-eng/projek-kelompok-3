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
              _buildNavItem(2, Icons.attach_money_outlined, Icons.attach_money, 'Pendapatan'),
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
<<<<<<< Updated upstream
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildStatsCards(context)),
          SliverToBoxAdapter(child: _buildJadwalSesi(context)),
          SliverToBoxAdapter(child: _buildNotifikasiSection(context)),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00BBA7), Color(0xFF009689)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: 4,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  const FisioCareLogoSmall(),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FisioCare',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                      Text('Fisioterapis',
                          style: GoogleFonts.inter(color: const Color(0xFFD9EFED), fontSize: 10)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withOpacity(0.25)),
                          ),
                          child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 18),
                        ),
                        Positioned(
                          right: 7,
                          top: 7,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD166),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF00BBA7), width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selamat pagi,',
                      style: GoogleFonts.inter(color: Colors.white.withOpacity(0.82), fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text('Ftr. Siti Nurhaliza 👋',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.22)),
                    ),
                    child: Text('⭐ Rating 4.9 · 120 Sesi',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calendar_today, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '8',
                        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryText),
                      ),
                      Text(
                        'Sesi Hari Ini',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightText),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.people, color: Color(0xFF059669), size: 22),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '24',
                        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryText),
                      ),
                      Text(
                        'Total Pasien',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightText),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalSesi(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jadwal Sesi Hari Ini',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF0F2B28), letterSpacing: -0.3)),
                  Text('Sesi yang dijadwalkan untuk hari ini',
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6EA8A2), fontStyle: FontStyle.italic)),
                ],
              ),
              const Spacer(),
              Text('Lihat semua →',
                  style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          _buildSesiCard(
            pasien: 'Budi Santoso',
            waktu: '10:00 - 11:00',
            jenis: 'Fisioterapi Lumbal',
            lokasi: 'Home Visit',
            status: 'Terkonfirmasi',
            statusColor: const Color(0xFFFFD166),
            statusTextColor: const Color(0xFF6B4000),
          ),
          const SizedBox(height: 12),
          _buildSesiCard(
            pasien: 'Siti Nurhaliza',
            waktu: '13:00 - 14:00',
            jenis: 'Terapi Bahu',
            lokasi: 'Klinik',
            status: 'Menunggu',
            statusColor: const Color(0xFFEFF6FF),
            statusTextColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildSesiCard({
    required String pasien,
    required String waktu,
    required String jenis,
    required String lokasi,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
  }) {
    return Container(
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
                  pasien,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryText),
                ),
                const SizedBox(height: 2),
                Text(
                  jenis,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondaryText),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('🕙 $waktu', style: GoogleFonts.inter(fontSize: 10, color: AppColors.lightText)),
                    const SizedBox(width: 8),
                    Text('📍 $lokasi', style: GoogleFonts.inter(fontSize: 10, color: AppColors.lightText)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(6)),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: statusTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifikasiSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notifikasi Terbaru',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF0F2B28), letterSpacing: -0.3)),
                  Text('Update dari pasien dan sistem',
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6EA8A2), fontStyle: FontStyle.italic)),
                ],
              ),
              const Spacer(),
              Text('Semua →',
                  style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            title: 'Booking Baru',
            subtitle: 'Ahmad Rizki ingin melakukan booking sesi baru',
            icon: Icons.calendar_today,
            time: '5 menit lalu',
            unread: true,
          ),
          const SizedBox(height: 10),
          _buildNotificationCard(
            title: 'Review dari Pasien',
            subtitle: 'Budi Santoso memberikan rating 5 bintang',
            icon: Icons.star,
            time: '1 jam lalu',
            unread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String time,
    required bool unread,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unread ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unread ? AppColors.primary.withOpacity(0.2) : AppColors.borderColor,
        ),
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
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryText),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.secondaryText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              if (unread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                time,
                style: GoogleFonts.inter(fontSize: 8, color: AppColors.lightText),
              ),
            ],
          ),
        ],
      ),
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
=======
      body: pages[_currentIndex],
      bottomNavigationBar: FisioterapisBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          // Jika jadwal, navigate ke jadwal_praktik setelah update index
          if (index == 1) {
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JadwalPraktikScreen()),
                ).then((_) {
                  // Kembali ke dashboard saat pop dari JadwalPraktikScreen
                  if (mounted) {
                    setState(() {
                      _currentIndex = 0;
                    });
                  }
                });
              }
            });
          }
>>>>>>> Stashed changes
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
