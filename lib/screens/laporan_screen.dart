import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../widgets/bottom_nav_bar.dart';

// =============================================================================
// MODEL
// =============================================================================

class _LaporanData {
  final Map<String, dynamic> patient;
  final Map<String, dynamic>? fisioterapis;
  final List<Map<String, dynamic>> records; // sudah include bookings
  final int totalPertemuan;
  final Map<String, List<Map<String, dynamic>>> recordsByService;

  const _LaporanData({
    required this.patient,
    required this.fisioterapis,
    required this.records,
    required this.totalPertemuan,
    required this.recordsByService,
  });
}

// =============================================================================
// SCREEN
// =============================================================================

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final _supabase = Supabase.instance.client;
  late Future<_LaporanData> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _fetchData();
  }

  // ---------------------------------------------------------------------------
  // Fetch data dari Supabase
  // ---------------------------------------------------------------------------
  Future<_LaporanData> _fetchData() async {
    final userId = _supabase.auth.currentUser!.id;

    // 1. Ambil data pasien (patients.id = auth.users.id)
    final patientRes = await _supabase
        .from('patients')
        .select()
        .eq('id', userId)
        .single();

    // 2. Ambil medical_records pasien beserta booking & fisioterapis
    //    Urut dari terbaru
    final recordsRes = await _supabase
        .from('medical_records')
        .select('''
          *,
          bookings (
            id,
            scheduled_date,
            scheduled_time,
            service_type,
            fisioterapis_id
          ),
          fisioterapis (
            id,
            nama_lengkap,
            gelar,
            foto_profil_url
          )
        ''')
        .eq('patient_id', userId)
        .order('created_at', ascending: false);

    final records = (recordsRes as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    // 3. Ambil fisioterapis dari record terbaru (jika ada)
    Map<String, dynamic>? fisioterapis;
    if (records.isNotEmpty) {
      fisioterapis = records.first['fisioterapis'] as Map<String, dynamic>?;
    }

    // 4. Grouping records berdasarkan service_type
    final Map<String, List<Map<String, dynamic>>> recordsByService = {};
    for (final record in records) {
      final booking = record['bookings'] as Map<String, dynamic>?;
      final serviceType = (booking?['service_type'] as String?) ?? 'Lainnya';
      recordsByService.putIfAbsent(serviceType, () => []).add(record);
    }

    return _LaporanData(
      patient: patientRes as Map<String, dynamic>,
      fisioterapis: fisioterapis,
      records: records,
      totalPertemuan: records.length,
      recordsByService: recordsByService,
    );
  }

  // ---------------------------------------------------------------------------
  // Helper: format tanggal
  // ---------------------------------------------------------------------------
  String _fmtTgl(String? raw) {
    if (raw == null) return '-';
    try {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  String _fmtJam(String? raw) {
    if (raw == null) return '';
    try {
      final parts = raw.split(':');
      final startH = int.parse(parts[0]);
      final endH = (startH + 1).toString().padLeft(2, '0');
      final start = '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      return '$start - $endH:${parts[1].padLeft(2, '0')} (60 menit)';
    } catch (_) {
      return raw;
    }
  }

  // ---------------------------------------------------------------------------
  // Export PDF per pertemuan
  // ---------------------------------------------------------------------------
  Future<void> _exportPdf({
    required Map<String, dynamic> record,
    required int sessionNumber,
    required Map<String, dynamic> patient,
    required Map<String, dynamic>? fisioterapis,
  }) async {
    try {
      final pdf = pw.Document();

      final tealColor = PdfColor.fromHex('#00BBA7');
      final lightTeal = PdfColor.fromHex('#E8F8F6');
      final greyColor = PdfColor.fromHex('#6B7280');
      final darkColor = PdfColor.fromHex('#111827');

      final booking = record['bookings'] as Map<String, dynamic>?;
      final namaFisio = fisioterapis?['nama_lengkap'] as String? ?? '-';
      final gelarFisio = fisioterapis?['gelar'] as String? ?? '';
      final namaLengkapFisio =
          gelarFisio.isNotEmpty ? '$namaFisio, $gelarFisio' : namaFisio;

      pw.Widget soapRow(String label, String value) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label,
                  style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: greyColor)),
              pw.SizedBox(height: 4),
              pw.Text(value,
                  style: pw.TextStyle(fontSize: 11, color: darkColor)),
            ],
          );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                    color: tealColor,
                    borderRadius: pw.BorderRadius.circular(10)),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Laporan Medis',
                              style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text(patient['full_name'] as String? ?? '-',
                              style: pw.TextStyle(
                                  color: PdfColors.white, fontSize: 13)),
                          if ((patient['phone'] as String? ?? '').isNotEmpty)
                            pw.Text(patient['phone'] as String,
                                style: pw.TextStyle(
                                    color: PdfColors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                            'Dicetak: ${DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.now())}',
                            style: pw.TextStyle(
                                color: PdfColors.white, fontSize: 10)),
                        pw.SizedBox(height: 2),
                        pw.Text('Pertemuan $sessionNumber',
                            style: pw.TextStyle(
                                color: PdfColors.white, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Detail Pertemuan $sessionNumber',
                  style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: darkColor)),
              pw.SizedBox(height: 10),
            ],
          ),
          footer: (ctx) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Laporan Fisioterapi — ${patient['full_name']}',
                  style: pw.TextStyle(fontSize: 9, color: greyColor)),
              pw.Text('Halaman ${ctx.pageNumber} dari ${ctx.pagesCount}',
                  style: pw.TextStyle(fontSize: 9, color: greyColor)),
            ],
          ),
          build: (_) => [
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(
                    color: PdfColor.fromHex('#E5E7EB'), width: 1),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(14),
                    decoration: pw.BoxDecoration(
                      color: lightTeal,
                      borderRadius: const pw.BorderRadius.only(
                        topLeft: pw.Radius.circular(10),
                        topRight: pw.Radius.circular(10),
                      ),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Container(
                          width: 32,
                          height: 32,
                          decoration: pw.BoxDecoration(
                              color: tealColor,
                              borderRadius: pw.BorderRadius.circular(8)),
                          child: pw.Center(
                            child: pw.Text('$sessionNumber',
                                style: pw.TextStyle(
                                    color: PdfColors.white,
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.SizedBox(width: 12),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Pertemuan $sessionNumber',
                                  style: pw.TextStyle(
                                      fontSize: 13,
                                      fontWeight: pw.FontWeight.bold,
                                      color: darkColor)),
                              pw.SizedBox(height: 3),
                              pw.Text(
                                _fmtTgl(booking?['scheduled_date'] as String?) +
                                    (booking?['scheduled_time'] != null
                                        ? '  |  ${_fmtJam(booking!['scheduled_time'] as String)}'
                                        : ''),
                                style: pw.TextStyle(
                                    fontSize: 10, color: greyColor)),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 12),
                        pw.Text(namaLengkapFisio,
                            style:
                                pw.TextStyle(fontSize: 11, color: greyColor)),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(14),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (record['subjective'] != null) ...[
                          soapRow('Keluhan (S)', record['subjective'] as String),
                          pw.SizedBox(height: 10),
                        ],
                        if (record['objective'] != null) ...[
                          soapRow('Data Pemeriksaan (O)',
                              record['objective'] as String),
                          pw.SizedBox(height: 10),
                        ],
                        if (record['assessment'] != null) ...[
                          soapRow('Diagnosa (A)', record['assessment'] as String),
                          pw.SizedBox(height: 10),
                        ],
                        if (record['plan'] != null) ...[
                          soapRow('Perencanaan Tindakan (P)',
                              record['plan'] as String),
                          pw.SizedBox(height: 10),
                        ],
                        if (record['evaluasi_terapi'] != null) ...[
                          pw.Container(
                            width: double.infinity,
                            padding: const pw.EdgeInsets.all(12),
                            decoration: pw.BoxDecoration(
                              color: lightTeal,
                              borderRadius: pw.BorderRadius.circular(8),
                              border: pw.Border.all(
                                  color: PdfColor.fromHex('#B2EDE7')),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Evaluasi Terapi',
                                    style: pw.TextStyle(
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold,
                                        color: tealColor)),
                                pw.SizedBox(height: 4),
                                pw.Text(record['evaluasi_terapi'] as String,
                                    style: pw.TextStyle(
                                        fontSize: 11, color: tealColor)),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 10),
                        ],
                        if (record['rekomendasi_latihan'] != null) ...[
                          soapRow('Rekomendasi Latihan',
                              record['rekomendasi_latihan'] as String),
                          pw.SizedBox(height: 10),
                        ],
                        if (record['terapi_berikutnya'] != null)
                          soapRow('Terapi Berikutnya',
                              _fmtTgl(record['terapi_berikutnya'] as String)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name:
            'LaporanMedis_${(patient['full_name'] as String).replaceAll(' ', '_')}_Sesi${sessionNumber}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal membuat laporan: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FutureBuilder<_LaporanData>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00BBA7)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          return _buildContent(data);
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildContent(_LaporanData data) {
    final patient = data.patient;
    final namaFisio = data.fisioterapis?['nama_lengkap'] as String? ?? '-';
    final gelarFisio = data.fisioterapis?['gelar'] as String? ?? '';
    final namaLengkapFisio =
        gelarFisio.isNotEmpty ? '$namaFisio, $gelarFisio' : namaFisio;

    // Inisial fisioterapis untuk avatar
    final parts = namaFisio.trim().split(' ');
    final inisialFisio = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (namaFisio.isNotEmpty ? namaFisio[0].toUpperCase() : 'F');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ──
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                    top: 60, left: 25, right: 25, bottom: 60),
                decoration: const BoxDecoration(color: Color(0xFF00BBA7)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Laporan Medis',
                        style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text('Riwayat pemeriksaan dan terapi',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9))),
                  ],
                ),
              ),
              // ── Kartu Profil Pasien (floating) ──
              Positioned(
                bottom: -44,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(Icons.person,
                              color: Color(0xFF00BBA7), size: 26),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient['full_name'] as String? ?? '-',
                            style: GoogleFonts.inter(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'ID: ${(patient['id'] as String).substring(0, 12).toUpperCase()}',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 62),

          // ── KONTEN ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul + badge total pertemuan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.description_outlined,
                            color: Color(0xFF00BBA7), size: 18),
                        const SizedBox(width: 8),
                        Text('Catatan Terapi',
                            style: GoogleFonts.inter(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7F4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${data.totalPertemuan} Pertemuan',
                        style: GoogleFonts.inter(
                            color: const Color(0xFF00BBA7), fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Daftar pertemuan dikelompokkan per layanan ──
                if (data.records.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.description_outlined,
                              size: 56, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('Belum ada catatan terapi',
                              style: GoogleFonts.inter(
                                  color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                else
                  ...data.recordsByService.entries.expand((serviceEntry) {
                    final serviceType = serviceEntry.key;
                    final serviceRecords = serviceEntry.value;

                    return [
                      // ── Label kategori layanan ──
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, top: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00BBA7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.medical_services_outlined,
                                      size: 14, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    serviceType,
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${serviceRecords.length} pertemuan',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),

                      // ── Kartu per sesi dalam kategori ini ──
                      ...serviceRecords.map((record) {
                        final globalIdx = data.records.indexOf(record);
                        final sessionNumber = data.records.length - globalIdx;
                        return _PertemuanCard(
                          record: record,
                          sessionNumber: sessionNumber,
                          namaFisio: namaLengkapFisio,
                          inisialFisio: inisialFisio,
                          patient: patient,
                          fisioterapis: data.fisioterapis,
                          fmtTgl: _fmtTgl,
                          fmtJam: _fmtJam,
                          onExport: () => _exportPdf(
                            record: record,
                            sessionNumber: sessionNumber,
                            patient: patient,
                            fisioterapis: data.fisioterapis,
                          ),
                        );
                      }),

                      const SizedBox(height: 8),
                    ];
                  }),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CARD PER PERTEMUAN
// =============================================================================

class _PertemuanCard extends StatefulWidget {
  final Map<String, dynamic> record;
  final int sessionNumber;
  final String namaFisio;
  final String inisialFisio;
  final Map<String, dynamic> patient;
  final Map<String, dynamic>? fisioterapis;
  final String Function(String?) fmtTgl;
  final String Function(String?) fmtJam;
  final Future<void> Function() onExport;

  const _PertemuanCard({
    required this.record,
    required this.sessionNumber,
    required this.namaFisio,
    required this.inisialFisio,
    required this.patient,
    required this.fisioterapis,
    required this.fmtTgl,
    required this.fmtJam,
    required this.onExport,
  });

  @override
  State<_PertemuanCard> createState() => _PertemuanCardState();
}

class _PertemuanCardState extends State<_PertemuanCard> {
  bool _isExporting = false;

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    try {
      await widget.onExport();
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.record['bookings'] as Map<String, dynamic>?;
    final scheduledDate = booking?['scheduled_date'] as String?;
    final scheduledTime = booking?['scheduled_time'] as String?;
    final r = widget.record;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header card (teal muda) ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFE0F7F4),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                // Badge "Pertemuan #N"
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BBA7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Pertemuan #${widget.sessionNumber}',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.calendar_today_outlined,
                    size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  widget.fmtTgl(scheduledDate),
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                ),
                const Spacer(),
                // Tombol download PDF
                GestureDetector(
                  onTap: _isExporting ? null : _handleExport,
                  child: _isExporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFF00BBA7)),
                        )
                      : const Icon(Icons.file_download_outlined,
                          color: Color(0xFF00BBA7), size: 22),
                ),
              ],
            ),
          ),

          // ── Nama fisioterapis ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BBA7).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      widget.inisialFisio,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF00BBA7)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.namaFisio,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Divider(height: 20, color: Color(0xFFF0F0F0)),
          ),

          // ── Info pertemuan ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F6),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.sessionNumber}',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF00BBA7)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pertemuan ${widget.sessionNumber}',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 11, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(widget.fmtTgl(scheduledDate),
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.grey)),
                    ]),
                    if (scheduledTime != null)
                      Row(children: [
                        const Icon(Icons.access_time,
                            size: 11, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(widget.fmtJam(scheduledTime),
                            style: GoogleFonts.inter(
                                fontSize: 11, color: Colors.grey)),
                      ]),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Tampilan ringkas: hanya Perencanaan Tindakan & Evaluasi Terapi ──
          // (PDF download tetap export SOAP lengkap)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (r['plan'] != null) ...[
                  _soapSection(
                      'Perencanaan Tindakan:', r['plan'] as String),
                  const SizedBox(height: 10),
                ],

                // Evaluasi Terapi (kotak teal muda)
                if (r['evaluasi_terapi'] != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1FAF9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFB2DFDB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Evaluasi Terapi',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00796B),
                                fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(r['evaluasi_terapi'] as String,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF00897B))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Rekomendasi Latihan
                if (r['rekomendasi_latihan'] != null) ...[
                  Text('Rekomendasi Latihan',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(r['rekomendasi_latihan'] as String,
                      style: GoogleFonts.inter(
                          fontSize: 12, height: 1.6, color: Colors.black87)),
                  const SizedBox(height: 12),
                ],

                // Terapi Berikutnya
                if (r['terapi_berikutnya'] != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5FDFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF00BBA7).withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined,
                            size: 16, color: Color(0xFF00796B)),
                        const SizedBox(width: 8),
                        Text('Terapi Berikutnya:',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF00796B))),
                        const Spacer(),
                        Text(
                          widget.fmtTgl(r['terapi_berikutnya'] as String?),
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00796B),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _soapSection(String label, String content) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(content,
              style: GoogleFonts.inter(fontSize: 12, height: 1.4)),
        ],
      );
}