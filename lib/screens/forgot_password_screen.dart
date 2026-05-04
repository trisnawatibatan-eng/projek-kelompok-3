import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Logic Steps: 0 = Input Email, 1 = Verifikasi Kode, 2 = Password Baru
  int _currentStep = 0;
  int _selectedTab = 0; // 0 untuk Pasien, 1 untuk Fisioterapis

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
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
                  child: SingleChildScrollView(
                    child: _buildCurrentForm(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HEADER LOGO ---
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
          child: const Icon(Icons.medical_services, color: Color(0xFF00BBA7), size: 40),
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

  // --- LOGIC SWITCHER FORM ---
  Widget _buildCurrentForm() {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildVerificationStep();
      case 2:
        return _buildNewPasswordStep();
      default:
        return _buildEmailStep();
    }
  }

  // --- STEP 1: LUPA PASSWORD ---
  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackButton(),
        Center(child: _buildTitle("Lupa Password?")),
        const SizedBox(height: 8),
        Center(child: _buildSubtitle("Masukkan email Anda untuk menerima link reset password")),
        const SizedBox(height: 24),
        _buildTabSwitcher(),
        const SizedBox(height: 24),
        _buildLabel("Email"),
        _buildTextField(_emailController, "nama@email.com", Icons.email_outlined),
        const SizedBox(height: 32),
        _buildPrimaryButton("Lanjutkan", () => setState(() => _currentStep = 1)),
        const SizedBox(height: 20),
        _buildFooterLink(),
      ],
    );
  }

  // --- STEP 2: LIHAT EMAIL ---
  Widget _buildVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(child: _buildTitle("Lihat Email Anda")),
        const SizedBox(height: 8),
        Center(child: _buildSubtitle("Kami mengirimkan kode ke email Anda. Masukkan kode tersebut untuk mengkonfirmasi akun Anda")),
        const SizedBox(height: 24),
        _buildTabSwitcher(),
        const SizedBox(height: 24),
        _buildLabel("Kode"),
        _buildTextField(_codeController, "Masukkan kode", null),
        const SizedBox(height: 32),
        _buildPrimaryButton("Lanjutkan", () => setState(() => _currentStep = 2)),
      ],
    );
  }

  // --- STEP 3: PASSWORD BARU ---
  Widget _buildNewPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(child: _buildTitle("Buat Kata sandi Baru")),
        const SizedBox(height: 8),
        Center(child: _buildSubtitle("Buat kata sandi dengan minimal 8 karakter")),
        const SizedBox(height: 24),
        _buildTabSwitcher(),
        const SizedBox(height: 24),
        _buildLabel("Kata Sandi Baru"),
        _buildTextField(_newPassController, "Masukkan Sandi Baru", Icons.lock_outline, isPassword: true),
        const SizedBox(height: 16),
        _buildLabel("Konfirmasi Kata Sandi Baru"),
        _buildTextField(_confirmPassController, "Konfirmasi Sandi Baru", Icons.lock_outline, isPassword: true),
        const SizedBox(height: 32),
        _buildPrimaryButton("Simpan", () => Navigator.pop(context)),
      ],
    );
  }

  // --- REUSABLE COMPONENTS ---

  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back_ios, size: 14, color: Color(0xFF00BBA7)),
      label: Text("Kembali ke Login", style: GoogleFonts.inter(color: const Color(0xFF00BBA7), fontSize: 13)),
    );
  }

  Widget _buildTitle(String text) => Text(text, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold));

  Widget _buildSubtitle(String text) => Text(text, textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.grey, fontSize: 14, height: 1.5));

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
      );

  Widget _buildTabSwitcher() {
    return Container(
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _tabItem(0, 'Pasien'),
          _tabItem(1, 'Fisioterapis'),
        ],
      ),
    );
  }

  Widget _tabItem(int index, String title) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          ),
          child: Center(
            child: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? const Color(0xFF00BBA7) : Colors.grey)),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData? icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20, color: const Color(0xFF00BBA7)) : null,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BBA7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFooterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Ingat password Anda? ", style: GoogleFonts.inter(color: Colors.grey, fontSize: 14)),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text("Masuk di sini", style: GoogleFonts.inter(color: const Color(0xFF00BBA7), fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }
}