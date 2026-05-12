class BookingModel {
  final String id;
  final String patientId;
  final String fisioterapisId;
  final String serviceType;
  final DateTime scheduledDate;
  final String scheduledTime; // "HH:mm"
  final String status; // pending | confirmed | on_going | completed | cancelled
  final String? notes;
  final String? address;
  final double? totalPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined dari tabel patients
  final String? patientFullName;
  final String? patientPhone;

  BookingModel({
    required this.id,
    required this.patientId,
    required this.fisioterapisId,
    required this.serviceType,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.status,
    this.notes,
    this.address,
    this.totalPrice,
    this.createdAt,
    this.updatedAt,
    this.patientFullName,
    this.patientPhone,
  });

  /// Inisial dari nama pasien (maks 2 huruf)
  String get patientInitials {
    if (patientFullName == null || patientFullName!.isEmpty) return '?';
    final parts = patientFullName!.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      fisioterapisId: map['fisioterapis_id'] as String,
      serviceType: map['service_type'] as String,
      scheduledDate: DateTime.parse(map['scheduled_date'] as String),
      scheduledTime: (map['scheduled_time'] as String).substring(0, 5),
      status: map['status'] as String,
      notes: map['notes'] as String?,
      address: map['address'] as String?,
      totalPrice: (map['total_price'] as num?)?.toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      // dari join ke tabel patients
      patientFullName: map['patients']?['full_name'] as String?,
      patientPhone: map['patients']?['phone'] as String?,
    );
  }
}