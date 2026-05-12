import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────

class ScheduleSlot {
  final String? id; // UUID dari Supabase (null = belum tersimpan)
  final String day;
  final String startTime; // format "HH:MM"
  final String endTime;   // format "HH:MM"

  ScheduleSlot({
    this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  /// Buat dari row Supabase
  factory ScheduleSlot.fromMap(Map<String, dynamic> map) {
    return ScheduleSlot(
      id: map['id'] as String?,
      day: map['hari'] as String,
      // kolom time di Supabase bisa "HH:MM:SS" → ambil 5 karakter pertama
      startTime: (map['jam_mulai'] as String).substring(0, 5),
      endTime: (map['jam_selesai'] as String).substring(0, 5),
    );
  }

  Map<String, dynamic> toInsertMap(String fisioterapisId) => {
        'fisioterapis_id': fisioterapisId,
        'hari': day,
        'jam_mulai': '$startTime:00',
        'jam_selesai': '$endTime:00',
        'is_available': true,
      };

  /// Durasi slot dalam menit
  int get durationMinutes {
    final start = _toMinutes(startTime);
    final end = _toMinutes(endTime);
    return end - start;
  }

  static int _toMinutes(String t) {
    final parts = t.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────

class AturJadwalScreen extends StatefulWidget {
  const AturJadwalScreen({super.key});

  @override
  State<AturJadwalScreen> createState() => _AturJadwalScreenState();
}

class _AturJadwalScreenState extends State<AturJadwalScreen> {
  final _supabase = Supabase.instance.client;

  final List<String> days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  Map<String, List<ScheduleSlot>> scheduleByDay = {};
  Map<String, bool> dayAvailability = {};
  int maxPatientPerDay = 5;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _fisioterapisId;

  // ── Lifecycle ──────────────────────────────

  @override
  void initState() {
    super.initState();
    _initEmpty();
    _loadData();
  }

  void _initEmpty() {
    scheduleByDay = {for (final d in days) d: []};
    dayAvailability = {for (final d in days) d: false};
  }

  // ── Load dari Supabase ─────────────────────

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User belum login');

      // 1. Ambil fisioterapis_id & max_pasien_per_hari
      final fisiRow = await _supabase
          .from('fisioterapis')
          .select('id, max_pasien_per_hari')
          .eq('user_id', userId)
          .single();

      _fisioterapisId = fisiRow['id'] as String;
      maxPatientPerDay = (fisiRow['max_pasien_per_hari'] as int?) ?? 5;

      // 2. Ambil semua jadwal milik fisioterapis ini
      final jadwalRows = await _supabase
          .from('jadwal_fisioterapis')
          .select()
          .eq('fisioterapis_id', _fisioterapisId!)
          .order('jam_mulai');

      // Reset sebelum diisi ulang
      _initEmpty();

      for (final row in (jadwalRows as List)) {
        final slot = ScheduleSlot.fromMap(row as Map<String, dynamic>);
        scheduleByDay[slot.day]!.add(slot);
        // Jika ada slot di hari ini, otomatis tandai hari tersedia
        if (row['is_available'] == true) {
          dayAvailability[slot.day] = true;
        }
      }
    } catch (e) {
      if (mounted) _showSnack('Gagal memuat jadwal: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Simpan ke Supabase ─────────────────────

  Future<void> _saveAll() async {
    if (_fisioterapisId == null) return;
    setState(() => _isSaving = true);
    try {
      // 1. Update max_pasien_per_hari di tabel fisioterapis
      await _supabase
          .from('fisioterapis')
          .update({
            'max_pasien_per_hari': maxPatientPerDay,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _fisioterapisId!);

      // 2. Hapus semua jadwal lama milik fisioterapis ini
      await _supabase
          .from('jadwal_fisioterapis')
          .delete()
          .eq('fisioterapis_id', _fisioterapisId!);

      // 3. Insert jadwal baru (hanya hari yang aktif dan punya slot)
      final List<Map<String, dynamic>> newRows = [];
      for (final day in days) {
        if (dayAvailability[day] == true) {
          for (final slot in scheduleByDay[day]!) {
            newRows.add(slot.toInsertMap(_fisioterapisId!));
          }
        }
      }

      if (newRows.isNotEmpty) {
        await _supabase.from('jadwal_fisioterapis').insert(newRows);
      }

      if (mounted) _showSnack('Jadwal berhasil disimpan ✓');
    } catch (e) {
      if (mounted) _showSnack('Gagal menyimpan: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Snackbar helper ────────────────────────

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter()),
      backgroundColor:
          isError ? Colors.red.shade600 : const Color(0xFF00BBA7),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── Dialog tambah slot ─────────────────────

  void _showAddTimeDialog(BuildContext context, String day) {
    TimeOfDay? selectedStart;
    TimeOfDay? selectedEnd;
    final startController = TextEditingController();
    final endController = TextEditingController();

    String fmt(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          // Pilih jam mulai
          Future<void> pickStart() async {
            final t = await showTimePicker(
              context: ctx,
              initialTime: const TimeOfDay(hour: 8, minute: 0),
            );
            if (t == null) return;
            setDialogState(() {
              selectedStart = t;
              startController.text = fmt(t);
              // Reset jam selesai jika sudah tidak valid (< 1 jam dari start baru)
              if (selectedEnd != null) {
                final diff =
                    (selectedEnd!.hour * 60 + selectedEnd!.minute) -
                        (t.hour * 60 + t.minute);
                if (diff < 60) {
                  selectedEnd = null;
                  endController.clear();
                }
              }
            });
          }

          // Pilih jam selesai — validasi minimal 1 jam dari start
          Future<void> pickEnd() async {
            if (selectedStart == null) {
              _showSnack('Pilih jam mulai terlebih dahulu', isError: true);
              return;
            }

            final minEndHour = selectedStart!.hour + 1;
            final initialEnd = minEndHour <= 23
                ? TimeOfDay(
                    hour: minEndHour, minute: selectedStart!.minute)
                : const TimeOfDay(hour: 23, minute: 59);

            final t = await showTimePicker(
              context: ctx,
              initialTime: initialEnd,
            );
            if (t == null) return;

            final startMin =
                selectedStart!.hour * 60 + selectedStart!.minute;
            final endMin = t.hour * 60 + t.minute;

            if (endMin - startMin < 60) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(
                    'Jam selesai harus minimal 1 jam setelah jam mulai',
                    style: GoogleFonts.inter(),
                  ),
                  backgroundColor: Colors.red.shade600,
                  behavior: SnackBarBehavior.floating,
                ));
              }
              return;
            }

            setDialogState(() {
              selectedEnd = t;
              endController.text = fmt(t);
            });
          }

          final durText = () {
            if (selectedStart == null || selectedEnd == null) return '';
            final diff = (selectedEnd!.hour * 60 + selectedEnd!.minute) -
                (selectedStart!.hour * 60 + selectedStart!.minute);
            if (diff <= 0) return '';
            final h = diff ~/ 60;
            final m = diff % 60;
            return h > 0 && m > 0
                ? '$h jam $m menit'
                : h > 0
                    ? '$h jam'
                    : '$m menit';
          }();

          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            title: Text(
              'Tambah Sesi – $day',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold, fontSize: 15),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Info minimal 1 jam
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F6F4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: Color(0xFF00BBA7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Durasi sesi minimal 1 jam',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF00BBA7)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Jam Mulai
                GestureDetector(
                  onTap: pickStart,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: startController,
                      decoration: InputDecoration(
                        labelText: 'Jam Mulai',
                        hintText: '08:00',
                        prefixIcon: const Icon(Icons.access_time,
                            color: Color(0xFF00BBA7)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color(0xFF00BBA7)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Jam Selesai
                GestureDetector(
                  onTap: pickEnd,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: endController,
                      decoration: InputDecoration(
                        labelText: 'Jam Selesai',
                        hintText: '09:00',
                        prefixIcon: const Icon(Icons.access_time_filled,
                            color: Color(0xFF00BBA7)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color(0xFF00BBA7)),
                        ),
                      ),
                    ),
                  ),
                ),

                // Preview durasi
                if (durText.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.timelapse,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Durasi: $durText',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Batal',
                    style: GoogleFonts.inter(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  // Validasi isi
                  if (selectedStart == null || selectedEnd == null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text('Semua field harus diisi',
                          style: GoogleFonts.inter()),
                      backgroundColor: Colors.red.shade600,
                    ));
                    return;
                  }

                  // Validasi overlap dengan slot yang sudah ada
                  final newStart =
                      selectedStart!.hour * 60 + selectedStart!.minute;
                  final newEnd =
                      selectedEnd!.hour * 60 + selectedEnd!.minute;
                  final existing = scheduleByDay[day] ?? [];
                  final hasOverlap = existing.any((s) {
                    final sStart = ScheduleSlot._toMinutes(s.startTime);
                    final sEnd = ScheduleSlot._toMinutes(s.endTime);
                    return newStart < sEnd && newEnd > sStart;
                  });

                  if (hasOverlap) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(
                        'Waktu bertabrakan dengan slot yang sudah ada',
                        style: GoogleFonts.inter(),
                      ),
                      backgroundColor: Colors.red.shade600,
                      behavior: SnackBarBehavior.floating,
                    ));
                    return;
                  }

                  setState(() {
                    scheduleByDay[day] ??= [];
                    scheduleByDay[day]!.add(ScheduleSlot(
                      day: day,
                      startTime: fmt(selectedStart!),
                      endTime: fmt(selectedEnd!),
                    ));
                    scheduleByDay[day]!
                        .sort((a, b) => a.startTime.compareTo(b.startTime));
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BBA7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Tambah',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00BBA7)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──────────────────────────
          SliverAppBar(
            backgroundColor: const Color(0xFF00BBA7),
            foregroundColor: Colors.white,
            pinned: true,
            elevation: 0,
            expandedHeight: 180,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              _isSaving
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      ),
                    )
                  : TextButton(
                      onPressed: _saveAll,
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFF00BBA7),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengaturan Jadwal',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                      Text(
                        'Atur jadwal kerja sesuai Anda',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 18, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tekan Simpan setelah selesai mengatur jadwal',
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pengaturan Umum
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pengaturan Umum',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Maksimal Pasien Per Hari',
                                style: GoogleFonts.inter(fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => setState(() =>
                                        maxPatientPerDay =
                                            (maxPatientPerDay - 1)
                                                .clamp(1, 20)),
                                    child: const Icon(Icons.remove,
                                        size: 18,
                                        color: Color(0xFF00BBA7)),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('$maxPatientPerDay',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () => setState(() =>
                                        maxPatientPerDay =
                                            (maxPatientPerDay + 1)
                                                .clamp(1, 20)),
                                    child: const Icon(Icons.add,
                                        size: 18,
                                        color: Color(0xFF00BBA7)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Jadwal Mingguan
                  Text('Jadwal Mingguan',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),

                  ...days.map((day) {
                    final slots = scheduleByDay[day] ?? [];
                    final isAvailable = dayAvailability[day] ?? false;
                    return _DayScheduleCard(
                      day: day,
                      isAvailable: isAvailable,
                      slots: slots,
                      onToggleAvailability: () => setState(
                          () => dayAvailability[day] = !isAvailable),
                      onAddSlot: () => _showAddTimeDialog(context, day),
                      onRemoveSlot: (slot) =>
                          setState(() => slots.remove(slot)),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Tombol Simpan bawah
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BBA7),
                        disabledBackgroundColor:
                            const Color(0xFF00BBA7).withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Simpan Jadwal',
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget: Card per hari
// ─────────────────────────────────────────────

class _DayScheduleCard extends StatelessWidget {
  final String day;
  final bool isAvailable;
  final List<ScheduleSlot> slots;
  final VoidCallback onToggleAvailability;
  final VoidCallback onAddSlot;
  final Function(ScheduleSlot) onRemoveSlot;

  const _DayScheduleCard({
    required this.day,
    required this.isAvailable,
    required this.slots,
    required this.onToggleAvailability,
    required this.onAddSlot,
    required this.onRemoveSlot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: onToggleAvailability,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 50,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: isAvailable
                            ? const Color(0xFF00BBA7)
                            : Colors.grey.shade300,
                      ),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 200),
                            left: isAvailable ? 24 : 2,
                            top: 2,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(day,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              if (isAvailable)
                TextButton.icon(
                  onPressed: onAddSlot,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    backgroundColor: const Color(0xFFE8F6F4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add,
                      size: 16, color: Color(0xFF00BBA7)),
                  label: Text('Tambah',
                      style: GoogleFonts.inter(
                          color: const Color(0xFF00BBA7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Libur',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          if (isAvailable) ...[
            if (slots.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 4),
              ...slots.map((slot) => _SlotTile(
                    slot: slot,
                    onRemove: () => onRemoveSlot(slot),
                  )),
            ] else ...[
              const SizedBox(height: 10),
              Text(
                'Belum ada sesi. Tap Tambah untuk menambahkan.',
                style: GoogleFonts.inter(
                    fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget: Tile per slot waktu
// ─────────────────────────────────────────────

class _SlotTile extends StatelessWidget {
  final ScheduleSlot slot;
  final VoidCallback onRemove;

  const _SlotTile({required this.slot, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final dur = slot.durationMinutes;
    final durText = dur >= 60
        ? '${dur ~/ 60} jam${dur % 60 != 0 ? ' ${dur % 60} menit' : ''}'
        : '$dur menit';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F6F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time,
                    size: 14, color: Color(0xFF00BBA7)),
                const SizedBox(width: 6),
                Text(
                  '${slot.startTime} – ${slot.endTime}',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00BBA7)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(durText,
              style: GoogleFonts.inter(
                  fontSize: 11, color: Colors.grey.shade500)),
          const Spacer(),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.close,
                  size: 16, color: Colors.red.shade400),
            ),
          ),
        ],
      ),
    );
  }
}