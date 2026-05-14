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
    // --- LOGIKA DINAMIS KONTEN BERDASARKAN TAG ---
    String deskripsiUtama = "";
    String headingEfektif = "";
    String deskripsiEfektif = "";
    List<String> langkahLangkah = [];
    String headingProgres = "";
    String deskripsiProgres = "";
    String headingPosisi = "";
    String deskripsiPosisi = "";

    if (tag == 'PERNAPASAN') {
      deskripsiUtama = "Teknik pernapasan diafragma merupakan metode yang terbukti efektif dalam mengurangi nyeri punggung bawah. Saat diafragma berkontraksi, tekanan intra-abdominal meningkat dan membantu menstabilkan tulang belakang.";
      headingEfektif = "🤔 Mengapa Ini Efektif?";
      deskripsiEfektif = "Pernapasan diafragma mengaktifkan otot inti yang berfungsi sebagai 'korset alami' tulang belakang. Ini mengurangi beban sendi dan ligamen punggung secara signifikan.";
      langkahLangkah = [
        "Duduk tegak atau berbaring nyaman. Letakkan satu tangan di dada, satu di perut.",
        "Tarik nafas dalam melalui hidung selama 4 hitungan. Perut harus naik — bukan dada.",
        "Tahan nafas selama 2 hitungan dengan rileks, tanpa menahan ketegangan di bahu.",
        "Hembuskan perlahan melalui mulut selama 6 hitungan. Rasakan perut turun perlahan.",
        "Ulangi 3-5 set. Lakukan 2x sehari — pagi setelah bangun dan malam sebelum tidur."
      ];
      headingProgres = "📈 Progres Latihan";
      deskripsiProgres = "Minggu pertama fokus pada teknik. Setelah merasa nyaman, tingkatkan durasi tahan nafas dari 2 menjadi 4 hitungan.";
      headingPosisi = "🧘 Posisi Terbaik";
      deskripsiPosisi = "Latihan ini paling efektif dilakukan dalam posisi semi-Fowler atau duduk bersandar.";
    } else if (tag == 'NUTRISI') {
      deskripsiUtama = "Nutrisi yang tepat sangat krusial untuk regenerasi jaringan sendi dan tulang. Suplemen tertentu dapat membantu mempercepat proses pemulihan peradangan.";
      headingEfektif = "🥗 Manfaat Nutrisi?";
      deskripsiEfektif = "Zat aktif seperti Glukosamin dan Omega-3 membantu melumasi persendian dan mengurangi rasa kaku di pagi hari.";
      langkahLangkah = [
        "Konsumsi air putih minimal 2 liter per hari untuk hidrasi sendi.",
        "Glukosamin: membantu pembentukan cairan tulang rawan.",
        "Omega-3: Mengurangi peradangan pada otot dan sendi.",
        "Vitamin D & Kalsium: Memperkuat struktur tulang belakang.",
        "Konsultasikan dosis dengan fisioterapis atau dokter Anda."
      ];
      headingProgres = "📅 Rutinitas";
      deskripsiProgres = "Efek nutrisi biasanya mulai terasa setelah penggunaan rutin selama 4-8 minggu.";
      headingPosisi = "🍽️ Cara Konsumsi";
      deskripsiPosisi = "Paling baik dikonsumsi setelah makan untuk penyerapan optimal oleh tubuh.";
    } else if (tag == 'LATIHAN') {
      deskripsiUtama = "Penguatan otot core (inti) adalah kunci utama stabilitas tubuh. Otot yang kuat akan melindungi tulang belakang dari tekanan berlebih.";
      headingEfektif = "💪 Mengapa Latihan Core?";
      deskripsiEfektif = "Otot core yang kuat berfungsi sebagai penopang utama postur tubuh saat Anda berdiri maupun duduk lama.";
      langkahLangkah = [
        "Plank: Tahan posisi tubuh lurus seperti papan selama 20-30 detik.",
        "Glute Bridge: Angkat pinggul dari posisi berbaring untuk memperkuat otot bokong.",
        "Bird Dog: Angkat tangan dan kaki berlawanan secara bersamaan untuk keseimbangan.",
        "Dead Bug: Gerakan koordinasi tangan dan kaki untuk menjaga punggung tetap datar.",
        "Leg Raise: Angkat kedua kaki perlahan untuk melatih otot perut bagian bawah."
      ];
      headingProgres = "🔥 Intensitas";
      deskripsiProgres = "Lakukan setiap gerakan 10-15 repetisi sebanyak 3 set. Tingkatkan durasi secara bertahap.";
      headingPosisi = "⚠️ Keamanan";
      deskripsiPosisi = "Pastikan punggung bawah tidak melengkung saat melakukan gerakan agar tidak cedera.";
    } else {
      // MENTAL atau Default
      deskripsiUtama = "Kesehatan mental sangat berpengaruh pada persepsi nyeri. Stres yang tinggi dapat menyebabkan ketegangan otot yang memperburuk nyeri fisik.";
      headingEfektif = "🧠 Hubungan Pikiran & Tubuh";
      deskripsiEfektif = "Relaksasi mental menurunkan hormon kortisol yang memicu peradangan dan ketegangan otot.";
      langkahLangkah = [
        "Meditasi harian selama 10 menit untuk menenangkan sistem saraf.",
        "Jurnal progres: Catat setiap kemajuan kecil yang Anda capai.",
        "Afirmasi positif: Sugesti diri untuk proses penyembuhan yang optimal.",
        "Istirahat cukup: Tidur 7-8 jam untuk pemulihan jaringan tubuh.",
        "Dukungan sosial: Berbagi cerita dengan keluarga atau teman dekat."
      ];
      headingProgres = "✨ Dampak";
      deskripsiProgres = "Pikiran yang tenang akan mempercepat durasi pemulihan fisik hingga 30%.";
      headingPosisi = "☁️ Lingkungan";
      deskripsiPosisi = "Lakukan di tempat yang tenang dengan pencahayaan yang redup agar lebih rileks.";
    }

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
                  _buildSectionText(deskripsiUtama),

                  const SizedBox(height: 25),
                  _buildHeading(headingEfektif),
                  _buildSectionText(deskripsiEfektif),

                  const SizedBox(height: 30),
                  _buildHeading("🔢 Langkah-Langkah Latihan"),
                  const SizedBox(height: 15),

                  // --- LIST LANGKAH-LANGKAH DINAMIS ---
                  ...langkahLangkah.asMap().entries.map((entry) {
                    return _buildStepItem(entry.key + 1, entry.value);
                  }).toList(),

                  const SizedBox(height: 30),
                  _buildHeading(headingProgres),
                  _buildSectionText(deskripsiProgres),

                  const SizedBox(height: 25),
                  _buildHeading(headingPosisi),
                  _buildSectionText(deskripsiPosisi),
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

  // Widget Pembantu untuk Item Langkah
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
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  color: color,
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