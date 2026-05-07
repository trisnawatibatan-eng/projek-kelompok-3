import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF26A69A)),
        useMaterial3: true,
        fontFamily: 'Roboto',
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
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    // weekday: 1=Monday, 7=Sunday
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Jadwal Praktik',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Text(
              'Kelola jadwal Terapi',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Colors.white, size: 16),
            label: const Text(
              'Atur Jadwal',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Booking request & stats
          Container(
            color: const Color(0xFF26A69A),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Permintaan Booking button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.calendar_month_outlined,
                      color: Color(0xFF26A69A),
                      size: 18,
                    ),
                    label: const Text(
                      'Permintaan Booking',
                      style: TextStyle(
                        color: Color(0xFF26A69A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Hari Ini',
                        value: '2',
                        icon: Icons.calendar_today_outlined,
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

          // Date navigator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      selectedDate = selectedDate.subtract(const Duration(days: 1));
                    });
                  },
                ),
                Column(
                  children: [
                    Text(
                      _formatDate(selectedDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      'Tampilkan Kalender',
                      style: TextStyle(
                        color: Color(0xFF26A69A),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      selectedDate = selectedDate.add(const Duration(days: 1));
                    });
                  },
                ),
              ],
            ),
          ),

          // Jadwal list header
          Container(
            color: const Color(0xFFF5F5F5),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            alignment: Alignment.centerLeft,
            child: Text(
              'Jadwal ${_formatDate(selectedDate)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),

          // Jadwal list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: jadwalList.length,
              itemBuilder: (context, index) {
                return _JadwalCard(item: jadwalList[index]);
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

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: const Color(0xFF26A69A), size: 20),
        ],
      ),
    );
  }
}

enum StatusJadwal { belumMulai, berlangsung, selesai }

class JadwalItem {
  final String jamMulai;
  final String jamSelesai;
  final String namaPasien;
  final String jenisTermi;
  final String alamat;
  final String telepon;
  final String pertemuan;
  final StatusJadwal status;

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

class _JadwalCard extends StatelessWidget {
  final JadwalItem item;

  const _JadwalCard({required this.item});

  Color get _borderColor {
    switch (item.status) {
      case StatusJadwal.berlangsung:
        return const Color(0xFFFFB300);
      case StatusJadwal.selesai:
        return const Color(0xFF26A69A);
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: item.status != StatusJadwal.belumMulai
            ? Border.all(color: _borderColor, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge (jika berlangsung atau selesai)
          if (item.status == StatusJadwal.berlangsung)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Sedang Berlangsung',
                style: TextStyle(
                  color: Color(0xFFFFB300),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          if (item.status == StatusJadwal.selesai)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Terapi Selesai',
                style: TextStyle(
                  color: Color(0xFF26A69A),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Jam & nama
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.jamMulai} - ${item.jamSelesai}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.namaPasien,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            item.jenisTermi,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Alamat
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.alamat,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Telepon
                Row(
                  children: [
                    const Icon(Icons.phone_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      item.telepon,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Pertemuan
                Row(
                  children: [
                    const Icon(Icons.repeat_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      item.pertemuan,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    // Chat icon button
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_bubble_outline,
                            size: 18, color: Colors.grey),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Main action button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item.status == StatusJadwal.berlangsung
                              ? const Color(0xFF26A69A)
                              : item.status == StatusJadwal.selesai
                                  ? Colors.grey.shade300
                                  : const Color(0xFF26A69A),
                          foregroundColor: item.status == StatusJadwal.selesai
                              ? Colors.black54
                              : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          item.status == StatusJadwal.belumMulai
                              ? 'Mulai'
                              : item.status == StatusJadwal.berlangsung
                                  ? 'Selesaikan'
                                  : 'Selesai',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}