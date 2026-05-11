import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordPasswordBaruScreen extends StatefulWidget {
  const ForgotPasswordPasswordBaruScreen({super.key});

  @override
  State<ForgotPasswordPasswordBaruScreen> createState() =>
      _ForgotPasswordPasswordBaruScreenState();
}

class _ForgotPasswordPasswordBaruScreenState
    extends State<ForgotPasswordPasswordBaruScreen> {
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();
  bool _showPassword = false;
  bool _showKonfirmasi = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  Future<void> _onLanjutkan() async {
    final password = _passwordController.text.trim();
    final konfirmasi = _konfirmasiController.text.trim();

    if (password.isEmpty || konfirmasi.isEmpty) {
      _showSnackbar('Semua kolom harus diisi.');
      return;
    }

    if (password.length < 8) {
      _showSnackbar('Kata sandi minimal 8 karakter.');
      return;
    }

    if (password != konfirmasi) {
      _showSnackbar('Kata sandi dan konfirmasi tidak sama.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update password baru via Supabase
      // Session sudah aktif setelah verifyOTP berhasil di screen sebelumnya
      final response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );

      if (!mounted) return;

      if (response.user != null) {
        _showSnackbar('Kata sandi berhasil diubah!');

        // Tunggu sebentar agar snackbar terlihat, lalu kembali ke login
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;

        // Logout session reset & kembali ke halaman login
        await Supabase.instance.client.auth.signOut();
        if (!mounted) return;

        // Pop semua screen sampai ke root (halaman login)
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        _showSnackbar('Gagal memperbarui kata sandi. Coba lagi.');
      }
    } on AuthException catch (e) {
      _showSnackbar(e.message);
    } catch (e) {
      _showSnackbar('Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: const Color(0xFF00BBA7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00BBA7), Color(0xFF009689)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildHeaderLogo(),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: SingleChildScrollView(child: _buildForm()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderLogo() {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset('assets/images/logo.jpeg', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'FisioCare',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Homecare Fisioterapi',
          style: GoogleFonts.inter(color: const Color(0xFFCBFBF1), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Buat Kata sandi Baru',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Buat kata sandi dengan minimal 8 karakter',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 14, height: 1.5),
          ),
        ),
        const SizedBox(height: 30),

        // Field Kata Sandi Baru
        Text(
          'Kata Sandi Baru',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: !_showPassword,
          decoration: InputDecoration(
            hintText: 'Masukan Sandi Baru',
            hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey.shade400,
                size: 20,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Field Konfirmasi Kata Sandi Baru
        Text(
          'Konfirmasi Kata Sandi Baru',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _konfirmasiController,
          obscureText: !_showKonfirmasi,
          decoration: InputDecoration(
            hintText: 'Konfirmasi Sandi Baru',
            hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                _showKonfirmasi ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey.shade400,
                size: 20,
              ),
              onPressed: () => setState(() => _showKonfirmasi = !_showKonfirmasi),
            ),
          ),
        ),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _onLanjutkan,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BBA7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    'Lanjutkan',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}