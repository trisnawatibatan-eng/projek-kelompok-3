import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_nav_bar.dart';

<<<<<<< Updated upstream
=======
enum StatusJadwal { menunggu, selesai, ditolak }

class JadwalItem {
  final String jenisTerapi;
  final String namaTerapis;
  final String tanggal;
  final String jam;
  final String alamat;
  final StatusJadwal status;
  final String? alasanPenolakan;

  JadwalItem({
    required this.jenisTerapi,
    required this.namaTerapis,
    required this.tanggal,
    required this.jam,
    required this.alamat,
    required this.status,
    this.alasanPenolakan,
  });
}

>>>>>>> Stashed changes
class JanjiTemuScreen extends StatefulWidget {
  const JanjiTemuScreen({super.key});

  @override
  State<JanjiTemuScreen> createState() => _JanjiTemuScreenState();
}

class _JanjiTemuScreenState extends State<JanjiTemuScreen> {
<<<<<<< Updated upstream
  bool isUpcomingActive = true;
  int _userRating = 0;

  // Map untuk melacak status ulasan per ID kartu
  final Map<String, bool> _ulasanTerkirim = {};
=======
  bool _isHistoryView = false;
  int _selectedRating = 0;

  final List<JadwalItem> daftarJadwal = [
    JadwalItem(
      jenisTerapi: 'Terapi Skoliosis',
      namaTerapis: 'Ftr. Siti Nurhaliza, S.Tr.Kes',
      tanggal: 'Senin, 06 April 2026',
      jam: '14:00 WIB',
      alamat: 'Jl. Tidar No. 1, Jember, Jawa Timur',
      status: StatusJadwal.menunggu,
    ),
    JadwalItem(
      jenisTerapi: 'Terapi Nyeri Punggung',
      namaTerapis: 'Ftr. Siti Nurhaliza, S.Tr.Kes',
      tanggal: 'Senin, 30 Maret 2026',
      jam: '10:00 WIB',
      alamat: 'Jl. Tidar No. 1, Jember, Jawa Timur',
      status: StatusJadwal.selesai,
    ),
    JadwalItem(
      jenisTerapi: 'Terapi Skoliosis',
      namaTerapis: 'Ftr. Siti Nurhaliza, S.Tr.Kes',
      tanggal: 'Senin, 06 April 2026',
      jam: '14:00 WIB',
      alamat: 'Jl. Tidar No. 1, Jember, Jawa Timur',
      status: StatusJadwal.ditolak,
      alasanPenolakan: 'Mohon maaf, jadwal pada tanggal dan waktu yang dipilih sudah penuh.',
    ),
  ];

  // --- MODAL ULASAN (Gambar 2) ---
  void _showRatingDialog(JadwalItem item) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 20),
                    Text('Beri Ulasan', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                Text('Rating Pelayanan', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => IconButton(
                    icon: Icon(index < _selectedRating ? Icons.star : Icons.star_border, color: Colors.orange, size: 30),
                    onPressed: () => setModalState(() => _selectedRating = index + 1),
                  )),
                ),
                const SizedBox(height: 10),
                TextField(maxLines: 3, decoration: InputDecoration(hintText: 'Ceritakan pengalaman Anda...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, height: 45, child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BBA7), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Kirim Ulasan', style: TextStyle(color: Colors.white)),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
>>>>>>> Stashed changes

  // --- MODAL TANGGAL ALTERNATIF ---
  void _showAlternativeDates() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pilih Tanggal Alternatif', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            _alternativeTile('Selasa, 07 April 2026', '09:00 WIB'),
            _alternativeTile('Selasa, 07 April 2026', '16:00 WIB'),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BBA7), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Booking Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _alternativeTile(String d, String t) => ListTile(
    leading: const Icon(Icons.calendar_month, color: Color(0xFF00BBA7)),
    title: Text(d, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
    subtitle: Text(t),
    trailing: const Icon(Icons.circle_outlined),
  );

  @override
  Widget build(BuildContext context) {
    List<JadwalItem> displayList = daftarJadwal.where((item) => _isHistoryView 
      ? (item.status == StatusJadwal.selesai || item.status == StatusJadwal.ditolak) 
      : item.status == StatusJadwal.menunggu).toList();

    return Scaffold(
<<<<<<< Updated upstream
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- HEADER ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
            decoration: const BoxDecoration(
              color: Color(0xFF00BBA7),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
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
=======
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBA7),
        elevation: 0,
        automaticallyImplyLeading: false, // Menghilangkan panah back default
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Janji Temu', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            Text('Kelola jadwal terapi Anda', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  _buildTab("Akan Datang", !_isHistoryView),
                  _buildTab("Riwayat", _isHistoryView),
>>>>>>> Stashed changes
                ],
              ),
            ),
          ),
