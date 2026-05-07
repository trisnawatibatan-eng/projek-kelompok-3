import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../widgets/fisioterapis_bottom_navbar.dart';
import 'fisioterapis_home_tab.dart';
import 'fisioterapis_jadwal_tab.dart';
import 'fisioterapis_pasien_tab.dart';
import 'fisioterapis_profil_tab.dart';
import 'jadwal_praktik.dart';

class FisioterapisDashboardScreen extends StatefulWidget {
  const FisioterapisDashboardScreen({super.key});

  @override
  State<FisioterapisDashboardScreen> createState() =>
      _FisioterapisDashboardScreenState();
}

class _FisioterapisDashboardScreenState
    extends State<FisioterapisDashboardScreen> {
  final _supabase = Supabase.instance.client;

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

    // Urutan: Dashboard (0), Jadwal (1), Pasien (2), Profil (3)
    final List<Widget> pages = [
      FisioterapisHomeTab(profil: _profilFisioterapis),
      FisioterapisJadwalTab(profil: _profilFisioterapis),
      FisioterapisPasienTab(profil: _profilFisioterapis),
      FisioterapisProfilTab(profil: _profilFisioterapis, onProfilUpdated: _loadProfil),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: pages[_currentIndex],
      bottomNavigationBar: FisioterapisBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            // Navigate ke jadwal_praktik.dart ketika klik jadwal
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const JadwalPraktikScreen()),
            );
          } else {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }
}