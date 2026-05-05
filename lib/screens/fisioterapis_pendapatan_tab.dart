import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class FisioterapisPendapatanTab extends StatefulWidget {
  final Map<String, dynamic>? profil;
  const FisioterapisPendapatanTab({super.key, this.profil});

  @override
  State<FisioterapisPendapatanTab> createState() =>
      _FisioterapisPendapatanTabState();
}

class _FisioterapisPendapatanTabState extends State<FisioterapisPendapatanTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<Map<String, dynamic>> _allItems = [
    {
      'pasien': 'Budi Santoso',
      'jenis': 'Fisioterapi Lumbal',
      'tanggal': '25 Mar 2026',
      'nominal': 'Rp 150.000',
      'status': 'Dibayar',
      'statusColor': Color(0xFFD1FAE5),
      'statusTextColor': Color(0xFF065F46),
    },
    {
      'pasien': 'Ahmad Rizki',
      'jenis': 'Terapi Bahu',
      'tanggal': '24 Mar 2026',
      'nominal': 'Rp 130.000',
      'status': 'Pending',
      'statusColor': Color(0xFFFEF3C7),
      'statusTextColor': Color(0xFF92400E),
    },
    {
      'pasien': 'Siti Nurhaliza',
      'jenis': 'Fisioterapi Lutut',
      'tanggal': '23 Mar 2026',
      'nominal': 'Rp 160.000',
      'status': 'Dibayar',
      'statusColor': Color(0xFFD1FAE5),
      'statusTextColor': Color(0xFF065F46),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Pendapatan',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.lightText,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(child: Text('Semua', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                Tab(child: Text('Pending', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                Tab(child: Text('Dibayar', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList('semua'),
          _buildList('pending'),
          _buildList('dibayar'),
        ],
      ),
    );
  }

  Widget _buildList(String filter) {
    final filtered = filter == 'semua'
        ? _allItems
        : _allItems
            .where((e) => (e['status'] as String).toLowerCase() == filter)
            .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Ringkasan total
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Pendapatan',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.lightText)),
              const SizedBox(height: 8),
              Text(
                'Rp 3.450.000',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text('Bulan ini',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.lightText)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...filtered.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.receipt_long,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['pasien'],
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryText,
                              )),
                          const SizedBox(height: 2),
                          Text(item['jenis'],
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: AppColors.secondaryText)),
                          const SizedBox(height: 4),
                          Text(item['tanggal'],
                              style: GoogleFonts.inter(
                                  fontSize: 10, color: AppColors.lightText)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(item['nominal'],
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            )),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item['statusColor'],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['status'],
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: item['statusTextColor'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}