import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booking_model.dart';
import 'fisioterapis_jadwal_praktik.dart'; // ← navigate setelah terima

// =============================================================================
// SCREEN
// =============================================================================

class FisioterapiBookingScreen extends StatefulWidget {
  const FisioterapiBookingScreen({super.key});

  @override
  State<FisioterapiBookingScreen> createState() =>
      _FisioterapiBookingScreenState();
}

class _FisioterapiBookingScreenState extends State<FisioterapiBookingScreen> {
  final _supabase = Supabase.instance.client;
  late Future<List<BookingModel>> _future;

  String? _fisioterapisId;
  String? _fisioterapisUserId;
  List<Map<String, dynamic>> _jadwal = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _future = _fetchAll());
  }

  // ---------------------------------------------------------------------------
  // Supabase queries
  // ---------------------------------------------------------------------------

  Future<String> _getFisioterapisId() async {
    if (_fisioterapisId != null) return _fisioterapisId!;
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login');
    final res = await _supabase
        .from('fisioterapis')
        .select('id, user_id')
        .eq('user_id', userId)
        .single();
    _fisioterapisId = res['id'] as String;
    _fisioterapisUserId = res['user_id'] as String;
    return _fisioterapisId!;
  }

  Future<List<BookingModel>> _fetchAll() async {
    final id = await _getFisioterapisId();

    // Load jadwal fisioterapis (untuk tanggal alternatif penolakan)
    final jadwalRes = await _supabase
        .from('jadwal_fisioterapis')
        .select()
        .eq('fisioterapis_id', id)
        .eq('is_available', true);
    _jadwal = List<Map<String, dynamic>>.from(jadwalRes as List);

    // ✅ Join ke patients(full_name, phone) — butuh RLS policy yang benar
    final res = await _supabase
        .from('bookings')
        .select('*, patients(full_name, phone)')
        .eq('fisioterapis_id', id)
        .eq('status', 'pending')
        .order('scheduled_date', ascending: true)
        .order('scheduled_time', ascending: true);

    // Debug — hapus setelah nama pasien sudah muncul dengan benar
    debugPrint('[BookingScreen] raw: $res');

    return (res as List)
        .map((e) => BookingModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // ✅ Terima: update DB → confirmed + notifikasi ke pasien
  // ---------------------------------------------------------------------------

  Future<void> _confirmBooking(BookingModel booking) async {
    final now = DateTime.now().toIso8601String();

    // 1. Update status di tabel bookings → confirmed
    await _supabase
        .from('bookings')
        .update({'status': 'confirmed', 'updated_at': now})
        .eq('id', booking.id);

    // 2. Notifikasi ke pasien
    final jadwalFormatted = DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
        .format(booking.scheduledDate);

    await _supabase.from('notifications').insert({
      'user_id': booking.patientId,
      'judul': 'Booking Dikonfirmasi ✅',
      'pesan':
          'Booking Anda pada $jadwalFormatted pukul ${booking.scheduledTime} '
          'untuk layanan "${booking.serviceType}" telah dikonfirmasi. '
          'Pastikan Anda hadir tepat waktu.',
      'type': 'jadwal',
      'is_read': false,
    });
  }

  // ---------------------------------------------------------------------------
  // Tolak: cancelled + notifikasi alasan + jadwal alternatif ke pasien
  // ---------------------------------------------------------------------------

  Future<void> _cancelBooking({
    required BookingModel booking,
    required String alasan,
    required Map<String, String>? alternatifDipilih,
  }) async {
    final now = DateTime.now().toIso8601String();
    final jadwalFormatted = DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
        .format(booking.scheduledDate);

    // 1. Update status → cancelled
    await _supabase
        .from('bookings')
        .update({'status': 'cancelled', 'updated_at': now})
        .eq('id', booking.id);

    // 2. Susun pesan ke pasien
    final buffer = StringBuffer(
      'Maaf, booking Anda pada $jadwalFormatted pukul ${booking.scheduledTime} '
      'untuk layanan "${booking.serviceType}" ditolak.\n\n'
      'Alasan: $alasan',
    );
    if (alternatifDipilih != null) {
      buffer.write(
        '\n\nFisioterapis menyarankan jadwal alternatif:\n'
        '📅 ${alternatifDipilih['tanggal']}\n'
        '🕐 ${alternatifDipilih['jam']}',
      );
    }

    // 3. Notifikasi ke pasien
    await _supabase.from('notifications').insert({
      'user_id': booking.patientId,
      'judul': 'Booking Ditolak',
      'pesan': buffer.toString(),
      'type': 'booking_cancelled',
      'is_read': false,
    });

    // 4. Notifikasi log ke fisioterapis sendiri
    if (_fisioterapisUserId != null) {
      await _supabase.from('notifications').insert({
        'user_id': _fisioterapisUserId,
        'judul': 'Booking Ditolak',
        'pesan':
            'Anda telah menolak booking dari ${booking.patientFullName ?? 'Pasien'} '
            'pada $jadwalFormatted pukul ${booking.scheduledTime}.',
        'type': 'booking',
        'is_read': false,
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Handlers
  // ---------------------------------------------------------------------------

  Future<void> _handleConfirm(BookingModel booking) async {
    // Dialog konfirmasi
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Terima Booking',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text(
          'Konfirmasi booking dari ${booking.patientFullName ?? 'Pasien'} '
          'pada ${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(booking.scheduledDate)} '
          'pukul ${booking.scheduledTime}?',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BBA7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Ya, Terima', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    try {
      await _confirmBooking(booking);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking diterima! Pasien telah diberitahu.'),
          backgroundColor: Color(0xFF00BBA7),
        ),
      );

      // ✅ Langsung ke JadwalPraktikScreen dengan tanggal booking
      // sehingga jadwal yang baru dikonfirmasi langsung terlihat
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              JadwalPraktikScreen(initialDate: booking.scheduledDate),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menerima booking: $e')),
      );
    }
  }

  Future<void> _handleTolak(BookingModel booking) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TolakBookingSheet(
        booking: booking,
        jadwal: _jadwal,
        onKirim: (alasan, alternatifDipilih) async {
          await _cancelBooking(
            booking: booking,
            alasan: alasan,
            alternatifDipilih: alternatifDipilih,
          );
        },
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking ditolak. Pasien telah diberitahu.'),
          backgroundColor: Color(0xFF00BBA7),
        ),
      );
      _load();
    }
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
        title: Text('Permintaan Booking',
            style:
                GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<BookingModel>>(
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
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text('Terjadi kesalahan:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 13)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _load,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BBA7),
                        foregroundColor: Colors.white),
                    child: const Text('Coba Lagi'),
                  ),
                ]),
              ),
            );
          }

          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.inbox_outlined,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text('Tidak ada permintaan booking',
                    style: GoogleFonts.inter(color: Colors.grey)),
              ]),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF00BBA7),
            onRefresh: () async => _load(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _BookingCard(
                  booking: booking,
                  onTerima: () => _handleConfirm(booking),
                  onTolak: () => _handleTolak(booking),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// BOOKING CARD
// =============================================================================

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTerima;
  final VoidCallback onTolak;

  const _BookingCard({
    required this.booking,
    required this.onTerima,
    required this.onTolak,
  });

  String _formatSchedule() {
    final hari = DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
        .format(booking.scheduledDate);
    return '$hari • ${booking.scheduledTime}';
  }

  String get _patientName {
    final name = booking.patientFullName;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    return 'Pasien';
  }

  String get _initials {
    final parts = _patientName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _patientName.isNotEmpty ? _patientName[0].toUpperCase() : 'P';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF00BBA7),
                child: Text(_initials,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_patientName,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis),
                    Text(booking.serviceType,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(status: booking.status),
            ],
          ),

          const Divider(height: 20),

          _infoRow(Icons.calendar_today, _formatSchedule()),
          if (booking.address != null && booking.address!.isNotEmpty)
            _infoRow(Icons.location_on_outlined, booking.address!),
          if (booking.notes != null && booking.notes!.isNotEmpty)
            _infoRow(Icons.notes, booking.notes!),
          if (booking.totalPrice != null)
            _infoRow(
              Icons.payments_outlined,
              NumberFormat.currency(
                      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                  .format(booking.totalPrice),
            ),

          const SizedBox(height: 16),

          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onTolak,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Tolak'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onTerima,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BBA7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Terima'),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 12))),
        ]),
      );
}

