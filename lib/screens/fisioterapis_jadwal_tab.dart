import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class FisioterapisJadwalTab extends StatelessWidget {
  final Map<String, dynamic>? profil;
  const FisioterapisJadwalTab({super.key, this.profil});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Jadwal',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Jadwal sesi akan ditampilkan di sini'),
      ),
    );
  }
}