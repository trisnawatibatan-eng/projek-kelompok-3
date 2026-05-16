import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../services/edukasi_service.dart';
import 'notifikasi_screen.dart';
import 'fisioterapis_booking_screen.dart';
import 'fisioterapis_chat_screen.dart';
import 'fisioterapis_payment_history_screen.dart';
import 'fisioterapis_kelola_edukasi.dart';

class FisioterapisHomeTab extends StatefulWidget {
  final Map<String, dynamic>? profil;
  const FisioterapisHomeTab({super.key, this.profil});

  @override
  State<FisioterapisHomeTab> createState() => _FisioterapisHomeTabState();
}

class _FisioterapisHomeTabState extends State<FisioterapisHomeTab> {
  final _supabase = Supabase.instance.client;
  final EdukasiService _edukasiService = EdukasiService();

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

  // ── State edukasi dari Supabase ──────────────────────────────
  List<Map<String, dynamic>> _edukasiList = [];
  bool _isLoadingEdukasi = false;

  // ── Getters profil ───────────────────────────────────────────
  String get _namaLengkap => widget.profil?['nama_lengkap'] ?? 'Fisioterapis';

  String get _gelar => widget.profil?['gelar'] ?? '';

  String get _fotoProfilUrl => widget.profil?['foto_profil_url'] ?? '';

  String get _namaLengkapDenganGelar {
    final nama = 'Ftr. $_namaLengkap';
    if (_gelar.isNotEmpty) return '$nama, $_gelar';
    return nama;
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
    _loadEdukasiList();
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

  // ── Supabase: load edukasi dari database ──────────────────

  Future<void> _loadEdukasiList() async {
    try {
      setState(() => _isLoadingEdukasi = true);
      final data = await _edukasiService.fetchEdukasiMilikSaya();
      if (mounted) {
        setState(() {
          _edukasiList = data.take(3).toList(); // Tampilkan max 3 edukasi
        });
      }
    } catch (e) {
      debugPrint('Error loading edukasi: $e');
    } finally {
      if (mounted) setState(() => _isLoadingEdukasi = false);
    }
  }

  Color _getKategoriColor(String? kategori) {
    const Map<String, Color> colors = {
      'Stroke': Color(0xFF3B82F6),
      'Nyeri Punggung': Color(0xFF10B981),
      'Nutrisi': Color(0xFFF59E0B),
      'Cedera Olahraga': Color(0xFF8B5CF6),
      'Mental': Color(0xFFF87171),
      'Latihan': Color(0xFF06B6D4),
      'Neurologi': Color(0xFFEC4899),
      'Geriatri': Color(0xFF14B8A6),
      'Pediatri': Color(0xFFF97316),
    };
    return colors[kategori] ?? AppColors.primary;
  }

  Color _getKategoriBgColor(String? kategori) {
    const Map<String, Color> colors = {
      'Stroke': Color(0xFFEFF6FF),
      'Nyeri Punggung': Color(0xFFD1FAE5),
      'Nutrisi': Color(0xFFFEF3C7),
      'Cedera Olahraga': Color(0xFFEDE9FE),
      'Mental': Color(0xFFFEE2E2),
      'Latihan': Color(0xFFCFFAFE),
      'Neurologi': Color(0xFFFCE7F3),
      'Geriatri': Color(0xFFCCFBF1),
      'Pediatri': Color(0xFFFEEDDA),
    };
    return colors[kategori] ?? AppColors.primary.withOpacity(0.1);
  }

  String _getEmojiForKategori(String? kategori) {
    const Map<String, String> emojis = {
      'Stroke': '🧠',
      'Nyeri Punggung': '🫁',
      'Nutrisi': '🥗',
      'Cedera Olahraga': '🏋️',
      'Mental': '🧘',
      'Latihan': '🏃',
      'Neurologi': '⚡',
      'Geriatri': '👴',
      'Pediatri': '👶',
    };
    return emojis[kategori] ?? '📄';
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

  // ════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════

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
                      child: Text(
                        _inisial,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      _inisial,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
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
                  _sapaan,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _namaLengkapDenganGelar,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
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
                constraints:
                    const BoxConstraints(minWidth: 16, minHeight: 16),
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

  // ── Pasien Hari Ini ──────────────────────────────────────────

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
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 11, color: AppColors.secondaryText),
        ),
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
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FisioterapisKelolaEdukasiScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadEdukasiList();
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.manage_history,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 2),
                    Text(
                      'Kelola',
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
          if (_isLoadingEdukasi)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            )
          else if (_edukasiList.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.article_outlined,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada edukasi',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._edukasiList.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildEdukasiCard(item),
                )),
        ],
      ),
    );
  }

  Widget _buildEdukasiCard(Map<String, dynamic> item) {
    final judul = item['judul'] as String? ?? 'Tanpa Judul';
    final kategori = item['kategori'] as String?;
    final createdAt = item['created_at'] as String?;

    String formattedDate = '-';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        formattedDate =
            '${date.day} ${_getMonthName(date.month)} ${date.year}';
      } catch (e) {
        // ignore
      }
    }

    final kategoriColor = _getKategoriColor(kategori);
    final kategoriBgColor = _getKategoriBgColor(kategori);
    final emoji = _getEmojiForKategori(kategori);

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
              color: kategoriBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (kategori != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: kategoriBgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      kategori,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: kategoriColor,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  judul,
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
                Text(
                  formattedDate,
                  style: GoogleFonts.inter(
                      fontSize: 10, color: AppColors.lightText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }
}