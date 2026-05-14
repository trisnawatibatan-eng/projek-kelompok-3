import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PaymentHistoryItem {
  final String patientName;
  final String patientRole;
  final DateTime dateTime;
  final String description;
  final double amount;

  PaymentHistoryItem({
    required this.patientName,
    required this.patientRole,
    required this.dateTime,
    required this.description,
    required this.amount,
  });
}

class FisioterapisPaymentHistoryScreen extends StatefulWidget {
  const FisioterapisPaymentHistoryScreen({super.key});

  @override
  State<FisioterapisPaymentHistoryScreen> createState() =>
      _FisioterapisPaymentHistoryScreenState();
}

class _FisioterapisPaymentHistoryScreenState
    extends State<FisioterapisPaymentHistoryScreen> {
  late List<PaymentHistoryItem> paymentHistory = [
    PaymentHistoryItem(
      patientName: 'Budi Santoso',
      patientRole: 'Tamu Umum',
      dateTime: DateTime(2026, 5, 24, 10, 00),
      description: 'Pembayaran',
      amount: 225000,
    ),
    PaymentHistoryItem(
      patientName: 'Dwi Yana Putri',
      patientRole: 'Tamu Langganan',
      dateTime: DateTime(2026, 5, 23, 14, 00),
      description: 'Pembayaran',
      amount: 234000,
    ),
    PaymentHistoryItem(
      patientName: 'Putri Amelia',
      patientRole: 'Tamu Langganan',
      dateTime: DateTime(2026, 5, 24, 10, 00),
      description: 'Pembayaran Berhasil',
      amount: 247000,
    ),
    PaymentHistoryItem(
      patientName: 'Audi Wijaya',
      patientRole: 'Tamu Domisili',
      dateTime: DateTime(2026, 5, 25, 11, 00),
      description: 'Pembayaran Berhasil',
      amount: 212000,
    ),
  ];

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
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        itemCount: paymentHistory.length,
        itemBuilder: (context, index) =>
            _buildPaymentCard(paymentHistory[index], index),
      ),
    );
  }

  Widget _buildPaymentCard(PaymentHistoryItem item, int index) {
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
          // Patient info row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF00BBA7).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    item.patientName[0],
                    style: GoogleFonts.inter(
                      fontSize: 16,
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
                      item.patientRole,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Date and time
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: const Color(0xFF718096),
              ),
              const SizedBox(width: 6),
              Text(
                DateFormat('yyyy-MM-dd').format(item.dateTime),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF718096),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.access_time_outlined,
                size: 14,
                color: const Color(0xFF718096),
              ),
              const SizedBox(width: 6),
              Text(
                DateFormat('HH:mm').format(item.dateTime),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF718096),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Description
          Text(
            item.description,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 10),
          // Amount
          Text(
            'Rp ${NumberFormat('#,##0', 'id_ID').format(item.amount)}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}
