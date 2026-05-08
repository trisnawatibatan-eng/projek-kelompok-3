import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _supabase = Supabase.instance.client;

  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isObscureCurrent = true;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;
  bool _isSaving = false;

  // ---- Validasi real-time ----
  bool get _hasMinLength => _newPassController.text.length >= 8;
  bool get _hasUpperAndNumber =>
      RegExp(r'[A-Z]').hasMatch(_newPassController.text) &&
      RegExp(r'[0-9]').hasMatch(_newPassController.text);
  bool get _hasSpecialChar =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_newPassController.text);
  bool get _passwordsMatch =>
      _newPassController.text == _confirmPassController.text &&
      _confirmPassController.text.isNotEmpty;

  bool get _allRequirementsMet =>
      _hasMinLength && _hasUpperAndNumber && _hasSpecialChar;

  @override
  void initState() {
    super.initState();
    _newPassController.addListener(() => setState(() {}));
    _confirmPassController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // ============================================================
  //  LOGIKA GANTI PASSWORD FISIOTERAPIS
  //  1. Verifikasi email dari tabel fisioterapis via user_id
  //  2. Re-sign in dengan password lama untuk verifikasi
  //  3. Update password via Supabase Auth updateUser()
  // ============================================================
  Future<void> _changePassword() async {
    final currentPass = _currentPassController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    // --- Validasi input kosong ---
    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showSnackbar('Semua kolom harus diisi.', isError: true);
      return;
    }

    // --- Validasi persyaratan password baru ---
    if (!_allRequirementsMet) {
      _showSnackbar('Password baru tidak memenuhi persyaratan.', isError: true);
      return;
    }

    // --- Validasi konfirmasi ---
    if (newPass != confirmPass) {
      _showSnackbar('Konfirmasi password tidak cocok.', isError: true);
      return;
    }

    // --- Tidak boleh sama dengan password lama ---
    if (currentPass == newPass) {
      _showSnackbar(
          'Password baru tidak boleh sama dengan password saat ini.',
          isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _showSnackbar('Sesi tidak ditemukan, silakan login ulang.',
            isError: true);
        setState(() => _isSaving = false);
        return;
      }

      // Ambil email dari tabel fisioterapis berdasarkan user_id
      // (sebagai fallback jika user.email null)
      String? email = user.email;
      if (email == null || email.isEmpty) {
        final data = await _supabase
            .from('fisioterapis')
            .select('email')
            .eq('user_id', user.id)
            .maybeSingle();
        email = data?['email'] as String?;
      }

      if (email == null || email.isEmpty) {
        _showSnackbar('Email tidak ditemukan, silakan login ulang.',
            isError: true);
        setState(() => _isSaving = false);
        return;
      }

      // Langkah 1: Verifikasi password lama dengan re-sign in
      await _supabase.auth.signInWithPassword(
        email: email,
        password: currentPass,
      );

      // Langkah 2: Update ke password baru
      await _supabase.auth.updateUser(
        UserAttributes(password: newPass),
      );

      // Langkah 3: Update kolom updated_at di tabel fisioterapis
      // (trigger trg_fisioterapis_updated_at akan otomatis memperbarui,
      //  tapi kita bisa trigger dengan update ringan jika diperlukan)
      // Tidak wajib karena password tersimpan di auth.users, bukan tabel fisioterapis.

      setState(() => _isSaving = false);

      if (mounted) {
        _showSnackbar('Password berhasil diperbarui!');
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } on AuthException catch (e) {
      setState(() => _isSaving = false);
      String message = 'Gagal memperbarui password.';
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid credentials') ||
          msg.contains('email not confirmed')) {
        message = 'Password saat ini salah.';
      } else if (msg.contains('same password')) {
        message = 'Password baru tidak boleh sama dengan yang lama.';
      } else if (msg.contains('weak password')) {
        message = 'Password terlalu lemah, gunakan kombinasi yang lebih kuat.';
      } else {
        message = e.message;
      }
      _showSnackbar(message, isError: true);
    } catch (e) {
      setState(() => _isSaving = false);
      _showSnackbar('Terjadi kesalahan: $e', isError: true);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor:
            isError ? Colors.red.shade600 : const Color(0xFF00BBA7),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ============================================================
  //  BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00BBA7), Color(0xFF009689)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 8, left: 16, right: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            style: IconButton.styleFrom(
                                backgroundColor: Colors.white24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Ubah Password',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5))
                      ],
                    ),
                    child: const Icon(Icons.lock_outline,
                        color: Color(0xFF00BBA7), size: 40),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // --- FORM ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderColor),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Ubah Password',
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w700,
                            color: AppColors.primaryText),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Pastikan password baru Anda kuat\ndan mudah diingat',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.lightText),
                      ),
                    ),
                    const SizedBox(height: 28),

                    _buildPasswordField(
                      label: 'Password Saat Ini',
                      hint: 'Masukkan password saat ini',
                      controller: _currentPassController,
                      isObscure: _isObscureCurrent,
                      onToggle: () => setState(
                          () => _isObscureCurrent = !_isObscureCurrent),
                    ),

                    _buildPasswordField(
                      label: 'Password Baru',
                      hint: 'Buat password baru',
                      controller: _newPassController,
                      isObscure: _isObscureNew,
                      onToggle: () =>
                          setState(() => _isObscureNew = !_isObscureNew),
                    ),

                    // --- BOX PERSYARATAN (real-time) ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6FAF8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFB2EFE9)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Persyaratan Password',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildRequirement(
                              'Minimal 8 karakter', _hasMinLength),
                          _buildRequirement(
                              'Mengandung huruf besar dan angka',
                              _hasUpperAndNumber),
                          _buildRequirement(
                              'Mengandung karakter spesial (!@#\$...)',
                              _hasSpecialChar),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildPasswordField(
                      label: 'Konfirmasi Password Baru',
                      hint: 'Ulangi password baru',
                      controller: _confirmPassController,
                      isObscure: _isObscureConfirm,
                      onToggle: () => setState(
                          () => _isObscureConfirm = !_isObscureConfirm),
                      hasError: _confirmPassController.text.isNotEmpty &&
                          !_passwordsMatch,
                    ),

                    // Pesan cocok/tidak cocok
                    if (_confirmPassController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16, top: -8),
                        child: Row(
                          children: [
                            Icon(
                              _passwordsMatch
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 14,
                              color: _passwordsMatch
                                  ? AppColors.primary
                                  : AppColors.errorRed,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _passwordsMatch
                                  ? 'Password cocok'
                                  : 'Password tidak cocok',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: _passwordsMatch
                                    ? AppColors.primary
                                    : AppColors.errorRed,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 8),

                    // --- TOMBOL SIMPAN ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.primary.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Simpan Password',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---- Widget Helpers ----

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggle,
    bool hasError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.primaryText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.lightText),
            filled: true,
            fillColor: AppColors.scaffoldBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? BorderSide(color: AppColors.errorRed, width: 1.5)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? BorderSide(color: AppColors.errorRed, width: 1.5)
                  : BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? BorderSide(color: AppColors.errorRed, width: 1.5)
                  : const BorderSide(color: Color(0xFF00BBA7), width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: AppColors.lightText,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 15,
            color: isMet ? AppColors.primary : AppColors.lightText,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isMet ? AppColors.primary : AppColors.lightText,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}