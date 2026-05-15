import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import 'notifikasi_screen.dart';
import 'fisioterapis_booking_screen.dart';
import 'fisioterapis_chat_screen.dart';
import 'fisioterapis_payment_history_screen.dart';

class FisioterapisHomeTab extends StatefulWidget {
  final Map<String, dynamic>? profil;
  const FisioterapisHomeTab({super.key, this.profil});

  @override
  State<FisioterapisHomeTab> createState() => _FisioterapisHomeTabState();
}

class _FisioterapisHomeTabState extends State<FisioterapisHomeTab> {
  final _supabase = Supabase.instance.client;

  // ── State booking pending ────────────────────────────────────
  int _pendingBookingCount = 0;
  bool _isLoadingBooking = false;

  // ── State notifikasi belum dibaca ────────────────────────────
  int _unreadNotifCount = 0;
  RealtimeChannel? _notifChannel;

  // ── State pasien hari ini ────────────────────────────────────
  int _pasienSelesai = 0;
  int _pasienBerlangsung = 0;
  int _pasienMendatang = 0;
  int _totalPasienHariIni = 0;
  bool _isLoadingPasien = false;

  // ── Getters profil ───────────────────────────────────────────
  String get _namaLengkap => widget.profil?['nama_lengkap'] ?? 'Fisioterapis';

  // ← DIUBAH: gelar dari database, kosong jika tidak ada (bukan hardcoded)
  String get _gelar => widget.profil?['gelar'] ?? '';

  String get _fotoProfilUrl => widget.profil?['foto_profil_url'] ?? '';

  String get _inisial {
    final parts = _namaLengkap.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _namaLengkap
        .substring(0, _namaLengkap.length >= 2 ? 2 : 1)
        .toUpperCase();
  }

