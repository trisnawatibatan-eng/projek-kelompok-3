import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../widgets/fisioterapis_bottom_navbar.dart';
import 'fisioterapis_home_tab.dart';
import 'fisioterapis_pasien_tab.dart';
import 'fisioterapis_profil_tab.dart';
import 'fisioterapis_jadwal_praktik.dart';

class FisioterapisDashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? profilCache; // ✅ terima cache dari luar
  const FisioterapisDashboardScreen({super.key, this.profilCache});

  @override
  State<FisioterapisDashboardScreen> createState() =>
      _FisioterapisDashboardScreenState();
}

class _FisioterapisDashboardScreenState
    extends State<FisioterapisDashboardScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _profilFisioterapis;

  @override
  void initState() {
    super.initState();
    // ✅ Pakai cache jika ada, fetch hanya jika belum punya data
    if (widget.profilCache != null) {
      _profilFisioterapis = widget.profilCache;
    } else {
      _loadProfil();
    }
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
    }
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        // Sudah di Dashboard
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const JadwalPraktikScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => FisioterapisPasienTab(
              profil: _profilFisioterapis,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => FisioterapisProfilTab(
              profil: _profilFisioterapis,
              onProfilUpdated: _loadProfil,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: FisioterapisHomeTab(profil: _profilFisioterapis),
      bottomNavigationBar: FisioterapisBottomNavbar(
        currentIndex: 0,
        onTap: _onNavTap,
      ),
    );
  }
}