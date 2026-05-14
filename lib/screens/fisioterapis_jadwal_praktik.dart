import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fisioterapis_booking_screen.dart';
import 'fisioterapis_jadwal_kalender_screen.dart';
import 'fisioterapis_atur_jadwal_screen.dart';
import '../widgets/fisioterapis_bottom_navbar.dart';
import 'fisioterapis_dashboard_screen.dart';
import 'fisioterapis_pasien_tab.dart';
import 'fisioterapis_profil_tab.dart';

// =============================================================================
// MODEL
// =============================================================================

class JadwalItem {
  final String bookingId;
  final String jamMulai;
  final String jamSelesai;
  final String namaPasien;
  final String jenisTerapi;
  final String alamat;
  final String telepon;
  String status;

  JadwalItem({
    required this.bookingId,
    required this.jamMulai,
    required this.jamSelesai,
    required this.namaPasien,
    required this.jenisTerapi,
    required this.alamat,
    required this.telepon,
    required this.status,
  });

  factory JadwalItem.fromMap(Map<String, dynamic> map) {
    final rawTime = (map['scheduled_time'] as String).substring(0, 5);
    final parts = rawTime.split(':');
    final endHour = (int.parse(parts[0]) + 1).toString().padLeft(2, '0');

    return JadwalItem(
      bookingId: map['id'] as String,
      jamMulai: rawTime,
      jamSelesai: '$endHour:${parts[1]}',
      // ✅ Ambil nama dari relasi patients — butuh RLS policy yang benar
      namaPasien:
          (map['patients'] as Map?)?['full_name'] as String? ?? 'Pasien',
      jenisTerapi: map['service_type'] as String,
      alamat: map['address'] as String? ?? '-',
      telepon: (map['patients'] as Map?)?['phone'] as String? ?? '-',
      status: map['status'] as String,
    );
  }
}

// =============================================================================
// SCREEN
// =============================================================================

class JadwalPraktikScreen extends StatefulWidget {
  /// Jika diisi, screen akan langsung menampilkan jadwal pada tanggal ini.
  /// Digunakan ketika fisioterapis baru saja menerima booking.
  final DateTime? initialDate;

  const JadwalPraktikScreen({super.key, this.initialDate});

  @override
  State<JadwalPraktikScreen> createState() => _JadwalPraktikScreenState();
}

class _JadwalPraktikScreenState extends State<JadwalPraktikScreen> {
  final _supabase = Supabase.instance.client;
  final int _currentNavIndex = 1;

  late DateTime selectedDate;
  late Future<List<JadwalItem>> _jadwalFuture;
  late Future<int> _countHariIniFuture;
  late Future<int> _countBulanIniFuture;

  @override
  void initState() {
    super.initState();
    // ✅ Gunakan initialDate jika ada, fallback ke hari ini
    selectedDate = widget.initialDate ?? DateTime.now();
    _load();
  }

  void _load() {
    setState(() {
      _jadwalFuture = _fetchJadwal(selectedDate);
      _countHariIniFuture = _countBookingHariIni();
      _countBulanIniFuture = _countBookingBulanIni();
    });
  }

  // ---------------------------------------------------------------------------
  // Supabase queries
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

