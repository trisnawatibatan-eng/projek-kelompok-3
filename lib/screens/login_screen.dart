import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../widgets/fisiocare_logo.dart';
import 'register_screen.dart';
import 'register_fisioterapis_screen.dart';
import 'dashboard_screen.dart';
import 'fisioterapis_dashboard_screen.dart';
import 'forgot_password_screen.dart';

final supabase = Supabase.instance.client; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _selectedTab = 0; // 0 = Pasien, 1 = Fisioterapis
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            colors: [
              Color(0xFF00BBA7),
              Color(0xFF009689),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo + Title
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: FisioCareLogoWidget(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'FisioCare',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
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
                ),
                const SizedBox(height: 32),
                // Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.1)),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Center(
                        child: Text(
                          'Masuk ke Akun',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF0F172B),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Tab Switcher
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECECF0),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTab = 0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _selectedTab == 0
                                        ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Pasien',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF0A0A0A),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTab = 1),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _selectedTab == 1
                                        ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Fisioterapis',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF0A0A0A),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Email field
                      _buildLabel(Icons.email_outlined, 'Email'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'nama@email.com',
                          hintStyle: GoogleFonts.inter(color: AppColors.hintText, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Password field
                      _buildLabel(Icons.lock_outline, 'Password'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Masukkan password',
                          hintStyle: GoogleFonts.inter(color: AppColors.hintText, fontSize: 14),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.hintText,
                              size: 18,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Forgot password - SUDAH DITAMBAHKAN NAVIGASI
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Lupa password?',
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => _handleLogin(),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Masuk',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Register link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            if (_selectedTab == 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterFisioterapisScreen()),
                              );
                            }
                          },
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF45556C)),
                              children: [
                                const TextSpan(text: 'Belum punya akun? '),
                                TextSpan(
                                  text: _selectedTab == 0 ? 'Daftar sebagai Pasien' : 'Daftar sebagai Fisioterapis',
                                  style: const TextStyle(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Dengan masuk, Anda menyetujui Syarat & Ketentuan kami',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFCBFBF1),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF0A0A0A),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    // Validasi input
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Mohon isi email dan password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Login dengan Supabase
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (res.user != null) {
        // Login berhasil, navigasi sesuai tab yang dipilih
        if (mounted) {
          if (_selectedTab == 0) {
            // Pasien login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          } else {
            // Fisioterapis login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const FisioterapisDashboardScreen()),
            );
          }
        }
      }
    } on AuthException catch (error) {
      _showError(_parseAuthError(error.message));
    } catch (error) {
      _showError('Terjadi kesalahan: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _parseAuthError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Email atau password salah';
    } else if (error.contains('Email not confirmed')) {
      return 'Email belum dikonfirmasi. Cek email Anda';
    } else if (error.contains('Too many requests')) {
      return 'Terlalu banyak percobaan login. Coba lagi nanti';
    }
    return error;
  }
}