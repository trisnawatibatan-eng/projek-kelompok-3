import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/fisioterapis_bottom_navbar.dart';
import 'fisioterapis_dashboard_screen.dart';
import 'fisioterapis_jadwal_praktik.dart';
import 'fisioterapis_profil_tab.dart';

class FisioterapisPasienTab extends StatefulWidget {
  final Map<String, dynamic>? profil;
  const FisioterapisPasienTab({super.key, this.profil});

  @override
  State<FisioterapisPasienTab> createState() => _FisioterapisPasienTabState();
}

class _FisioterapisPasienTabState extends State<FisioterapisPasienTab> {
  // ✅ Navbar index untuk tab Pasien = 2
  final int _currentNavIndex = 2;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _pasienList = [
    {
      'nama': 'Budi Santoso',
      'inisial': 'AR',
      'usia': 28,
      'jenisKelamin': 'Laki-laki',
      'layanan': 'Terapi Cedera Olahraga',
      'telepon': '+62 814 5678 9012',
      'alamat': 'Jl. Gatot Subroto No. 78, Jakarta Selatan',
      'terapiBerikutnya': '30/03/2026',
    },
    {
      'nama': 'Andi Wijaya',
      'inisial': 'AW',
      'usia': 35,
      'jenisKelamin': 'Laki-laki',
      'layanan': 'Terapi Pasca Operasi',
      'telepon': '+62 816 7890 1234',
      'alamat': 'Jl. Thamrin No. 12, Jakarta Pusat',
      'terapiBerikutnya': '30/03/2026',
    },
    {
      'nama': 'Siti Aminah',
      'inisial': 'SA',
      'usia': 42,
      'jenisKelamin': 'Perempuan',
      'layanan': 'Terapi Nyeri Punggung',
      'telepon': '+62 813 4567 8901',
      'alamat': 'Jl. Sudirman No. 45, Jakarta Pusat',
      'terapiBerikutnya': '31/03/2026',
    },
    {
      'nama': 'Rina Kusuma',
      'inisial': 'RK',
      'usia': 55,
      'jenisKelamin': 'Perempuan',
      'layanan': 'Terapi Stroke',
      'telepon': '+62 812 3456 7890',
      'alamat': 'Jl. Merdeka No. 5, Jakarta Barat',
      'terapiBerikutnya': '01/04/2026',
    },
    {
      'nama': 'Hendra Gunawan',
      'inisial': 'HG',
      'usia': 30,
      'jenisKelamin': 'Laki-laki',
      'layanan': 'Terapi Cedera Olahraga',
      'telepon': '+62 817 8901 2345',
      'alamat': 'Jl. Kebon Jeruk No. 22, Jakarta Barat',
      'terapiBerikutnya': '02/04/2026',
    },
    {
      'nama': 'Dewi Lestari',
      'inisial': 'DL',
      'usia': 48,
      'jenisKelamin': 'Perempuan',
      'layanan': 'Terapi Sendi Lutut',
      'telepon': '+62 819 0123 4567',
      'alamat': 'Jl. Mangga Dua No. 10, Jakarta Utara',
      'terapiBerikutnya': '03/04/2026',
    },
    {
      'nama': 'Agus Prasetyo',
      'inisial': 'AP',
      'usia': 60,
      'jenisKelamin': 'Laki-laki',
      'layanan': 'Terapi Parkinson',
      'telepon': '+62 821 2345 6789',
      'alamat': 'Jl. Raya Bogor No. 88, Jakarta Timur',
      'terapiBerikutnya': '04/04/2026',
    },
    {
      'nama': 'Maya Indah',
      'inisial': 'MI',
      'usia': 25,
      'jenisKelamin': 'Perempuan',
      'layanan': 'Terapi Postur Tubuh',
      'telepon': '+62 822 3456 7890',
      'alamat': 'Jl. Cipete Raya No. 33, Jakarta Selatan',
      'terapiBerikutnya': '05/04/2026',
    },
    {
      'nama': 'Bambang Susilo',
      'inisial': 'BS',
      'usia': 50,
      'jenisKelamin': 'Laki-laki',
      'layanan': 'Terapi Nyeri Leher',
      'telepon': '+62 823 4567 8901',
      'alamat': 'Jl. Fatmawati No. 15, Jakarta Selatan',
      'terapiBerikutnya': '06/04/2026',
    },
  ];

  List<Map<String, dynamic>> get _filteredList {
    if (_searchQuery.isEmpty) return _pasienList;
    final q = _searchQuery.toLowerCase();
    return _pasienList.where((p) {
      return p['nama'].toString().toLowerCase().contains(q) ||
          p['layanan'].toString().toLowerCase().contains(q) ||
          p['telepon'].toString().toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _avatarColor(String inisial) {
    const colors = [
      Color(0xFF00BBA7),
      Color(0xFF6366F1),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF10B981),
      Color(0xFF3B82F6),
    ];
    final index = inisial.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  // ✅ Handler navigasi navbar — sama polanya dengan JadwalPraktikScreen
  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;

    Widget targetScreen;
    switch (index) {
      case 0:
        targetScreen = const FisioterapisDashboardScreen();
        break;
      case 1:
        targetScreen = const JadwalPraktikScreen();
        break;
      case 2:
        targetScreen = const FisioterapisPasienTab(); // halaman ini sendiri
        break;
      case 3:
        targetScreen = const FisioterapisProfilTab();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredList;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,

      // ✅ Bottom navbar terhubung
      bottomNavigationBar: FisioterapisBottomNavbar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // hapus tombol back karena ada navbar
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Pasien',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              '${_pasienList.length} pasien terdaftar',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.inter(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Cari nama, layanan, atau nomor telepon...',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.lightText),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.lightText, size: 20),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // List Pasien
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'Pasien tidak ditemukan',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.lightText),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final pasien = filtered[index];
                      return _PasienCard(
                        pasien: pasien,
                        avatarColor: _avatarColor(pasien['inisial']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PasienCard extends StatelessWidget {
  final Map<String, dynamic> pasien;
  final Color avatarColor;

  const _PasienCard({required this.pasien, required this.avatarColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      pasien['inisial'],
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
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
                        pasien['nama'],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${pasien['usia']} tahun • ${pasien['jenisKelamin']}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    size: 18,
                    color: AppColors.lightText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.monitor_heart_outlined, text: pasien['layanan']),
            const SizedBox(height: 6),
            _InfoRow(icon: Icons.phone_outlined, text: pasien['telepon']),
            const SizedBox(height: 6),
            _InfoRow(icon: Icons.location_on_outlined, text: pasien['alamat']),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE6FAF8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFB2EDE7)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Terapi Berikutnya : ',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.primary),
                  ),
                  Text(
                    pasien['terapiBerikutnya'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.lightText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
                fontSize: 12, color: AppColors.secondaryText),
          ),
        ),
      ],
    );
  }
}