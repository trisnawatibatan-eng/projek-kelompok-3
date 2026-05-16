import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// =============================================================================
// MODEL
// =============================================================================

class PaymentHistoryItem {
  final String bookingId;
  final String patientName;
  final String patientPhone;
  final DateTime dateTime;
  final String serviceType;
  final double amount;

  PaymentHistoryItem({
    required this.bookingId,
    required this.patientName,
    required this.patientPhone,
    required this.dateTime,
    required this.serviceType,
    required this.amount,
  });

  factory PaymentHistoryItem.fromMap(Map<String, dynamic> map) {
    final dateStr = map['scheduled_date'] as String;
    final timeStr = (map['scheduled_time'] as String).substring(0, 5);
    final dt = DateTime.parse('${dateStr}T$timeStr:00');

    return PaymentHistoryItem(
      bookingId: map['id'] as String,
      patientName:
          (map['patients'] as Map?)?['full_name'] as String? ?? 'Pasien',
      patientPhone:
          (map['patients'] as Map?)?['phone'] as String? ?? '-',
      dateTime: dt,
      serviceType: map['service_type'] as String? ?? '-',
      amount: (map['total_price'] as num?)?.toDouble() ?? 0,
    );
  }
}

// =============================================================================
// SCREEN
// =============================================================================

class FisioterapisPaymentHistoryScreen extends StatefulWidget {
  const FisioterapisPaymentHistoryScreen({super.key});

  @override
  State<FisioterapisPaymentHistoryScreen> createState() =>
      _FisioterapisPaymentHistoryScreenState();
}

class _FisioterapisPaymentHistoryScreenState
    extends State<FisioterapisPaymentHistoryScreen> {
  final _supabase = Supabase.instance.client;

  late Future<List<PaymentHistoryItem>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistory();
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

  Future<List<PaymentHistoryItem>> _fetchHistory() async {
    final fisioterapisId = await _getFisioterapisId();

    final response = await _supabase
        .from('bookings')
        .select('*, patients(full_name, phone)')
        .eq('fisioterapis_id', fisioterapisId)
        .eq('status', 'completed')
        .order('scheduled_date', ascending: false)
        .order('scheduled_time', ascending: false);

    return (response as List)
        .map((e) => PaymentHistoryItem.fromMap(e as Map<String, dynamic>))
        .toList();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Riwayat Pembayaran',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => setState(() {
              _historyFuture = _fetchHistory();
            }),
            icon: const Icon(Icons.refresh, size: 20),
          ),
        ],
      ),
      body: FutureBuilder<List<PaymentHistoryItem>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00BBA7)),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 56, color: Colors.red.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat data:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _historyFuture = _fetchHistory();
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BBA7),
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Coba Lagi', style: GoogleFonts.inter()),
                    ),
                  ],
                ),
              ),
            );
          }

          final list = snapshot.data ?? [];

          // Empty state
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada riwayat pembayaran',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Riwayat akan muncul setelah layanan selesai',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            );
          }

          // Summary header
          final totalIncome =
              list.fold<double>(0, (sum, e) => sum + e.amount);

          return RefreshIndicator(
            color: const Color(0xFF00BBA7),
            onRefresh: () async =>
                setState(() => _historyFuture = _fetchHistory()),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: list.length + 1, // +1 for summary card
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildSummaryCard(list.length, totalIncome);
                }
                return _buildPaymentCard(list[index - 1]);
              },
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Summary Card
  // ---------------------------------------------------------------------------

  Widget _buildSummaryCard(int totalSesi, double totalIncome) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00BBA7), Color(0xFF00A896)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BBA7).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Pendapatan',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${NumberFormat('#,##0', 'id_ID').format(totalIncome)}',
                  style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  '$totalSesi',
                  style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  'Sesi Selesai',
                  style: GoogleFonts.inter(
                      fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Payment Card
  // ---------------------------------------------------------------------------

  Widget _buildPaymentCard(PaymentHistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Avatar + Nama + Status ──
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF00BBA7).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    item.patientName.isNotEmpty
                        ? item.patientName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00BBA7),
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
                      item.patientName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A202C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.serviceType,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              // Badge Selesai
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Selesai',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00BBA7),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 10),

          // ── Tanggal & Waktu ──
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: Color(0xFF718096)),
              const SizedBox(width: 5),
              Text(
                DateFormat('dd MMM yyyy', 'id_ID').format(item.dateTime),
                style: GoogleFonts.inter(
                    fontSize: 11, color: const Color(0xFF718096)),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_outlined,
                  size: 13, color: Color(0xFF718096)),
              const SizedBox(width: 5),
              Text(
                DateFormat('HH:mm').format(item.dateTime),
                style: GoogleFonts.inter(
                    fontSize: 11, color: const Color(0xFF718096)),
              ),
              if (item.patientPhone != '-') ...[
                const SizedBox(width: 12),
                const Icon(Icons.phone_outlined,
                    size: 13, color: Color(0xFF718096)),
                const SizedBox(width: 5),
                Text(
                  item.patientPhone,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: const Color(0xFF718096)),
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // ── Pembayaran ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pembayaran',
                style: GoogleFonts.inter(
                    fontSize: 11, color: const Color(0xFF718096)),
              ),
              Text(
                item.amount > 0
                    ? 'Rp ${NumberFormat('#,##0', 'id_ID').format(item.amount)}'
                    : 'Belum diisi',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: item.amount > 0
                      ? const Color(0xFF10B981)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}