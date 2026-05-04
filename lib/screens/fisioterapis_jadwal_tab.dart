import 'package:flutter/material.dart';

class FisioterapisJadwalTab extends StatefulWidget {
  const FisioterapisJadwalTab({super.key});

  @override
  State<FisioterapisJadwalTab> createState() => _FisioterapisJadwalTabState();
}

class _FisioterapisJadwalTabState extends State<FisioterapisJadwalTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text("Tampilkan Kalender")),
        ),
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
}
