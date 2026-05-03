import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class EdukasiScreen extends StatelessWidget {
  const EdukasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBA7), // Hijau FisioCare
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edukasi',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Artikel Unggulan (Grid Horizontal)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Artikel Unggulan',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                children: [
                  _buildFeaturedCard(
                    'FISIOTERAPI',
                    'Cara Efektif Pemulihan Nyeri Punggung Bawah',
                    '8 mnt',
                  ),
                  _buildFeaturedCard(
                    'FISIOTERAPI',
                    'Cara Efektif Pemulihan Nyeri lutut',
                    '8 mnt',
                  ),
                ],
              ),
            ),

            // Bagian Artikel Lain (List Vertical)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
              child: Text(
                'Artikel lain',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            _buildArticleList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget untuk Kartu Unggulan (Atas)
  Widget _buildFeaturedCard(String category, String title, String time) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFF2D8B73), // Hijau Gelap
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(
              child: Icon(Icons.healing, color: Colors.white, size: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BBA7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Color(0xFF00BBA7),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk List Artikel Bawah
  Widget _buildArticleList() {
    final List<Map<String, dynamic>> articles = [
      {'cat': 'FISIOTERAPI', 'title': 'Pentingnya Fisioterapi Setelah Operasi Lutut', 'date': '28 Mei 2026', 'icon': Icons.healing, 'color': Colors.teal},
      {'cat': 'NUTRISI', 'title': 'Suplemen yang Baik untuk Kesehatan Sendi', 'date': '24 Mei 2026', 'icon': Icons.restaurant, 'color': Colors.orange},
      {'cat': 'LATIHAN', 'title': '5 Gerakan Penguatan Otot Core untuk Pemula', 'date': '20 Mei 2026', 'icon': Icons.fitness_center, 'color': Colors.blue},
      {'cat': 'MENTAL', 'title': 'Mengelola Stres Saat Proses Pemulihan', 'date': '16 Mei 2026', 'icon': Icons.psychology, 'color': Colors.purple},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: articles.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (articles[index]['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(articles[index]['icon'] as IconData, color: articles[index]['color'] as Color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      articles[index]['cat'] as String,
                      style: TextStyle(
                        color: articles[index]['color'] as Color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      articles[index]['title'] as String,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      articles[index]['date'] as String,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }
}