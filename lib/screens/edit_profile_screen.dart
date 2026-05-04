import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controller untuk input data
  final TextEditingController _nameController = TextEditingController(text: 'Budi Santoso');
  final TextEditingController _dateController = TextEditingController(text: '08/14/1985');
  final TextEditingController _genderController = TextEditingController(text: 'Laki-laki');
  final TextEditingController _bloodController = TextEditingController(text: 'B');
  final TextEditingController _emailController = TextEditingController(text: 'budi.santoso@email.com');
  final TextEditingController _phoneController = TextEditingController(text: '+62 812-3456-7890');
  final TextEditingController _addressController = TextEditingController(text: 'Jl. Merdeka No. 12, Surabaya');
  final TextEditingController _weightController = TextEditingController(text: '70');
  final TextEditingController _heightController = TextEditingController(text: '170');

  bool _isNotificationOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  _buildInformasiPribadi(),
                  const SizedBox(height: 20),
                  _buildDataMedis(),
                  const SizedBox(height: 20),
                  _buildPengaturan(),
                  const SizedBox(height: 30),
                  _buildSaveButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header Hijau dengan Foto Profil
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF00BBA7),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Edit Profil',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 48), 
              ],
            ),
          ),
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: const Color(0xFF009689),
                child: Text(
                  'BS',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, size: 18, color: Color(0xFF00BBA7)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Budi Santoso',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ID : FSC-2026-01',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Section Informasi Pribadi
  Widget _buildInformasiPribadi() {
    return _buildCardWrapper(
      title: 'INFORMASI PRIBADI',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildTextField('Nama Lengkap', _nameController),
          _buildTextField('Tanggal Lahir', _dateController, isDate: true),
          Row(
            children: [
              Expanded(child: _buildTextField('Jenis Kelamin', _genderController)),
              const SizedBox(width: 15),
              Expanded(child: _buildTextField('Golongan Darah', _bloodController)),
            ],
          ),
          _buildTextField('Email', _emailController),
          _buildTextField('No. Telepon', _phoneController),
          _buildTextField('Alamat', _addressController),
        ],
      ),
    );
  }

  // Section Data Medis (Perbaikan Icon Error di sini)
  Widget _buildDataMedis() {
    return _buildCardWrapper(
      title: 'DATA MEDIS',
      icon: Icons.medical_services, // Diubah agar tidak error
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField('Berat Badan (kg)', _weightController)),
              const SizedBox(width: 15),
              Expanded(child: _buildTextField('Tinggi Badan (cm)', _heightController)),
            ],
          ),
          _buildTextField('Riwayat Alergi', TextEditingController(), hint: 'Contoh: Penisilin, Seafood...'),
          _buildTextField('Riwayat Penyakit', TextEditingController(), hint: 'Contoh: Diabetes, Hipertensi...'),
        ],
      ),
    );
  }

  // Section Pengaturan
  Widget _buildPengaturan() {
    return _buildCardWrapper(
      title: 'PENGATURAN & PREFERENSI',
      icon: Icons.settings_outlined,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('Notifikasi Pengingat', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('Pengingat jadwal terapi', style: GoogleFonts.inter(fontSize: 12)),
        trailing: Switch(
          value: _isNotificationOn,
          activeColor: const Color(0xFF00BBA7),
          onChanged: (val) => setState(() => _isNotificationOn = val),
        ),
      ),
    );
  }

  // Helper Card
  Widget _buildCardWrapper({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF00BBA7)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00BBA7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  // Helper TextField
  Widget _buildTextField(String label, TextEditingController controller, {bool isDate = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: isDate ? const Icon(Icons.calendar_today_outlined, size: 18) : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tombol Simpan
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BBA7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: Text(
          'Simpan',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}