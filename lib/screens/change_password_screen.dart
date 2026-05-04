import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Controller untuk mengambil teks input
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isObscureCurrent = true;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;

  @override
  void dispose() {
    // Membersihkan memory controller
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION ---
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

            // --- FORM SECTION ---
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

                    // Box Persyaratan
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
                              color: const Color(0xFF00796B)
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildRequirementText("Minimal 8 Karakter"),
                          _buildRequirementText("Mengandung huruf besar dan angka"),
                          _buildRequirementText("Mengandung karakter spesial"),
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
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Logika sederhana untuk simulasi simpan
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password berhasil diperbarui!')),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BBA7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          "Simpan Password",
                          style: GoogleFonts.inter(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            fontSize: 14
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

  Widget _buildPasswordField({
    required String label, 
    required String hint, 
    required TextEditingController controller,
    required bool isObscure, 
    required VoidCallback onToggle
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
        ),
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
              borderSide: BorderSide.none,
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

  Widget _buildRequirementText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Color(0xFF00796B)),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF00796B)),
          ),
        ],
      ),
    );
  }
}