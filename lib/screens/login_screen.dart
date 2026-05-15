import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_screen.dart';
import 'register_fisioterapis_screen.dart';
import 'dashboard_screen.dart';
import 'fisioterapis_dashboard_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Email dan password tidak boleh kosong.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) {
        setState(() => _errorMessage = 'Login gagal. Periksa email dan password.');
        return;
      }

      final patientData = await _supabase
          .from('patients')
          .select('id, full_name, email')
          .eq('id', user.id)
          .maybeSingle();

      if (patientData != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
        return;
      }

      final fisioData = await _supabase
          .from('fisioterapis')
          .select('user_id, nama_lengkap, status_verifikasi, is_active')
          .eq('user_id', user.id)
          .maybeSingle();

      if (fisioData != null) {
        final isActive = fisioData['is_active'] as bool? ?? false;
        if (!isActive) {
          await _supabase.auth.signOut();
          setState(() => _errorMessage =
              'Akun Anda telah dinonaktifkan. Hubungi admin untuk informasi lebih lanjut.');
          return;
        }

        final status = fisioData['status_verifikasi'] as String? ?? 'pending';
        if (status == 'pending') {
          await _supabase.auth.signOut();
          setState(() => _errorMessage =
              'Akun Anda sedang dalam proses verifikasi. Tunggu konfirmasi dari admin.');
          return;
        }

        if (status == 'rejected') {
          await _supabase.auth.signOut();
          setState(() => _errorMessage =
              'Akun Anda ditolak oleh admin. Hubungi kami untuk informasi lebih lanjut.');
          return;
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FisioterapisDashboardScreen()),
          );
        }
        return;
      }

      await _supabase.auth.signOut();
      setState(() => _errorMessage =
          'Akun tidak ditemukan. Pastikan Anda sudah mendaftar.');
    } on AuthException catch (e) {
      setState(() => _errorMessage = _mapAuthError(e.message));
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email atau password salah.';
    } else if (message.contains('Email not confirmed')) {
      return 'Email belum dikonfirmasi. Cek inbox Anda.';
    } else if (message.contains('Too many requests')) {
      return 'Terlalu banyak percobaan. Tunggu beberapa saat.';
    }
    return 'Login gagal: $message';
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildLogoSection(),
                const SizedBox(height: 32),
                _buildLoginForm(),
                const SizedBox(height: 20),
                _buildFooterText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              'assets/images/logo.jpeg',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'FisioCare',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Homecare Fisioterapi',
          style: GoogleFonts.inter(
            color: const Color(0xFFCBFBF1),
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Masuk ke Akun',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'nama@email.com',
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Masukkan password',
            icon: Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 10),
          _buildForgotPassword(),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFEF4444),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFB91C1C),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildLoginButton(),
          const SizedBox(height: 16),
          _buildRegisterLink(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          keyboardType:
              isPassword ? TextInputType.text : TextInputType.emailAddress,
          onChanged: (_) {
            if (_errorMessage != null) setState(() => _errorMessage = null);
          },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF00BBA7)),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
        ),
        child: Text(
          'Lupa password?',
          style: GoogleFonts.inter(
            color: const Color(0xFF00BBA7),
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BBA7),
          disabledBackgroundColor: const Color(0xFF00BBA7).withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'Masuk',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
          children: [
            const TextSpan(text: 'Belum punya akun? '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  );
                },
                child: Text(
                  'Daftar Sekarang',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00BBA7),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    return Text(
      'Dengan masuk, Anda menyetujui Syarat & Ketentuan kami',
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        color: const Color(0xFFCBFBF1),
        fontSize: 12,
      ),
    );
  }
}