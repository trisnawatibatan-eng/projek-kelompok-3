import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// =============================================================================
// SCREEN UTAMA
// =============================================================================

class FisioterapisPasienDetail extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String? inisial;
  final Color? avatarColor;

  /// Jika dibuka dari halaman booking yang baru selesai,
  /// isi [fromBookingId] agar form SOAP langsung terhubung ke booking itu.
  final String? fromBookingId;

  const FisioterapisPasienDetail({
    super.key,
    required this.patientId,
    required this.patientName,
    this.inisial,
    this.avatarColor,
    this.fromBookingId,
  });

  @override
  State<FisioterapisPasienDetail> createState() =>
      _FisioterapisPasienDetailState();
}

class _FisioterapisPasienDetailState extends State<FisioterapisPasienDetail>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  late TabController _tabController;
  late Future<Map<String, dynamic>> _futureDetail;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _futureDetail = _fetchDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _futureDetail = _fetchDetail();
    });
  }

  // ---------------------------------------------------------------------------
  // Fetch: profil pasien + semua catatan medis + hitung nomor sesi
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> _fetchDetail() async {
    final patientRes = await _supabase
        .from('patients')
        .select()
        .eq('id', widget.patientId)
        .single();

    final userId = _supabase.auth.currentUser!.id;
    final fisioRes = await _supabase
        .from('fisioterapis')
        .select('id')
        .eq('user_id', userId)
        .single();
    final fisioterapisId = fisioRes['id'] as String;

    final recordsRes = await _supabase
        .from('medical_records')
        .select('''
          *,
          bookings (
            id,
            scheduled_date,
            scheduled_time,
            service_type
          )
        ''')
        .eq('patient_id', widget.patientId)
        .eq('fisioterapis_id', fisioterapisId)
        .order('created_at', ascending: false);

    final records = recordsRes as List;

    String? targetBookingId = widget.fromBookingId;

    if (targetBookingId == null) {
      final existingBookingIds = records
          .map((r) =>
              (r['bookings'] as Map?)?.containsKey('id') == true
                  ? r['bookings']['id'] as String?
                  : null)
          .whereType<String>()
          .toSet();

      final completedBookings = await _supabase
          .from('bookings')
          .select('id, service_type, scheduled_date')
          .eq('patient_id', widget.patientId)
          .eq('fisioterapis_id', fisioterapisId)
          .eq('status', 'completed')
          .order('scheduled_date', ascending: false);

      for (final b in completedBookings as List) {
        final bid = b['id'] as String;
        if (!existingBookingIds.contains(bid)) {
          targetBookingId = bid;
          break;
        }
      }
    }

    final allCompleted = await _supabase
        .from('bookings')
        .select('id, service_type, scheduled_date')
        .eq('patient_id', widget.patientId)
        .eq('fisioterapis_id', fisioterapisId)
        .eq('status', 'completed')
        .order('scheduled_date', ascending: true);

    final Map<String, Map<String, dynamic>> sessionMap = {};
    final Map<String, int> serviceCounter = {};
    for (final b in allCompleted as List) {
      final bid = b['id'] as String;
      final svc = b['service_type'] as String;
      serviceCounter[svc] = (serviceCounter[svc] ?? 0) + 1;
      sessionMap[bid] = {
        'session_number': serviceCounter[svc],
        'service_type': svc,
      };
    }

    final latestRecord =
        records.isNotEmpty ? records.first as Map<String, dynamic> : null;

    return {
      'patient': patientRes as Map<String, dynamic>,
      'records': records,
      'fisioterapis_id': fisioterapisId,
      'target_booking_id': targetBookingId,
      'session_map': sessionMap,
      'latest_record': latestRecord,
    };
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  int? _hitungUsia(String? dob) {
    if (dob == null || dob.isEmpty) return null;
    try {
      final birth = dob.contains('-')
          ? DateTime.parse(dob)
          : () {
              final p = dob.split('/');
              return DateTime(
                  int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
            }();
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month ||
          (now.month == birth.month && now.day < birth.day)) age--;
      return age;
    } catch (_) {
      return null;
    }
  }

  String get _initials {
    if (widget.inisial != null) return widget.inisial!;
    final parts = widget.patientName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return widget.patientName.isNotEmpty
        ? widget.patientName[0].toUpperCase()
        : '?';
  }

  Color get _color => widget.avatarColor ?? const Color(0xFF00BBA7);

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF00BBA7)),
              ),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: const Color(0xFF00BBA7),
                foregroundColor: Colors.white,
                title: Text('Detail Pasien',
                    style:
                        GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          }

          final data = snapshot.data!;
          final patient = data['patient'] as Map<String, dynamic>;
          final records = data['records'] as List;
          final fisioterapisId = data['fisioterapis_id'] as String;
          final targetBookingId = data['target_booking_id'] as String?;
          final sessionMap =
              data['session_map'] as Map<String, Map<String, dynamic>>;
          final latestRecord =
              data['latest_record'] as Map<String, dynamic>?;

          final usia = _hitungUsia(patient['date_of_birth'] as String?);
          final gender = (patient['gender'] as String?) == 'male'
              ? 'Laki-laki'
              : (patient['gender'] as String?) == 'female'
                  ? 'Perempuan'
                  : null;
          final usiaGender = [
            if (usia != null) '$usia tahun',
            if (gender != null) gender,
          ].join(' • ');

          final nextSessionInfo =
              targetBookingId != null ? sessionMap[targetBookingId] : null;
          final nextSessionNumber =
              nextSessionInfo?['session_number'] as int? ?? 1;
          final nextServiceType =
              nextSessionInfo?['service_type'] as String? ?? '';

          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverAppBar(
                  backgroundColor: const Color(0xFF00BBA7),
                  foregroundColor: Colors.white,
                  pinned: true,
                  expandedHeight: 0,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detail Pasien',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Catatan medis & riwayat terapi',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ),

                // ── Kartu profil pasien ──
                SliverToBoxAdapter(
                  child: Container(
                    color: const Color(0xFF00BBA7),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: _color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(_initials,
                                  style: GoogleFonts.inter(
                                    color: _color,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.patientName,
                                    style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)),
                                if (usiaGender.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(usiaGender,
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.grey.shade600)),
                                ],
                                const SizedBox(height: 8),
                                if (patient['phone'] != null &&
                                    (patient['phone'] as String)
                                        .isNotEmpty) ...[
                                  _profileInfoRow(Icons.phone_outlined,
                                      patient['phone'] as String),
                                  const SizedBox(height: 4),
                                ],
                                if (patient['full_address'] != null &&
                                    (patient['full_address'] as String)
                                        .isNotEmpty) ...[
                                  _profileInfoRow(
                                      Icons.location_on_outlined,
                                      patient['full_address'] as String),
                                  const SizedBox(height: 4),
                                ],
                                if (latestRecord != null) ...[
                                  _profileInfoRow(
                                    Icons.monitor_heart_outlined,
                                    (latestRecord['bookings']
                                            as Map<String, dynamic>?)?[
                                        'service_type'] as String? ??
                                        '-',
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Banner "Sesi Baru" ──
                if (targetBookingId != null)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F8F6),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: const Color(0xFF00BBA7)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Color(0xFF00BBA7), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              nextServiceType.isNotEmpty
                                  ? 'Terapi $nextSessionNumber · $nextServiceType siap dicatat'
                                  : 'Terapi $nextSessionNumber siap dicatat',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF00897B),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Tab bar ──
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF00BBA7),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFF00BBA7),
                      indicatorWeight: 2.5,
                      labelStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, fontSize: 13),
                      unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
                      tabs: const [
                        Tab(text: 'Catatan Medis'),
                        Tab(text: 'Riwayat'),
                      ],
                    ),
                  ),
                ),
              ],

              body: TabBarView(
                controller: _tabController,
                children: [
                  _CatatanMedisTab(
                    patientId: widget.patientId,
                    fisioterapisId: fisioterapisId,
                    targetBookingId: targetBookingId,
                    latestRecord: latestRecord,
                    autoOpenForm: widget.fromBookingId != null &&
                        targetBookingId != null,
                    sessionNumber: nextSessionNumber,
                    serviceType: nextServiceType,
                    onSaved: _reload,
                  ),
                  _RiwayatTab(
                    records: records,
                    sessionMap: sessionMap,
                    patientName: widget.patientName,
                    patient: patient,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _profileInfoRow(IconData icon, String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF00BBA7)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: GoogleFonts.inter(
                    fontSize: 12, color: Colors.grey.shade700)),
          ),
        ],
      );
}

