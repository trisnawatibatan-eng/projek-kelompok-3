enum BookingRequestStatus { waiting, accepted, rejected, completed }

class BookingRequest {
  final String patientName;
  final String therapy;
  final String date;
  final String time;
  final String address;
  final String phone;
  BookingRequestStatus status;
  String? rejectionReason;
  List<DateTime>? alternativeDates;
  int? rating;
  String? review;
  String? subjective;
  String? objective;
  String? assessment;
  String? plan;
  String? evaluation;
  String? recommendation;
  String? painScale;
  String? nextTherapyDate;
  String? reportFileUrl;
  String? lastUpdatedText;

  BookingRequest({
    required this.patientName,
    required this.therapy,
    required this.date,
    required this.time,
    required this.address,
    required this.phone,
    this.status = BookingRequestStatus.waiting,
    this.rejectionReason,
    this.alternativeDates,
    this.rating,
    this.review,
    this.subjective,
    this.objective,
    this.assessment,
    this.plan,
    this.evaluation,
    this.recommendation,
    this.painScale,
    this.nextTherapyDate,
    this.reportFileUrl,
  });
}

class BookingRequestRepository {
  static final List<BookingRequest> requests = [
    BookingRequest(
      patientName: 'Budi Santoso',
      therapy: 'Terapi Skoliosis',
      date: 'Senin, 06 April 2026',
      time: '14:00',
      address: 'Jl. Tidar No. 1, Jember, Jawa Timur',
      phone: '+62 812 3456 7890',
    ),
    BookingRequest(
      patientName: 'Budi Santoso',
      therapy: 'Terapi Stroke',
      date: 'Rabu, 08 April 2026',
      time: '09:30',
      address: 'Jl. Tidar No. 1, Jember, Jawa Timur',
      phone: '+62 812 3456 7890',
      status: BookingRequestStatus.accepted,
    ),
    BookingRequest(
      patientName: 'Budi Santoso',
      therapy: 'Terapi Nyeri Punggung',
      date: 'Senin, 30 Maret 2026',
      time: '10:00',
      address: 'Jl. Tidar No. 1, Jember, Jawa Timur',
      phone: '+62 812 3456 7890',
      status: BookingRequestStatus.completed,
      subjective: 'Pasien mengeluhkan nyeri ringan pada punggung bawah saat berdiri lama.',
      objective: 'ROM lumbar terbatas, kekuatan otot inti 4/5, tidak ada edema. Pasien dapat duduk dengan nyaman selama 20 menit.',
      assessment: 'Nyeri mekanis lumbar, kemungkinan akibat postur dan ketegangan otot.',
      plan: 'Latihan stabilisasi inti, peregangan punggung bawah, dan edukasi postur.',
      evaluation: 'Progress baik; pasien menunjukkan berkurangnya nyeri setelah beberapa set latihan.',
      recommendation: 'Lanjutkan latihan 2x sehari, kursi ergonomis, dan pendinginan pasca-aktivitas.',
      painScale: '5/10',
      nextTherapyDate: '30 Maret 2026',
      reportFileUrl: 'https://example.com/laporan-budi.pdf',
    ),
    BookingRequest(
      patientName: 'Rina Kusuma',
      therapy: 'Terapi Stroke',
      date: 'Selasa, 21 Mei 2026',
      time: '10:30',
      address: 'Jl. Diponegoro No. 88, Jakarta Pusat',
      phone: '+62 817 9876 5432',
    ),
    BookingRequest(
      patientName: 'Budi Hartono',
      therapy: 'Terapi Cedera Olahraga',
      date: 'Rabu, 1 April 2026',
      time: '09:00',
      address: 'Jl. Sudirman No. 123, Jakarta Selatan',
      phone: '+62 818 9012 3456',
    ),
  ];

  static void add(BookingRequest request) {
    requests.add(request);
  }
}
