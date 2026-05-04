import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/fisiocare_logo.dart';
import 'notifikasi_screen.dart';

class FisioterapisHomeTab extends StatelessWidget {
  const FisioterapisHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildStatsCards()),
          SliverToBoxAdapter(child: _buildJadwalSesi()),
          SliverToBoxAdapter(child: _buildNotifikasiSection(context)),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00BBA7), Color(0xFF009689)],
        ),
      ),
      child: Stack(
        children: [
          // Dekorasi lingkaran latar
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
              // App bar row
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
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Fisioterapis',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFD9EFED),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Tombol notifikasi
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotifikasiScreen()),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.25)),
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: Colors.white, size: 18),
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
                              border: Border.all(
                                  color: const Color(0xFF00BBA7), width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Sapaan
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat pagi,',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.82),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ftr. Siti Nurhaliza 👋',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.22)),
                    ),
                    child: Text(
                      '⭐ Rating 4.9 · 120 Sesi',
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
        ],
      ),
    );
  }

  // ── Stat Cards ───────────────────────────────────────────────

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              iconBgColor: const Color(0xFFEFF6FF),
              icon: Icons.calendar_today,
              iconColor: AppColors.primary,
              value: '8',
              label: 'Sesi Hari Ini',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              iconBgColor: const Color(0xFFD1FAE5),
              icon: Icons.people,
              iconColor: const Color(0xFF059669),
              value: '24',
              label: 'Total Pasien',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required Color iconBgColor,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
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
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightText),
          ),
        ],
      ),
    );
  }

  // ── Jadwal Sesi ──────────────────────────────────────────────

  Widget _buildJadwalSesi() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
      child: Column(
        children: [
          _buildSectionHeader(
            title: 'Jadwal Sesi Hari Ini',
            subtitle: 'Sesi yang dijadwalkan untuk hari ini',
            actionLabel: 'Lihat semua →',
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
            child: const Center(
                child: Text('👤', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pasien,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  jenis,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.secondaryText),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('🕙 $waktu',
                        style: GoogleFonts.inter(
                            fontSize: 10, color: AppColors.lightText)),
                    const SizedBox(width: 8),
                    Text('📍 $lokasi',
                        style: GoogleFonts.inter(
                            fontSize: 10, color: AppColors.lightText)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: statusColor, borderRadius: BorderRadius.circular(6)),
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

  // ── Notifikasi ───────────────────────────────────────────────

  Widget _buildNotifikasiSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
      child: Column(
        children: [
          _buildSectionHeader(
            title: 'Notifikasi Terbaru',
            subtitle: 'Update dari pasien dan sistem',
            actionLabel: 'Semua →',
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
          color: unread
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.borderColor,
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
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                      fontSize: 10, color: AppColors.secondaryText),
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
                style:
                    GoogleFonts.inter(fontSize: 8, color: AppColors.lightText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Shared Helper ────────────────────────────────────────────

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required String actionLabel,
  }) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F2B28),
                letterSpacing: -0.3,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF6EA8A2),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          actionLabel,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}