import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/fisioterapis_bottom_navbar.dart';

class FisioterapisJadwalTab extends StatefulWidget {
  final Map<String, dynamic>? profil;
  const FisioterapisJadwalTab({super.key, this.profil});

  @override
  State<FisioterapisJadwalTab> createState() => _FisioterapisJadwalTabState();
}

class _FisioterapisJadwalTabState extends State<FisioterapisJadwalTab> {
  int _currentIndex = 1;

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/fisioterapis/dashboard');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/fisioterapis/pasien');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/fisioterapis/profil');
        break;
    }
  }

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
      bottomNavigationBar: FisioterapisBottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}