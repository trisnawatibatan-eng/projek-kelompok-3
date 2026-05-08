import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScheduleSlot {
  final String day;
  final String startTime;
  final String endTime;

  ScheduleSlot({
    required this.day,
    required this.startTime,
    required this.endTime,
  });
}

class AturJadwalScreen extends StatefulWidget {
  const AturJadwalScreen({super.key});

  @override
  State<AturJadwalScreen> createState() => _AturJadwalScreenState();
}

class _AturJadwalScreenState extends State<AturJadwalScreen> {
  final List<String> days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  late Map<String, List<ScheduleSlot>> scheduleByDay;
  late Map<String, bool> dayAvailability; // Track availability per day
  int maxPatientPerDay = 5;

  @override
  void initState() {
    super.initState();
    _initializeSchedule();
  }

  void _initializeSchedule() {
    scheduleByDay = {
      'Senin': [
        ScheduleSlot(day: 'Senin', startTime: '08:00', endTime: '12:00'),
        ScheduleSlot(day: 'Senin', startTime: '13:00', endTime: '16:00'),
      ],
      'Selasa': [
        ScheduleSlot(day: 'Selasa', startTime: '08:00', endTime: '12:00'),
        ScheduleSlot(day: 'Selasa', startTime: '13:00', endTime: '16:00'),
      ],
      'Rabu': [
        ScheduleSlot(day: 'Rabu', startTime: '08:00', endTime: '12:00'),
        ScheduleSlot(day: 'Rabu', startTime: '13:00', endTime: '16:00'),
      ],
      'Kamis': [
        ScheduleSlot(day: 'Kamis', startTime: '08:00', endTime: '12:00'),
        ScheduleSlot(day: 'Kamis', startTime: '13:00', endTime: '16:00'),
      ],
      'Jumat': [
        ScheduleSlot(day: 'Jumat', startTime: '08:00', endTime: '12:00'),
        ScheduleSlot(day: 'Jumat', startTime: '13:00', endTime: '16:00'),
      ],
      'Sabtu': [],
      'Minggu': [],
    };

    dayAvailability = {
      'Senin': true,
      'Selasa': true,
      'Rabu': true,
      'Kamis': true,
      'Jumat': true,
      'Sabtu': false,
      'Minggu': false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Custom AppBar dengan header info
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
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                      ),
                      Text(
                        'Atur jadwal kerja sesuai Anda',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
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
                            const Icon(Icons.info_outline, size: 18, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Pengaturan jadwal akan membantu pasien mengetahui ketersediaan Anda',
                                style: GoogleFonts.inter(fontSize: 11, color: Colors.white),
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
          // Content
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
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengaturan Umum',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Maksimal Pasien Per Hari',
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => setState(() => maxPatientPerDay = (maxPatientPerDay - 1).clamp(1, 20)),
                                    child: const Icon(Icons.remove, size: 18, color: Color(0xFF00BBA7)),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '$maxPatientPerDay',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () => setState(() => maxPatientPerDay = (maxPatientPerDay + 1).clamp(1, 20)),
                                    child: const Icon(Icons.add, size: 18, color: Color(0xFF00BBA7)),
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
                  Text(
                    'Jadwal Mingguan',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  ...days.map((day) {
                    final slots = scheduleByDay[day] ?? [];
                    final isAvailable = dayAvailability[day] ?? true;
                    return _DayScheduleCard(
                      day: day,
                      isAvailable: isAvailable,
                      slots: slots,
                      onToggleAvailability: () => setState(() => dayAvailability[day] = !isAvailable),
                      onAddSlot: () => _showAddTimeDialog(context, day),
                      onRemoveSlot: (slot) => setState(() => slots.remove(slot)),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTimeDialog(BuildContext context, String day) {
    final startController = TextEditingController();
    final endController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Waktu - $day', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: startController,
                decoration: InputDecoration(
                  labelText: 'Jam Mulai',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: '08:00',
                ),
                readOnly: true,
                onTap: () => _selectTime(context, startController),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: endController,
                decoration: InputDecoration(
                  labelText: 'Jam Selesai',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: '12:00',
                ),
                readOnly: true,
                onTap: () => _selectTime(context, endController),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.inter(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              if (startController.text.isNotEmpty && endController.text.isNotEmpty) {
                final newSlot = ScheduleSlot(
                  day: day,
                  startTime: startController.text,
                  endTime: endController.text,
                );
                setState(() {
                  if (scheduleByDay[day] == null) {
                    scheduleByDay[day] = [];
                  }
                  scheduleByDay[day]!.add(newSlot);
                  scheduleByDay[day]!.sort((a, b) => a.startTime.compareTo(b.startTime));
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua field harus diisi')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BBA7)),
            child: Text('Simpan', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _selectTime(BuildContext context, TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null && context.mounted) {
      controller.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Toggle Button
                  GestureDetector(
                    onTap: onToggleAvailability,
                    child: Container(
                      width: 50,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: isAvailable ? const Color(0xFF00BBA7) : Colors.grey.shade300,
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
                  Text(day, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              if (isAvailable)
                TextButton.icon(
                  onPressed: onAddSlot,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: const Color(0xFFE8F6F4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, size: 16, color: Color(0xFF00BBA7)),
                  label: Text('Tambah', style: GoogleFonts.inter(color: const Color(0xFF00BBA7), fontSize: 12, fontWeight: FontWeight.w600)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Libur',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          if (isAvailable) ...[
            const SizedBox(height: 12),
            if (slots.isNotEmpty) ...[
              ...slots.map((slot) => _ScheduleSlotTile(
                slot: slot,
                onRemove: () => onRemoveSlot(slot),
              )),
            ],
          ],
        ],
      ),
    );
  }
}

class _ScheduleSlotTile extends StatelessWidget {
  final ScheduleSlot slot;
  final VoidCallback onRemove;

  const _ScheduleSlotTile({
    required this.slot,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${slot.startTime} - ${slot.endTime}',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 20, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
