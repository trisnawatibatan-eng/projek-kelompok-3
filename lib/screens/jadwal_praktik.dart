import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Pastikan sudah install google_fonts di pubspec.yaml
import 'fisioterapis_booking_screen.dart';

enum StatusJadwal { belumMulai, berlangsung, selesai }

class JadwalItem {
  final String jamMulai;
  final String jamSelesai;
  final String namaPasien;
  final String jenisTermi;
  final String alamat;
  final String telepon;
  final String pertemuan;
  StatusJadwal status;

  JadwalItem({
    required this.jamMulai,
    required this.jamSelesai,
    required this.namaPasien,
    required this.jenisTermi,
    required this.alamat,
    required this.telepon,
    required this.pertemuan,
    required this.status,
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jadwal Praktik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00BBA7)),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const JadwalPraktikScreen(),
    );
  }
}

class JadwalPraktikScreen extends StatefulWidget {
  const JadwalPraktikScreen({super.key});

  @override
  State<JadwalPraktikScreen> createState() => _JadwalPraktikScreenState();
}

class _JadwalPraktikScreenState extends State<JadwalPraktikScreen> {
  DateTime selectedDate = DateTime(2026, 3, 30);

  final List<JadwalItem> jadwalList = [
    JadwalItem(
      jamMulai: '08:00',
      jamSelesai: '09:00',
      namaPasien: 'Budi Santoso',
      jenisTermi: 'Terapi Stroke',
      alamat: 'Jl. Merdeka No. 123, Jakarta Pusat',
      telepon: '+62 813 3456 7890',
      pertemuan: 'Pertemuan ke-3 dari 12',
      status: StatusJadwal.belumMulai,
    ),
    JadwalItem(
      jamMulai: '09:30',
      jamSelesai: '10:30',
      namaPasien: 'Siti Aminah',
      jenisTermi: 'Terapi Nyeri Punggung',
      alamat: 'Jl. Sudirman No. 45, Jakarta Pusat',
      telepon: '+62 813 4567 8901',
      pertemuan: 'Pertemuan pertama',
      status: StatusJadwal.berlangsung,
    ),
    JadwalItem(
      jamMulai: '09:00',
      jamSelesai: '10:30',
      namaPasien: 'Siti Aminah',
      jenisTermi: 'Terapi Nyeri Punggung',
      alamat: 'Jl. Sudirman No. 45, Jakarta Pusat',
      telepon: '+62 813 4567 8901',
      pertemuan: 'Pertemuan pertama',
      status: StatusJadwal.selesai,
    ),
  ];

  String _formatDate(DateTime date) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBA7),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jadwal Praktik',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Kelola jadwal Terapi',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, size: 20),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text("Atur Jadwal", style: GoogleFonts.inter(fontSize: 12)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Bagian Hijau (Button & Stats)
          Container(
            color: const Color(0xFF00BBA7),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              children: [
                // Button Permintaan Booking (Sesuai Figma)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FisioterapiBookingScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: Color(0xFF00BBA7), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Permintaan Booking',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF00BBA7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Hari Ini',
                        value: '2',
                        icon: Icons.calendar_today,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Total Pasien Bulan Ini',
                        value: '20',
                        icon: Icons.people_outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Date Navigator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.grey),
                  onPressed: () => setState(() => selectedDate = selectedDate.subtract(const Duration(days: 1))),
                ),
                Column(
                  children: [
                    Text(
                      _formatDate(selectedDate),
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      'Tampilkan Kalender',
                      style: GoogleFonts.inter(color: const Color(0xFF00BBA7), fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.grey),
                  onPressed: () => setState(() => selectedDate = selectedDate.add(const Duration(days: 1))),
                ),
              ],
            ),
          ),

          // List Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Jadwal ${_formatDate(selectedDate)}',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),

          // List Jadwal
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: jadwalList.length,
              itemBuilder: (context, index) {
                final item = jadwalList[index];
                return _JadwalCard(
                  item: item,
                  onPressed: item.status == StatusJadwal.selesai
                      ? null
                      : () async {
                          if (item.status == StatusJadwal.belumMulai) {
                            setState(() => item.status = StatusJadwal.berlangsung);
                          }
                          final completed = await Navigator.push<bool?>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => _SelesaikanFormScreen(item: item),
                            ),
                          );
                          if (completed == true) {
                            setState(() => item.status = StatusJadwal.selesai);
                          }
                        },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 10, color: Colors.black54, height: 1.2),
            ),
          ),
          Icon(icon, color: const Color(0xFF00BBA7), size: 20),
        ],
      ),
    );
  }
}

// ... (Tetap gunakan Enum StatusJadwal dan Class JadwalItem milik Anda)

class _JadwalCard extends StatelessWidget {
  final JadwalItem item;
  final VoidCallback? onPressed;

  const _JadwalCard({required this.item, this.onPressed});

  @override
  Widget build(BuildContext context) {
    bool isBerlangsung = item.status == StatusJadwal.berlangsung;
    bool isSelesai = item.status == StatusJadwal.selesai;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isBerlangsung 
            ? Border.all(color: const Color(0xFFFFB300), width: 1.5)
            : isSelesai ? Border.all(color: const Color(0xFF00BBA7), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          if (isBerlangsung || isSelesai)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isBerlangsung ? const Color(0xFFFFF8E1) : const Color(0xFFE0F2F1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: Center(
                child: Text(
                  isBerlangsung ? 'Sedang Berlangsung' : 'Terapi Selesai',
                  style: GoogleFonts.inter(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    color: isBerlangsung ? const Color(0xFFFFB300) : const Color(0xFF00BBA7)
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${item.jamMulai} - ${item.jamSelesai}', 
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.namaPasien, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(item.jenisTermi, style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _iconInfo(Icons.location_on_outlined, item.alamat),
                _iconInfo(Icons.phone_outlined, item.telepon),
                _iconInfo(Icons.repeat, item.pertemuan),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item.status == StatusJadwal.selesai ? Colors.grey.shade200 : const Color(0xFF00BBA7),
                          foregroundColor: item.status == StatusJadwal.selesai ? Colors.black54 : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          item.status == StatusJadwal.belumMulai ? 'Mulai' : 
                          isBerlangsung ? 'Selesaikan' : 'Selesai',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 12, color: Colors.black54))),
        ],
      ),
    );
  }
}

class _SelesaikanFormScreen extends StatelessWidget {
  final JadwalItem item;

  const _SelesaikanFormScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBA7),
        title: Text('Form Selesaikan', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item.jamMulai} - ${item.jamSelesai}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(item.namaPasien, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(item.jenisTermi, style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 12),
                  _detailRow(Icons.location_on_outlined, item.alamat),
                  _detailRow(Icons.phone_outlined, item.telepon),
                  _detailRow(Icons.repeat, item.pertemuan),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selesaikan Layanan', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 16),
                    Text('Pastikan pasien sudah menyelesaikan sesi dan pembayaran sebelum menandai selesai.', style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 16),
                    TextFormField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Catatan penyelesaian (opsional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => _confirmCompletion(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BBA7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text('Selesaikan', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCompletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Pembayaran dan Layanan', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Apakah anda yakin pasien sudah melakukan layanan dan pembayaran?', style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Belum', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BBA7)),
            child: Text('Sudah', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 12, color: Colors.black54))),
        ],
      ),
    );
  }
}
