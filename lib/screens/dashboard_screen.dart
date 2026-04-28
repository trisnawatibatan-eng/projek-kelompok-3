import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/fisiocare_logo.dart';
import 'appointments_screen.dart';
import 'laporan_screen.dart';
import 'profil_screen.dart';
import 'booking_screen.dart';
import 'jadwal_terapi_screen.dart';
import 'latihan_screen.dart';
import '../models/promo_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    const BookingScreen(),
    const JadwalTerapiScreen(),
    const LaporanScreen(),
    const ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFE2E8F0), width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: isMobile ? 70 : 80,
          child: Row(
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Beranda'),
              _buildNavItem(1, Icons.favorite_outline, Icons.favorite, 'Pemesanan'),
              _buildNavItem(2, Icons.calendar_today_outlined, Icons.calendar_today, 'Jadwal'),
              _buildNavItem(3, Icons.description_outlined, Icons.description, 'Laporan'),
              _buildNavItem(4, Icons.person_outline, Icons.person, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: isMobile ? 24 : 28,
                color: isActive ? AppColors.primary : const Color(0xFF62748E),
              ),
              SizedBox(height: isMobile ? 2 : 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 10 : 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppColors.primary : const Color(0xFF62748E),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return 'Selamat pagi,';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat siang,';
    } else if (hour >= 15 && hour < 19) {
      return 'Selamat sore,';
    } else {
      return 'Selamat malam,';
    }
  }
}

// ─── Home Tab ───────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return 'Selamat pagi,';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat siang,';
    } else if (hour >= 15 && hour < 19) {
      return 'Selamat sore,';
    } else {
      return 'Selamat malam,';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -2),
              child: _buildBookingBanner(context),
            ),
          ),
          SliverPadding(padding: EdgeInsets.only(top: isMobile ? 8 : 10)),
          SliverToBoxAdapter(child: _buildHomeCareCard(context)),
          SliverToBoxAdapter(child: _buildPromoSection(context)),
          SliverToBoxAdapter(child: _buildJadwalSection(context)),
          SliverPadding(padding: EdgeInsets.only(bottom: isMobile ? 20 : 24)),
        ],
      ),
    );
  }

  // ───────────────── HEADER BARU (SESUIAI GAMBAR) ─────────────────