<<<<<<< Updated upstream

          // --- CONTENT LIST ---
          Expanded(
            child: isUpcomingActive ? _buildUpcomingList() : _buildHistoryList(),
          ),
        ],
      ),
      // BAGIAN bottomNavigationBar SUDAH DIHAPUS AGAR TIDAK DOUBLE
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
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? const Color(0xFF00BBA7) : Colors.grey,
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
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
=======
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: displayList.length,
        itemBuilder: (context, index) => _buildItemCard(displayList[index]),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildTab(String label, bool active) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _isHistoryView = label == "Riwayat"),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: active ? const Color(0xFF00BBA7) : Colors.white))),
      ),
    ),
  );

  Widget _buildItemCard(JadwalItem item) {
    bool isDitolak = item.status == StatusJadwal.ditolak;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDitolak ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDitolak ? Colors.red.shade100 : Colors.grey.shade200),
>>>>>>> Stashed changes
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< Updated upstream
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF00BBA7), size: 18),
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
                    child: Text("Beri Ulasan", style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.w600)),
                  ),
                ),
=======
          ListTile(
            title: Text(item.jenisTerapi, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            trailing: _statusBadge(item.status), // Label di pojok kanan atas
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(children: [
              _infoRow(Icons.person_outline, item.namaTerapis),
              _infoRow(Icons.calendar_today_outlined, "${item.tanggal} • ${item.jam}"),
              _infoRow(Icons.location_on_outlined, item.alamat),
            ]),
          ),
          if (item.status == StatusJadwal.selesai) ...[
            const Divider(),
            _actionBtn("Beri Ulasan", () => _showRatingDialog(item)),
          ] else if (isDitolak) ...[
            const Divider(),
            _rejectionSection(item),
>>>>>>> Stashed changes
          ],
        ],
      ),
    );
  }

<<<<<<< Updated upstream
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
                        const SizedBox(width: 40),
                        Text("Beri Ulasan", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF5F9FF), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(therapy, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(doctor, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Ceritakan pengalaman Anda...",
                        hintStyle: const TextStyle(fontSize: 13),
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00BBA7),
                              elevation: 0,
                            ),
                            child: const Text("Kirim", style: TextStyle(color: Colors.white)),
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
=======
  Widget _statusBadge(StatusJadwal s) {
    String txt = s == StatusJadwal.menunggu ? "Menunggu Konfirmasi" : (s == StatusJadwal.selesai ? "Selesai" : "Booking ditolak");
    Color c = s == StatusJadwal.menunggu ? Colors.orange : (s == StatusJadwal.selesai ? Colors.green : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: s == StatusJadwal.menunggu ? const Color(0xFFFFF8E1) : c.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(txt, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.bold)),
>>>>>>> Stashed changes
    );
  }

  Widget _infoRow(IconData i, String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [Icon(i, size: 18, color: const Color(0xFF00BBA7)), const SizedBox(width: 10), Text(t, style: const TextStyle(fontSize: 12))]),
  );

  Widget _actionBtn(String label, VoidCallback tap) => Padding(
    padding: const EdgeInsets.all(16),
    child: SizedBox(width: double.infinity, height: 45, child: ElevatedButton(onPressed: tap, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BBA7), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text(label, style: const TextStyle(color: Colors.white)))),
  );

  Widget _rejectionSection(JadwalItem item) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Alasan Penolakan", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(item.alasanPenolakan!, style: const TextStyle(fontSize: 12)),
      const SizedBox(height: 12),
      _actionBtn("Lihat Tanggal Alternatif", () => _showAlternativeDates()),
    ]),
  );
}