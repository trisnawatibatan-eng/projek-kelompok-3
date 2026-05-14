import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class JadwalKalenderScreen extends StatefulWidget {
  final DateTime? initialDate;
  const JadwalKalenderScreen({super.key, this.initialDate});

  @override
  State<JadwalKalenderScreen> createState() => _JadwalKalenderScreenState();
}

class _JadwalKalenderScreenState extends State<JadwalKalenderScreen> {
  final _supabase = Supabase.instance.client;

  late DateTime focusedDay;
  late DateTime selectedDay;

  /// Tanggal yang punya booking (dari Supabase)
  Set<DateTime> _bookedDays = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final init = widget.initialDate ?? DateTime.now();
    focusedDay = init;
    selectedDay = init;
    _fetchBookedDays(focusedDay);
  }

  // ---------------------------------------------------------------------------
  // Supabase query
  // ---------------------------------------------------------------------------

  Future<String> _getFisioterapisId() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login');
    final res = await _supabase
        .from('fisioterapis')
        .select('id')
        .eq('user_id', userId)
        .single();
    return res['id'] as String;
  }

  Future<void> _fetchBookedDays(DateTime month) async {
    setState(() => _isLoading = true);
    try {
      final fisioterapisId = await _getFisioterapisId();
      final firstDay = DateFormat('yyyy-MM-dd').format(DateTime(month.year, month.month, 1));
      final lastDay = DateFormat('yyyy-MM-dd').format(DateTime(month.year, month.month + 1, 0));

      final response = await _supabase
          .from('bookings')
          .select('scheduled_date')
          .eq('fisioterapis_id', fisioterapisId)
          .inFilter('status', ['confirmed', 'on_going', 'completed'])
          .gte('scheduled_date', firstDay)
          .lte('scheduled_date', lastDay);

      final days = (response as List).map((e) {
        final d = DateTime.parse(e['scheduled_date'] as String);
        return DateTime(d.year, d.month, d.day);
      }).toSet();

      setState(() {
        _bookedDays = days;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  bool _hasBooking(DateTime day) {
    return _bookedDays.contains(DateTime(day.year, day.month, day.day));
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBA7),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Jadwal Praktik (Kalender)',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
            ),
            child: Column(
              children: [
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(
                      color: Color(0xFF00BBA7),
                      backgroundColor: Color(0xFFE0F2F1),
                    ),
                  ),
                TableCalendar(
                  firstDay: DateTime(DateTime.now().year - 1, 1, 1),
                  lastDay: DateTime(DateTime.now().year + 1, 12, 31),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      selectedDay = selected;
                      focusedDay = focused;
                    });
                    Navigator.pop(context, selected);
                  },
                  onPageChanged: (focused) {
                    setState(() => focusedDay = focused);
                    _fetchBookedDays(focused);
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                        color: Color(0xFF00BBA7), shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(
                        color: Color(0xFF00BBA7), shape: BoxShape.circle),
                    defaultDecoration:
                        BoxDecoration(shape: BoxShape.circle),
                    weekendDecoration:
                        BoxDecoration(shape: BoxShape.circle),
                    outsideDecoration:
                        BoxDecoration(shape: BoxShape.circle),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    leftChevronIcon: const Icon(Icons.chevron_left,
                        color: Color(0xFF00BBA7)),
                    rightChevronIcon: const Icon(Icons.chevron_right,
                        color: Color(0xFF00BBA7)),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey.shade600),
                    weekendStyle: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                  calendarBuilders: CalendarBuilders(
                    dowBuilder: (context, day) {
                      final text = [
                        'Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'
                      ][day.weekday % 7];
                      return Center(
                        child: Text(text,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade700)),
                      );
                    },
                    defaultBuilder: (context, day, _) =>
                        _buildDayCell(day),
                    todayBuilder: (context, day, _) =>
                        _buildDayCell(day, isToday: true),
                    selectedBuilder: (context, day, _) =>
                        _buildDayCell(day, isSelected: true),
                    outsideBuilder: (context, day, _) =>
                        _buildDayCell(day, isOutside: true),
                  ),
                ),
                const SizedBox(height: 16),
                // Legenda
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F7F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _legendItem(Colors.grey.shade400, 'Hari Ini'),
                      _legendItem(const Color(0xFF43A047), 'Ada Booking'),
                      _legendItem(Colors.transparent, 'Kosong',
                          border: true),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Detail booking tanggal yang dipilih ──────────────────────────
          const SizedBox(height: 16),
          if (_hasBooking(selectedDay))
            _SelectedDayBookings(
              selectedDay: selectedDay,
              supabase: _supabase,
            ),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day, {
    bool isToday = false,
    bool isSelected = false,
    bool isOutside = false,
  }) {
    final hasBooking = _hasBooking(day);

    BoxDecoration decoration;
    Color textColor;

    if (isToday && isSelected) {
      decoration = BoxDecoration(
          color: Colors.grey.shade600,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade800, width: 2));
      textColor = Colors.white;
    } else if (isToday) {
      decoration = BoxDecoration(
          color: Colors.grey.shade400, shape: BoxShape.circle);
      textColor = Colors.white;
    } else if (isSelected && hasBooking) {
      decoration = const BoxDecoration(
          color: Color(0xFF00897B), shape: BoxShape.circle);
      textColor = Colors.white;
    } else if (isSelected) {
      decoration = BoxDecoration(
          color: const Color(0xFF00BBA7).withOpacity(0.20),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF00BBA7), width: 1.5));
      textColor = const Color(0xFF00BBA7);
    } else if (hasBooking) {
      decoration = const BoxDecoration(
          color: Color(0xFF43A047), shape: BoxShape.circle);
      textColor = Colors.white;
    } else {
      decoration = const BoxDecoration();
      textColor = isOutside ? Colors.grey.shade400 : Colors.black87;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: decoration,
      child: Center(
        child: Text(
          '${day.day}',
          style: GoogleFonts.inter(fontSize: 14, color: textColor),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label, {bool border = false}) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: border ? Border.all(color: Colors.grey.shade300) : null,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12, color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// WIDGET: detail booking tanggal yang dipilih
// =============================================================================

class _SelectedDayBookings extends StatefulWidget {
  final DateTime selectedDay;
  final SupabaseClient supabase;

  const _SelectedDayBookings({
    required this.selectedDay,
    required this.supabase,
  });

  @override
  State<_SelectedDayBookings> createState() => _SelectedDayBookingsState();
}

class _SelectedDayBookingsState extends State<_SelectedDayBookings> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchDetail();
  }

  @override
  void didUpdateWidget(_SelectedDayBookings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDay(oldWidget.selectedDay, widget.selectedDay)) {
      // ✅ FIX: WidgetsBinding (bukan WidgetBinding) + mounted check
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _future = _fetchDetail());
        }
      });
    }
  }

  Future<String> _getFisioterapisId() async {
    final userId = widget.supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login');
    final res = await widget.supabase
        .from('fisioterapis')
        .select('id')
        .eq('user_id', userId)
        .single();
    return res['id'] as String;
  }

  Future<List<Map<String, dynamic>>> _fetchDetail() async {
    final fisioterapisId = await _getFisioterapisId();
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.selectedDay);

    final response = await widget.supabase
        .from('bookings')
        .select('scheduled_time, service_type, status, patients(full_name)')
        .eq('fisioterapis_id', fisioterapisId)
        .eq('scheduled_date', dateStr)
        .inFilter('status', ['confirmed', 'on_going', 'completed'])
        .order('scheduled_time', ascending: true);

    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final items = snapshot.data!;
        if (items.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05), blurRadius: 8)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jadwal ${DateFormat('dd MMMM yyyy', 'id_ID').format(widget.selectedDay)}',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              ...items.map((e) {
                final time =
                    (e['scheduled_time'] as String).substring(0, 5);
                final name =
                    (e['patients'] as Map?)?['full_name'] ?? 'Pasien';
                final service = e['service_type'] as String;
                final status = e['status'] as String;

                final statusColor = switch (status) {
                  'on_going' => Colors.orange,
                  'completed' => const Color(0xFF00BBA7),
                  _ => Colors.blue,
                };
                final statusLabel = switch (status) {
                  'confirmed' => 'Dikonfirmasi',
                  'on_going' => 'Berlangsung',
                  'completed' => 'Selesai',
                  _ => status,
                };

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Text(time,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: const Color(0xFF00BBA7))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                            Text(service,
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.grey)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(statusLabel,
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}