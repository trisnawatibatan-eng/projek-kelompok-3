import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class FisioterapisTambahEdukasi extends StatefulWidget {
  const FisioterapisTambahEdukasi({super.key});

  @override
  State<FisioterapisTambahEdukasi> createState() => _FisioterapisTambahEdukasiState();
}

class _FisioterapisTambahEdukasiState extends State<FisioterapisTambahEdukasi> {
  String selectedKategori = 'Pernapasan';
  final List<String> kategoriList = [
    'Nyeri Punggung',
    'Pasca Operasi',
    'Cedera Olahraga',
    'Pernapasan',
    'Neurologi',
    'Geriatri',
    'Pediatri'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBA7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tambah Edukasi',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text('Kelola materi edukasi fisioterapi Anda',
                style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSection(
              title: 'THUMBNAIL KONTEN',
              child: _buildUploadBox(),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'INFORMASI KONTEN',
              child: Column(
                children: [
                  _buildTextField('Judul Edukasi',
                      'Teknik Pernapasan untuk Nyeri Punggung'),
                  const SizedBox(height: 15),
                  _buildTextField(
                      'Deskripsi Singkat', 'Panduan pernapasan diafragma...',
                      maxLines: 3),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'KATEGORI',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kategoriList.map((kat) => _buildChip(kat)).toList(),
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'KONTEN UTAMA',
              child: _buildRichTextEditor(),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'LAMPIRAN & MEDIA',
              child: _buildFileAttachment(),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'PENGATURAN PUBLIKASI',
              child: _buildPublishSetting(),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BBA7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Publikasikan Edukasi',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildUploadBox() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00BBA7).withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_outlined, color: Color(0xFF00BBA7), size: 38),
          const SizedBox(height: 8),
          Text('Upload Gambar Utama',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00BBA7))),
          Text('Rasio 16:9 recommended',
              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label) {
    bool isSelected = selectedKategori == label;
    return GestureDetector(
      onTap: () => setState(() => selectedKategori = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00BBA7) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? Colors.transparent : Colors.black12),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 11,
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildRichTextEditor() {
    return Column(
      children: [
        Row(
          children: [
            _editorIcon(Icons.format_bold),
            _editorIcon(Icons.format_italic),
            _editorIcon(Icons.format_list_bulleted),
            _editorIcon(Icons.link),
          ],
        ),
        const Divider(height: 20),
        const TextField(
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Tulis isi edukasi lengkap di sini...',
            hintStyle: TextStyle(fontSize: 13),
            border: InputBorder.none,
          ),
        ),
      ],
    );
  }

  Widget _editorIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Icon(icon, size: 20, color: Colors.black45),
    );
  }

  Widget _buildFileAttachment() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('panduan_nyeri_punggung.pdf',
                    style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.bold)),
                Text('1.4 MB',
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.close, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildPublishSetting() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kirim Notifikasi ke Pasien',
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.bold)),
            Text('Beritahu pasien tentang materi baru',
                style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
          ],
        ),
        Switch(
          value: true,
          onChanged: (val) {},
          activeColor: const Color(0xFF00BBA7),
        ),
      ],
    );
  }
}
