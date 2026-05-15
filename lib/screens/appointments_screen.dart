import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _appointments = [
    {
      'title': 'Sesi Fisioterapi Lumbal',
      'therapist': 'Ftr. Siti Nurhaliza S.Tr.Kes',
      'date': 'Senin, 25 Mar 2026',
      'time': '10:00–11:00 WIB',
      'status': 'Terkonfirmasi',
      'type': 'Home Visit',
      'price': 'Rp 150.000',
      'emoji': '👩‍⚕️',
      'tab': 'upcoming',
    },
    {
      'title': 'Terapi Bahu Kanan',
      'therapist': 'Ftr. Ahmad Rizky S.Fis',
      'date': 'Jumat, 28 Mar 2026',
      'time': '14:00–15:00 WIB',
      'status': 'Menunggu',
      'type': 'Klinik',
      'price': 'Rp 130.000',
      'emoji': '👨‍⚕️',
      'tab': 'upcoming',
    },
    {
      'title': 'Sesi Terapi Punggung',
      'therapist': 'Ftr. Siti Nurhaliza S.Tr.Kes',
      'date': 'Jumat, 14 Mar 2026',
      'time': '10:00–11:00 WIB',
      'status': 'Selesai',
      'type': 'Home Visit',
      'price': 'Rp 150.000',
      'emoji': '👩‍⚕️',
      'tab': 'history',
    },
  ];

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

  // Fungsi helper untuk mendapatkan warna status
  Color _getStatusColor(String status, bool isText) {
    switch (status) {
      case 'Terkonfirmasi':
      case 'Selesai':
        return isText ? const Color(0xFF065F46) : const Color(0xFFD1FAE5);
      case 'Menunggu':
        return isText ? const Color(0xFFB45309) : const Color(0xFFFEF3C7);
      default:
        return isText ? Colors.blue : Colors.blue.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(_appointments),
                _buildList(_appointments.where((a) => a['tab'] == 'upcoming').toList()),
                _buildList(_appointments.where((a) => a['tab'] == 'history').toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00BBA7), Color(0xFF009689)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Janji Temu', 
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                  )
                ],
              ),
              Text('Pantau jadwal terapi Anda', 
                style: GoogleFonts.inter(color: const Color(0xFFD9EFED), fontSize: 13)),
              const SizedBox(height: 15),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.6),
                labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                tabs: const [Tab(text: 'Semua'), Tab(text: 'Mendatang'), Tab(text: 'Riwayat')],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📅', style: GoogleFonts.inter(fontSize: 60)),
            const SizedBox(height: 16),
            Text('Tidak ada janji temu', 
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightText)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _buildCard(items[i]),
    );
  }

  Widget _buildCard(Map<String, dynamic> apt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFF1F5F9),
                      ),
                      child: Center(child: Text(apt['emoji'], style: GoogleFonts.inter(fontSize: 24))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(apt['title'], 
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
                          Text(apt['therapist'], 
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.blueGrey)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(apt['status'], false),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(apt['status'], 
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: _getStatusColor(apt['status'], true))),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 14, color: Colors.teal),
                    const SizedBox(width: 6),
                    Text(apt['date'], style: GoogleFonts.inter(fontSize: 12, color: Colors.black87)),
                    const SizedBox(width: 15),
                    const Icon(Icons.access_time, size: 14, color: Colors.teal),
                    const SizedBox(width: 6),
                    Text(apt['time'], style: GoogleFonts.inter(fontSize: 12, color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(apt['type'], style: GoogleFonts.inter(fontSize: 12, color: Colors.black87)),
                    const Spacer(),
                    Text(apt['price'], 
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF009689))),
                  ],
                ),
              ],
            ),
          ),
          if (apt['tab'] == 'upcoming')
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Batalkan', style: GoogleFonts.inter(fontSize: 12, color: Colors.redAccent)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009689),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Bantuan', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}