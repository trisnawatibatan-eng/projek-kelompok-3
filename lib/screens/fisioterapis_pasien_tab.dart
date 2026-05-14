import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme.dart';
import '../widgets/fisioterapis_bottom_navbar.dart';
import 'fisioterapis_dashboard_screen.dart';
import 'fisioterapis_jadwal_praktik.dart';
import 'fisioterapis_profil_tab.dart';
import 'fisioterapis_pasien_detail.dart';

class FisioterapisPasienTab extends StatefulWidget {
  final Map<String, dynamic>? profil;
  const FisioterapisPasienTab({super.key, this.profil});

  @override
  State<FisioterapisPasienTab> createState() => _FisioterapisPasienTabState();
}

class _FisioterapisPasienTabState extends State<FisioterapisPasienTab> {
  final _supabase = Supabase.instance.client;
  final int _currentNavIndex = 2;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchPasien();
  }

  void _reload() {
    setState(() => _future = _fetchPasien());
  }

  // ---------------------------------------------------------------------------
  // Supabase
  // ---------------------------------------------------------------------------

  Future<String> _getFisioterapisId() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login');
    final res = await _supabase
        .from('fisioterapis')
        .select('id')
        .eq('user_id', userId)
        .single();
    return res['id'] as String;
  }

  Future<List<Map<String, dynamic>>> _fetchPasien() async {
    final fisioterapisId = await _getFisioterapisId();

    // Ambil semua booking completed + data pasien, urutkan terbaru dulu
    final res = await _supabase
        .from('bookings')
        .select('''
          patient_id,
          service_type,
          scheduled_date,
          patients (
            full_name,
            phone,
            date_of_birth,
            gender,
            full_address
          )
        ''')
        .eq('fisioterapis_id', fisioterapisId)
        .eq('status', 'completed')
        .order('scheduled_date', ascending: false);

    final raw = res as List;

    // Deduplicate: satu entri per pasien (ambil booking terbaru)
    final Map<String, Map<String, dynamic>> seen = {};
    for (final item in raw) {
      final pid = item['patient_id'] as String;
      if (!seen.containsKey(pid)) {
        seen[pid] = Map<String, dynamic>.from(item as Map);
      }
    }

    return seen.values.toList();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  int? _hitungUsia(String? dob) {
    if (dob == null || dob.isEmpty) return null;
    try {
      DateTime birth;
      if (dob.contains('-')) {
        birth = DateTime.parse(dob);
      } else {
        final parts = dob.split('/');
        birth = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month ||
          (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return null;
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color _avatarColor(String inisial) {
    const colors = [
      Color(0xFF00BBA7),
      Color(0xFF6366F1),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF10B981),
      Color(0xFF3B82F6),
    ];
    return colors[inisial.codeUnitAt(0) % colors.length];
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((item) {
      final pasien = item['patients'] as Map<String, dynamic>? ?? {};
      return (pasien['full_name'] ?? '').toString().toLowerCase().contains(q) ||
          (item['service_type'] ?? '').toString().toLowerCase().contains(q) ||
          (pasien['phone'] ?? '').toString().toLowerCase().contains(q);
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Navbar
  // ---------------------------------------------------------------------------

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    Widget target;
    switch (index) {
      case 0:
        target = const FisioterapisDashboardScreen();
        break;
      case 1:
        target = const JadwalPraktikScreen();
        break;
      case 2:
        target = const FisioterapisPasienTab();
        break;
      case 3:
        target = const FisioterapisProfilTab();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => target));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      bottomNavigationBar: FisioterapisBottomNavbar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daftar Pasien',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            Text('Pasien yang telah menyelesaikan layanan',
                style:
                    GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00BBA7)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text('Terjadi kesalahan:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 13)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _reload,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BBA7),
                        foregroundColor: Colors.white),
                    child: const Text('Coba Lagi'),
                  ),
                ]),
              ),
            );
          }

          final all = snapshot.data ?? [];
          final filtered = _filtered(all);

          return Column(children: [
            // Search bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: GoogleFonts.inter(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Cari nama, layanan, atau nomor telepon...',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.lightText),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.lightText, size: 20),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Counter
            if (all.isNotEmpty)
              Container(
                width: double.infinity,
                color: Colors.white,
                padding:
                    const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                child: Text(
                  '${all.length} pasien terdaftar',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.secondaryText),
                ),
              ),

            // List
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF00BBA7),
                onRefresh: () async => _reload(),
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              all.isEmpty
                                  ? 'Belum ada pasien yang\nmenyelesaikan layanan'
                                  : 'Pasien tidak ditemukan',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.lightText),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final pasien =
                              (item['patients'] as Map<String, dynamic>?) ??
                                  {};

                          final nama =
                              (pasien['full_name'] as String? ?? 'Pasien')
                                  .trim();
                          final inisial = _initials(nama);
                          final usia =
                              _hitungUsia(pasien['date_of_birth'] as String?);
                          final gender =
                              (pasien['gender'] as String?) == 'male'
                                  ? 'Laki-laki'
                                  : (pasien['gender'] as String?) == 'female'
                                      ? 'Perempuan'
                                      : null;
                          final layanan =
                              item['service_type'] as String? ?? '-';
                          final telepon =
                              pasien['phone'] as String? ?? '-';
                          final alamat =
                              pasien['full_address'] as String? ?? '-';
                          final scheduledDate =
                              item['scheduled_date'] as String?;
                          final terapiTerakhir = scheduledDate != null
                              ? DateFormat('dd/MM/yyyy').format(
                                  DateTime.parse(scheduledDate))
                              : '-';

                          return _PasienCard(
                            patientId: item['patient_id'] as String,
                            nama: nama,
                            inisial: inisial,
                            avatarColor: _avatarColor(inisial),
                            usia: usia,
                            gender: gender,
                            layanan: layanan,
                            telepon: telepon,
                            alamat: alamat,
                            terapiTerakhir: terapiTerakhir,
                          );
                        },
                      ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

