import 'package:flutter/material.dart';

class FisioterapisJadwalTab extends StatefulWidget {
  const FisioterapisJadwalTab({super.key});

  @override
  State<FisioterapisJadwalTab> createState() => _FisioterapisJadwalTabState();
}

class _FisioterapisJadwalTabState extends State<FisioterapisJadwalTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool showCalendar = false;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _jadwalHeader(context),
          Expanded(child: _jadwalContent(context)),
        ],
      ),
    );
  }

  Widget _jadwalHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 10, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00BBA7), Color(0xFF009688)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.arrow_back, color: Colors.white),
              const SizedBox(width: 10),
              const Text("Jadwal Praktik",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text("Atur Jadwal"),
              )
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Text("Permintaan Booking")),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _infoBox("Hari ini", "2")),
              const SizedBox(width: 10),
              Expanded(child: _infoBox("Total bulan ini", "20")),
            ],
          )
        ],
      ),
    );
  }

  Widget _jadwalContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              showCalendar = !showCalendar;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                showCalendar
                    ? "Sembunyikan Kalender"
                    : "Tampilkan Kalender",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 🔥 INI YANG KAMU LUPA
        if (showCalendar) _buildCalendar(),

        const SizedBox(height: 16),

        _jadwalCard("08:00 - 09:00", "Budi Santoso", false),
        const SizedBox(height: 10),
        _jadwalCard("09:30 - 10:30", "Siti Aminah", true),
      ],
    );
  }

  Widget _infoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _jadwalCard(String waktu, String nama, bool confirmed) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              confirmed ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: confirmed
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              confirmed ? Icons.check_circle : Icons.access_time,
              color: confirmed ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(waktu,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: confirmed
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              confirmed ? "Terkonfirmasi" : "Menunggu",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: confirmed
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    int daysInMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    ).day;

    int firstDayOffset = DateTime(
      selectedDate.year,
      selectedDate.month,
      1,
    ).weekday % 7;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [

          // HEADER BULAN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = DateTime(
                      selectedDate.year,
                      selectedDate.month - 1,
                    );
                  });
                },
                child: const Icon(Icons.chevron_left),
              ),

              Text(
                "${_getMonthName(selectedDate.month)} ${selectedDate.year}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = DateTime(
                      selectedDate.year,
                      selectedDate.month + 1,
                    );
                  });
                },
                child: const Icon(Icons.chevron_right),
              ),
            ],
          ),

          // HARI
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text("Min"), Text("Sen"), Text("Sel"),
              Text("Rab"), Text("Kam"), Text("Jum"), Text("Sab"),
            ],
          ),

          const SizedBox(height: 10),



          // GRID TANGGAL
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + firstDayOffset,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemBuilder: (context, index) {

              if (index < firstDayOffset) {
                return const SizedBox();
              }

              int day = index - firstDayOffset + 1;

              DateTime now = DateTime.now();

              bool isToday =
                  day == now.day &&
                  selectedDate.month == now.month &&
                  selectedDate.year == now.year;

              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isToday ? Colors.teal : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "$day",
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // LEGEND
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _legend(Colors.teal, "Hari Ini"),
              _legend(Colors.teal.withOpacity(0.2), "Ada Jadwal"),
              _legend(Colors.grey.shade300, "Kosong"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return monthNames[month - 1];
  }
}
