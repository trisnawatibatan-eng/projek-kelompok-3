import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'fisioterapis_home_tab.dart';
import 'fisioterapis_jadwal_tab.dart';
import 'fisioterapis_pasien_tab.dart';
import 'fisioterapis_profil_tab.dart';

class FisioterapisDashboardScreen extends StatefulWidget {
  const FisioterapisDashboardScreen({super.key});

  @override
  State<FisioterapisDashboardScreen> createState() =>
      _FisioterapisDashboardScreenState();
}

class _FisioterapisDashboardScreenState
    extends State<FisioterapisDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const FisioterapisHomeTab(),
    const FisioterapisJadwalTab(),
    const FisioterapisPasienTab(),
    const FisioterapisProfilTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 65,
          child: Row(
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Beranda'),
              _buildNavItem(
                  1, Icons.calendar_today_outlined, Icons.calendar_today, 'Jadwal'),
              _buildNavItem(2, Icons.people_outline, Icons.people, 'Pasien'),
              _buildNavItem(3, Icons.person_outline, Icons.person, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : const Color(0xFF62748E),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isActive ? AppColors.primary : const Color(0xFF62748E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}