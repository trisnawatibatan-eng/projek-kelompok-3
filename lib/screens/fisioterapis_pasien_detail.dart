import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme.dart';

// =============================================================================
// SCREEN UTAMA
// =============================================================================

class FisioterapisPasienDetail extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String? inisial;
  final Color? avatarColor;

  const FisioterapisPasienDetail({
    super.key,
    required this.patientId,
    required this.patientName,
    this.inisial,
    this.avatarColor,
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

  void _reload() => setState(() => _futureDetail = _fetchDetail());

  // ---------------------------------------------------------------------------
  // Fetch: profil pasien + semua catatan medis (join booking untuk info sesi)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> _fetchDetail() async {
    // Profil pasien
    final patientRes = await _supabase
        .from('patients')
        .select()
        .eq('id', widget.patientId)
        .single();

    // Fisioterapis id berdasarkan user login
    final userId = _supabase.auth.currentUser!.id;

    final fisioRes = await _supabase
        .from('fisioterapis')
        .select('id')
        .eq('user_id', userId)
        .single();

    final fisioterapisId = fisioRes['id'] as String;

    // Ambil booking terbaru pasien untuk mengisi booking_id pada medical_records
    final latestBookingRes = await _supabase
        .from('bookings')
        .select('id')
        .eq('patient_id', widget.patientId)
        .eq('fisioterapis_id', fisioterapisId)
        .order('scheduled_date', ascending: false)
        .limit(1)
        .maybeSingle();

    final latestBookingId = latestBookingRes?['id'] as String?;

    // Catatan medis pasien ini
    final recordsRes = await _supabase
        .from('medical_records')
        .select('''
          *,
          bookings (
            scheduled_date,
            scheduled_time,
            service_type
          )
        ''')
        .eq('patient_id', widget.patientId)
        .eq('fisioterapis_id', fisioterapisId)
        .order('created_at', ascending: false);

    return {
      'patient': patientRes as Map<String, dynamic>,
      'records': recordsRes as List,
      'fisioterapis_id': fisioterapisId,
      'latest_booking_id': latestBookingId,
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
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          }

          final patient =
              snapshot.data!['patient'] as Map<String, dynamic>;
          final records = snapshot.data!['records'] as List;
          final fisioterapisId =
              snapshot.data!['fisioterapis_id'] as String;
          final latestBookingId =
              snapshot.data!['latest_booking_id'] as String?;

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

          // Catatan medis terbaru (untuk tab Catatan Medis)
          final latestRecord =
              records.isNotEmpty ? records.first as Map<String, dynamic> : null;

          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                // ── AppBar teal ──
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
                                  _profileInfoRow(
                                      Icons.phone_outlined,
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
                      unselectedLabelStyle:
                          GoogleFonts.inter(fontSize: 13),
                      tabs: const [
                        Tab(text: 'Catatan Medis'),
                        Tab(text: 'Riwayat'),
                      ],
                    ),
                  ),
                ),
              ],

              // ── Body tab ──
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 0: Catatan Medis
                  _CatatanMedisTab(
                    patientId: widget.patientId,
                    fisioterapisId: fisioterapisId,
                    latestBookingId: latestBookingId,
                    latestRecord: latestRecord,
                    onSaved: _reload,
                  ),
                  // Tab 1: Riwayat
                  _RiwayatTab(records: records),
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
  final String? latestBookingId;
  final Map<String, dynamic>? latestRecord;
  final VoidCallback onSaved;

  const _CatatanMedisTab({
    required this.patientId,
    required this.fisioterapisId,
    required this.latestBookingId,
    required this.latestRecord,
    required this.onSaved,
  });

  @override
  State<_CatatanMedisTab> createState() => _CatatanMedisTabState();
}

