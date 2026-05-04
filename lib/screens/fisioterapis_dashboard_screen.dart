import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/fisioterapis_bottom_navbar.dart';
import 'fisioterapis_home_tab.dart';
import 'fisioterapis_pasien_tab.dart';
import 'fisioterapis_pendapatan_tab.dart';
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
    const FisioterapisPasienTab(),
    const FisioterapisPendapatanTab(),
    const FisioterapisProfilTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: _pages[_currentIndex],
      bottomNavigationBar: FisioterapisBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}