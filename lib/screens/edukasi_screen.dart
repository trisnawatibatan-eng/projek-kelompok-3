import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detail_artikel_screen.dart'; 

class EdukasiScreen extends StatelessWidget {
  const EdukasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- HEADER HIJAU ---
          Container(
            padding: const EdgeInsets.fromLTRB(10, 50, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF00BBA7),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Edukasi',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Artikel Unggulan',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFeaturedCard(
                          context,
                          tag: 'PERNAPASAN',
                          title: 'Teknik Pernapasan untuk Nyeri Punggung',
                          icon: Icons.air,
                          color: Colors.green,
                        ),
                        _buildFeaturedCard(
                          context,
                          tag: 'LUTUT',
                          title: 'Cara Efektif Pemulihan Nyeri Lutut',
                          icon: Icons.accessibility_new,
                          color: Colors.teal,
                        ),
                        _buildFeaturedCard(
                          context,
                          tag: 'POSTUR',
                          title: 'Memperbaiki Posisi Duduk Saat Bekerja',
                          icon: Icons.chair_alt,
                          color: Colors.blueGrey,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    'Edukasi',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  
                  _buildEdukasiItem(
                    context,
                    icon: Icons.air,
                    color: Colors.green,
                    tag: 'PERNAPASAN',
                    title: 'Teknik Pernapasan untuk Nyeri Punggung',
                    date: '28 Mei 2025',
                  ),
                  _buildEdukasiItem(
                    context,
                    icon: Icons.restaurant,
                    color: Colors.orange,
                    tag: 'NUTRISI',
                    title: 'Suplemen yang Baik untuk Kesehatan Sendi',
                    date: '24 Mei 2025',
                  ),
                  _buildEdukasiItem(
                    context,
                    icon: Icons.fitness_center,
                    color: Colors.blue,
                    tag: 'LATIHAN',
                    title: '5 Gerakan Penguatan Otot Core untuk Pemula',
                    date: '20 Mei 2025',
                  ),
                  _buildEdukasiItem(
                    context,
                    icon: Icons.psychology,
                    color: Colors.purple,
                    tag: 'MENTAL',
                    title: 'Mengelola Stres Saat Proses Pemulihan',
                    date: '15 Mei 2025',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(
    BuildContext context, {
    required String tag,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 15),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailArtikelScreen(
                title: title,
                tag: tag,
                icon: icon,
                color: color,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Icon(icon, color: color, size: 45),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEdukasiItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String tag,
    required String title,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailArtikelScreen(
                title: title,
                tag: tag,
                icon: icon,
                color: color,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tag,
                      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}