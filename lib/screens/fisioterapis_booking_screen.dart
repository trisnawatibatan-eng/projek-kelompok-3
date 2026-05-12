import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/booking_model.dart';
import '../repositories/booking_repository.dart';

class FisioterapiBookingScreen extends StatefulWidget {
  const FisioterapiBookingScreen({super.key});

  @override
  State<FisioterapiBookingScreen> createState() =>
      _FisioterapiBookingScreenState();
}

class _FisioterapiBookingScreenState extends State<FisioterapiBookingScreen> {
  final _repo = BookingRepository();
  late Future<List<BookingModel>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _repo.fetchBookings(status: 'pending');
    });
  }

  // ---------------------------------------------------------------------------
  // Handlers
  // ---------------------------------------------------------------------------

  Future<void> _handleConfirm(String bookingId) async {
    try {
      await _repo.confirmBooking(bookingId);
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

  Future<void> _handleCancel(String bookingId) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Booking'),
        content: const Text('Yakin ingin menolak permintaan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    try {
      await _repo.cancelBooking(bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking ditolak')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menolak booking: $e')),
      );
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
        title: Text(
          'Permintaan Booking',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Terjadi kesalahan:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _load,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BBA7),
                          foregroundColor: Colors.white),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak ada permintaan booking',
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                ],
              ),
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
                return _FisioterapiBookingCard(
                  booking: booking,
                  onTerima: () => _handleConfirm(booking.id),
                  onTolak: () => _handleCancel(booking.id),
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
// CARD
// =============================================================================

class _FisioterapiBookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTerima;
  final VoidCallback onTolak;

  const _FisioterapiBookingCard({
    required this.booking,
    required this.onTerima,
    required this.onTolak,
  });

  String _formatSchedule() {
    final hari =
        DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(booking.scheduledDate);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF00BBA7),
                    child: Text(
                      booking.patientInitials,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.patientFullName ?? 'Pasien',
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        booking.serviceType,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              _StatusChip(status: booking.status),
            ],
          ),
          const Divider(height: 24),
          _detailRow(Icons.calendar_today, _formatSchedule()),
          if (booking.address != null && booking.address!.isNotEmpty)
            _detailRow(Icons.location_on_outlined, booking.address!),
          if (booking.notes != null && booking.notes!.isNotEmpty)
            _detailRow(Icons.notes, booking.notes!),
          if (booking.totalPrice != null)
            _detailRow(
              Icons.payments_outlined,
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(booking.totalPrice),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onTolak,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
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
                  ),
                  child: const Text('Terima'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: GoogleFonts.inter(fontSize: 12)),
          ),
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
          'Dikonfirmasi'
        ),
      'on_going' => (Colors.blue.shade50, Colors.blue, 'Berlangsung'),
      'completed' => (Colors.green.shade50, Colors.green, 'Selesai'),
      'cancelled' => (Colors.red.shade50, Colors.red, 'Dibatalkan'),
      _ => (Colors.grey.shade100, Colors.grey, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}