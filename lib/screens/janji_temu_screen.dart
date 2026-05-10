import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class JanjiTemuScreen extends StatefulWidget {
  const JanjiTemuScreen({super.key});

  @override
  State<JanjiTemuScreen> createState() => _JanjiTemuScreenState();
}

class _JanjiTemuScreenState extends State<JanjiTemuScreen> {
  DateTime _focusedMonth = DateTime(2026, 3);
  DateTime? _selectedDate = DateTime(2026, 3, 30);

  static const Color primaryColor = Color(0xFF00BBA7);
  static const Color bgColor = Color(0xFFF0FAFA);

  // Dummy data: tanggal yang ada jadwal terapi
  final List<int> _terapiDays = [25, 30];

  // Dummy data janji temu
  final List<Map<String, dynamic>> _janjiList = [
    {
      'nama': 'Ftr. Siti Nurhaliza, S.Tr.Kes',
      'tanggal': 'Besok, 25 Mar 2026',
      'waktu': '10:00–11:00',
      'durasi': '60 menit',
      'status': 'Menunggu Pembayaran',
      'isToday': true,
    },
  ];

  final List<Map<String, dynamic>> _riwayatList = [
    {
      'nama': 'Ftr. Siti Nurhaliza, S.Tr.Kes',
      'tanggal': 'Besok, 25 Mar',
      'waktu': '10:00–11:00',
      'durasi': '60 mnt',
      'status': 'Selesai',
    },
  ];

  int _getDaysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  int _firstWeekdayOfMonth(int year, int month) {
    // Monday=0 ... Sunday=6
    int wd = DateTime(year, month, 1).weekday; // 1=Mon,7=Sun
    return wd - 1;
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  String _monthName(int month) {
    const names = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return names[month];
  }

  bool _isToday(int day) {
    final now = DateTime.now();
    return _focusedMonth.year == now.year &&
        _focusedMonth.month == now.month &&
        day == now.day;
  }

  bool _isSelected(int day) {
    return _selectedDate != null &&
        _selectedDate!.year == _focusedMonth.year &&
        _selectedDate!.month == _focusedMonth.month &&
        _selectedDate!.day == day;
  }

  bool _hasTerapi(int day) => _terapiDays.contains(day);

  Widget _buildCalendar() {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final daysInMonth = _getDaysInMonth(year, month);
    final firstWeekday = _firstWeekdayOfMonth(year, month);

    final List<String> headers = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    // Reorder: Mon first
    // headers: Sen Sel Rab Kam Jum Sab Min
    final List<String> orderedHeaders = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    // Build day grid: firstWeekday offset (Mon=0 => index 1 in our Sun-first grid)
    // We use Mon-first layout (firstWeekday: Mon=0)
    // But in our header we show Min first (Sun=6 in weekday, so offset = firstWeekday+1 mod 7? No.
    // Let's just use standard Sun-first for simplicity to match image (image shows Min..Sab = Sun..Sat)
    // DateTime.weekday: 1=Mon, 7=Sun
    // firstWeekday of month with Sun=0: (DateTime(y,m,1).weekday % 7)
    final int sunFirstOffset = DateTime(year, month, 1).weekday % 7;

    List<Widget> cells = [];
    // Empty cells before day 1
    for (int i = 0; i < sunFirstOffset; i++) {
      cells.add(const SizedBox());
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final bool today = _isToday(d);
      final bool selected = _isSelected(d);
      final bool hasTerapi = _hasTerapi(d);

      cells.add(GestureDetector(
        onTap: () => setState(() => _selectedDate = DateTime(year, month, d)),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: selected
                ? primaryColor
                : today
                    ? primaryColor.withOpacity(0.15)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: selected
                ? null
                : hasTerapi && !today
                    ? Border.all(color: primaryColor.withOpacity(0.4), width: 1)
                    : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$d',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : today
                          ? primaryColor
                          : Colors.black87,
                ),
              ),
              if (hasTerapi)
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month navigator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _prevMonth,
                icon: const Icon(Icons.chevron_left, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                '${_monthName(month)} $year',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Day headers
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: orderedHeaders
                .map((h) => Center(
                      child: Text(
                        h,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ))
                .toList(),
          ),
          // Day cells
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            children: cells,
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            children: [
              _legendItem(primaryColor, 'Hari Ini'),
              const SizedBox(width: 12),
              _legendItem(primaryColor.withOpacity(0.2), 'Jadwal Terapi',
                  isOutline: true),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                      width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, {bool isOutline = false}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: isOutline ? Colors.white : color,
            borderRadius: BorderRadius.circular(3),
            border: isOutline ? Border.all(color: color, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color textColor;
    switch (status) {
      case 'Menunggu Pembayaran':
        bg = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF856404);
        break;
      case 'Selesai':
        bg = const Color(0xFFD1ECF1);
        textColor = const Color(0xFF0C5460);
        break;
      case 'Dikonfirmasi':
        bg = const Color(0xFFD4EDDA);
        textColor = const Color(0xFF155724);
        break;
      default:
        bg = Colors.grey.shade200;
        textColor = Colors.black54;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
    );
  }

  Widget _buildTerapiHariIni() {
    final item = _janjiList.first;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item['tanggal'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(item['status']),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item['nama'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(item['waktu'],
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12)),
                const SizedBox(width: 16),
                const Icon(Icons.timer_outlined, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(item['durasi'],
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: primaryColor, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item['nama'],
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              _buildStatusBadge(item['status']),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  color: Colors.grey, size: 13),
              const SizedBox(width: 4),
              Text(item['tanggal'],
                  style:
                      const TextStyle(color: Colors.black54, fontSize: 11)),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, color: Colors.grey, size: 13),
              const SizedBox(width: 4),
              Text(item['waktu'],
                  style:
                      const TextStyle(color: Colors.black54, fontSize: 11)),
              const SizedBox(width: 12),
              const Icon(Icons.timer_outlined, color: Colors.grey, size: 13),
              const SizedBox(width: 4),
              Text(item['durasi'],
                  style:
                      const TextStyle(color: Colors.black54, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Jadwal Terapi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar
            _buildCalendar(),
            const SizedBox(height: 20),

            // Terapi Hari Ini
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Terapi Hari Ini',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black87),
              ),
            ),
            const SizedBox(height: 10),
            _buildTerapiHariIni(),
            const SizedBox(height: 20),

            // Riwayat Terapi
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Riwayat Terapi',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black87),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: _riwayatList
                    .map((item) => _buildRiwayatCard(item))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}