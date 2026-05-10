import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../widgets/fisioterapis_bottom_navbar.dart';
import 'fisioterapis_home_tab.dart';
import 'fisioterapis_pasien_tab.dart';
import 'fisioterapis_profil_tab.dart';
import 'fisioterapis_jadwal_praktik.dart';

class FisioterapisDashboardScreen extends StatefulWidget {
  const FisioterapisDashboardScreen({super.key});

  @override
  State<FisioterapisDashboardScreen> createState() =>
      _FisioterapisDashboardScreenState();
}

class _FisioterapisDashboardScreenState
    extends State<FisioterapisDashboardScreen> {
  final _supabase = Supabase.instance.client;

  // 0=Dashboard, 1=Pasien, 2=Profil
  // Jadwal (navbar index 1) → Navigator.push, tidak masuk pages[]
  int _currentIndex = 0;
  Map<String, dynamic>? _profilFisioterapis;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('fisioterapis')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (mounted) setState(() => _profilFisioterapis = data);
    } catch (e) {
      // Tetap lanjut meski gagal load profil
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // Navbar 4 item: Dashboard(0), Jadwal(1), Pasien(2), Profil(3)
    // pages[] hanya 3: Jadwal ditangani Navigator.push
    final List<Widget> pages = [
      FisioterapisHomeTab(profil: _profilFisioterapis),
      FisioterapisPasienTab(profil: _profilFisioterapis),
      FisioterapisProfilTab(
        profil: _profilFisioterapis,
        onProfilUpdated: _loadProfil,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: pages[_currentIndex],
      bottomNavigationBar: FisioterapisBottomNavbar(
        currentIndex: _navbarIndex,
        onTap: (index) {
          if (index == 1) {
            // Jadwal → halaman terpisah
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const JadwalPraktikScreen(),
              ),
            );
          } else {
            // Remap navbar index ke pages index:
            // navbar 0 → pages[0] (Dashboard)
            // navbar 2 → pages[1] (Pasien)
            // navbar 3 → pages[2] (Profil)
            final pageIndex = index < 1 ? index : index - 1;
            setState(() => _currentIndex = pageIndex);
          }
        },
      ),
    );
  }

  // Konversi pages index balik ke navbar index untuk highlight yang benar
  int get _navbarIndex {
    if (_currentIndex == 0) return 0;
    return _currentIndex + 1; // pages[1]=Pasien→navbar 2, pages[2]=Profil→navbar 3
  }
}