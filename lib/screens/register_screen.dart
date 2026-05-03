import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Import halaman tujuan agar tombol berfungsi
import 'login_screen.dart'; 
import 'dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController teleponController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController beratController = TextEditingController();
  TextEditingController tinggiController = TextEditingController();
  TextEditingController golonganDarahController = TextEditingController();
  TextEditingController alergiController = TextEditingController();
  TextEditingController riwayatController = TextEditingController();

  String selectedGender = 'Laki-laki';
  DateTime? selectedDate;

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
                  _buildTextField('Masukkan nama lengkap', controller: namaController),
                  _buildLabel('Email *'),
                  _buildTextField('nama@email.com', controller: emailController),
                  _buildLabel('Nomor Telepon *'),
                  _buildTextField('+62 812 3456 7890', controller: teleponController),
                  _buildLabel('Tanggal Lahir'),
                  _buildDatePickerField(),
                  _buildLabel('Jenis Kelamin'),
                  _buildDropdownField('Pilih jenis kelamin', ['Laki-laki', 'Perempuan'],
                    onChanged: (value) => setState(() => selectedGender = value ?? 'Laki-laki'),
                  ),
                  _buildLabel('Alamat'),
                  _buildTextField('Masukkan alamat lengkap', maxLines: 3, controller: alamatController),

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
                            _buildTextField('Contoh : 72 kg', controller: beratController),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Tinggi Badan'),
                            _buildTextField('Contoh : 170 cm', controller: tinggiController),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _buildLabel('Golongan Darah'),
                  _buildTextField('Contoh : O+', controller: golonganDarahController),
                  _buildLabel('Alergi'),
                  _buildTextField('Contoh : Kacang, Debu, dll', controller: alergiController),
                  _buildLabel('Riwayat Penyakit (Opsional)'),
                  _buildTextField('Contoh: Diabetes, Hipertensi, dll.', maxLines: 3, controller: riwayatController),

                  const SizedBox(height: 30),

                  // --- KEAMANAN AKUN ---
                  _buildSectionTitle('Keamanan Akun'),
                  const SizedBox(height: 15),
                  _buildLabel('Password *'),
                  _buildPasswordField('Minimal 8 karakter', _obscurePassword, () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  }, controller: passwordController),
                  _buildLabel('Konfirmasi Password *'),
                  _buildPasswordField('Masukkan ulang password', _obscureConfirmPassword, () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  }, controller: confirmPasswordController),

                  const SizedBox(height: 30),

                  // --- TOMBOL DAFTAR ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Navigasi ke Dashboard setelah daftar
                        await _registerUser();
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

  Widget _buildTextField(String hint, {int maxLines = 1, TextEditingController? controller}) {
    return TextFormField(
      controller: controller,
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

  Widget _buildPasswordField(String hint, bool obscure, VoidCallback toggle, {TextEditingController? controller}) {
    return TextFormField(
      controller: controller,
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

  Widget _buildDropdownField(String hint, List<String> items, {required Function(String?)? onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFF5F7F9), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint, style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14)),
          isExpanded: true,
          value: selectedGender.isNotEmpty ? selectedGender : null,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate == null
                  ? 'Pilih tanggal lahir'
                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: selectedDate == null ? Colors.grey.shade400 : Colors.black87,
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.grey.shade400, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF00BBA7)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _registerUser() async {
    // Validasi field kosong
    if (namaController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua field yang wajib')),
      );
      return;
    }

    // Validasi password tidak cocok
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak cocok')),
      );
      return;
    }

    // Validasi panjang password
    if (passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 8 karakter')),
      );
      return;
    }

    try {
      // 1. Register user di Auth Supabase
      final AuthResponse res = await supabase.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );

      if (res.user != null) {
        // 2. Simpan data pasien ke tabel 'patients'
        await supabase.from('patients').insert({
          'id': res.user!.id,
          'email': emailController.text,
          'full_name': namaController.text,
          'phone': teleponController.text,
          'birth_date': selectedDate != null ? selectedDate!.toIso8601String().split('T')[0] : null,
          'gender': selectedGender,
          'address': alamatController.text,
          'weight': beratController.text,
          'height': tinggiController.text,
          'blood_type': golonganDarahController.text,
          'allergies': alergiController.text,
          'medical_history': riwayatController.text,
          'created_at': DateTime.now().toIso8601String(),
        });

        // 3. Navigasi ke Dashboard
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }
    }
  }
}