// =============================================================================
// BOTTOM SHEET: TOLAK BOOKING
// =============================================================================

class _TolakBookingSheet extends StatefulWidget {
  final BookingModel booking;
  final List<Map<String, dynamic>> jadwal;
  final Future<void> Function(
          String alasan, Map<String, String>? alternatifDipilih)
      onKirim;

  const _TolakBookingSheet({
    required this.booking,
    required this.jadwal,
    required this.onKirim,
  });

  @override
  State<_TolakBookingSheet> createState() => _TolakBookingSheetState();
}

class _TolakBookingSheetState extends State<_TolakBookingSheet> {
  final _alasanController = TextEditingController();
  bool _isSubmitting = false;
  int? _selectedAlternatifIndex;

  static const _hariOrder = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];

  String _weekdayToHari(int w) => _hariOrder[w - 1];

  List<Map<String, String>> _buildAlternatif() {
    final result = <Map<String, String>>[];
    final base = widget.booking.scheduledDate;

    for (int i = 1; i <= 21 && result.length < 5; i++) {
      final candidate = base.add(Duration(days: i));
      final hari = _weekdayToHari(candidate.weekday);
      final jadwalHari = widget.jadwal
          .firstWhere((j) => j['hari'] == hari, orElse: () => {});
      if (jadwalHari.isEmpty) continue;

      final parts = (jadwalHari['jam_mulai'] as String).split(':');
      result.add({
        'tanggal':
            DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(candidate),
        'jam': 'Pukul ${parts[0]}:${parts[1]} WIB',
        'date_raw': DateFormat('yyyy-MM-dd').format(candidate),
      });
    }
    return result;
  }

  Future<void> _submit(List<Map<String, String>> alternatif) async {
    if (_alasanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alasan penolakan harus diisi')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final dipilih = _selectedAlternatifIndex != null
          ? alternatif[_selectedAlternatifIndex!]
          : null;
      await widget.onKirim(_alasanController.text.trim(), dipilih);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menolak booking: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientName =
        widget.booking.patientFullName?.trim().isNotEmpty == true
            ? widget.booking.patientFullName!
            : 'Pasien';
    final jadwalBooking = DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
        .format(widget.booking.scheduledDate);
    final alternatif = _buildAlternatif();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Center(
              child: Text('Tolak Booking',
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Berikan alasan penolakan kepada $patientName.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // Info booking
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patientName,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                      '$jadwalBooking • ${widget.booking.scheduledTime}',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey.shade700)),
                  Text(widget.booking.serviceType,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey.shade700)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Alasan
            Row(children: [
              Text('Alasan Penolakan',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              Text(' *',
                  style: GoogleFonts.inter(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 6),
            TextField(
              controller: _alasanController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Contoh: Jadwal sudah penuh. Mohon pilih waktu lain.',
                hintStyle:
                    GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF00BBA7))),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 20),

            // Jadwal alternatif
            Text('Tawarkan Jadwal Alternatif',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Pilih satu jadwal untuk ditawarkan ke pasien (opsional)',
                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 12),

            if (alternatif.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  'Tidak ada jadwal alternatif dalam 3 minggu ke depan.',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.orange.shade800),
                ),
              )
            else
              ...alternatif.asMap().entries.map((entry) {
                final idx = entry.key;
                final alt = entry.value;
                final isSelected = _selectedAlternatifIndex == idx;
                return GestureDetector(
                  onTap: () => setState(() =>
                      _selectedAlternatifIndex = isSelected ? null : idx),
                  child: _AlternatifTile(
                    tanggal: alt['tanggal']!,
                    jam: alt['jam']!,
                    isSelected: isSelected,
                  ),
                );
              }),

            if (_selectedAlternatifIndex != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Row(children: [
                  const Icon(Icons.check_circle,
                      color: Color(0xFF00BBA7), size: 14),
                  const SizedBox(width: 6),
                  Text('Jadwal alternatif akan dikirim ke pasien',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF00BBA7))),
                ]),
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    _isSubmitting ? null : () => _submit(alternatif),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text('Kirim Penolakan',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Batal',
                    style:
                        GoogleFonts.inter(fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TILE: TANGGAL ALTERNATIF
// =============================================================================

class _AlternatifTile extends StatelessWidget {
  final String tanggal;
  final String jam;
  final bool isSelected;

  const _AlternatifTile({
    required this.tanggal,
    required this.jam,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8F8F6) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              isSelected ? const Color(0xFF00BBA7) : Colors.grey.shade200,
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03), blurRadius: 6),
        ],
      ),
      child: Row(children: [
        Icon(Icons.calendar_month_outlined,
            color: isSelected
                ? const Color(0xFF00BBA7)
                : Colors.grey.shade400,
            size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tanggal,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected
                          ? const Color(0xFF00BBA7)
                          : Colors.black87,
                    )),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.access_time,
                      size: 12,
                      color: isSelected
                          ? const Color(0xFF00BBA7)
                          : Colors.grey),
                  const SizedBox(width: 4),
                  Text(jam,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isSelected
                              ? const Color(0xFF00BBA7)
                              : Colors.grey)),
                ]),
              ]),
        ),
        if (isSelected)
          const Icon(Icons.check_circle,
              color: Color(0xFF00BBA7), size: 20),
      ]),
    );
  }
}

// =============================================================================
// STATUS CHIP
// =============================================================================

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      'pending' => (Colors.orange.shade50, Colors.orange, 'Menunggu'),
      'confirmed' => (
          const Color(0xFFE8F8F6),
          const Color(0xFF00BBA7),
          'Dikonfirmasi',
        ),
      'on_going' => (Colors.blue.shade50, Colors.blue, 'Berlangsung'),
      'completed' => (Colors.green.shade50, Colors.green, 'Selesai'),
      'cancelled' => (Colors.red.shade50, Colors.red, 'Dibatalkan'),
      _ => (Colors.grey.shade100, Colors.grey, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: TextStyle(
              color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}