// =============================================================================
// TAB: CATATAN MEDIS
// =============================================================================

class _CatatanMedisTab extends StatefulWidget {
  final String patientId;
  final String fisioterapisId;
  final String? targetBookingId;
  final Map<String, dynamic>? latestRecord;
  final bool autoOpenForm;
  final int sessionNumber;
  final String serviceType;
  final VoidCallback onSaved;

  const _CatatanMedisTab({
    required this.patientId,
    required this.fisioterapisId,
    required this.targetBookingId,
    required this.latestRecord,
    required this.autoOpenForm,
    required this.sessionNumber,
    required this.serviceType,
    required this.onSaved,
  });

  @override
  State<_CatatanMedisTab> createState() => _CatatanMedisTabState();
}

class _CatatanMedisTabState extends State<_CatatanMedisTab> {
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.autoOpenForm;
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.latestRecord;
    final hasRecord = record != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header card ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description_outlined,
                        color: Color(0xFF00BBA7), size: 18),
                    const SizedBox(width: 8),
                    Text('Catatan Medis',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    if (widget.sessionNumber > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F8F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Sesi ${widget.sessionNumber}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF00BBA7),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (hasRecord && !_isEditing)
                      GestureDetector(
                        onTap: () => setState(() => _isEditing = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.edit_outlined,
                                  size: 13, color: Color(0xFF00BBA7)),
                              const SizedBox(width: 4),
                              Text('Edit',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF00BBA7),
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                if (hasRecord) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.access_time,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Terakhir diperbarui: ${_formatDate(record['updated_at'] as String?)}',
                      style:
                          GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                    ),
                  ]),
                ],
                if (!hasRecord &&
                    !_isEditing &&
                    widget.targetBookingId != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _isEditing = true),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(
                        widget.serviceType.isNotEmpty
                            ? 'Buat Catatan SOAP — Sesi ${widget.sessionNumber} (${widget.serviceType})'
                            : 'Buat Catatan SOAP — Sesi ${widget.sessionNumber}',
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BBA7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (_isEditing || (!hasRecord && widget.targetBookingId != null))
            _CatatanMedisForm(
              patientId: widget.patientId,
              fisioterapisId: widget.fisioterapisId,
              bookingId: widget.targetBookingId,
              existingRecord: _isEditing && hasRecord ? record : null,
              sessionNumber: widget.sessionNumber,
              serviceType: widget.serviceType,
              onCancel: () => setState(() => _isEditing = false),
              onSaved: () {
                setState(() => _isEditing = false);
                Future.microtask(() => widget.onSaved());
              },
            )
          else if (hasRecord)
            _CatatanMedisView(record: record)
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.description_outlined,
                        size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('Belum ada catatan medis',
                        style: GoogleFonts.inter(
                            color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return raw;
    }
  }
}

