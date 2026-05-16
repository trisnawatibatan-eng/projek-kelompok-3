import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/edukasi_service.dart';
import '../theme.dart';
import 'fisioterapis_tambah_edukasi.dart';

class FisioterapisKelolaEdukasiScreen extends StatefulWidget {
  const FisioterapisKelolaEdukasiScreen({super.key});

  @override
  State<FisioterapisKelolaEdukasiScreen> createState() =>
      _FisioterapisKelolaEdukasiScreenState();
}

class _FisioterapisKelolaEdukasiScreenState
    extends State<FisioterapisKelolaEdukasiScreen> {
  final EdukasiService _service = EdukasiService();
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _edukasiList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadEdukasi();
  }

  Future<void> _loadEdukasi() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      final data = await _service.fetchEdukasiMilikSaya();
      setState(() {
        _edukasiList = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat edukasi: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteEdukasi(String id) async {
    try {
      // Tampilkan dialog konfirmasi
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Hapus Edukasi', style: GoogleFonts.inter()),
          content: Text('Apakah Anda yakin ingin menghapus edukasi ini?',
              style: GoogleFonts.inter()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal', style: GoogleFonts.inter()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Hapus',
                  style: GoogleFonts.inter(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Hapus dari database
        await _supabase.from('edukasi').delete().eq('id', id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Edukasi berhasil dihapus',
                  style: GoogleFonts.inter(color: Colors.white)),
              backgroundColor: AppColors.primary,
            ),
          );
          _loadEdukasi();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: ${e.toString()}',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getKategoriColor(String? kategori) {
    const Map<String, Color> colors = {
      'Stroke': Color(0xFF3B82F6),
      'Nyeri Punggung': Color(0xFF10B981),
      'Nutrisi': Color(0xFFF59E0B),
      'Cedera Olahraga': Color(0xFF8B5CF6),
      'Mental': Color(0xFFF87171),
      'Latihan': Color(0xFF06B6D4),
      'Neurologi': Color(0xFFEC4899),
      'Geriatri': Color(0xFF14B8A6),
      'Pediatri': Color(0xFFF97316),
    };
    return colors[kategori] ?? AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red.shade300),
                            const SizedBox(height: 16),
                            Text(_errorMessage,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.secondaryText,
                                ),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadEdukasi,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              child: Text('Coba Lagi',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ],
                        ),
                      )
                    : _edukasiList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.article_outlined,
                                    size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text('Belum ada edukasi',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondaryText,
                                    )),
                                const SizedBox(height: 8),
                                Text(
                                  'Buat edukasi baru untuk memulai',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.lightText,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadEdukasi,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 24),
                              itemCount: _edukasiList.length,
                              itemBuilder: (context, index) {
                                final edukasi = _edukasiList[index];
                                return _buildEdukasiCard(edukasi);
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FisioterapisTambahEdukasiScreen(),
            ),
          );
          if (result == true) {
            _loadEdukasi();
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Tambah Edukasi',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 18, color: AppColors.primaryText),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Kelola Edukasi',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${_edukasiList.length}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEdukasiCard(Map<String, dynamic> edukasi) {
    final id = edukasi['id'] as String;
    final judul = edukasi['judul'] as String? ?? 'Tanpa Judul';
    final kategori = edukasi['kategori'] as String?;
    final isPublished = edukasi['is_published'] as bool? ?? false;
    final thumbnailUrl = edukasi['thumbnail_url'] as String?;
    final createdAt = edukasi['created_at'] as String?;

    // Parse tanggal
    String formattedDate = '-';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        formattedDate =
            '${date.day} ${_getMonthName(date.month)} ${date.year}';
      } catch (e) {
        // ignore
      }
    }

    final kategoriColor = _getKategoriColor(kategori);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Thumbnail
          if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Image.network(
                thumbnailUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported,
                      size: 40, color: Colors.grey),
                ),
              ),
            ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPublished
                            ? const Color(0xFFD1FAE5)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPublished ? 'Published' : 'Draft',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isPublished
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (kategori != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kategoriColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          kategori,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: kategoriColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Judul
                Text(
                  judul,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Tanggal & Actions
                Row(
                  children: [
                    Text(
                      formattedDate,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.lightText,
                      ),
                    ),
                    const Spacer(),
                    // Edit button
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Edit fitur akan segera hadir',
                                style: GoogleFonts.inter()),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Edit',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete button
                    GestureDetector(
                      onTap: () => _deleteEdukasi(id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Hapus',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[month - 1];
  }
}
