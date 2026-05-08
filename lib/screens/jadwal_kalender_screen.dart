import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

class JadwalKalenderScreen extends StatefulWidget {
  const JadwalKalenderScreen({super.key});

  @override
  State<JadwalKalenderScreen> createState() => _JadwalKalenderScreenState();
}

class _JadwalKalenderScreenState extends State<JadwalKalenderScreen> {
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  final List<DateTime> scheduledDays = [
    DateTime.now().add(const Duration(days: 3)),
    DateTime.now().add(const Duration(days: 7)),
    DateTime.now().subtract(const Duration(days: 5)),
  ];

  bool _isScheduled(DateTime day) {
    return scheduledDays.any((scheduled) => isSameDay(scheduled, day));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBA7),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Jadwal Praktik (Kalender)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
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
                  },
                  onPageChanged: (focused) {
                    setState(() {
                      focusedDay = focused;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(color: const Color(0xFF00BBA7), shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(color: const Color(0xFF00BBA7), shape: BoxShape.circle),
                    markerDecoration: BoxDecoration(color: const Color(0xFF00BBA7), shape: BoxShape.circle),
                    defaultDecoration: BoxDecoration(shape: BoxShape.circle),
                    weekendDecoration: BoxDecoration(shape: BoxShape.circle),
                    outsideDecoration: BoxDecoration(shape: BoxShape.circle),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                    leftChevronIcon: const Icon(Icons.chevron_left, color: Color(0xFF00BBA7)),
                    rightChevronIcon: const Icon(Icons.chevron_right, color: Color(0xFF00BBA7)),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                    weekendStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  calendarBuilders: CalendarBuilders(
                    dowBuilder: (context, day) {
                      final text = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'][day.weekday % 7];
                      return Center(
                        child: Text(text, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700)),
                      );
                    },
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildDayCell(day);
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildDayCell(day, isToday: true);
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return _buildDayCell(day, isSelected: true);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F7F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _legendItem(const Color(0xFF00BBA7), 'Hari Ini'),
                      _legendItem(const Color(0xFFB8EBD0), 'Ada Jadwal'),
                      _legendItem(Colors.transparent, 'Kosong', border: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendarActionButton(String label, VoidCallback onPressed) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 40,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF00BBA7),
            elevation: 0,
            side: const BorderSide(color: Color(0xFF00BBA7)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
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
            child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime day, {bool isToday = false, bool isSelected = false}) {
    final bool isScheduled = _isScheduled(day);
    final textColor = isToday ? Colors.white : Colors.black87;
    BoxDecoration decoration;

    if (isToday) {
      decoration = const BoxDecoration(color: Color(0xFF00BBA7), shape: BoxShape.circle);
    } else if (isScheduled) {
      decoration = BoxDecoration(color: const Color(0xFFB8EBD0), shape: BoxShape.circle);
    } else if (isSelected) {
      decoration = BoxDecoration(color: const Color(0xFF00BBA7).withOpacity(0.15), shape: BoxShape.circle);
    } else {
      decoration = const BoxDecoration();
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
}