  Future<List<JadwalItem>> _fetchJadwal(DateTime date) async {
    final fisioterapisId = await _getFisioterapisId();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    final response = await _supabase
        .from('bookings')
        .select('*, patients(full_name, phone)')
        .eq('fisioterapis_id', fisioterapisId)
        .eq('scheduled_date', dateStr)
        .inFilter('status', ['confirmed', 'on_going', 'completed'])
        .order('scheduled_time', ascending: true);

    return (response as List)
        .map((e) => JadwalItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> _countBookingHariIni() async {
    final fisioterapisId = await _getFisioterapisId();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final response = await _supabase
        .from('bookings')
        .select('id')
        .eq('fisioterapis_id', fisioterapisId)
        .eq('scheduled_date', today)
        .inFilter('status', ['confirmed', 'on_going']);
    return (response as List).length;
  }

  Future<int> _countBookingBulanIni() async {
    final fisioterapisId = await _getFisioterapisId();
    final now = DateTime.now();
    final firstDay =
        DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
    final lastDay = DateFormat('yyyy-MM-dd')
        .format(DateTime(now.year, now.month + 1, 0));
    final response = await _supabase
        .from('bookings')
        .select('id')
        .eq('fisioterapis_id', fisioterapisId)
        .gte('scheduled_date', firstDay)
        .lte('scheduled_date', lastDay)
        .inFilter('status', ['confirmed', 'on_going', 'completed']);
    return (response as List).length;
  }

  Future<void> _mulaiSesi(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({
          'status': 'on_going',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);
  }

  Future<void> _selesaikanSesi(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({
          'status': 'completed',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _formatDate(DateTime date) =>
      DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    final screens = [
      const FisioterapisDashboardScreen(),
      const JadwalPraktikScreen(),
      const FisioterapisPasienTab(),
      FisioterapisProfilTab(),
    ];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screens[index]),
    );
  }

  void _changeDate(DateTime newDate) {
    selectedDate = newDate;
    _load();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBA7),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jadwal Praktik',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Kelola jadwal Terapi',
                style:
                    GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, size: 20),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AturJadwalScreen()),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child:
                    Text('Atur Jadwal', style: GoogleFonts.inter(fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: FisioterapisBottomNavbar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
      body: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Container(
            color: const Color(0xFF00BBA7),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FisioterapiBookingScreen()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: Color(0xFF00BBA7), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Permintaan Booking',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF00BBA7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: _countHariIniFuture,
                    builder: (_, snap) => _StatCard(
                      label: 'Hari Ini',
                      value: snap.data?.toString() ?? '-',
                      icon: Icons.calendar_today,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _countBulanIniFuture,
                    builder: (_, snap) => _StatCard(
                      label: 'Total Pasien Bulan Ini',
                      value: snap.data?.toString() ?? '-',
                      icon: Icons.people_outline,
                    ),
                  ),
                ),
              ]),
            ]),
          ),

          // ── Navigasi tanggal ──────────────────────────────────────────────
          GestureDetector(
            onTap: () async {
              final picked = await Navigator.push<DateTime>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      JadwalKalenderScreen(initialDate: selectedDate),
                ),
              );
              if (picked != null) _changeDate(picked);
            },
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.grey),
                    onPressed: () => _changeDate(
                        selectedDate.subtract(const Duration(days: 1))),
                  ),
                  Column(children: [
                    Text(_formatDate(selectedDate),
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                      'Tampilkan Kalender',
                      style: GoogleFonts.inter(
                          color: const Color(0xFF00BBA7),
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ]),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.grey),
                    onPressed: () =>
                        _changeDate(selectedDate.add(const Duration(days: 1))),
                  ),
                ],
              ),
            ),
          ),

          // ── Label tanggal ─────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Jadwal ${_formatDate(selectedDate)}',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                // ✅ Badge "Hari Ini" jika tanggal yang ditampilkan adalah hari ini
                if (_isSameDay(selectedDate, DateTime.now())) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('Hari Ini',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF00BBA7),
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ],
              ],
            ),
          ),

          // ── List jadwal ───────────────────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<JadwalItem>>(
              future: _jadwalFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF00BBA7)),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: GoogleFonts.inter(fontSize: 13)),
                  );
                }

                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.event_busy,
                          size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('Tidak ada jadwal pada tanggal ini',
                          style: GoogleFonts.inter(
                              color: Colors.grey, fontSize: 13)),
                    ]),
                  );
                }

                return RefreshIndicator(
                  color: const Color(0xFF00BBA7),
                  onRefresh: () async => _load(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return _JadwalCard(
                        item: item,
                        onPressed: item.status == 'completed'
                            ? null
                            : () async {
                                if (item.status == 'confirmed') {
                                  await _mulaiSesi(item.bookingId);
                                  setState(() => item.status = 'on_going');
                                }
                                if (!mounted) return;
                                final completed =
                                    await Navigator.push<bool?>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        _SelesaikanFormScreen(item: item),
                                  ),
                                );
                                if (completed == true) {
                                  await _selesaikanSesi(item.bookingId);
                                  _load();
                                }
                              },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// =============================================================================
// STAT CARD
// =============================================================================

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Text(value,
            style:
                GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10, color: Colors.black54, height: 1.2)),
        ),
        Icon(icon, color: const Color(0xFF00BBA7), size: 20),
      ]),
    );
  }
}

// =============================================================================
// JADWAL CARD
// =============================================================================

class _JadwalCard extends StatelessWidget {
  final JadwalItem item;
  final VoidCallback? onPressed;

  const _JadwalCard({required this.item, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isBerlangsung = item.status == 'on_going';
    final isSelesai = item.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isBerlangsung
            ? Border.all(color: const Color(0xFFFFB300), width: 1.5)
            : isSelesai
                ? Border.all(color: const Color(0xFF00BBA7), width: 1.5)
                : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: [
        if (isBerlangsung || isSelesai)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isBerlangsung
                  ? const Color(0xFFFFF8E1)
                  : const Color(0xFFE0F2F1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Center(
              child: Text(
                isBerlangsung ? 'Sedang Berlangsung' : 'Terapi Selesai',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isBerlangsung
                        ? const Color(0xFFFFB300)
                        : const Color(0xFF00BBA7)),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${item.jamMulai} - ${item.jamSelesai}',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.namaPasien,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(item.jenisTerapi,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              _iconInfo(Icons.location_on_outlined, item.alamat),
              _iconInfo(Icons.phone_outlined, item.telepon),
              const SizedBox(height: 16),
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chat_bubble_outline,
                      size: 18, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelesai
                          ? Colors.grey.shade200
                          : const Color(0xFF00BBA7),
                      foregroundColor:
                          isSelesai ? Colors.black54 : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      item.status == 'confirmed'
                          ? 'Mulai'
                          : isBerlangsung
                              ? 'Selesaikan'
                              : 'Selesai',
                      style:
                          GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _iconInfo(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.black54))),
        ]),
      );
}

// =============================================================================
// FORM SELESAIKAN
// =============================================================================

class _SelesaikanFormScreen extends StatelessWidget {
  final JadwalItem item;
  const _SelesaikanFormScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBA7),
        foregroundColor: Colors.white,
        title: Text('Form Selesaikan',
            style:
                GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item.jamMulai} - ${item.jamSelesai}',
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(item.namaPasien,
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(item.jenisTerapi,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 12),
                  _detailRow(Icons.location_on_outlined, item.alamat),
                  _detailRow(Icons.phone_outlined, item.telepon),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selesaikan Layanan',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 16),
                    Text(
                      'Pastikan pasien sudah menyelesaikan sesi dan pembayaran '
                      'sebelum menandai selesai.',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Catatan penyelesaian (opsional)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _confirmCompletion(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BBA7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text('Selesaikan',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCompletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Konfirmasi Pembayaran dan Layanan',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text(
          'Apakah anda yakin pasien sudah melakukan layanan dan pembayaran?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Belum',
                style: GoogleFonts.inter(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BBA7),
                foregroundColor: Colors.white),
            child: Text('Sudah', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  Widget _detailRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.black54))),
        ]),
      );
}