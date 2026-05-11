import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../widgets/fisioterapis_bottom_navbar.dart';
import 'login_screen.dart';
import 'fisioterapis_edit_profil_screen.dart';
import 'fisioterapis_kelola_layanan_screen.dart';
import 'fisioterapis_dashboard_screen.dart';
import 'fisioterapis_jadwal_praktik.dart';
import 'fisioterapis_pasien_tab.dart';

class FisioterapisProfilTab extends StatefulWidget {
  final Map<String, dynamic>? profil;
  final VoidCallback? onProfilUpdated;
  const FisioterapisProfilTab({super.key, this.profil, this.onProfilUpdated});

  @override
  State<FisioterapisProfilTab> createState() => _FisioterapisProfilTabState();
}

class _FisioterapisProfilTabState extends State<FisioterapisProfilTab> {
  final _supabase = Supabase.instance.client;

  String get _namaLengkap => widget.profil?['nama_lengkap'] ?? 'Fisioterapis';
  String get _email => widget.profil?['email'] ?? '-';
  String get _telepon => widget.profil?['nomor_telepon'] ?? '-';
  String get _alamat => widget.profil?['alamat'] ?? '-';
  String get _pengalaman => widget.profil?['pengalaman_kerja'] ?? '-';
  String get _pendidikan => widget.profil?['pendidikan_terakhir'] ?? '-';
  String get _str => widget.profil?['nomor_str_sipa'] ?? '-';
  String get _biografi => widget.profil?['biografi'] ?? '-';
  String get _sertifikasi => widget.profil?['sertifikasi'] ?? '-';
  String get _fotoProfilUrl => widget.profil?['foto_profil_url'] ?? '';

  String get _statusVerifikasi =>
      widget.profil?['status_verifikasi'] ?? 'pending';

  Color get _statusColor {
    switch (_statusVerifikasi) {
      case 'verified':
        return const Color(0xFF00BBA7);
      case 'rejected':
        return AppColors.errorRed;
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String get _statusLabel {
    switch (_statusVerifikasi) {
      case 'verified':
        return 'TERVERIFIKASI';
      case 'rejected':
        return 'DITOLAK';
      default:
        return 'MENUNGGU';
    }
  }

  IconData get _statusIcon {
    switch (_statusVerifikasi) {
      case 'verified':
        return Icons.verified_outlined;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_empty_outlined;
    }
  }

  String get _inisial {
    final parts = _namaLengkap.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _namaLengkap
        .substring(0, _namaLengkap.length >= 2 ? 2 : 1)
        .toUpperCase();
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => FisioterapisDashboardScreen(
              profilCache: widget.profil,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const JadwalPraktikScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => FisioterapisPasienTab(
              profil: widget.profil,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      bottomNavigationBar: FisioterapisBottomNavbar(
        currentIndex: 3,
        onTap: _onNavTap,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => widget.onProfilUpdated?.call(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildProfileHeader(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Informasi Kontak'),
                    const SizedBox(height: 10),
                    _buildContactCard(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Informasi Profesional'),
                    const SizedBox(height: 10),
                    _buildProfesionalCard(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Akun & Profil'),
                    const SizedBox(height: 10),
                    _buildMenuCard(context),
                    const SizedBox(height: 20),
                    _buildLogoutButton(context),
                    const SizedBox(height: 20),
                    _buildFooter(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              Text(
                'Profil Saya',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BBA7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _fotoProfilUrl.isNotEmpty
                              ? Image.network(
                                  _fotoProfilUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Text(_inisial,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                )
                              : Center(
                                  child: Text(_inisial,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700)),
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _namaLengkap,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryText,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: _statusColor.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_statusIcon,
                                        size: 11, color: _statusColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      _statusLabel,
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                              Icons.work_outline, 'Pengalaman', _pengalaman),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatItem(
                            Icons.badge_outlined,
                            'Lisensi',
                            _str.length > 12
                                ? '${_str.substring(0, 12)}...'
                                : _str,
                            valueColor: const Color(0xFF00BBA7),
                          ),
                        ),
                      ],
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

  Widget _buildStatItem(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.lightText),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 9, color: AppColors.lightText)),
                Text(value,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: valueColor ?? AppColors.primaryText,
                    ),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText));
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          _buildContactItem(Icons.email_outlined, 'Email', _email),
          Divider(height: 1, color: AppColors.borderColor),
          _buildContactItem(Icons.phone_outlined, 'Telepon', _telepon),
          Divider(height: 1, color: AppColors.borderColor),
          _buildContactItem(Icons.location_on_outlined, 'Alamat', _alamat),
        ],
      ),
    );
  }

  Widget _buildProfesionalCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          _buildContactItem(
              Icons.school_outlined, 'Pendidikan Terakhir', _pendidikan),
          Divider(height: 1, color: AppColors.borderColor),
          _buildContactItem(
              Icons.verified_outlined, 'Sertifikasi', _sertifikasi),
          Divider(height: 1, color: AppColors.borderColor),
          _buildBiografiItem(),
        ],
      ),
    );
  }

  Widget _buildBiografiItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE6FAF8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_outline,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Biografi',
                    style: GoogleFonts.inter(
                        fontSize: 10, color: AppColors.lightText)),
                const SizedBox(height: 2),
                Text(
                  _biografi == '-' ? 'Belum diisi' : _biografi,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _biografi == '-'
                        ? AppColors.lightText
                        : AppColors.primaryText,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE6FAF8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 10, color: AppColors.lightText)),
                Text(
                  value.isEmpty ? 'Belum diisi' : value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: value.isEmpty || value == '-'
                        ? AppColors.lightText
                        : AppColors.primaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    final items = [
      {
        'icon': Icons.edit_outlined,
        'label': 'Edit Profil',
        'color': const Color(0xFF00BBA7),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const FisioterapisEditProfilScreen()),
            ).then((_) => widget.onProfilUpdated?.call()),
      },
      {
        'icon': Icons.settings_outlined,
        'label': 'Kelola Layanan',
        'color': const Color(0xFFF59E0B),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => FisioterapisKelolaLayananScreen()),
            ),
      },
      {
        'icon': Icons.lock_outline,
        'label': 'Ubah Password',
        'color': const Color(0xFF6366F1),
        'onTap': () {},
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              InkWell(
                onTap: item['onTap'] as VoidCallback,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item['icon'] as IconData,
                            color: item['color'] as Color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item['label'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: AppColors.lightText),
                    ],
                  ),
                ),
              ),
              if (index < items.length - 1)
                Divider(height: 1, indent: 64, color: AppColors.borderColor),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: InkWell(
        onTap: () async {
          await _supabase.auth.signOut();
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECEC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout,
                    color: AppColors.errorRed, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'Keluar',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.errorRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCCF4EF)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/logo.jpeg',
              width: 44,
              height: 44,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text('Fisiocare',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary)),
          const SizedBox(height: 2),
          Text('Fisioterapi Homecare',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText)),
          const SizedBox(height: 2),
          Text('Layanan Fisioterapi Profesional di Rumah Pasien',
              style:
                  GoogleFonts.inter(fontSize: 10, color: AppColors.lightText),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}