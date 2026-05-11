import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';

class FisioterapisTambahLayananScreen extends StatefulWidget {
  final String fisioterapisId;
  final String fisioterapisNama;

  const FisioterapisTambahLayananScreen({
    super.key,
    required this.fisioterapisId,
    required this.fisioterapisNama,
  });

  @override
  State<FisioterapisTambahLayananScreen> createState() =>
      _FisioterapisTambahLayananScreenState();
}

class _FisioterapisTambahLayananScreenState
    extends State<FisioterapisTambahLayananScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  final _namaLayananCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();
  final _durasiCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _namaLayananCtrl.dispose();
    _deskripsiCtrl.dispose();
    _hargaCtrl.dispose();
    _durasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpanLayanan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final namaLayanan = _namaLayananCtrl.text.trim();
      final deskripsi = _deskripsiCtrl.text.trim();
      final harga = double.parse(_hargaCtrl.text.trim());
      final durasi = _durasiCtrl.text.trim().isEmpty
          ? null
          : int.parse(_durasiCtrl.text.trim());

      await _supabase.from('services').insert({
        'fisioterapis_id': widget.fisioterapisId,
        'nama_layanan': namaLayanan,
        'harga': harga,
        if (deskripsi.isNotEmpty) 'deskripsi': deskripsi,
        if (durasi != null) 'durasi_menit': durasi,
        'is_active': true,
      });

      if (mounted) {
        _showSnackbar('Layanan berhasil ditambahkan!');
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Gagal menambahkan layanan: ${e.toString()}',
            isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(msg,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.errorRed : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _buildForm(),
            ),
          ),
        ],
      ),
    );
  }

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tambah Layanan Baru',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tambahkan layanan baru untuk fisioterapi Anda',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
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

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Layanan
          _buildFieldLabel('Nama Layanan *'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _namaLayananCtrl,
            autofocus: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama layanan tidak boleh kosong';
              }
              if (value.trim().length < 3) {
                return 'Nama layanan minimal 3 karakter';
              }
              return null;
            },
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
            decoration: InputDecoration(
              hintText: 'Contoh: Terapi Stroke, Fisioterapi Lutut',
              hintStyle: GoogleFonts.inter(
                color: AppColors.lightText,
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.errorRed, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Deskripsi
          _buildFieldLabel('Deskripsi (Opsional)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _deskripsiCtrl,
            maxLines: 4,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.primaryText,
            ),
            decoration: InputDecoration(
              hintText: 'Jelaskan detail layanan Anda...',
              hintStyle: GoogleFonts.inter(
                color: AppColors.lightText,
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Harga Layanan
          _buildFieldLabel('Harga Layanan *'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _hargaCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Harga tidak boleh kosong';
              }
              final harga = double.tryParse(value.trim());
              if (harga == null || harga <= 0) {
                return 'Harga harus lebih dari 0';
              }
              return null;
            },
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
            decoration: InputDecoration(
              prefixText: 'Rp  ',
              prefixStyle: GoogleFonts.inter(
                color: AppColors.secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              hintText: '50000',
              hintStyle: GoogleFonts.inter(
                color: AppColors.lightText,
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.errorRed, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Durasi (Opsional)
          _buildFieldLabel('Durasi Layanan (Menit) - Opsional'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _durasiCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final durasi = int.tryParse(value.trim());
                if (durasi == null || durasi <= 0) {
                  return 'Durasi harus berupa angka positif';
                }
              }
              return null;
            },
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
            decoration: InputDecoration(
              suffixText: 'menit',
              suffixStyle: GoogleFonts.inter(
                color: AppColors.secondaryText,
                fontSize: 12,
              ),
              hintText: '60',
              hintStyle: GoogleFonts.inter(
                color: AppColors.lightText,
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.errorRed, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Tombol Simpan
          _buildSaveButton(),
          const SizedBox(height: 20),

          // Tombol Batal
          _buildCancelButton(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _simpanLayanan,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: _isLoading
              ? LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade500],
                )
              : const LinearGradient(
                  colors: [Color(0xFF00BBA7), Color(0xFF009689)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF00BBA7).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                  strokeWidth: 2.5,
                ),
              )
            else
              const Icon(Icons.save_outlined, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              _isLoading ? 'Menyimpan...' : 'Simpan Layanan',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: _isLoading ? null : () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.close_rounded,
                color: AppColors.secondaryText, size: 18),
            const SizedBox(width: 8),
            Text(
              'Batal',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