class _CatatanMedisTabState extends State<_CatatanMedisTab> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final record = widget.latestRecord;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    const Icon(
                      Icons.description_outlined,
                      color: Color(0xFF00BBA7),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Catatan Medis',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (record != null)
                      GestureDetector(
                        onTap: () => setState(() => _isEditing = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.edit_outlined,
                                size: 13,
                                color: Color(0xFF00BBA7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF00BBA7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                if (record != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Terakhir diperbarui: ${_formatDate(record['updated_at'] as String?)}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (_isEditing || record == null)
            _CatatanMedisForm(
              patientId: widget.patientId,
              fisioterapisId: widget.fisioterapisId,
              bookingId: widget.latestBookingId,
              existingRecord: record,
              onCancel: () => setState(() => _isEditing = false),
              onSaved: () {
                setState(() => _isEditing = false);
                // Delay onSaved call to avoid setState with async callback
                Future.microtask(() => widget.onSaved());
              },
            )
          else
            _CatatanMedisView(record: record),
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
        if (record['skala_nyeri'] != null)
          _SimpleCard(
            title: 'Skala Nyeri',
            child: Row(children: [
              Text(
                '${record['skala_nyeri']}/10',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _nyeriColor(record['skala_nyeri'] as int),
                ),
              ),
            ]),
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

  Color _nyeriColor(int skala) {
    if (skala <= 3) return Colors.green;
    if (skala <= 6) return Colors.orange;
    return Colors.red;
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
  final VoidCallback onCancel;
  final VoidCallback onSaved;

  const _CatatanMedisForm({
    required this.patientId,
    required this.fisioterapisId,
    required this.bookingId,
    required this.existingRecord,
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

  int? _skalaNyeri;
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
      _skalaNyeri = r['skala_nyeri'] as int?;

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
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF00BBA7),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _terapiBerikutnya = picked);
    }
  }

  Future<void> _save() async {
    if (_subjCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keluhan pasien harus diisi')),
      );
      return;
    }

    if (_skalaNyeri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skala nyeri harus dipilih')),
      );
      return;
    }

    if (widget.existingRecord == null && widget.bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak bisa menyimpan. Pasien belum memiliki booking yang terhubung.',
          ),
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
        'plan': _planCtrl.text.trim().isEmpty ? null : _planCtrl.text.trim(),
        'evaluasi_terapi':
            _evalCtrl.text.trim().isEmpty ? null : _evalCtrl.text.trim(),
        'skala_nyeri': _skalaNyeri,
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
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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

        // Skala Nyeri Dropdown
        _cardWrap(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skala Nyeri',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<int>(
                value: _skalaNyeri,
                isExpanded: true,
                decoration: _inputDecor('Pilih skala nyeri'),
                hint: Text(
                  'Pilih skala nyeri',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                items: List.generate(10, (index) {
                  final value = index + 1;

                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      '$value/10',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _skalaNyeri = value;
                  });
                },
              ),
            ],
          ),
        ),

        // Rekomendasi Latihan
        _cardWrap(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rekomendasi Latihan',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _rekomenCtrl,
                maxLines: 3,
                decoration: _inputDecor(
                  'Masukkan rekomendasi latihan untuk pasien',
                ),
              ),
            ],
          ),
        ),

        // Terapi Berikutnya
        _cardWrap(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month_outlined,
                      size: 15,
                      color: Color(0xFF00BBA7),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    'Terapi Berikutnya',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
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

        // Tombol Simpan
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BBA7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Simpan',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Batal',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                ),
              ),
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 12,
        color: Colors.grey,
      ),
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
    );
  }
}

// =============================================================================
// TAB: RIWAYAT TERAPI
// =============================================================================

class _RiwayatTab extends StatelessWidget {
  final List records;
  const _RiwayatTab({required this.records});

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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('Riwayat Terapi',
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w700)),
          );
        }

        final record =
            records[index - 1] as Map<String, dynamic>;
        final pertemuan = records.length - (index - 1);
        final booking =
            record['bookings'] as Map<String, dynamic>?;

        return _RiwayatCard(
          pertemuanKe: pertemuan,
          record: record,
          booking: booking,
        );
      },
    );
  }
}

// =============================================================================
// CARD: RIWAYAT PER SESI
// =============================================================================

class _RiwayatCard extends StatelessWidget {
  final int pertemuanKe;
  final Map<String, dynamic> record;
  final Map<String, dynamic>? booking;

  const _RiwayatCard({
    required this.pertemuanKe,
    required this.record,
    required this.booking,
  });

