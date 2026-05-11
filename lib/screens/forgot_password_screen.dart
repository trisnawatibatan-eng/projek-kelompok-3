import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import 'forgot_password_email_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onLanjutkan() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackbar('Masukkan email terlebih dahulu.');
      return;
    }

    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showSnackbar('Format email tidak valid.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Kirim OTP ke email via Supabase
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false, // Hanya untuk user yang sudah terdaftar
      );

      if (!mounted) return;

      // Navigasi ke screen verifikasi kode OTP
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ForgotPasswordEmailScreen(email: email),
        ),
      );
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
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 14, color: Color(0xFF00BBA7)),
          label: Text(
            'Kembali ke Login',
            style: GoogleFonts.inter(color: const Color(0xFF00BBA7), fontSize: 13),
          ),
        ),
        Center(
          child: Text(
            'Lupa Password?',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Masukkan email Anda untuk menerima kode OTP reset password',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 14, height: 1.5),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Email',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'nama@email.com',
            hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.email_outlined, size: 20, color: Color(0xFF00BBA7)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ingat password Anda? ', style: GoogleFonts.inter(color: Colors.grey, fontSize: 14)),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Masuk di sini',
                style: GoogleFonts.inter(
                  color: const Color(0xFF00BBA7),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}