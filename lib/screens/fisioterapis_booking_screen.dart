import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booking_model.dart';

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

  // Simpan fisioterapis_id & jadwal agar tidak re-fetch tiap aksi
  String? _fisioterapisId;
  List<Map<String, dynamic>> _jadwal = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _fetchAll();
    });
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
        .select('id')
        .eq('user_id', userId)
        .single();
    _fisioterapisId = res['id'] as String;
    return _fisioterapisId!;
  }

  Future<List<BookingModel>> _fetchAll() async {
    final id = await _getFisioterapisId();

    // Load jadwal fisioterapis (untuk tanggal alternatif)
    final jadwalRes = await _supabase
        .from('jadwal_fisioterapis')
        .select()
        .eq('fisioterapis_id', id)
        .eq('is_available', true);
    _jadwal = List<Map<String, dynamic>>.from(jadwalRes as List);

    // Load bookings pending
    final res = await _supabase
        .from('bookings')
        .select('*, patients(full_name, phone)')
        .eq('fisioterapis_id', id)
        .eq('status', 'pending')
        .order('scheduled_date', ascending: true)
        .order('scheduled_time', ascending: true);

    return (res as List)
        .map((e) => BookingModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _confirmBooking(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({'status': 'confirmed', 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', bookingId);
  }

  Future<void> _cancelBooking(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({'status': 'cancelled', 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', bookingId);
  }

  // ---------------------------------------------------------------------------
  // Handlers
  // ---------------------------------------------------------------------------

  Future<void> _handleConfirm(String bookingId) async {
    try {
      await _confirmBooking(bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking berhasil diterima'),
          backgroundColor: Color(0xFF00BBA7),
        ),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menerima booking: $e')),
      );
    }
  }

  /// Tampilkan bottom sheet tolak booking, lalu proses jika dikonfirmasi
  Future<void> _handleTolak(BookingModel booking) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TolakBookingSheet(
        booking: booking,
        jadwal: _jadwal,
        onKirim: (alasan) async {
          await _cancelBooking(booking.id);
          // TODO: simpan alasan ke tabel notifications / kolom baru jika diperlukan
          // Contoh: await _supabase.from('notifications').insert({...})
        },
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking ditolak dan pasien diberitahu')),
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
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
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
                child: CircularProgressIndicator(color: Color(0xFF00BBA7)));
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
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
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
                  onTerima: () => _handleConfirm(booking.id),
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
          // Header: avatar + nama + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF00BBA7),
                  child: Text(
                    booking.patientInitials,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    booking.patientFullName ?? 'Pasien',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  Text(booking.serviceType,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey)),
                ]),
              ]),
              _StatusChip(status: booking.status),
            ],
          ),

          const Divider(height: 20),

          // Info detail
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

          // Tombol aksi
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
  final Future<void> Function(String alasan) onKirim;

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

  // Nama hari Indonesia → urutan
  static const _hariOrder = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  // Weekday number → nama hari
  String _weekdayToHari(int w) => _hariOrder[w - 1];

  // Hitung 3 slot alternatif (H+1 s/d H+14) berdasarkan jadwal fisioterapis
  List<Map<String, String>> _buildAlternatif() {
    final List<Map<String, String>> result = [];
    final base = widget.booking.scheduledDate;

    for (int i = 1; i <= 14 && result.length < 3; i++) {
      final candidate = base.add(Duration(days: i));
      final hari = _weekdayToHari(candidate.weekday);

      final jadwalHari = widget.jadwal.firstWhere(
        (j) => j['hari'] == hari,
        orElse: () => {},
      );
      if (jadwalHari.isEmpty) continue;

      final jamMulai = jadwalHari['jam_mulai'] as String;
      final parts = jamMulai.split(':');
      final jamLabel =
          '${parts[0]}:${parts[1]} WIB';

      result.add({
        'tanggal': DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(candidate),
        'jam': 'Pukul $jamLabel',
        'date_raw': DateFormat('yyyy-MM-dd').format(candidate),
      });
    }
    return result;
  }

  Future<void> _submit() async {
    if (_alasanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alasan penolakan harus diisi')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await widget.onKirim(_alasanController.text.trim());
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
    final patientName = widget.booking.patientFullName ?? 'Pasien';
    final jadwalBooking = DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
        .format(widget.booking.scheduledDate);
    final alternatif = _buildAlternatif();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Judul
            Center(
              child: Text(
                'Tolak Booking',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Berikan alasan penolakan dan tawarkan tanggal alternatif\nkepada $patientName. Informasi ini akan dikirimkan ke pasien.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // Info booking yang ditolak
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
                        fontSize: 12, color: Colors.grey.shade700),
                  ),
                  Text(
                    widget.booking.serviceType,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Alasan penolakan
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
                    'Contoh: Jadwal sudah penuh pada waktu tersebut.\nMohon pilih waktu lain.',
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
                    borderSide: const BorderSide(color: Color(0xFF00BBA7))),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Berikan penjelasan yang jelas dan profesional kepada pasien',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Tanggal alternatif
            Row(children: [
              Text('Tanggal Alternatif yang Tersedia',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              Text(' *',
                  style: GoogleFonts.inter(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 4),
            Text(
              'Pilih tanggal dan waktu alternatif yang tersedia untuk memudahkan\npasien memilih jadwal baru',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
            ),
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
                  'Tidak ada jadwal alternatif dalam 2 minggu ke depan.',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.orange.shade800),
                ),
              )
            else
              ...alternatif.map((alt) => _AlternatifTile(
                    tanggal: alt['tanggal']!,
                    jam: alt['jam']!,
                  )),

            const SizedBox(height: 24),

            // Tombol kirim
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
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

            // Tombol batal
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
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
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

  const _AlternatifTile({required this.tanggal, required this.jam});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_outlined,
              color: Color(0xFF00BBA7), size: 20),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tanggal,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 2),
            Row(children: [
              const Icon(Icons.access_time, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(jam,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.grey)),
            ]),
          ]),
        ],
      ),
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