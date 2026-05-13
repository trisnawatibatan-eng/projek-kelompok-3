import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ← untuk inputFormatters
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';

class FisioterapisEditProfilScreen extends StatefulWidget {
  const FisioterapisEditProfilScreen({super.key});

  @override
  State<FisioterapisEditProfilScreen> createState() =>
      _FisioterapisEditProfilScreenState();
}

class _FisioterapisEditProfilScreenState
    extends State<FisioterapisEditProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  // Controllers - Informasi Pribadi
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();

  // Controllers - Informasi Profesional
  final _strController = TextEditingController();
  final _pengalamanController = TextEditingController();
  final _pendidikanController = TextEditingController();
  final _biografiController = TextEditingController();
  final _sertifikasiController = TextEditingController(); // controller input tambah sertifikasi

  // ── Daftar sertifikasi (multi-item) ──────────────────────────
  final List<String> _sertifikasiList = [];

  // Files
  File? _fotoProfilFile;
  File? _fotoStrFile;
  File? _sertifikatFile;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _strController.dispose();
    _pengalamanController.dispose();
    _pendidikanController.dispose();
    _biografiController.dispose();
    _sertifikasiController.dispose();
    super.dispose();
  }

  Future<void> _loadProfil() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('fisioterapis')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) return;

      if (mounted) {
        _namaController.text = data['nama_lengkap'] ?? '';
        _emailController.text = data['email'] ?? '';
        _teleponController.text = data['nomor_telepon'] ?? '';
        _alamatController.text = data['alamat'] ?? '';
        _strController.text = data['nomor_str_sipa'] ?? '';
        _pengalamanController.text = data['pengalaman_kerja'] ?? '';
        _pendidikanController.text = data['pendidikan_terakhir'] ?? '';
        _biografiController.text = data['biografi'] ?? '';

        // ── Parse sertifikasi: tersimpan sebagai teks dipisah koma ──
        final raw = data['sertifikasi'] as String? ?? '';
        if (raw.isNotEmpty) {
          setState(() {
            _sertifikasiList.clear();
            _sertifikasiList.addAll(
              raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty),
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat profil: $e',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _uploadFile(File file, String bucket, String path) async {
    try {
      await _supabase.storage.from(bucket).upload(
            path,
            file,
            fileOptions: const FileOptions(upsert: true),
          );
      return _supabase.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }

  Future<void> _simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      String? fotoProfilUrl;
      String? fotoStrUrl;
      String? sertifikatUrl;

      if (_fotoProfilFile != null) {
        fotoProfilUrl = await _uploadFile(
          _fotoProfilFile!,
          'fisioterapis-assets',
          '$userId/foto_profil.jpg',
        );
      }
      if (_fotoStrFile != null) {
        fotoStrUrl = await _uploadFile(
          _fotoStrFile!,
          'fisioterapis-assets',
          '$userId/foto_str.jpg',
        );
      }
      if (_sertifikatFile != null) {
        sertifikatUrl = await _uploadFile(
          _sertifikatFile!,
          'fisioterapis-assets',
          '$userId/sertifikat.jpg',
        );
      }

      // Sertifikasi disimpan sebagai teks dipisah koma
      final sertifikasiValue = _sertifikasiList.join(', ');

      final payload = {
        'user_id': userId,
        'nama_lengkap': _namaController.text.trim(),
        'email': _emailController.text.trim(),
        'nomor_telepon': _teleponController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'nomor_str_sipa': _strController.text.trim(),
        'pengalaman_kerja': _pengalamanController.text.trim(),
        'pendidikan_terakhir': _pendidikanController.text.trim(),
        'biografi': _biografiController.text.trim(),
        'sertifikasi': sertifikasiValue,
        if (fotoProfilUrl != null) 'foto_profil_url': fotoProfilUrl,
        if (fotoStrUrl != null) 'foto_str_url': fotoStrUrl,
        if (sertifikatUrl != null) 'sertifikat_url': sertifikatUrl,
      };

      await _supabase
          .from('fisioterapis')
          .upsert(payload, onConflict: 'user_id');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil berhasil disimpan',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Tambah sertifikasi ke list ────────────────────────────────
  void _tambahSertifikasi() {
    final value = _sertifikasiController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _sertifikasiList.add(value);
      _sertifikasiController.clear();
    });
  }

  // ── Hapus sertifikasi dari list ───────────────────────────────
  void _hapusSertifikasi(int index) {
    setState(() => _sertifikasiList.removeAt(index));
  }

  Future<void> _pickFotoProfil() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _fotoProfilFile = File(picked.path));
  }

  Future<void> _pickFile(bool isStr) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        if (isStr) {
          _fotoStrFile = File(picked.path);
        } else {
          _sertifikatFile = File(picked.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 16),
                          _buildSection(
                            'Informasi Pribadi',
                            [
                              // ── Nama Lengkap: hanya huruf & spasi ──
                              _buildField(
                                icon: Icons.person_outline,
                                label: 'Nama Lengkap',
                                hint: 'Ftr. Siti Nurhaliza S.Tr.Kes',
                                controller: _namaController,
                                required: true,
                                inputFormatters: [
                                  // Blokir angka, hanya izinkan huruf, spasi, titik
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r"[a-zA-Z\s\.\,\'\-]"),
                                  ),
                                ],
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Nama Lengkap wajib diisi';
                                  }
                                  if (RegExp(r'[0-9]').hasMatch(val)) {
                                    return 'Nama tidak boleh mengandung angka';
                                  }
                                  return null;
                                },
                              ),
                              _buildField(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                hint: 'siti@email.com',
                                controller: _emailController,
                                required: true,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              // ── Nomor Telepon: hanya angka & + di awal ──
                              _buildField(
                                icon: Icons.phone_outlined,
                                label: 'Nomor Telepon',
                                hint: '+62 812 3456 7890',
                                controller: _teleponController,
                                required: true,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  // Izinkan angka, +, spasi, strip
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9\+\-\s]'),
                                  ),
                                ],
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Nomor Telepon wajib diisi';
                                  }
                                  final digitsOnly =
                                      val.replaceAll(RegExp(r'[^\d]'), '');
                                  if (digitsOnly.length < 8) {
                                    return 'Nomor telepon minimal 8 digit';
                                  }
                                  return null;
                                },
                              ),
                              _buildField(
                                icon: Icons.location_on_outlined,
                                label: 'Alamat',
                                hint: 'Jl. Danautoba VII Blok1 No.9, Jember',
                                controller: _alamatController,
                                required: true,
                                maxLines: 2,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSection(
                            'Informasi Profesional',
                            [
                              _buildField(
                                icon: Icons.badge_outlined,
                                label: 'Nomor STR/SIPA',
                                hint: '23456898765445678',
                                controller: _strController,
                                required: true,
                                subtitle:
                                    'Surat Tanda Registrasi/Surat Izin Praktik Apoteker',
                              ),
                              _buildField(
                                icon: Icons.work_outline,
                                label: 'Pengalaman Kerja',
                                hint: '12 tahun di rs raffa',
                                controller: _pengalamanController,
                                required: false,
                              ),
                              _buildField(
                                icon: Icons.school_outlined,
                                label: 'Pendidikan Terakhir',
                                hint: 'S1 Fisioterapi, Universitas Indonesia',
                                controller: _pendidikanController,
                                required: false,
                              ),
                              _buildTextAreaField(
                                label: 'Biografi',
                                hint:
                                    'Fisioterapis berpengalaman dengan spesialisasi neurologi dan rehabilitasi pasca...',
                                controller: _biografiController,
                              ),
                              // ── Sertifikasi multi-item ──
                              _buildSertifikasiMultiField(),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDokumenSection(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildSimpanButton(),
              ],
            ),
    );
  }

  // ── Widget sertifikasi multi-item ────────────────────────────

  Widget _buildSertifikasiMultiField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              const Icon(Icons.verified_outlined,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Sertifikasi',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Daftar sertifikasi yang sudah ditambahkan
          if (_sertifikasiList.isNotEmpty) ...[
            ..._sertifikasiList.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6FAF8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _hapusSertifikasi(index),
                      child: const Icon(Icons.close,
                          size: 16, color: AppColors.lightText),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],

          // Input tambah sertifikasi baru
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _sertifikasiController,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.primaryText),
                  decoration: InputDecoration(
                    hintText: 'Tambah sertifikasi...',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.lightText),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                  ),
                  onFieldSubmitted: (_) => _tambahSertifikasi(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _tambahSertifikasi,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Ketuk + untuk menambah sertifikasi',
            style: GoogleFonts.inter(fontSize: 9, color: AppColors.lightText),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00BBA7), Color(0xFF009689)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 18),
                  ),
                  Text(
                    'Edit Profil',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickFotoProfil,
              child: Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: _fotoProfilFile != null
                        ? ClipOval(
                            child: Image.file(_fotoProfilFile!,
                                fit: BoxFit.cover))
                        : const Center(
                            child: Text('SN',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF00BBA7),
                                ))),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF00BBA7), width: 1.5),
                      ),
                      child: const Icon(Icons.edit,
                          size: 13, color: Color(0xFF00BBA7)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ketuk untuk ganti foto profil',
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.85),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
    bool required = false,
    String? subtitle,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText),
              ),
              if (required)
                Text(' *',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.errorRed)),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle,
                style:
                    GoogleFonts.inter(fontSize: 9, color: AppColors.lightText)),
          ],
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            inputFormatters: inputFormatters,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.primaryText),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.lightText),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
            ),
            validator: validator ??
                (required
                    ? (val) => val == null || val.isEmpty
                        ? '$label wajib diisi'
                        : null
                    : null),
          ),
        ],
      ),
    );
  }

  Widget _buildTextAreaField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: 4,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.primaryText),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.lightText),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDokumenSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dokumen Pendukung',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderColor),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildUploadBox(
                  label: 'Foto STR/SIPA',
                  required: true,
                  subtitle: 'PNG, JPG atau PDF (Max. 5MB)',
                  file: _fotoStrFile,
                  onTap: () => _pickFile(true),
                ),
                const SizedBox(height: 14),
                _buildUploadBox(
                  label: 'Sertifikat Kompetensi',
                  required: false,
                  subtitle:
                      'Upload sertifikat tambahan (Opsional)\nPNG, JPG atau PDF (Max. 5MB)',
                  file: _sertifikatFile,
                  onTap: () => _pickFile(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox({
    required String label,
    required bool required,
    required String subtitle,
    required File? file,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText)),
            if (required)
              Text(' *',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.errorRed)),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: file != null ? AppColors.primary : AppColors.borderColor,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  file != null
                      ? Icons.check_circle_outline
                      : Icons.upload_outlined,
                  color: file != null ? AppColors.primary : AppColors.lightText,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  file != null
                      ? 'File dipilih'
                      : 'Klik untuk upload atau drag & drop',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: file != null
                        ? AppColors.primary
                        : AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                      fontSize: 9, color: AppColors.lightText),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpanButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _simpanPerubahan,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  'Simpan Perubahan',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}