Widget _buildHeader(BuildContext context) {
  return Container(
    padding: EdgeInsets.fromLTRB(
      16,
      MediaQuery.of(context).padding.top + 16,
      16,
      80,
    ),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF00BBA7), Color(0xFF009689)],
      ),
    ),
    child: Stack(
      children: [
        // Background kanan
        Positioned(
          right: -60,
          top: -80,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Background kiri
        Positioned(
          left: -30,
          bottom: -10,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
            ),
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── TOP ROW ───
            Row(
              children: [
                const FisioCareLogoSmall(),
                const SizedBox(width: 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FisioCare',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Your Physio Partner',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                _buildIconHeader(Icons.notifications_outlined),
                const SizedBox(width: 8),
                _buildIconHeader(Icons.chat_bubble_outline),
              ],
            ),

            const SizedBox(height: 16),

            // ─── GREETING ───
            Text(
              _getGreeting(),
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Budi Santoso 👋',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            // ─── BADGE ───
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🏥 Pasien Aktif  ·  Sesi ke-24',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ───────────────── ICON HEADER ─────────────────

Widget _buildIconHeader(IconData icon) {
  return Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(
      icon,
      color: Colors.white,
      size: 18,
    ),
  );
}

  Widget _buildBookingBanner(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF009B89).withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Gradient
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00BBA7), Color(0xFF009689)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.all(isMobile ? 12 : 14),
              child: Row(
                children: [
                  Container(
                    width: isMobile ? 40 : 44,
                    height: isMobile ? 40 : 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Text('📋',
                          style: TextStyle(fontSize: isMobile ? 18 : 20)),
                    ),
                  ),
                  SizedBox(width: isMobile ? 10 : 12),
                  Expanded(
                    child: Text('✓ BOOKING DITERIMA',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        )),
                  ),
                  Container(
                    width: isMobile ? 32 : 36,
                    height: isMobile ? 32 : 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(0.25),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: isMobile ? 18 : 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(isMobile ? 14 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sesi Fisioterapi Lumbal',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF0F2B28),
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.w700,
                      )),
                  SizedBox(height: isMobile ? 2 : 3),
                  Text('Ftr. Siti Nurhaliza S.Tr.Kes',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF0F2B28),
                        fontSize: isMobile ? 12 : 13,
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(height: isMobile ? 6 : 8),
                  Text('Senin, 25 Mar 2026 · 10:00–11:00 WIB',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6EA8A2),
                        fontSize: isMobile ? 9 : 10,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeCareCard(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 20,
        0,
        isMobile ? 12 : 20,
        0,
      ),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pesan Home Care',
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0F172B),
                )),
            SizedBox(height: isMobile ? 6 : 8),
            Text('Dapatkan layanan fisioterapi profesional di rumah Anda',
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 13 : 14,
                  color: const Color(0xFF45556C),
                )),
            SizedBox(height: isMobile ? 12 : 16),
            SizedBox(
              width: double.infinity,
              height: isMobile ? 40 : 44,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingScreen()),
                  );
                },
                icon: Icon(
                  Icons.calendar_today_outlined,
                  size: isMobile ? 14 : 16,
                  color: Colors.white,
                ),
                label: Text('Pesan Sekarang',
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final promos = PromoModel.samplePromos;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 12 : 20, isMobile ? 16 : 20, isMobile ? 12 : 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Promo Spesial',
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 14 : 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F2B28),
                        letterSpacing: -0.3,
                      )),
                  Text('Penawaran terbatas untuk Anda',
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 10 : 11,
                        color: const Color(0xFF6EA8A2),
                        fontStyle: FontStyle.italic,
                      )),
                ],
              ),
              const Spacer(),
              Text('Semua →',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 10.5 : 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  )),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 12),
          SizedBox(
            height: isMobile ? 130 : 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: promos.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == promos.length - 1 ? 0 : isMobile ? 10 : 12,
                  ),
                  child: _buildPromoCard(promos[index], context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(PromoModel promo, BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      width: isMobile ? 260 : 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00BBA7), Color(0xFF009689)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009B89).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promo.title,
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 13 : 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isMobile ? 3 : 4),
                        Text(
                          promo.description,
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 9 : 10,
                            color: Colors.white.withOpacity(0.85),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 6 : 8,
                      vertical: isMobile ? 3 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD166),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      promo.discountPercentage,
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 11 : 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6B4000),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 10,
                  vertical: isMobile ? 5 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  'Kode: ${promo.code}',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 9 : 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildJadwalSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 12 : 20, isMobile ? 16 : 20, isMobile ? 12 : 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jadwal Terapi',
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 14 : 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F2B28),
                        letterSpacing: -0.3,
                      )),
                  Text('Sesi yang telah dijadwalkan',
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 10 : 11,
                        color: const Color(0xFF6EA8A2),
                        fontStyle: FontStyle.italic,
                      )),
                ],
              ),
              const Spacer(),
              Text('Semua →',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 10.5 : 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  )),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 12),
          // Featured session card (gradient)
          _buildFeaturedSession(isMobile),
          SizedBox(height: isMobile ? 10 : 12),
          // Secondary session card
          _buildSecondarySession(isMobile),
        ],
      ),
    );
  }

  Widget _buildFeaturedSession(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00BBA7), Color(0xFF009689)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009B89).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // BG overlay
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 9 : 11,
                      vertical: isMobile ? 4 : 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.17),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.22)),
                    ),
                    child: Text('📅 Besok, 25 Mar 2026',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 10,
                      vertical: isMobile ? 3 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD166),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Terkonfirmasi',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF6B4000),
                          fontSize: isMobile ? 9 : 10,
                          fontWeight: FontWeight.w800,
                        )),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 10 : 12),
              Row(
                children: [
                  Container(
                    width: isMobile ? 40 : 44,
                    height: isMobile ? 40 : 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.35)),
                    ),
                    child: Center(
                      child: Text('👩‍⚕️',
                          style: TextStyle(fontSize: isMobile ? 20 : 22)),
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ftr. Siti Nurhaliza S.Tr.Kes',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: isMobile ? 13 : 15,
                              fontWeight: FontWeight.w700,
                            )),
                        Text('Spesialis Fisioterapi Tulang Belakang',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.84),
                              fontSize: isMobile ? 9.5 : 10.5,
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 10 : 12),
              Divider(
                color: Colors.white.withOpacity(0.18),
                height: 1,
              ),
              SizedBox(height: isMobile ? 9 : 11),
              Wrap(
                spacing: isMobile ? 10 : 12,
                children: [
                  Text('🕙 10:00–11:00',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: isMobile ? 10 : 11,
                        fontWeight: FontWeight.w600,
                      )),
                  Text('📍 Home Visit',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: isMobile ? 10 : 11,
                        fontWeight: FontWeight.w600,
                      )),
                  Text('⏱ 60 menit',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: isMobile ? 10 : 11,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondarySession(bool isMobile) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 14,
        isMobile ? 8 : 10,
        isMobile ? 12 : 14,
        isMobile ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009B89).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 38 : 42,
            height: isMobile ? 38 : 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFFDDD6FE), Color(0xFFB2EDE7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('28',
                    style: GoogleFonts.inter(
                      color: AppColors.primary,
                      fontSize: isMobile ? 13 : 15,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    )),
                Text('MAR',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6EA8A2),
                      fontSize: isMobile ? 8 : 9,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
          SizedBox(width: isMobile ? 9 : 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Terapi Bahu Kanan',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF0F2B28),
                      fontSize: isMobile ? 11.5 : 12.5,
                      fontWeight: FontWeight.w700,
                    )),
                Text('Dr. Rizky · Klinik FisioCare',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6EA8A2),
                      fontSize: isMobile ? 9.5 : 10.5,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 10,
              vertical: isMobile ? 3 : 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text('Menunggu',
                style: GoogleFonts.inter(
                  color: const Color(0xFF3B82F6),
                  fontSize: isMobile ? 9 : 10,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ],
      ),
    );
  }
}
