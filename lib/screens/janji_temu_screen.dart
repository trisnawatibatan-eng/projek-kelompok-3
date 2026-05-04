import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import screen lain agar navigasi berfungsi (sesuaikan dengan nama class di file Anda)
import 'dashboard_screen.dart';
import 'booking_screen.dart';
import 'laporan_screen.dart';
import 'profile_screen.dart';

class JanjiTemuScreen extends StatefulWidget {
  const JanjiTemuScreen({super.key});

  @override
  State<JanjiTemuScreen> createState() => _JanjiTemuScreenState();
}

class _JanjiTemuScreenState extends State<JanjiTemuScreen> {
  bool isUpcomingActive = true;
  int _userRating = 0;

  // Map untuk melacak status ulasan per ID kartu
  final Map<String, bool> _ulasanTerkirim = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- HEADER ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
            decoration: const BoxDecoration(color: Color(0xFF00796B)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Janji Temu',
                  style: GoogleFonts.inter(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Kelola jadwal terapi Anda',
                  style: GoogleFonts.inter(
                    fontSize: 14, 
                    color: Colors.white.withOpacity(0.9)
                  ),
                ),
              ],
            ),
          ),

          // --- TAB SWITCHER ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey[200], 
                borderRadius: BorderRadius.circular(25)
              ),
              child: Row(
                children: [
                  _buildTabItem("Akan Datang", isUpcomingActive, () {
                    setState(() => isUpcomingActive = true);
                  }),
                  _buildTabItem("Riwayat", !isUpcomingActive, () {
                    setState(() => isUpcomingActive = false);
                  }),
                ],
              ),
            ),
          ),

          // --- CONTENT LIST ---
          Expanded(
            child: isUpcomingActive ? _buildUpcomingList() : _buildHistoryList(),
          ),
        ],
      ),

      // --- BOTTOM NAVIGATION BAR DENGAN NAVIGASI AKTIF ---
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00BBA7),
        unselectedItemColor: Colors.grey,
        currentIndex: 2, // Halaman Janji Temu aktif
        onTap: (index) {
          if (index == 2) return; // Tetap di sini jika klik Janji Temu

          Widget targetScreen;
          switch (index) {
            case 0:
              targetScreen = const DashboardScreen();
              break;
            case 1:
              targetScreen = const BookingScreen();
              break;
            case 3:
              targetScreen = const LaporanScreen();
              break;
            case 4:
              targetScreen = const ProfileScreen();
              break;
            default:
              return;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Pemesanan"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Janji Temu"),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: "Laporan"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isActive 
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)] 
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      children: [
        _buildAppointmentCard(
          id: "upcoming_1",
          title: "Terapi Skoliosis",
          status: "Menunggu Konfirmasi",
          statusColor: const Color(0xFFFFE082),
          labelColor: Colors.black87,
          therapist: "Ftr. Siti Nurhaliza, S.Tr.Kes",
          dateTime: "Senin, 06 Apr 2026 • 14:00 WIB",
          isHistory: false,
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      children: [
        _buildAppointmentCard(
          id: "history_1",
          title: "Terapi Stroke",
          status: "Selesai",
          statusColor: const Color(0xFFD1E4FF),
          labelColor: const Color(0xFF1976D2),
          therapist: "Ftr. Siti Nurhaliza, S.Tr.Kes",
          dateTime: "Jumat, 21 Feb 2026 • 10:00 WIB",
          isHistory: true,
        ),
        const SizedBox(height: 15),
        _buildAppointmentCard(
          id: "history_2",
          title: "Terapi Stroke",
          status: "Selesai",
          statusColor: const Color(0xFFD1E4FF),
          labelColor: const Color(0xFF1976D2),
          therapist: "Ftr. Siti Nurhaliza, S.Tr.Kes",
          dateTime: "Senin, 17 Feb 2026 • 10:00 WIB",
          isHistory: true,
        ),
      ],
    );
  }

  Widget _buildAppointmentCard({
    required String id,
    required String title,
    required String status,
    required Color statusColor,
    required Color labelColor,
    required String therapist,
    required String dateTime,
    required bool isHistory,
  }) {
    bool sudahReview = _ulasanTerkirim[id] ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: labelColor)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildInfoRow(Icons.person_outline, therapist),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.calendar_today_outlined, dateTime),
          
          if (isHistory) ...[
            const SizedBox(height: 20),
            sudahReview 
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.black, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        "Ulasan Anda telah dikirim!", 
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showReviewDialog(id, title, therapist, dateTime),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Beri Ulasan", style: TextStyle(color: Colors.black)),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF00BBA7)),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]))),
      ],
    );
  }

  void _showReviewDialog(String id, String therapy, String doctor, String date) {
    _userRating = 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 20),
                        Text("Beri Ulasan", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF5F9FF), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(therapy, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(doctor, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Rating Pelayanan", style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () => setDialogState(() => _userRating = index + 1),
                          icon: Icon(
                            _userRating > index ? Icons.star : Icons.star_border, 
                            color: _userRating > index ? Colors.amber : Colors.grey[300], 
                            size: 30
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    const Align(alignment: Alignment.centerLeft, child: Text("Ulasan Anda", style: TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Ceritakan pengalaman Anda...",
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Batal"))),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _ulasanTerkirim[id] = true;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BBA7)),
                            child: const Text("Kirim Ulasan", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}