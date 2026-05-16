// lib/screens/edukasi_screen.dart
//
// Letakkan file ini di: lib/screens/edukasi_screen.dart
// Dependency: edukasi_service.dart, detail_artikel_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/edukasi_service.dart';
import 'detail_artikel_screen.dart';

// --------------------------------------------------
// HELPER: Mapping kategori → icon & warna
// --------------------------------------------------
IconData _iconForKategori(String? kategori) {
  switch (kategori) {
    case 'Nyeri Punggung':
      return Icons.accessibility_new;
    case 'Nutrisi':
      return Icons.restaurant;
    case 'Latihan':
      return Icons.fitness_center;
    case 'Mental':
      return Icons.psychology;
    case 'Cedera Olahraga':
      return Icons.sports;
    case 'Stroke':
      return Icons.monitor_heart;
    case 'Neurologi':
      return Icons.biotech;
    case 'Geriatri':
      return Icons.elderly;
    case 'Pediatri':
      return Icons.child_care;
    default:
      return Icons.article_outlined;
  }
}

Color _colorForKategori(String? kategori) {
  switch (kategori) {
    case 'Nutrisi':
      return Colors.orange;
    case 'Latihan':
      return Colors.blue;
    case 'Mental':
      return Colors.purple;
    case 'Stroke':
      return Colors.red;
    case 'Neurologi':
      return Colors.indigo;
    case 'Geriatri':
      return Colors.brown;
    case 'Pediatri':
      return Colors.pink;
    case 'Cedera Olahraga':
      return Colors.deepOrange;
    case 'Nyeri Punggung':
    default:
      return Colors.teal;
  }
}

// --------------------------------------------------
// Helper: format ukuran file
// --------------------------------------------------
String _formatTanggal(String? isoString) {
  if (isoString == null) return '';
  final dt = DateTime.tryParse(isoString);
  if (dt == null) return '';
  const bulan = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  return '${dt.day} ${bulan[dt.month]} ${dt.year}';
}

// --------------------------------------------------
// SCREEN
// --------------------------------------------------
class EdukasiScreen extends StatefulWidget {
  const EdukasiScreen({super.key});

  @override
  State<EdukasiScreen> createState() => _EdukasiScreenState();
}

class _EdukasiScreenState extends State<EdukasiScreen> {
  final EdukasiService _service = EdukasiService();

  List<Map<String, dynamic>> _unggulan = [];
  List<Map<String, dynamic>> _semuaEdukasi = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.fetchArtikelUnggulan(),
        _service.fetchEdukasiPublished(),
      ]);
      if (!mounted) return;
      setState(() {
        _unggulan = results[0];
        _semuaEdukasi = results[1];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data. Periksa koneksi internet Anda.';
        _isLoading = false;
      });
    }
  }

  void _navigateToDetail(Map<String, dynamic> data) {
    final kategori = data['kategori'] as String?;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailArtikelScreen(
          title: data['judul'] as String? ?? '',
          tag: kategori ?? '',
          icon: _iconForKategori(kategori),
          color: _colorForKategori(kategori),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00BBA7)),
                  )
                : _error != null
                    ? _buildErrorState()
                    : RefreshIndicator(
                        color: const Color(0xFF00BBA7),
                        onRefresh: _loadData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ---- Artikel Unggulan ----
                              Text(
                                'Artikel Unggulan',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              if (_unggulan.isEmpty)
                                _buildEmptyPlaceholder('Belum ada artikel unggulan')
                              else
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: _unggulan
                                        .map((e) => _buildFeaturedCard(e))
                                        .toList(),
                                  ),
                                ),

                              const SizedBox(height: 30),

                              // ---- Semua Edukasi ----
                              Text(
                                'Edukasi',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              if (_semuaEdukasi.isEmpty)
                                _buildEmptyPlaceholder('Belum ada konten edukasi')
                              else
                                ..._semuaEdukasi
                                    .map((e) => _buildEdukasiItem(e))
                                    .toList(),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // WIDGETS
  // --------------------------------------------------

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 50, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF00BBA7),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Edukasi',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.grey, size: 56),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BBA7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic> data) {
    final kategori = data['kategori'] as String?;
    final color = _colorForKategori(kategori);
    final icon = _iconForKategori(kategori);
    final thumbnailUrl = data['thumbnail_url'] as String?;

    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 15),
      child: InkWell(
        onTap: () => _navigateToDetail(data),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail / fallback icon
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: thumbnailUrl != null
                    ? Image.network(
                        thumbnailUrl,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildIconPlaceholder(
                          color: color,
                          icon: icon,
                          height: 110,
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return _buildIconPlaceholder(
                            color: color,
                            icon: icon,
                            height: 110,
                          );
                        },
                      )
                    : _buildIconPlaceholder(
                        color: color,
                        icon: icon,
                        height: 110,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag kategori
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        kategori ?? '-',
                        style: GoogleFonts.inter(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['judul'] as String? ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEdukasiItem(Map<String, dynamic> data) {
    final kategori = data['kategori'] as String?;
    final color = _colorForKategori(kategori);
    final icon = _iconForKategori(kategori);
    final tanggal = _formatTanggal(data['created_at'] as String?);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () => _navigateToDetail(data),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon / thumbnail kecil
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: data['thumbnail_url'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          data['thumbnail_url'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Icon(icon, color: color, size: 28),
                        ),
                      )
                    : Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 15),
              // Info teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kategori ?? '-',
                      style: GoogleFonts.inter(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data['judul'] as String? ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          tanggal,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconPlaceholder({
    required Color color,
    required IconData icon,
    required double height,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      color: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 45),
    );
  }
}