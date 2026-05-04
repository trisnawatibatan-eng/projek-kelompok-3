import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailArtikelScreen extends StatelessWidget {
  final String title;
  final String tag;
  final IconData icon;
  final Color color;

  const DetailArtikelScreen({
    super.key,
    required this.title,
    required this.tag,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER DENGAN GAMBAR/ICON ---
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Center(
                    child: Icon(icon, size: 120, color: color),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TAG & JUDUL ---
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tag,
                        style: GoogleFonts.inter(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- DESKRIPSI ---
                  _buildSectionText(
                    "Teknik pernapasan diafragma merupakan metode yang terbukti efektif dalam mengurangi nyeri punggung bawah. Saat diafragma berkontraksi, tekanan intra-abdominal meningkat dan membantu menstabilkan tulang belakang.",
                  ),

                  const SizedBox(height: 25),
                  _buildHeading("🤔 Mengapa Ini Efektif?"),
                  _buildSectionText(
                    "Pernapasan diafragma mengaktifkan otot inti yang berfungsi sebagai 'korset alami' tulang belakang. Ini mengurangi beban sendi dan ligamen punggung secara signifikan.",
                  ),

                  const SizedBox(height: 30),
                  _buildHeading("🔢 Langkah-Langkah Latihan"),
                  const SizedBox(height: 15),

                  // --- LIST LANGKAH-LANGKAH ---
                  _buildStepItem(1, "Duduk tegak atau berbaring nyaman. Letakkan satu tangan di dada, satu di perut."),
                  _buildStepItem(2, "Tarik nafas dalam melalui hidung selama 4 hitungan. Perut harus naik — bukan dada."),
                  _buildStepItem(3, "Tahan nafas selama 2 hitungan dengan rileks, tanpa menahan ketegangan di bahu."),
                  _buildStepItem(4, "Hembuskan perlahan melalui mulut selama 6 hitungan. Rasakan perut turun perlahan."),
                  _buildStepItem(5, "Ulangi 3-5 set. Lakukan 2x sehari — pagi setelah bangun dan malam sebelum tidur."),

                  const SizedBox(height: 30),
                  _buildHeading("📈 Progres Latihan"),
                  _buildSectionText(
                    "Minggu pertama fokus pada teknik. Setelah merasa nyaman, tingkatkan durasi tahan nafas dari 2 menjadi 4 hitungan. Pada minggu ke-3, Anda dapat menambahkan gerakan lengan untuk memperluas ekspansi dada.",
                  ),

                  const SizedBox(height: 25),
                  _buildHeading("🧘 Posisi Terbaik"),
                  _buildSectionText(
                    "Latihan ini paling efektif dilakukan dalam posisi semi-Fowler (berbaring dengan kepala dinaikkan 30-45°) atau duduk bersandar. Hindari posisi terlentang penuh jika nyeri punggung bawah masih akut.",
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

  // Widget Pembantu untuk Text Body
  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 15,
        color: Colors.black54,
        height: 1.6,
      ),
    );
  }

  // Widget Pembantu untuk Heading Section
  Widget _buildHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Widget Pembantu untuk Item Langkah (Nomor di dalam lingkaran)
  Widget _buildStepItem(int number, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: const Color(0xFF00BBA7).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00BBA7), width: 2),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Color(0xFF00BBA7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              content,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}