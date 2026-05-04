import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    // Listener agar UI requirement box update saat mengetik
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
  //  LOGIKA GANTI PASSWORD
  //  Supabase Auth menggunakan updateUser() untuk ganti password.
  //  "Password saat ini" diverifikasi dengan re-login terlebih dulu
  //  agar tidak bisa diubah tanpa mengetahui password lama.
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
    if (!_hasMinLength || !_hasUpperAndNumber || !_hasSpecialChar) {
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
      _showSnackbar('Password baru tidak boleh sama dengan password saat ini.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null || user.email == null) {
        _showSnackbar('Sesi tidak ditemukan, silakan login ulang.', isError: true);
        setState(() => _isSaving = false);
        return;
      }

      // Langkah 1: Verifikasi password lama dengan re-sign in
      // Ini memastikan hanya pemilik akun yang bisa ganti password
      await _supabase.auth.signInWithPassword(
        email: user.email!,
        password: currentPass,
      );

      // Langkah 2: Update ke password baru
      await _supabase.auth.updateUser(
        UserAttributes(password: newPass),
      );

      setState(() => _isSaving = false);

      if (mounted) {
        _showSnackbar('Password berhasil diperbarui!');
        // Kembali ke halaman sebelumnya setelah berhasil
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } on AuthException catch (e) {
      setState(() => _isSaving = false);
      // Pesan error khusus dari Supabase Auth
      String message = 'Gagal memperbarui password.';
      if (e.message.toLowerCase().contains('invalid login credentials') ||
          e.message.toLowerCase().contains('invalid credentials')) {
        message = 'Password saat ini salah.';
      } else if (e.message.toLowerCase().contains('same password')) {
        message = 'Password baru tidak boleh sama dengan yang lama.';
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
        backgroundColor: isError ? Colors.red.shade600 : const Color(0xFF00BBA7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ============================================================
  //  BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
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
                    color: Color(0xFF00BBA7),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, left: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          style: IconButton.styleFrom(backgroundColor: Colors.white24),
                        ),
                        const SizedBox(width: 15),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Ubah Password",
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
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
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                      ],
                    ),
                    child: const Icon(Icons.verified_user, color: Color(0xFF00BBA7), size: 40),
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
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Ubah Password",
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Pastikan password baru Anda kuat\ndan mudah diingat",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),

                    _buildPasswordField(
                      label: "Password Saat Ini",
                      hint: "Masukkan Password Saat Ini",
                      controller: _currentPassController,
                      isObscure: _isObscureCurrent,
                      onToggle: () => setState(() => _isObscureCurrent = !_isObscureCurrent),
                    ),

                    _buildPasswordField(
                      label: "Password Baru",
                      hint: "Buat Password Baru",
                      controller: _newPassController,
                      isObscure: _isObscureNew,
                      onToggle: () => setState(() => _isObscureNew = !_isObscureNew),
                    ),

                    // --- BOX PERSYARATAN (real-time) ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7F4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Persyaratan Password",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00796B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildRequirement("Minimal 8 karakter", _hasMinLength),
                          _buildRequirement("Mengandung huruf besar dan angka", _hasUpperAndNumber),
                          _buildRequirement("Mengandung karakter spesial (!@#\$...)", _hasSpecialChar),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildPasswordField(
                      label: "Konfirmasi Password Baru",
                      hint: "Konfirmasi Password Baru",
                      controller: _confirmPassController,
                      isObscure: _isObscureConfirm,
                      onToggle: () => setState(() => _isObscureConfirm = !_isObscureConfirm),
                      // Tampilkan border merah jika tidak cocok dan sudah ada input
                      hasError: _confirmPassController.text.isNotEmpty && !_passwordsMatch,
                    ),

                    // Pesan cocok/tidak cocok
                    if (_confirmPassController.text.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Icon(
                                _passwordsMatch ? Icons.check_circle : Icons.cancel,
                                size: 14,
                                color: _passwordsMatch ? const Color(0xFF00BBA7) : Colors.red,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _passwordsMatch ? 'Password cocok' : 'Password tidak cocok',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: _passwordsMatch ? const Color(0xFF00BBA7) : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // --- TOMBOL SIMPAN ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BBA7),
                          disabledBackgroundColor: const Color(0xFF00BBA7).withOpacity(0.6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                "Simpan Password",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? const BorderSide(color: Colors.red, width: 1.5)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? const BorderSide(color: Colors.red, width: 1.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? const BorderSide(color: Colors.red, width: 1.5)
                  : const BorderSide(color: Color(0xFF00BBA7), width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
                color: Colors.grey,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  /// Requirement item dengan centang real-time
  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle,
            size: isMet ? 14 : 6,
            color: isMet ? const Color(0xFF00BBA7) : const Color(0xFF00796B),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isMet ? const Color(0xFF00BBA7) : const Color(0xFF00796B),
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isMet) ...[
            const SizedBox(width: 4),
            const Icon(Icons.check, size: 12, color: Color(0xFF00BBA7)),
          ]
        ],
      ),
    );
  }
}