// =============================================================================
// VIEW: CATATAN MEDIS (read-only)
// =============================================================================

class _CatatanMedisView extends StatelessWidget {
  final Map<String, dynamic> record;
  const _CatatanMedisView({required this.record});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SoapCard(
          icon: Icons.error_outline,
          iconColor: Colors.red.shade400,
          iconBg: Colors.red.shade50,
          title: 'Subjective (Keluhan Pasien)',
          content: record['subjective'] as String? ?? '-',
        ),
        _SoapCard(
          icon: Icons.description_outlined,
          iconColor: Colors.blue.shade400,
          iconBg: Colors.blue.shade50,
          title: 'Objective (Data Pemeriksaan)',
          content: record['objective'] as String? ?? '-',
        ),
        _SoapCard(
          icon: Icons.show_chart,
          iconColor: Colors.purple.shade400,
          iconBg: Colors.purple.shade50,
          title: 'Assesment (Diagnosa)',
          content: record['assessment'] as String? ?? '-',
        ),
        _SoapCard(
          icon: Icons.description_outlined,
          iconColor: Colors.teal.shade400,
          iconBg: Colors.teal.shade50,
          title: 'Plan (Perencanaan Tindakan)',
          content: record['plan'] as String? ?? '-',
        ),
        if (record['evaluasi_terapi'] != null)
          _SoapCard(
            icon: Icons.trending_up,
            iconColor: Colors.green.shade400,
            iconBg: Colors.green.shade50,
            title: 'Evaluasi Terapi',
            content: record['evaluasi_terapi'] as String,
            highlight: true,
          ),
        if (record['rekomendasi_latihan'] != null)
          _SimpleCard(
            title: 'Rekomendasi Latihan',
            child: Text(record['rekomendasi_latihan'] as String,
                style: GoogleFonts.inter(fontSize: 13)),
          ),
        if (record['terapi_berikutnya'] != null)
          _SimpleCard(
            title: 'Terapi Berikutnya',
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Color(0xFF00BBA7)),
              const SizedBox(width: 6),
              Text(
                _formatTanggal(record['terapi_berikutnya'] as String),
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00BBA7)),
              ),
            ]),
          ),
      ],
    );
  }

  String _formatTanggal(String raw) {
    try {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }
}