  String get _sapaan {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Selamat pagi,';
    if (hour >= 12 && hour < 15) return 'Selamat siang,';
    if (hour >= 15 && hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  // ── Lifecycle ────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadPendingBookingCount();
    _loadPasienHariIni();
    _loadUnreadNotifCount();
    _subscribeNotifRealtime();
  }

  @override
  void dispose() {
    _notifChannel?.unsubscribe();
    super.dispose();
  }

  // ── Supabase: jumlah booking pending ────────────────────────

  Future<void> _loadPendingBookingCount() async {
    if (_isLoadingBooking) return;
    setState(() => _isLoadingBooking = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final profil = await _supabase
          .from('fisioterapis')
          .select('id')
          .eq('user_id', userId)
          .single();

      final fisioterapisId = profil['id'] as String;

      final response = await _supabase
          .from('bookings')
          .select('id')
          .eq('fisioterapis_id', fisioterapisId)
          .eq('status', 'pending');

      if (mounted) {
        setState(() {
          _pendingBookingCount = (response as List).length;
        });
      }
    } catch (e) {
      debugPrint('Error loading pending booking count: $e');
    } finally {
      if (mounted) setState(() => _isLoadingBooking = false);
    }
  }

  // ── Supabase: pasien hari ini ────────────────────────────────

  Future<void> _loadPasienHariIni() async {
    if (_isLoadingPasien) return;
    setState(() => _isLoadingPasien = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final profil = await _supabase
          .from('fisioterapis')
          .select('id')
          .eq('user_id', userId)
          .single();

      final fisioterapisId = profil['id'] as String;
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final response = await _supabase
          .from('bookings')
          .select('status')
          .eq('fisioterapis_id', fisioterapisId)
          .eq('scheduled_date', todayStr)
          .inFilter('status', ['completed', 'on_going', 'confirmed']);

      if (mounted) {
        final list = response as List;
        setState(() {
          _pasienSelesai =
              list.where((b) => b['status'] == 'completed').length;
          _pasienBerlangsung =
              list.where((b) => b['status'] == 'on_going').length;
          _pasienMendatang =
              list.where((b) => b['status'] == 'confirmed').length;
          _totalPasienHariIni = list.length;
        });
      }
    } catch (e) {
      debugPrint('Error loading pasien hari ini: $e');
    } finally {
      if (mounted) setState(() => _isLoadingPasien = false);
    }
  }

  // ── Supabase: jumlah notifikasi belum dibaca ─────────────────

  Future<void> _loadUnreadNotifCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      if (mounted) {
        setState(() {
          _unreadNotifCount = (response as List).length;
        });
      }
    } catch (e) {
      debugPrint('Error loading unread notif count: $e');
    }
  }

  // ── Realtime: notifikasi ─────────────────────────────────────

  void _subscribeNotifRealtime() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _notifChannel = _supabase
        .channel('notifications_badge_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => _loadUnreadNotifCount(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => _loadUnreadNotifCount(),
        )
        .subscribe();
  }

  // ── Navigasi ─────────────────────────────────────────────────

  Future<void> _navigateToNotifikasiScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotifikasiPasienScreen()),
    );
    _loadUnreadNotifCount();
  }

  Future<void> _navigateToBookingScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FisioterapiBookingScreen()),
    );
    _loadPendingBookingCount();
    _loadPasienHariIni();
  }

  // ── Edukasi (data statis) ────────────────────────────────────

  static const List<Map<String, dynamic>> _edukasiList = [
    {
      'kategori': 'PERNAPASAN',
      'kategoriColor': Color(0xFF3B82F6),
      'kategoriBg': Color(0xFFEFF6FF),
      'judul': 'Teknik Pernapasan untuk Nyeri Punggung',
      'tanggal': '12 Mei 2023',
      'emoji': '🫁',
    },
    {
      'kategori': 'NUTRISI',
      'kategoriColor': Color(0xFF10B981),
      'kategoriBg': Color(0xFFD1FAE5),
      'judul': 'Suplemen yang Baik untuk Kesehatan Sendi',
      'tanggal': '24 Mei 2023',
      'emoji': '🥗',
    },
    {
      'kategori': 'LATIHAN',
      'kategoriColor': Color(0xFFF59E0B),
      'kategoriBg': Color(0xFFFEF3C7),
      'judul': '5 Gerakan Penguatan Otot Core untuk Pemula',
      'tanggal': '24 Mei 2023',
      'emoji': '🏋️',
    },
    {
      'kategori': 'MENTAL',
      'kategoriColor': Color(0xFF8B5CF6),
      'kategoriBg': Color(0xFFEDE9FE),
      'judul': 'Mengelola Stres Saat Proses Pemulihan',
      'tanggal': '24 Mei 2023',
      'emoji': '🧘',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildActionCards(context)),
          SliverToBoxAdapter(child: _buildPasienHariIni()),
          SliverToBoxAdapter(child: _buildEdukasi()),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00BBA7), Color(0xFF009689)],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            clipBehavior: Clip.antiAlias,
            child: _fotoProfilUrl.isNotEmpty
                ? Image.network(
                    _fotoProfilUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(_inisial,
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ),
                  )
                : Center(
                    child: Text(_inisial,
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                  ),
          ),
          const SizedBox(width: 12),
          // Nama & gelar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _sapaan,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ftr. $_namaLengkap',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                // ← DIUBAH: hanya tampil jika gelar tidak kosong
                if (_gelar.isNotEmpty)
                  Text(
                    _gelar,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          // Ikon kanan
          Row(
            children: [
              _buildHeaderIconButton(
                icon: Icons.chat_bubble_outline,
                badgeCount: 0,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                ),
              ),
              const SizedBox(width: 8),
              _buildHeaderIconButton(
                icon: Icons.notifications_outlined,
                badgeCount: _unreadNotifCount,
                onTap: () => _navigateToNotifikasiScreen(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required int badgeCount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          if (badgeCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: const EdgeInsets.symmetric(horizontal: 3),
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Action Cards ─────────────────────────────────────────────

  Widget _buildActionCards(BuildContext context) {
    final bookingTitle = _isLoadingBooking
        ? 'Memuat...'
        : _pendingBookingCount == 0
            ? 'Permintaan Booking'
            : '$_pendingBookingCount Permintaan Booking';

    final bookingSubtitle = _pendingBookingCount > 0
        ? 'Menunggu konfirmasi Anda'
        : 'Tidak ada permintaan baru';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _navigateToBookingScreen(context),
            child: _buildActionCard(
              icon: Icons.calendar_today_outlined,
              iconBg: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF3B82F6),
              title: bookingTitle,
              subtitle: bookingSubtitle,
              badgeCount: _pendingBookingCount,
              badgeColor: const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FisioterapisPaymentHistoryScreen(),
              ),
            ),
            child: _buildActionCard(
              icon: Icons.account_balance_wallet_outlined,
              iconBg: const Color(0xFFF0FDF4),
              iconColor: const Color(0xFF10B981),
              title: 'Riwayat Pembayaran',
              subtitle: null,
              badgeCount: 0,
              badgeColor: Colors.transparent,
              prefixText: 'Rp',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String? subtitle,
    required int badgeCount,
    required Color badgeColor,
    String? prefixText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: prefixText != null
                ? Center(
                    child: Text(
                      prefixText,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: iconColor,
                      ),
                    ),
                  )
                : Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.secondaryText),
                  ),
                ],
              ],
            ),
          ),
          if (badgeCount > 0)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$badgeCount',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.lightText),
        ],
      ),
    );
  }

  // ── Pasien Hari Ini (dinamis) ────────────────────────────────

  Widget _buildPasienHariIni() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Pasien Hari Ini',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                const Spacer(),
                _isLoadingPasien
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_totalPasienHariIni Pasien',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 20),
            _isLoadingPasien
                ? const SizedBox(
                    height: 60,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildPasienStat(
                          icon: Icons.check_circle_outline,
                          iconColor: const Color(0xFF10B981),
                          iconBg: const Color(0xFFD1FAE5),
                          value: '$_pasienSelesai',
                          label: 'Selesai',
                        ),
                      ),
                      Expanded(
                        child: _buildPasienStat(
                          icon: Icons.play_circle_outline,
                          iconColor: const Color(0xFFF59E0B),
                          iconBg: const Color(0xFFFEF3C7),
                          value: '$_pasienBerlangsung',
                          label: 'Berlangsung',
                        ),
                      ),
                      Expanded(
                        child: _buildPasienStat(
                          icon: Icons.schedule_outlined,
                          iconColor: const Color(0xFF3B82F6),
                          iconBg: const Color(0xFFEFF6FF),
                          value: '$_pasienMendatang',
                          label: 'Mendatang',
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasienStat({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11, color: AppColors.secondaryText)),
      ],
    );
  }

  // ── Edukasi ──────────────────────────────────────────────────

  Widget _buildEdukasi() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Edukasi',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(Icons.add, size: 14, color: AppColors.primary),
                    const SizedBox(width: 2),
                    Text(
                      'Tambah',
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
          const SizedBox(height: 12),
          ..._edukasiList.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildEdukasiCard(item),
              )),
        ],
      ),
    );
  }

  Widget _buildEdukasiCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item['kategoriBg'] as Color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(item['emoji'], style: GoogleFonts.inter(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: item['kategoriBg'] as Color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item['kategori'],
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: item['kategoriColor'] as Color,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['judul'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(item['tanggal'],
                    style: GoogleFonts.inter(
                        fontSize: 10, color: AppColors.lightText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
