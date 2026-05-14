class JadwalSesi {
  final String id;
  final String patientName;
  final String patientRole;
  final String address;
  final String phone;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // scheduled, ongoing, completed
  final String? therapyNotes;
  final double? therapyPrice;
  final List<String>? therapyServices;

  JadwalSesi({
    required this.id,
    required this.patientName,
    required this.patientRole,
    required this.address,
    required this.phone,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.therapyNotes,
    this.therapyPrice,
    this.therapyServices,
  });
}

class ScheduleRepository {
  static final List<JadwalSesi> _schedules = [
    JadwalSesi(
      id: '1',
      patientName: 'Budi Santoso',
      patientRole: 'Tamu Umum',
      address: 'Jl. Merdeka No. 123, Jakarta Pusat',
      phone: '+62 812 3456 7890',
      startTime: DateTime(2026, 5, 30, 9, 0),
      endTime: DateTime(2026, 5, 30, 10, 0),
      status: 'scheduled',
    ),
    JadwalSesi(
      id: '2',
      patientName: 'Dwi Yana Putri',
      patientRole: 'Tamu Langganan',
      address: 'Jl. Ahmad Yani No. 456, Jakarta Utara',
      phone: '+62 812 3456 7891',
      startTime: DateTime(2026, 5, 30, 11, 0),
      endTime: DateTime(2026, 5, 30, 12, 0),
      status: 'scheduled',
    ),
    JadwalSesi(
      id: '3',
      patientName: 'Siti Aisyah',
      patientRole: 'Tamu Langganan',
      address: 'Jl. Sudirman No. 789, Jakarta Selatan',
      phone: '+62 812 3456 7892',
      startTime: DateTime(2026, 5, 30, 14, 0),
      endTime: DateTime(2026, 5, 30, 15, 0),
      status: 'scheduled',
    ),
    JadwalSesi(
      id: '4',
      patientName: 'Andi Wijaya',
      patientRole: 'Tamu Domisili',
      address: 'Jl. Gatot Subroto No. 321, Jakarta Timur',
      phone: '+62 812 3456 7893',
      startTime: DateTime(2026, 5, 30, 15, 30),
      endTime: DateTime(2026, 5, 30, 16, 30),
      status: 'scheduled',
    ),
  ];

  static List<JadwalSesi> getSchedules() => _schedules;

  static JadwalSesi? getScheduleById(String id) {
    try {
      return _schedules.firstWhere((schedule) => schedule.id == id);
    } catch (e) {
      return null;
    }
  }

  static void updateScheduleStatus(String id, String newStatus) {
    final index = _schedules.indexWhere((schedule) => schedule.id == id);
    if (index != -1) {
      _schedules[index] = JadwalSesi(
        id: _schedules[index].id,
        patientName: _schedules[index].patientName,
        patientRole: _schedules[index].patientRole,
        address: _schedules[index].address,
        phone: _schedules[index].phone,
        startTime: _schedules[index].startTime,
        endTime: _schedules[index].endTime,
        status: newStatus,
        therapyNotes: _schedules[index].therapyNotes,
        therapyPrice: _schedules[index].therapyPrice,
        therapyServices: _schedules[index].therapyServices,
      );
    }
  }

  static void completeSession(String id, String notes, double price, List<String> services) {
    final index = _schedules.indexWhere((schedule) => schedule.id == id);
    if (index != -1) {
      _schedules[index] = JadwalSesi(
        id: _schedules[index].id,
        patientName: _schedules[index].patientName,
        patientRole: _schedules[index].patientRole,
        address: _schedules[index].address,
        phone: _schedules[index].phone,
        startTime: _schedules[index].startTime,
        endTime: _schedules[index].endTime,
        status: 'completed',
        therapyNotes: notes,
        therapyPrice: price,
        therapyServices: services,
      );
    }
  }
}
