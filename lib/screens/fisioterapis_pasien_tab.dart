import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/booking_request_model.dart';
import '../screens/laporan_fisioterapis_screen.dart';
import '../theme.dart';

class FisioterapisPasienTab extends StatelessWidget {
  final Map<String, dynamic>? profil;
  const FisioterapisPasienTab({super.key, this.profil});

  List<BookingRequest> get _patientBookings {
    final map = <String, BookingRequest>{};
    for (final request in BookingRequestRepository.requests) {
      map[request.patientName] = request;
    }
    return map.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final patients = _patientBookings;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Daftar Pasien',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: patients.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Belum ada pasien yang memesan layanan saat ini.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final request = patients[index];
                final statusLabel = request.status == BookingRequestStatus.waiting
                    ? 'Menunggu'
                    : request.status == BookingRequestStatus.accepted
                        ? 'Diterima'
                        : 'Ditolak';
                final statusColor = request.status == BookingRequestStatus.waiting
                    ? const Color(0xFFF59E0B)
                    : request.status == BookingRequestStatus.accepted
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LaporanFisioterapisScreen(request: request),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFDDD6FE), Color(0xFFB2EDE7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Text('👤', style: TextStyle(fontSize: 24)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.patientName,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${request.therapy} • ${request.date} • ${request.time}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.lightText,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}