// =============================================================================
// PASIEN CARD
// =============================================================================

class _PasienCard extends StatelessWidget {
  final String patientId;      // ← tambah ini
  final String nama;
  final String inisial;
  final Color avatarColor;
  final int? usia;
  final String? gender;
  final String layanan;
  final String telepon;
  final String alamat;
  final String terapiTerakhir;

  const _PasienCard({
    required this.patientId,   // ← tambah ini
    required this.nama,
    required this.inisial,
    required this.avatarColor,
    required this.usia,
    required this.gender,
    required this.layanan,
    required this.telepon,
    required this.alamat,
    required this.terapiTerakhir,
  });

  @override
  Widget build(BuildContext context) {
    final usiaGender = [
      if (usia != null) '$usia tahun',
      if (gender != null) gender!,
    ].join(' • ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      inisial,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                      if (usiaGender.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          usiaGender,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ✅ Ikon laporan — terhubung ke FisioterapisPasienDetail
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FisioterapisPasienDetail(
                        patientId: patientId,
                        patientName: nama,
                        inisial: inisial,
                        avatarColor: avatarColor,
                      ),
                    ),
                  ),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F6),   // ← warna teal muda saat terhubung
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      size: 18,
                      color: AppColors.primary,          // ← ikon teal
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _InfoRow(icon: Icons.monitor_heart_outlined, text: layanan),
            const SizedBox(height: 6),
            _InfoRow(icon: Icons.phone_outlined, text: telepon),
            const SizedBox(height: 6),
            _InfoRow(icon: Icons.location_on_outlined, text: alamat),

            const SizedBox(height: 12),

            // Terapi Terakhir
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE6FAF8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFB2EDE7)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Terapi Terakhir : ',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.primary),
                  ),
                  Text(
                    terapiTerakhir,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
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
}

// =============================================================================
// INFO ROW
// =============================================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.lightText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
                fontSize: 12, color: AppColors.secondaryText),
          ),
        ),
      ],
    );
  }
}