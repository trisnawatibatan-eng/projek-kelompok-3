// lib/screens/fisioterapis_tambah_edukasi_screen.dart
//
// Letakkan file ini di: lib/screens/fisioterapis_tambah_edukasi_screen.dart
// Dependency: edukasi_service.dart, theme.dart
//
// TAMBAHKAN dependency berikut di pubspec.yaml jika belum ada:
//   file_picker: ^8.0.0+1
//   image_picker: ^1.1.2

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../services/edukasi_service.dart';
import '../theme.dart';

class FisioterapisTambahEdukasiScreen extends StatefulWidget {
  const FisioterapisTambahEdukasiScreen({super.key});

  @override
  State<FisioterapisTambahEdukasiScreen> createState() =>
      _FisioterapisTambahEdukasiScreenState();
}

class _FisioterapisTambahEdukasiScreenState
    extends State<FisioterapisTambahEdukasiScreen> {
  // --------------------------------------------------
  // Controllers & state
  // --------------------------------------------------
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _kontenController = TextEditingController();

  String _selectedKategori = 'Nyeri Punggung';
  String _selectedFormat = 'B';
  bool _isSubmitting = false;

  // File yang dipilih user
  File? _thumbnailFile;
  Uint8List? _thumbnailBytes; // Untuk web platform
  File? _lampiranFile;
  String? _lampiranNama;
  int? _lampiranUkuranBytes;

  final EdukasiService _service = EdukasiService();
  final ImagePicker _imagePicker = ImagePicker();

  // --------------------------------------------------
  // Data statis
  // --------------------------------------------------
  final List<String> _kategoriList = [
    'Stroke',
    'Nyeri Punggung',
    'Nutrisi',
    'Cedera Olahraga',
    'Mental',
    'Latihan',
    'Neurologi',
    'Geriatri',
    'Pediatri',
  ];

  final List<String> _formatList = [
    'B', 'I', 'U', 'H1', 'H2', '• List', '1. List',
  ];

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _kontenController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // ACTIONS
  // --------------------------------------------------

  /// Pilih thumbnail dari galeri / kamera
  Future<void> _pilihThumbnail() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('Pilih dari Galeri',
                  style: GoogleFonts.inter(fontSize: 14)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title:
                  Text('Ambil Foto', style: GoogleFonts.inter(fontSize: 14)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (picked != null) {
      if (kIsWeb) {
        // Di web, baca bytes dari file
        final bytes = await picked.readAsBytes();
        setState(() {
          _thumbnailBytes = bytes;
          _thumbnailFile = null;
        });
      } else {
        // Di platform native, gunakan path
        setState(() {
          _thumbnailFile = File(picked.path);
          _thumbnailBytes = null;
        });
      }
    }
  }

  /// Pilih lampiran PDF/dokumen
  Future<void> _pilihLampiran() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final ukuran = await file.length();
      setState(() {
        _lampiranFile = file;
        _lampiranNama = result.files.single.name;
        _lampiranUkuranBytes = ukuran;
      });
    }
  }

  /// Hapus lampiran yang sudah dipilih
  void _hapusLampiran() {
    setState(() {
      _lampiranFile = null;
      _lampiranNama = null;
      _lampiranUkuranBytes = null;
    });
  }

  /// Format bytes ke string yang mudah dibaca
  String _formatUkuran(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Validasi dan publikasikan ke Supabase
  Future<void> _publikasikanEdukasi() async {
    // Validasi wajib
    if (_judulController.text.trim().isEmpty ||
        _deskripsiController.text.trim().isEmpty ||
        _kontenController.text.trim().isEmpty) {
      _showSnackbar(
        'Judul, deskripsi, dan konten utama wajib diisi',
        isError: true,
      );
      return;
    }

    if (_thumbnailFile == null && _thumbnailBytes == null) {
      _showSnackbar('Thumbnail wajib diunggah', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Upload thumbnail
      final thumbnailUrl = kIsWeb && _thumbnailBytes != null
          ? await _service.uploadThumbnail(_thumbnailBytes!, filename: 'thumbnail.jpg')
          : await _service.uploadThumbnail(_thumbnailFile!);

      // 2. Upload lampiran (jika ada)
      String? lampiranUrl;
      String? lampiranNama;
      int? lampiranUkuran;
      String? lampiranTipe;

      if (_lampiranFile != null) {
        final lampiranData = await _service.uploadLampiran(_lampiranFile!);
        lampiranUrl = lampiranData['url'] as String;
        lampiranNama = lampiranData['nama'] as String;
        lampiranUkuran = lampiranData['ukuran_bytes'] as int;
        lampiranTipe = lampiranData['tipe'] as String;
      }

      // 3. Simpan ke database
      await _service.publikasikanEdukasi(
        judul: _judulController.text.trim(),
        deskripsiSingkat: _deskripsiController.text.trim(),
        kontenUtama: _kontenController.text.trim(),
        kategori: _selectedKategori,
        thumbnailUrl: thumbnailUrl,
        lampiranUrl: lampiranUrl,
        lampiranNama: lampiranNama,
        lampiranUkuranBytes: lampiranUkuran,
        lampiranTipe: lampiranTipe,
      );

      if (!mounted) return;
      _showSnackbar('Edukasi berhasil dipublikasikan');
      Navigator.pop(context, true); // return true agar parent bisa refresh
    } catch (e) {
      if (!mounted) return;
      _showSnackbar(
        'Gagal mempublikasikan: ${e.toString()}',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: isError ? Colors.redAccent : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Column(
                children: [
                  _buildUploadCard(),
                  const SizedBox(height: 14),
                  _buildInformasiKonten(),
                  const SizedBox(height: 14),
                  _buildKategoriCard(),
                  const SizedBox(height: 14),
                  _buildKontenUtamaCard(),
                  const SizedBox(height: 14),
                  _buildLampiranCard(),
                  const SizedBox(height: 22),
                  _buildPublikasiButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // WIDGET BUILDERS
  // --------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00BBA7), Color(0xFF009689)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Edukasi',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Kelola materi edukasi fisioterapi Anda',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard() {
    return _buildCard(
      title: 'THUMBNAIL KONTEN',
      child: GestureDetector(
        onTap: _isSubmitting ? null : _pilihThumbnail,
        child: Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFEFFFFD),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.7),
              width: 1.3,
            ),
          ),
          // Tampilkan preview jika sudah pilih gambar
          child: _thumbnailFile != null || _thumbnailBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      kIsWeb && _thumbnailBytes != null
                          ? Image.memory(_thumbnailBytes!, fit: BoxFit.cover)
                          : Image.file(_thumbnailFile!, fit: BoxFit.cover),
                      // Overlay untuk edit
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.edit,
                                  color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                'Ganti',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Wajib',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(Icons.image_outlined,
                        color: AppColors.primary, size: 30),
                    const SizedBox(height: 6),
                    Text(
                      'Upload Gambar',
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PNG, JPG - Maks. 5MB',
                      style: GoogleFonts.inter(
                        color: AppColors.lightText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInformasiKonten() {
    return _buildCard(
      title: 'INFORMASI KONTEN',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Judul Edukasi'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _judulController,
            hintText: 'Masukkan judul edukasi',
          ),
          const SizedBox(height: 12),
          _buildLabel('Deskripsi Singkat'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _deskripsiController,
            hintText: 'Tulis deskripsi singkat',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildKategoriCard() {
    return _buildCard(
      title: 'KATEGORI',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _kategoriList.map((kategori) {
          final isSelected = _selectedKategori == kategori;
          return GestureDetector(
            onTap: () => setState(() => _selectedKategori = kategori),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                kategori,
                style: GoogleFonts.inter(
                  color:
                      isSelected ? Colors.white : AppColors.secondaryText,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKontenUtamaCard() {
    return _buildCard(
      title: 'KONTEN UTAMA',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _formatList.map((format) {
              final isSelected = _selectedFormat == format;
              return GestureDetector(
                onTap: () => setState(() => _selectedFormat = format),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    format,
                    style: GoogleFonts.inter(
                      color: isSelected
                          ? Colors.white
                          : AppColors.secondaryText,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _kontenController,
            hintText: 'Tulis isi edukasi...',
            maxLines: 10,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_kontenController.text.length} karakter',
              style: GoogleFonts.inter(
                color: AppColors.lightText,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLampiranCard() {
    return _buildCard(
      title: 'LAMPIRAN & MEDIA',
      child: Column(
        children: [
          // Tombol upload lampiran
          GestureDetector(
            onTap: _isSubmitting ? null : _pilihLampiran,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Icon(Icons.attach_file,
                      color: AppColors.secondaryText, size: 18),
                  const SizedBox(height: 4),
                  Text(
                    'PDF / Dokumen',
                    style: GoogleFonts.inter(
                      color: AppColors.secondaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Preview lampiran yang sudah dipilih
          if (_lampiranFile != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_lampiranNama ?? 'file'}\n'
                      '${_lampiranUkuranBytes != null ? _formatUkuran(_lampiranUkuranBytes!) : ''} • PDF',
                      style: GoogleFonts.inter(
                        color: AppColors.primaryText,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _hapusLampiran,
                    child: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPublikasiButton() {
    return SizedBox(
      width: 180,
      height: 46,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _publikasikanEdukasi,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          elevation: 6,
          shadowColor: AppColors.primary.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Publikasikan',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  // --------------------------------------------------
  // SHARED WIDGET HELPERS
  // --------------------------------------------------

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: AppColors.lightText,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: AppColors.secondaryText,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: !_isSubmitting,
      onChanged: (_) => setState(() {}),
      style: GoogleFonts.inter(
        color: AppColors.primaryText,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(
          color: AppColors.lightText,
          fontSize: 11,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}