// =============================================================================
// FORM: CATATAN MEDIS (tambah / edit)
// =============================================================================

class _CatatanMedisForm extends StatefulWidget {
  final String patientId;
  final String fisioterapisId;
  final String? bookingId;
  final Map<String, dynamic>? existingRecord;
  final int sessionNumber;
  final String serviceType;
  final VoidCallback onCancel;
  final VoidCallback onSaved;

  const _CatatanMedisForm({
    required this.patientId,
    required this.fisioterapisId,
    required this.bookingId,
    required this.existingRecord,
    required this.sessionNumber,
    required this.serviceType,
    required this.onCancel,
    required this.onSaved,
  });

  @override
  State<_CatatanMedisForm> createState() => _CatatanMedisFormState();
}

class _CatatanMedisFormState extends State<_CatatanMedisForm> {
  final _supabase = Supabase.instance.client;

  final _subjCtrl = TextEditingController();
  final _objCtrl = TextEditingController();
  final _assessCtrl = TextEditingController();
  final _planCtrl = TextEditingController();
  final _evalCtrl = TextEditingController();
  final _rekomenCtrl = TextEditingController();

  DateTime? _terapiBerikutnya;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.existingRecord;
    if (r != null) {
      _subjCtrl.text = r['subjective'] as String? ?? '';
      _objCtrl.text = r['objective'] as String? ?? '';
      _assessCtrl.text = r['assessment'] as String? ?? '';
      _planCtrl.text = r['plan'] as String? ?? '';
      _evalCtrl.text = r['evaluasi_terapi'] as String? ?? '';
      _rekomenCtrl.text = r['rekomendasi_latihan'] as String? ?? '';
      if (r['terapi_berikutnya'] != null) {
        try {
          _terapiBerikutnya =
              DateTime.parse(r['terapi_berikutnya'] as String);
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    for (final c in [
      _subjCtrl,
      _objCtrl,
      _assessCtrl,
      _planCtrl,
      _evalCtrl,
      _rekomenCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _terapiBerikutnya ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: Color(0xFF00BBA7)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _terapiBerikutnya = picked);
  }

  Future<void> _save() async {
    if (_subjCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keluhan pasien harus diisi')),
      );
      return;
    }
    if (widget.existingRecord == null && widget.bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Tidak bisa menyimpan. Pasien belum memiliki booking yang terhubung.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final now = DateTime.now().toIso8601String();
      final payload = <String, dynamic>{
        'patient_id': widget.patientId,
        'fisioterapis_id': widget.fisioterapisId,
        'subjective': _subjCtrl.text.trim(),
        'objective':
            _objCtrl.text.trim().isEmpty ? null : _objCtrl.text.trim(),
        'assessment':
            _assessCtrl.text.trim().isEmpty ? null : _assessCtrl.text.trim(),
        'plan':
            _planCtrl.text.trim().isEmpty ? null : _planCtrl.text.trim(),
        'evaluasi_terapi':
            _evalCtrl.text.trim().isEmpty ? null : _evalCtrl.text.trim(),
        'rekomendasi_latihan': _rekomenCtrl.text.trim().isEmpty
            ? null
            : _rekomenCtrl.text.trim(),
        'terapi_berikutnya': _terapiBerikutnya != null
            ? DateFormat('yyyy-MM-dd').format(_terapiBerikutnya!)
            : null,
        'updated_at': now,
      };

      final existing = widget.existingRecord;
      if (existing != null) {
        await _supabase
            .from('medical_records')
            .update(payload)
            .eq('id', existing['id'] as String);
      } else {
        payload['booking_id'] = widget.bookingId;
        payload['created_at'] = now;
        await _supabase.from('medical_records').insert(payload);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan medis berhasil disimpan'),
          backgroundColor: Color(0xFF00BBA7),
        ),
      );
      widget.onSaved();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Info sesi ──
        if (widget.sessionNumber > 0) ...[
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF00BBA7)),
            ),
            child: Row(
              children: [
                const Icon(Icons.medical_services_outlined,
                    color: Color(0xFF00BBA7), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.serviceType.isNotEmpty
                        ? 'Sesi ${widget.sessionNumber} · ${widget.serviceType}'
                        : 'Sesi ${widget.sessionNumber}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF00897B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── SOAP Fields ──
        _FormField(
          icon: Icons.error_outline,
          iconColor: Colors.red.shade400,
          iconBg: Colors.red.shade50,
          label: 'Subjective (Keluhan Pasien)',
          required: true,
          controller: _subjCtrl,
          hint: 'Masukkan keluhan pasien',
        ),
        _FormField(
          icon: Icons.description_outlined,
          iconColor: Colors.blue.shade400,
          iconBg: Colors.blue.shade50,
          label: 'Objective (Data Pemeriksaan)',
          controller: _objCtrl,
          hint: 'Masukkan data pemeriksaan pasien',
        ),
        _FormField(
          icon: Icons.show_chart,
          iconColor: Colors.purple.shade400,
          iconBg: Colors.purple.shade50,
          label: 'Assesment (Diagnosa)',
          controller: _assessCtrl,
          hint: 'Masukkan diagnosa pasien',
        ),
        _FormField(
          icon: Icons.description_outlined,
          iconColor: Colors.teal.shade400,
          iconBg: Colors.teal.shade50,
          label: 'Plan (Perencanaan Tindakan)',
          controller: _planCtrl,
          hint: 'Masukkan perencanaan tindakan',
        ),
        _FormField(
          icon: Icons.trending_up,
          iconColor: Colors.green.shade400,
          iconBg: Colors.green.shade50,
          label: 'Evaluasi Terapi',
          controller: _evalCtrl,
          hint: 'Masukkan evaluasi progress pasien',
        ),

        // ── Rekomendasi Latihan ──
        _cardWrap(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rekomendasi Latihan',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _rekomenCtrl,
                maxLines: 3,
                decoration: _inputDecor(
                    'Masukkan rekomendasi latihan untuk pasien'),
              ),
            ],
          ),
        ),

        // ── Terapi Berikutnya ──
        _cardWrap(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_month_outlined,
                      size: 15, color: Color(0xFF00BBA7)),
                ),
                const SizedBox(width: 8),
                Text('Terapi Berikutnya',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ]),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _terapiBerikutnya != null
                        ? DateFormat('dd MMMM yyyy', 'id_ID')
                            .format(_terapiBerikutnya!)
                        : 'Masukkan Tanggal',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _terapiBerikutnya != null
                          ? Colors.black87
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ── Tombol Simpan ──
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BBA7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text('Simpan',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),

        if (widget.existingRecord != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: widget.onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Batal',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _cardWrap({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}

// =============================================================================
// TAB: RIWAYAT TERAPI
// =============================================================================

class _RiwayatTab extends StatelessWidget {
  final List records;
  final Map<String, Map<String, dynamic>> sessionMap;
  final String patientName;
  final Map<String, dynamic> patient;

  const _RiwayatTab({
    required this.records,
    required this.sessionMap,
    required this.patientName,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.history, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('Belum ada riwayat terapi',
              style: GoogleFonts.inter(color: Colors.grey)),
        ]),
      );
    }

    // ── Kelompokkan records berdasarkan service_type ──
    final Map<String, List<Map<String, dynamic>>> grouped =
        <String, List<Map<String, dynamic>>>{};

    for (final r in records) {
      final record = r as Map<String, dynamic>;
      final booking = record['bookings'] as Map<String, dynamic>?;
      final bookingId = booking?['id'] as String?;
      final sessionInfo =
          bookingId != null ? sessionMap[bookingId] : null;
      final serviceType = sessionInfo?['service_type'] as String? ??
          booking?['service_type'] as String? ??
          'Layanan Lainnya';
      grouped.putIfAbsent(serviceType, () => []).add(record);
    }

    // Flatten → [header, card, card, header, card, ...]
    final List<_RiwayatListItem> items = [];
    grouped.forEach((serviceType, recs) {
      items.add(_RiwayatListItem(isHeader: true, serviceType: serviceType));
      final totalSesi = recs.length;
      for (int i = 0; i < recs.length; i++) {
        items.add(_RiwayatListItem(
          isHeader: false,
          serviceType: serviceType,
          record: recs[i],
          sessionNumber: totalSesi - i,
        ));
      }
    });

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        // ── Judul halaman ──
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Riwayat Terapi',
              style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w700),
            ),
          );
        }

        final item = items[index - 1];

        // ── Header grup layanan ──
        if (item.isHeader) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BBA7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.serviceType,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Divider(
                      color: Colors.grey.shade300, thickness: 1),
                ),
              ],
            ),
          );
        }

        // ── Card riwayat ──
        return _RiwayatCard(
          sessionNumber: item.sessionNumber,
          serviceType: item.serviceType,
          record: item.record!,
          booking: item.record!['bookings'] as Map<String, dynamic>?,
          patientName: patientName,
          patient: patient,
        );
      },
    );
  }
}

