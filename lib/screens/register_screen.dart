import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Import halaman tujuan agar tombol berfungsi
import 'login_screen.dart'; 
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
              decoration: const BoxDecoration(
                color: Color(0xFF00BBA7),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daftar Pasien',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Buat akun untuk layanan fisioterapi',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- INFORMASI PRIBADI ---
                  _buildSectionTitle('Informasi Pribadi'),
                  const SizedBox(height: 15),
                  _buildLabel('Nama Lengkap *'),
                  _buildTextField('Masukkan nama lengkap'),
                  _buildLabel('Email *'),
                  _buildTextField('nama@email.com'),
                  _buildLabel('Nomor Telepon *'),
                  _buildTextField('+62 812 3456 7890'),
                  _buildLabel('Tanggal Lahir'),
                  _buildTextField('dd/mm/yyyy'),
                  _buildLabel('Jenis Kelamin'),
                  _buildDropdownField('Pilih jenis kelamin', ['Laki-laki', 'Perempuan']),
                  _buildLabel('Alamat'),
                  _buildTextField('Masukkan alamat lengkap', maxLines: 3),

                  const SizedBox(height: 30),
                  
                  // --- INFORMASI MEDIS ---
                  _buildSectionTitle('Informasi Medis'),
                  const SizedBox(height: 5),
                  Text(
                    'Informasi ini membantu terapis memberikan perawatan terbaik',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Berat Badan'),
                            _buildTextField('Contoh : 72 kg'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Tinggi Badan'),
                            _buildTextField('Contoh : 170 cm'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _buildLabel('Golongan Darah'),
                  _buildTextField('Contoh : O+'),
                  _buildLabel('Alergi'),
                  _buildTextField('Contoh : Kacang, Debu, dll'),
                  _buildLabel('Riwayat Penyakit (Opsional)'),
                  _buildTextField('Contoh: Diabetes, Hipertensi, dll.', maxLines: 3),

                  const SizedBox(height: 30),

                  // --- KEAMANAN AKUN ---
                  _buildSectionTitle('Keamanan Akun'),
                  const SizedBox(height: 15),
                  _buildLabel('Password *'),
                  _buildPasswordField('Minimal 8 karakter', _obscurePassword, () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  }),
                  _buildLabel('Konfirmasi Password *'),
                  _buildPasswordField('Masukkan ulang password', _obscureConfirmPassword, () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  }),

                  const SizedBox(height: 30),

                  // --- TOMBOL DAFTAR ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigasi ke Dashboard setelah daftar
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const DashboardScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BBA7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Daftar Sekarang',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- TOMBOL MASUK (LOGIN) ---
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Fungsi Navigasi ke Halaman Login
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: Text(
                            'Masuk',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF00BBA7),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets untuk merapikan kode
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E)),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 10),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF5F7F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildPasswordField(String hint, bool obscure, VoidCallback toggle) {
    return TextFormField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF5F7F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
          onPressed: toggle,
        ),
      ),
    );
  }

  Widget _buildDropdownField(String hint, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFF5F7F9), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint, style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14)),
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) {},
        ),
      ),
    );
  }
}