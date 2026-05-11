import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import 'forgot_password_password_baru.dart';

class ForgotPasswordEmailScreen extends StatefulWidget {
  final String email; // Email diterima dari ForgotPasswordScreen

  const ForgotPasswordEmailScreen({super.key, required this.email});

  @override
  State<ForgotPasswordEmailScreen> createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState
    extends State<ForgotPasswordEmailScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _onLanjutkan() async {
    final kode = _codeController.text.trim();

    if (kode.isEmpty) {
      _showSnackbar('Masukkan kode OTP terlebih dahulu.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Verifikasi OTP dari Supabase
      final response = await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: kode,
        type: OtpType.email,
      );

      if (!mounted) return;

      if (response.session != null) {
        // OTP valid → navigasi ke screen buat password baru
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ForgotPasswordPasswordBaruScreen(),
          ),
        );
      } else {
        _showSnackbar('Kode OTP tidak valid atau sudah kadaluarsa.');
      }
    } on AuthException catch (e) {
      _showSnackbar(e.message);
    } catch (e) {
      _showSnackbar('Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onKirimUlang() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: widget.email,
        shouldCreateUser: false,
      );
      _showSnackbar('Kode OTP telah dikirim ulang ke ${widget.email}');
    } on AuthException catch (e) {
      _showSnackbar(e.message);
    } catch (e) {
      _showSnackbar('Gagal kirim ulang kode. Coba lagi.');
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
            'Lihat Email Anda',
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
            'Kami mengirimkan kode OTP ke ${widget.email}. Masukkan kode tersebut untuk mengkonfirmasi akun Anda.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 14, height: 1.5),
          ),
        ),
        const SizedBox(height: 30),
        Text(
          'Kode OTP',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            hintText: 'Masukkan kode 6 digit',
            hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 12),
        // Tombol kirim ulang kode
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : _onKirimUlang,
            child: Text(
              'Kirim ulang kode',
              style: GoogleFonts.inter(
                color: const Color(0xFF00BBA7),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
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