// Helper data class untuk item di ListView
class _RiwayatListItem {
  final bool isHeader;
  final String serviceType;
  final Map<String, dynamic>? record;
  final int sessionNumber;

  const _RiwayatListItem({
    required this.isHeader,
    required this.serviceType,
    this.record,
    this.sessionNumber = 0,
  });
}

// =============================================================================
// CARD: RIWAYAT PER SESI
// =============================================================================

class _RiwayatCard extends StatefulWidget {
  final int sessionNumber;
  final String serviceType;
  final Map<String, dynamic> record;
  final Map<String, dynamic>? booking;
  final String patientName;
  final Map<String, dynamic> patient;

  const _RiwayatCard({
    required this.sessionNumber,
    required this.serviceType,
    required this.record,
    required this.booking,
    required this.patientName,
    required this.patient,
  });

  @override
  State<_RiwayatCard> createState() => _RiwayatCardState();
}

class _RiwayatCardState extends State<_RiwayatCard> {
  bool _isExporting = false;

  String _formatTanggal(String? raw) {
    if (raw == null) return '-';
    try {
      return DateFormat('dd MMMM yyyy', 'id_ID')
          .format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  String _buildJamRange(String? raw) {
    if (raw == null) return '';
    try {
      final parts = raw.split(':');
      final startHour = int.parse(parts[0]);
      final endHour = (startHour + 1).toString().padLeft(2, '0');
      final start = '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      return '$start - $endHour:${parts[1].padLeft(2, '0')} (60 menit)';
    } catch (_) {
      return raw;
    }
  }

  // ---------------------------------------------------------------------------
  // Generate & share PDF per pertemuan
  // ---------------------------------------------------------------------------
  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    try {
      final pdf = pw.Document();

      final tealColor = PdfColor.fromHex('#00BBA7');
      final lightTeal = PdfColor.fromHex('#E8F8F6');
      final greyColor = PdfColor.fromHex('#6B7280');
      final darkColor = PdfColor.fromHex('#111827');

      final scheduledDate = widget.booking?['scheduled_date'] as String?;
      final scheduledTime = widget.booking?['scheduled_time'] as String?;

      String fmtTgl(String? raw) {
        if (raw == null) return '-';
        try {
          return DateFormat('dd MMMM yyyy', 'id_ID')
              .format(DateTime.parse(raw));
        } catch (_) {
          return raw;
        }
      }

      String fmtJam(String? raw) {
        if (raw == null) return '';
        try {
          final parts = raw.split(':');
          final startH = int.parse(parts[0]);
          final endH = (startH + 1).toString().padLeft(2, '0');
          final start =
              '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
          return '$start - $endH:${parts[1].padLeft(2, '0')} (60 menit)';
        } catch (_) {
          return raw;
        }
      }

      pw.Widget pdfSoapRow(String label, String value) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: greyColor,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(fontSize: 11, color: darkColor),
            ),
          ],
        );
      }

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
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Laporan Riwayat Terapi',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            widget.patientName,
                            style: pw.TextStyle(
                                color: PdfColors.white, fontSize: 13),
                          ),
                          if ((widget.patient['phone'] as String? ?? '')
                              .isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              widget.patient['phone'] as String,
                              style: pw.TextStyle(
                                  color: PdfColors.white, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Dicetak: ${DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.now())}',
                          style: pw.TextStyle(
                              color: PdfColors.white, fontSize: 10),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Sesi ${widget.sessionNumber} — ${widget.serviceType}',
                          style: pw.TextStyle(
                              color: PdfColors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Detail Pertemuan ${widget.sessionNumber}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: darkColor,
                ),
              ),
              pw.SizedBox(height: 10),
            ],
          ),
          footer: (ctx) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Laporan Fisioterapi — ${widget.patientName}',
                style: pw.TextStyle(fontSize: 9, color: greyColor),
              ),
              pw.Text(
                'Halaman ${ctx.pageNumber} dari ${ctx.pagesCount}',
                style: pw.TextStyle(fontSize: 9, color: greyColor),
              ),
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
                  // Header sesi
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
                            borderRadius: pw.BorderRadius.circular(8),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              '${widget.sessionNumber}',
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 12),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Pertemuan ${widget.sessionNumber}',
                                style: pw.TextStyle(
                                  fontSize: 13,
                                  fontWeight: pw.FontWeight.bold,
                                  color: darkColor,
                                ),
                              ),
                              pw.SizedBox(height: 3),
                              pw.Text(
                                fmtTgl(scheduledDate) +
                                    (scheduledTime != null
                                        ? '  |  ${fmtJam(scheduledTime)}'
                                        : ''),
                                style: pw.TextStyle(
                                    fontSize: 10, color: greyColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Isi SOAP
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(14),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (widget.record['subjective'] != null) ...[
                          pdfSoapRow('Keluhan (S)',
                              widget.record['subjective'] as String),
                          pw.SizedBox(height: 10),
                        ],
                        if (widget.record['objective'] != null) ...[
                          pdfSoapRow('Data Pemeriksaan (O)',
                              widget.record['objective'] as String),
                          pw.SizedBox(height: 10),
                        ],
                        if (widget.record['assessment'] != null) ...[
                          pdfSoapRow('Diagnosa (A)',
                              widget.record['assessment'] as String),
                          pw.SizedBox(height: 10),
                        ],
                        if (widget.record['plan'] != null) ...[
                          pdfSoapRow('Perencanaan Tindakan (P)',
                              widget.record['plan'] as String),
                          pw.SizedBox(height: 10),
                        ],
                        if (widget.record['evaluasi_terapi'] != null) ...[
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
                              crossAxisAlignment:
                                  pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Evaluasi Terapi',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: tealColor,
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  widget.record['evaluasi_terapi'] as String,
                                  style: pw.TextStyle(
                                      fontSize: 11, color: tealColor),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 10),
                        ],
                        if (widget.record['rekomendasi_latihan'] != null) ...[
                          pdfSoapRow('Rekomendasi Latihan',
                              widget.record['rekomendasi_latihan'] as String),
                          pw.SizedBox(height: 10),
                        ],
                        if (widget.record['terapi_berikutnya'] != null) ...[
                          pdfSoapRow('Terapi Berikutnya',
                              fmtTgl(widget.record['terapi_berikutnya'] as String)),
                        ],
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
            'Laporan_${widget.patientName.replaceAll(' ', '_')}_Sesi${widget.sessionNumber}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat laporan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduledDate = widget.booking?['scheduled_date'] as String?;
    final scheduledTime = widget.booking?['scheduled_time'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nomor sesi
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.sessionNumber}',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: const Color(0xFF00BBA7)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Info tanggal & jam
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pertemuan ${widget.sessionNumber}',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _formatTanggal(scheduledDate),
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ]),
                      const SizedBox(height: 2),
                      if (scheduledTime != null)
                        Row(children: [
                          const Icon(Icons.access_time,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            _buildJamRange(scheduledTime),
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ]),
                    ],
                  ),
                ),
                // Tombol Edit (outline teal, sesuai gambar)
                GestureDetector(
                  onTap: () {
                    // TODO: implement edit riwayat
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00BBA7)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_outlined,
                            size: 13, color: Color(0xFF00BBA7)),
                        const SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00BBA7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          // ── Isi SOAP ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.record['subjective'] != null) ...[
                  _soapLabel('Keluhan:'),
                  const SizedBox(height: 3),
                  _soapContent(widget.record['subjective'] as String),
                  const SizedBox(height: 12),
                ],
                if (widget.record['objective'] != null) ...[
                  _soapLabel('Data Pemeriksaan'),
                  const SizedBox(height: 3),
                  _soapContent(widget.record['objective'] as String),
                  const SizedBox(height: 12),
                ],
                if (widget.record['assessment'] != null) ...[
                  _soapLabel('Diagnosa'),
                  const SizedBox(height: 3),
                  _soapContent(widget.record['assessment'] as String),
                  const SizedBox(height: 12),
                ],
                if (widget.record['plan'] != null) ...[
                  _soapLabel('Perencanaan Tindakan'),
                  const SizedBox(height: 3),
                  _soapContent(widget.record['plan'] as String),
                  const SizedBox(height: 12),
                ],
                if (widget.record['evaluasi_terapi'] != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFB2EDE7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evaluasi Terapi',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00BBA7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.record['evaluasi_terapi'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF00897B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Divider + Tombol Export ──
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          InkWell(
            onTap: _isExporting ? null : _exportPdf,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: _isExporting
                  ? const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF00BBA7),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.file_download_outlined,
                          size: 18,
                          color: Color(0xFF00BBA7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Export',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00BBA7),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _soapLabel(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      );

  Widget _soapContent(String text) => Text(
        text,
        style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
      );
}

// =============================================================================
// REUSABLE WIDGETS
// =============================================================================

class _SoapCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String content;
  final bool highlight;

  const _SoapCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.content,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFE8F8F6) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            highlight ? Border.all(color: const Color(0xFFB2EDE7)) : null,
        boxShadow: highlight
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04), blurRadius: 6)
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: highlight
                          ? const Color(0xFF00BBA7)
                          : Colors.black87)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(content,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: highlight
                      ? const Color(0xFF00BBA7)
                      : Colors.black87)),
        ],
      ),
    );
  }
}

class _SimpleCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SimpleCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool required;

  const _FormField({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.hint,
    required this.controller,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            if (required)
              Text(' *',
                  style: GoogleFonts.inter(
                      color: Colors.red, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TAB BAR DELEGATE
// =============================================================================

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: Colors.white, child: tabBar);

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}