  String _formatTanggal(String? raw) {
    if (raw == null) return '-';
    try {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  String _formatJam(String? raw) {
    if (raw == null) return '';
    try {
      final parts = raw.split(':');
      return '${parts[0]}:${parts[1]}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final skala = record['skala_nyeri'] as int?;
    final skalaColor = skala == null
        ? Colors.grey
        : skala <= 3
            ? Colors.green
            : skala <= 6
                ? Colors.orange
                : Colors.red;

    final scheduledDate = booking?['scheduled_date'] as String?;
    final scheduledTime = booking?['scheduled_time'] as String?;

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
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('$pertemuanKe',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF00BBA7))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pertemuan $pertemuanKe',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      if (scheduledDate != null)
                        Row(children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 11, color: Colors.grey),
                          const SizedBox(width: 3),
                          Text(_formatTanggal(scheduledDate),
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: Colors.grey)),
                        ]),
                      if (scheduledTime != null)
                        Row(children: [
                          const Icon(Icons.access_time,
                              size: 11, color: Colors.grey),
                          const SizedBox(width: 3),
                          Text(_formatJam(scheduledTime),
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: Colors.grey)),
                        ]),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Export PDF
                  },
                  icon: const Icon(Icons.download_outlined, size: 14),
                  label: Text('Edit',
                      style: GoogleFonts.inter(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00BBA7),
                    side:
                        const BorderSide(color: Color(0xFF00BBA7)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Keluhan
                if (record['subjective'] != null) ...[
                  Text('Keluhan:',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700)),
                  const SizedBox(height: 2),
                  Text(record['subjective'] as String,
                      style: GoogleFonts.inter(fontSize: 12)),
                  const SizedBox(height: 10),
                ],

                // Data Pemeriksaan
                if (record['objective'] != null) ...[
                  Text('Data Pemeriksaan',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700)),
                  const SizedBox(height: 2),
                  Text(record['objective'] as String,
                      style: GoogleFonts.inter(fontSize: 12)),
                  const SizedBox(height: 10),
                ],

                // Skala Nyeri + Diagnosa (side by side)
                if (skala != null ||
                    record['assessment'] != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (skala != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('Skala Nyeri:',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700)),
                              const SizedBox(height: 2),
                              Text('$skala/10',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: skalaColor,
                                  )),
                            ],
                          ),
                        ),
                      if (record['assessment'] != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('Diagnosa',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700)),
                              const SizedBox(height: 2),
                              Text(
                                  record['assessment'] as String,
                                  style:
                                      GoogleFonts.inter(fontSize: 12)),
                            ],
                          ),
                        ),
                    ],
                  ),

                if ((skala != null || record['assessment'] != null) &&
                    record['plan'] != null)
                  const SizedBox(height: 10),

                // Perencanaan Tindakan
                if (record['plan'] != null) ...[
                  Text('Perencanaan Tindakan',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700)),
                  const SizedBox(height: 2),
                  Text(record['plan'] as String,
                      style: GoogleFonts.inter(fontSize: 12)),
                ],

                // Evaluasi Terapi (highlight box)
                if (record['evaluasi_terapi'] != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFB2EDE7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Evaluasi Terapi',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF00BBA7))),
                        const SizedBox(height: 4),
                        Text(
                            record['evaluasi_terapi'] as String,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF00BBA7))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Export button
          Container(
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: TextButton.icon(
              onPressed: () {
                // TODO: Implement export PDF
              },
              icon: const Icon(Icons.download_outlined,
                  size: 16, color: Color(0xFF00BBA7)),
              label: Text('Export',
                  style: GoogleFonts.inter(
                      color: const Color(0xFF00BBA7),
                      fontWeight: FontWeight.w500)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
        border: highlight
            ? Border.all(color: const Color(0xFFB2EDE7))
            : null,
        boxShadow: highlight
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6)
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
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, fontSize: 13,
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
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            if (required)
              Text(' *',
                  style: GoogleFonts.inter(
                      color: Colors.red,
                      fontWeight: FontWeight.bold)),
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
      Container(
          color: Colors.white,
          child: tabBar);

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}