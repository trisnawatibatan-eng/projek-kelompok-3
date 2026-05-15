import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav_bar.dart';

class JanjiTemuScreen extends StatefulWidget {
  const JanjiTemuScreen({super.key});

  @override
  State<JanjiTemuScreen> createState() => _JanjiTemuScreenState();
}

class _JanjiTemuScreenState extends State<JanjiTemuScreen> {
  final _supabase = Supabase.instance.client;

  bool _isHistoryView = false;
  bool _isLoading = true;

  List<Map<String, dynamic>> _bookings = [];

  // Rating modal state
  int _selectedRating = 0;
  final TextEditingController _komentarController = TextEditingController();
  bool _isSubmittingReview = false;

  String? get _userId => _supabase.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }

  // ── Load bookings dari Supabase ───────────────────────────────

  Future<void> _loadBookings() async {
    if (_userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final res = await _supabase
          .from('bookings')
          .select('*, fisioterapis(id, nama_lengkap, foto_profil_url)')
          .eq('patient_id', _userId!)
          .order('scheduled_date', ascending: false)
          .order('scheduled_time', ascending: false);

      // Cek apakah booking sudah direview
      final bookingIds =
          (res as List).map((b) => b['id'] as String).toList();

      Map<String, bool> reviewedMap = {};
      if (bookingIds.isNotEmpty) {
        final reviews = await _supabase
            .from('reviews')
            .select('booking_id')
            .eq('patient_id', _userId!)
            .inFilter('booking_id', bookingIds);

        for (final r in reviews as List) {
          reviewedMap[r['booking_id'] as String] = true;
        }
      }

      if (mounted) {
        setState(() {
          _bookings = (res as List).map((b) {
            final map = Map<String, dynamic>.from(b as Map);
            map['already_reviewed'] = reviewedMap[b['id']] ?? false;
            return map;
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading bookings: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Helper: status → label & warna ───────────────────────────

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'on_going':
        return 'Sedang Berlangsung';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
      case 'on_going':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFF8E1);
      case 'confirmed':
      case 'on_going':
        return const Color(0xFFE3F2FD);
      case 'completed':
        return const Color(0xFFE8F5E9);
      case 'cancelled':
        return const Color(0xFFFFEBEE);
      default:
        return Colors.grey.shade100;
    }
  }

  bool _isHistory(String status) =>
      status == 'completed' || status == 'cancelled';

  // ── Format tanggal & waktu ────────────────────────────────────

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} WIB';
    } catch (_) {
      return timeStr;
    }
  }

  // ── Submit ulasan ─────────────────────────────────────────────

  Future<void> _submitReview(Map<String, dynamic> booking) async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pilih rating terlebih dahulu')));
      return;
    }
    setState(() => _isSubmittingReview = true);
    try {
      final fisio = booking['fisioterapis'] as Map?;
      await _supabase.from('reviews').insert({
        'booking_id': booking['id'],
        'patient_id': _userId,
        'fisioterapis_id': fisio?['id'] ?? booking['fisioterapis_id'],
        'rating': _selectedRating,
        'komentar': _komentarController.text.trim().isEmpty
            ? null
            : _komentarController.text.trim(),
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ulasan berhasil dikirim!')));
      _selectedRating = 0;
      _komentarController.clear();
      _loadBookings(); // refresh supaya tombol "Beri Ulasan" hilang
    } catch (e) {
      debugPrint('Error submit review: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengirim ulasan. Coba lagi.')));
      }
    } finally {
      if (mounted) setState(() => _isSubmittingReview = false);
    }
  }

  // ── Modal Ulasan ──────────────────────────────────────────────

  void _showRatingDialog(Map<String, dynamic> booking) {
    _selectedRating = 0;
    _komentarController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 20),
                    Text('Beri Ulasan',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Rating Pelayanan',
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.bold)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      icon: Icon(
                        index < _selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.orange,
                        size: 30,
                      ),
                      onPressed: () {
                        setModalState(() => _selectedRating = index + 1);
                        setState(() {});
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _komentarController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Ceritakan pengalaman Anda...',
                    hintStyle:
                        GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _isSubmittingReview
                        ? null
                        : () => _submitReview(booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BBA7),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isSubmittingReview
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text('Kirim Ulasan',
                            style: GoogleFonts.inter(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final displayed = _bookings
        .where((b) =>
            _isHistoryView
                ? _isHistory(b['status'] as String)
                : !_isHistory(b['status'] as String))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBA7),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Janji Temu',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white)),
            Text('Lihat jadwal terapi Anda',
                style: GoogleFonts.inter(
                    fontSize: 12, color: Colors.white70)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  _buildTab("Akan Datang", !_isHistoryView),
                  _buildTab("Riwayat", _isHistoryView),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00BBA7)))
          : displayed.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  color: const Color(0xFF00BBA7),
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayed.length,
                    itemBuilder: (context, index) =>
                        _buildItemCard(displayed[index]),
                  ),
                ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              _isHistoryView
                  ? 'Belum ada riwayat booking'
                  : 'Belum ada jadwal mendatang',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ],
        ),
      );

  Widget _buildTab(String label, bool active) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _isHistoryView = label == "Riwayat"),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                color: active ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: active
                          ? const Color(0xFF00BBA7)
                          : Colors.white)),
            ),
          ),
        ),
      );

  Widget _buildItemCard(Map<String, dynamic> booking) {
    final status = booking['status'] as String;
    final isCancelled = status == 'cancelled';
    final isCompleted = status == 'completed';
    final alreadyReviewed = booking['already_reviewed'] as bool? ?? false;
    final fisio = booking['fisioterapis'] as Map?;
    final namaFisio = fisio?['nama_lengkap'] as String? ?? '-';
    final fotoUrl = fisio?['foto_profil_url'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isCancelled ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isCancelled
                ? Colors.red.shade100
                : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF00BBA7),
              backgroundImage:
                  fotoUrl != null && fotoUrl.isNotEmpty
                      ? NetworkImage(fotoUrl)
                      : null,
              child: fotoUrl == null || fotoUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 18)
                  : null,
            ),
            title: Text(booking['service_type'] as String? ?? '-',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text('Ftr. $namaFisio',
                style: GoogleFonts.inter(
                    fontSize: 11, color: Colors.grey)),
            trailing: _statusBadge(status),
          ),

          // Info rows
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _infoRow(
                  Icons.calendar_today_outlined,
                  '${_formatDate(booking['scheduled_date'] as String)} • '
                  '${_formatTime(booking['scheduled_time'] as String)}',
                ),
                _infoRow(
                  Icons.location_on_outlined,
                  booking['address'] as String? ?? '-',
                ),
                if ((booking['notes'] as String?) != null &&
                    (booking['notes'] as String).isNotEmpty)
                  _infoRow(Icons.notes_outlined,
                      booking['notes'] as String),
                _infoRow(
                  Icons.payments_outlined,
                  'Rp ${NumberFormat('#,###', 'id_ID').format((booking['total_price'] as num?) ?? 0)}',
                ),
              ],
            ),
          ),

          // Action section
          if (isCompleted && !alreadyReviewed) ...[
            const Divider(height: 1),
            _actionBtn('Beri Ulasan', () => _showRatingDialog(booking)),
          ] else if (isCompleted && alreadyReviewed) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 16),
                  const SizedBox(width: 6),
                  Text('Ulasan sudah dikirim',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.green)),
                ],
              ),
            ),
          ] else if (isCancelled) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.cancel_outlined,
                      color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Booking ini telah dibatalkan',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    final bg = _statusBgColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(_statusLabel(status),
          style: GoogleFonts.inter(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF00BBA7)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(text,
                    style: GoogleFonts.inter(fontSize: 12))),
          ],
        ),
      );

  Widget _actionBtn(String label, VoidCallback tap) => Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed: tap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BBA7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(label,
                style: GoogleFonts.inter(color: Colors.white)),
          ),
        ),
      );
}