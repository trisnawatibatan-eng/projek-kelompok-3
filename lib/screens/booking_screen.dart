import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav_bar.dart';
import 'janji_temu_screen.dart';

class BookingScreen extends StatefulWidget {
  final String? initialTherapy;
  final String? initialPrice;
  final int? initialCost;

  const BookingScreen({
    super.key,
    this.initialTherapy,
    this.initialPrice,
    this.initialCost,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _supabase = Supabase.instance.client;

  int _currentStep = 1;

  // ── Step 1: Services ──────────────────────────────────────────
  List<Map<String, dynamic>> _services = [];
  bool _isLoadingServices = true;

  Map<String, dynamic>? _selectedService;
  String? _selectedTherapy;
  String? _selectedPrice;
  int _therapyCost = 0;

  // ── Wilayah pasien ────────────────────────────────────────────
  // FIX: Dibaca dari patient_addresses (is_primary=true), bukan dari patients
  String? _patientRegencyId;
  String? _patientRegencyName;
  bool _hasPrimaryAddress = false; // true jika punya alamat utama

  // ── Step 2: Alamat ────────────────────────────────────────────
  List<Map<String, dynamic>> _addresses = [];
  Map<String, dynamic>? _selectedAddressRow;
  bool _isChoosingAddress = false;
  bool _isLoadingAddresses = true;

  int _visitCost = 50000;

  // ── Jadwal Fisioterapis ───────────────────────────────────────
  Map<String, Map<String, dynamic>> _jadwalMap = {};
  bool _isLoadingJadwal = true;

  List<TimeOfDay> _availableSlots = [];

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _noteController = TextEditingController();

  // ── Step 3: Fisioterapis ──────────────────────────────────────
  Map<String, dynamic>? _fisioterapis;
  bool _isLoadingFisio = true;

  bool _isSubmitting = false;

  String? get _patientId => _supabase.auth.currentUser?.id;

  static const List<String> _hariIndonesia = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  String _weekdayToHari(int weekday) => _hariIndonesia[weekday - 1];

  @override
  void initState() {
    super.initState();
    _loadAll();

    if (widget.initialTherapy != null) {
      _selectedTherapy = widget.initialTherapy;
      _therapyCost = widget.initialCost ?? 0;
      _selectedPrice = widget.initialPrice ??
          'Rp ${NumberFormat('#,###', 'id_ID').format(_therapyCost)}';
      _currentStep = 2;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // ── Load semua data ───────────────────────────────────────────

  Future<void> _loadAll() async {
    // FIX: Load addresses dulu (untuk ambil regency_id dari alamat utama),
    // baru load services & fisioterapis yang butuh regency_id
    await _loadAddresses();
    await Future.wait([
      _loadServices(),
      _loadFisioterapis(),
    ]);
    await _loadJadwal();
  }

  // ── FIX: Baca regency dari patient_addresses (is_primary=true) ──
  // Jika tidak ada alamat utama, fallback ke alamat pertama.
  // Jika tidak ada alamat sama sekali → _hasPrimaryAddress = false.
  Future<void> _loadAddresses() async {
    if (_patientId == null) {
      if (mounted) setState(() => _isLoadingAddresses = false);
      return;
    }
    try {
      final res = await _supabase
          .from('patient_addresses')
          .select()
          .eq('patient_id', _patientId!)
          .order('is_primary', ascending: false)
          .order('created_at');

      if (mounted) {
        final list = List<Map<String, dynamic>>.from(res as List);

        // Pilih alamat utama untuk dipakai sebagai filter wilayah
        Map<String, dynamic>? primaryAddr;
        if (list.isNotEmpty) {
          primaryAddr = list.firstWhere(
            (a) => a['is_primary'] == true,
            orElse: () => list.first,
          );
        }

        setState(() {
          _addresses = list;
          _isLoadingAddresses = false;
          _selectedAddressRow = primaryAddr;

          if (primaryAddr != null) {
            // FIX: Ambil regency_id dari patient_addresses, bukan dari patients
            _patientRegencyId = primaryAddr['regency_id'] as String?;
            _patientRegencyName = primaryAddr['regency_name'] as String?;
            _hasPrimaryAddress = true;
          } else {
            _patientRegencyId = null;
            _patientRegencyName = null;
            _hasPrimaryAddress = false;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading addresses: $e');
      if (mounted) setState(() => _isLoadingAddresses = false);
    }
  }

  Future<void> _loadServices() async {
    try {
      // Jika pasien belum punya alamat tersimpan, tampilkan pesan kosong
      if (!_hasPrimaryAddress ||
          _patientRegencyId == null ||
          _patientRegencyId!.isEmpty) {
        if (mounted) setState(() => _isLoadingServices = false);
        return;
      }

      // Query services dengan filter fisioterapis di kabupaten/kota yang sama
      final res = await _supabase
          .from('services')
          .select(
            '*, fisioterapis!inner(id, nama_lengkap, pengalaman_kerja, '
            'foto_profil_url, regency_id, regency_name)',
          )
          .eq('is_active', true)
          .eq('fisioterapis.status_verifikasi', 'verified')
          .eq('fisioterapis.is_active', true)
          .eq('fisioterapis.regency_id', _patientRegencyId!)
          .order('nama_layanan');

      if (mounted) {
        setState(() {
          _services = List<Map<String, dynamic>>.from(res as List);
          _isLoadingServices = false;

          if (widget.initialTherapy != null && _selectedService == null) {
            final matches = _services
                .where((s) => s['nama_layanan'] == widget.initialTherapy);
            if (matches.isNotEmpty) {
              final match = matches.first;
              _selectedService = match;
              _therapyCost = (match['harga'] as num).toInt();
              _selectedPrice =
                  'Rp ${NumberFormat('#,###', 'id_ID').format(_therapyCost)}';
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading services: $e');
      if (mounted) setState(() => _isLoadingServices = false);
    }
  }

  Future<void> _loadFisioterapis() async {
    try {
      // Jika pasien tidak memiliki alamat, tidak perlu load fisioterapis
      if (!_hasPrimaryAddress ||
          _patientRegencyId == null ||
          _patientRegencyId!.isEmpty) {
        if (mounted) setState(() => _isLoadingFisio = false);
        return;
      }

      final res = await _supabase
          .from('fisioterapis')
          .select('*, harga_kunjungan(harga)')
          .eq('is_active', true)
          .eq('status_verifikasi', 'verified')
          .eq('regency_id', _patientRegencyId!)
          .limit(1)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _fisioterapis = res;
          if (res != null) {
            final hargaData = res['harga_kunjungan'];
            if (hargaData != null && hargaData is Map) {
              _visitCost = (hargaData['harga'] as num?)?.toInt() ?? 50000;
            }
          }
          _isLoadingFisio = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading fisioterapis: $e');
      if (mounted) setState(() => _isLoadingFisio = false);
    }
  }

  Future<void> _loadJadwal() async {
    final fisioterapisId =
        (_selectedService?['fisioterapis'] as Map?)?['id'] ??
            _fisioterapis?['id'];

    if (fisioterapisId == null) {
      if (mounted) setState(() => _isLoadingJadwal = false);
      return;
    }

    try {
      final res = await _supabase
          .from('jadwal_fisioterapis')
          .select()
          .eq('fisioterapis_id', fisioterapisId)
          .eq('is_available', true);

      if (mounted) {
        final map = <String, Map<String, dynamic>>{};
        for (final row in res as List) {
          final hari = row['hari'] as String;
          map[hari] = Map<String, dynamic>.from(row as Map);
        }
        setState(() {
          _jadwalMap = map;
          _isLoadingJadwal = false;
          _selectedDate = null;
          _selectedTime = null;
          _availableSlots = [];
        });
      }
    } catch (e) {
      debugPrint('Error loading jadwal: $e');
      if (mounted) setState(() => _isLoadingJadwal = false);
    }
  }

  // ── Hitung slot jam tersedia ──────────────────────────────────

  List<TimeOfDay> _buildSlots(String jamMulai, String jamSelesai) {
    final mulai = _parseTime(jamMulai);
    final selesai = _parseTime(jamSelesai);
    if (mulai == null || selesai == null) return [];

    final slots = <TimeOfDay>[];
    var current = mulai;
    while (_timeToMinutes(current) + 60 <= _timeToMinutes(selesai)) {
      slots.add(current);
      current = TimeOfDay(
        hour: (current.hour * 60 + current.minute + 60) ~/ 60 % 24,
        minute: (current.minute + 60) % 60,
      );
    }
    return slots;
  }

  TimeOfDay? _parseTime(String t) {
    try {
      final parts = t.split(':');
      return TimeOfDay(
          hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }

  int _timeToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  void _onDateSelected(DateTime date) {
    final hari = _weekdayToHari(date.weekday);
    final jadwal = _jadwalMap[hari];

    setState(() {
      _selectedDate = date;
      _selectedTime = null;
      if (jadwal != null) {
        _availableSlots = _buildSlots(
          jadwal['jam_mulai'] as String,
          jadwal['jam_selesai'] as String,
        );
      } else {
        _availableSlots = [];
      }
    });
  }

  bool _isDateAvailable(DateTime date) {
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return false;
    }
    final hari = _weekdayToHari(date.weekday);
    return _jadwalMap.containsKey(hari);
  }

  // ── Submit booking ────────────────────────────────────────────

  Future<void> _submitBooking() async {
    if (_patientId == null) {
      _showSnack('Silakan login terlebih dahulu');
      return;
    }
    if (_fisioterapis == null) {
      _showSnack('Fisioterapis tidak ditemukan');
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      _showSnack('Pilih tanggal dan jam dahulu');
      return;
    }
    if (_selectedAddressRow == null) {
      _showSnack('Pilih alamat terlebih dahulu');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final timeStr =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00';
      final total = _therapyCost + _visitCost;
      final address =
          _selectedAddressRow!['full_address'] as String? ?? '';

      final fisioterapisId =
          (_selectedService?['fisioterapis'] as Map?)?['id'] ??
              _fisioterapis!['id'];

      await _supabase.from('bookings').insert({
        'patient_id': _patientId,
        'fisioterapis_id': fisioterapisId,
        'service_type': _selectedTherapy,
        'scheduled_date': dateStr,
        'scheduled_time': timeStr,
        'status': 'pending',
        'notes': _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        'address': address,
        'total_price': total,
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const JanjiTemuScreen()),
      );
    } catch (e) {
      debugPrint('Error submitting booking: $e');
      _showSnack('Gagal membuat booking. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBA7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_isChoosingAddress) {
              setState(() => _isChoosingAddress = false);
            } else if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text('Pesan Home Care',
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildStepperHeader(),
          Expanded(child: _buildCurrentContent()),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildCurrentContent() {
    if (_currentStep == 1) return _buildTherapySelection();
    if (_currentStep == 2) return _buildBookingForm();
    return _buildPaymentSummary();
  }

  // ── STEPPER ───────────────────────────────────────────────────

  Widget _buildStepperHeader() => Container(
        color: const Color(0xFF00BBA7),
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _stepCircle("1", _currentStep >= 1),
            _stepLine(_currentStep >= 2),
            _stepCircle("2", _currentStep >= 2),
            _stepLine(_currentStep >= 3),
            _stepCircle("3", _currentStep >= 3),
          ],
        ),
      );

  Widget _stepCircle(String t, bool a) => Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
            color: a ? const Color(0xFF00897B) : Colors.white24,
            shape: BoxShape.circle),
        child: Center(
            child: Text(t,
                style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 12))),
      );

  Widget _stepLine(bool a) => Container(
      width: 40,
      height: 2,
      color: a ? const Color(0xFF00897B) : Colors.white24);

  // ── STEP 1: PILIH LAYANAN ─────────────────────────────────────

  Widget _buildTherapySelection() {
    if (_isLoadingServices || _isLoadingAddresses) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF00BBA7)));
    }

    // FIX: Kasus pasien belum punya alamat tersimpan sama sekali
    if (!_hasPrimaryAddress || _addresses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_off_outlined,
                    size: 56, color: Colors.orange.shade400),
              ),
              const SizedBox(height: 16),
              Text(
                'Tambahkan Alamat Terlebih Dahulu',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Harap tambahkan alamat pada profil Anda agar kami dapat menampilkan fisioterapis yang tersedia di area Anda.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: Text('Kembali ke Profil',
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BBA7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Kasus: tidak ada fisioterapis/layanan di wilayah pasien
    if (_services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_off_outlined,
                    size: 56, color: Color(0xFF00BBA7)),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum Tersedia di Wilayah Anda',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              if (_patientRegencyName != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Color(0xFF00BBA7)),
                      const SizedBox(width: 4),
                      Text(
                        _patientRegencyName!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF00897B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                'Fisioterapis belum tersedia di kabupaten/kota Anda saat ini. Silakan coba lagi nanti atau hubungi admin.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final svc = _services[index];
        final harga = (svc['harga'] as num).toInt();
        final hargaStr =
            'Rp ${NumberFormat('#,###', 'id_ID').format(harga)}';
        final isSelected = _selectedService?['id'] == svc['id'];
        final fisio = svc['fisioterapis'] as Map?;
        final deskripsi = svc['deskripsi'] as String?;
        final durasi = svc['durasi_menit'] as int?;

        return GestureDetector(
          onTap: () async {
            setState(() {
              _selectedService = svc;
              _selectedTherapy = svc['nama_layanan'] as String;
              _selectedPrice = hargaStr;
              _therapyCost = harga;
              _isLoadingJadwal = true;
              _selectedDate = null;
              _selectedTime = null;
              _availableSlots = [];
            });
            await _loadJadwal();
            if (mounted) setState(() => _currentStep = 2);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00BBA7)
                      : Colors.grey.shade200,
                  width: isSelected ? 2 : 1),
              borderRadius: BorderRadius.circular(12),
              color:
                  isSelected ? const Color(0xFFE0F2F1) : Colors.white,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.medical_services_outlined,
                      color: Color(0xFF00BBA7)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(svc['nama_layanan'] as String,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      if (fisio != null) ...[
                        const SizedBox(height: 2),
                        Text('Ftr. ${fisio['nama_lengkap'] ?? ''}',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: Colors.grey)),
                      ],
                      if (deskripsi != null &&
                          deskripsi.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(deskripsi,
                            style: GoogleFonts.inter(
                                fontSize: 11, color: Colors.black54),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                      if (durasi != null) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.timer_outlined,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('$durasi menit',
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: Colors.grey)),
                        ]),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(hargaStr,
                    style: GoogleFonts.inter(
                        color: const Color(0xFF00BBA7),
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── STEP 2: FORM BOOKING ──────────────────────────────────────

  Widget _buildBookingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectedTherapyCard(),
          const SizedBox(height: 20),
          if (!_isLoadingJadwal) _buildJadwalInfo(),
          const SizedBox(height: 20),
          _buildLabel(Icons.location_on, "Alamat"),
          _isLoadingAddresses
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF00BBA7)))
              : _isChoosingAddress
                  ? _buildAddressList()
                  : _buildSelectedAddressCard(),
          const SizedBox(height: 20),
          _buildLabel(Icons.calendar_today, "Tanggal Kunjungan *"),
          _isLoadingJadwal
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF00BBA7)))
              : _buildDateSelector(),
          const SizedBox(height: 20),
          _buildLabel(Icons.access_time, "Waktu Kunjungan *"),
          _buildTimeSelector(),
          const SizedBox(height: 20),
          _buildLabel(Icons.notes, "Catatan (opsional)"),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tulis catatan untuk fisioterapis...',
                hintStyle: GoogleFonts.inter(
                    fontSize: 13, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(15),
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildActionButtons(
            onNext: () {
              if (_selectedDate == null || _selectedTime == null) {
                _showSnack('Pilih tanggal dan jam dahulu');
              } else if (_selectedAddressRow == null) {
                _showSnack('Pilih alamat terlebih dahulu');
              } else {
                setState(() => _currentStep = 3);
              }
            },
            nextLabel: "Lanjutkan",
          ),
        ],
      ),
    );
  }

  // ── Widget info jadwal tersedia ───────────────────────────────

  Widget _buildJadwalInfo() {
    if (_jadwalMap.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.orange.shade400, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Fisioterapis belum mengatur jadwal. Silakan hubungi admin.',
              style: GoogleFonts.inter(
                  fontSize: 12, color: Colors.orange.shade800),
            ),
          ),
        ]),
      );
    }

    final hariTersedia =
        _hariIndonesia.where((h) => _jadwalMap.containsKey(h)).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.schedule,
                size: 16, color: Color(0xFF00BBA7)),
            const SizedBox(width: 6),
            Text('Jadwal Tersedia',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00897B))),
          ]),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: hariTersedia.map((hari) {
              final jadwal = _jadwalMap[hari]!;
              final mulai =
                  _formatTimeStr(jadwal['jam_mulai'] as String);
              final selesai =
                  _formatTimeStr(jadwal['jam_selesai'] as String);
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: const Color(0xFF00BBA7)),
                ),
                child: Text(
                  '$hari  $mulai–$selesai',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF00897B),
                      fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatTimeStr(String t) {
    try {
      final parts = t.split(':');
      return '${parts[0]}:${parts[1]}';
    } catch (_) {
      return t;
    }
  }

  // ── Date selector ─────────────────────────────────────────────

  Widget _buildDateSelector() {
    if (_jadwalMap.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('Tidak ada jadwal tersedia',
            style:
                GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
      );
    }

    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Icon(Icons.calendar_month,
                  color: Color(0xFF00BBA7), size: 18),
              const SizedBox(width: 10),
              Text(
                _selectedDate == null
                    ? 'Pilih tanggal yang tersedia'
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _selectedDate == null
                        ? Colors.grey
                        : Colors.black87),
              ),
            ]),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ── Time selector ─────────────────────────────────────────────

  Widget _buildTimeSelector() {
    if (_selectedDate == null) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12)),
        child: Text('Pilih tanggal terlebih dahulu',
            style:
                GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
      );
    }

    if (_availableSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Text(
          'Tidak ada slot jam tersedia pada hari ini',
          style: GoogleFonts.inter(
              fontSize: 13, color: Colors.orange.shade800),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilih jam kunjungan',
              style:
                  GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSlots.map((slot) {
              final isSelected = _selectedTime != null &&
                  _selectedTime!.hour == slot.hour &&
                  _selectedTime!.minute == slot.minute;
              final label =
                  '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}';

              return GestureDetector(
                onTap: () => setState(() => _selectedTime = slot),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00BBA7)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00BBA7)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── STEP 3: RINGKASAN PEMBAYARAN ──────────────────────────────

  Widget _buildPaymentSummary() {
    if (_selectedDate == null || _selectedTime == null) {
      return const Center(child: Text("Data tidak lengkap"));
    }

    final total = _therapyCost + _visitCost;
    final fisioData =
        (_selectedService?['fisioterapis'] as Map<String, dynamic>?) ??
            _fisioterapis;
    final namaFisio =
        fisioData?['nama_lengkap'] as String? ?? '-';
    final pengalaman =
        fisioData?['pengalaman_kerja'] as String? ?? '';
    final fotoUrl = fisioData?['foto_profil_url'] as String?;
    final timeLabel =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')} WIB';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Terapis
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                border:
                    Border.all(color: const Color(0xFF00BBA7)),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF00BBA7),
                  backgroundImage:
                      fotoUrl != null && fotoUrl.isNotEmpty
                          ? NetworkImage(fotoUrl)
                          : null,
                  child: fotoUrl == null || fotoUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ftr. $namaFisio',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      if (pengalaman.isNotEmpty)
                        Text('• $pengalaman',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // Rincian
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                _rowDetail("Layanan", _selectedTherapy ?? ""),
                _rowDetail(
                  "Waktu",
                  "${DateFormat('dd MMM yyyy').format(_selectedDate!)} • $timeLabel",
                ),
                _rowDetail(
                  "Alamat",
                  _selectedAddressRow?['full_address'] as String? ??
                      '-',
                ),
                if (_noteController.text.trim().isNotEmpty)
                  _rowDetail("Catatan", _noteController.text.trim()),
                const Divider(height: 30),
                _rowDetail("Biaya Layanan", _selectedPrice ?? ""),
                _rowDetail(
                  "Biaya Kunjungan",
                  'Rp ${NumberFormat('#,###', 'id_ID').format(_visitCost)}',
                ),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Bayar",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold)),
                    Text(
                      "Rp ${NumberFormat('#,###', 'id_ID').format(total)}",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00BBA7),
                          fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Pembayaran tunai dilakukan setelah layanan selesai.",
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          _buildActionButtons(
            onNext: _isSubmitting ? () {} : _submitBooking,
            nextLabel:
                _isSubmitting ? "Memproses..." : "Konfirmasi Pesanan",
          ),
        ],
      ),
    );
  }

  // ── Sub Widgets ───────────────────────────────────────────────

  Widget _buildSelectedTherapyCard() => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: const Color(0xFFE0F2F1),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.check_circle, color: Color(0xFF00BBA7)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(_selectedTherapy ?? '',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600))),
          Text(_selectedPrice ?? '',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00BBA7))),
        ]),
      );

  Widget _buildSelectedAddressCard() {
    if (_addresses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200)),
        child: Row(children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.orange.shade400),
          const SizedBox(width: 10),
          Expanded(
              child: Text(
                  'Belum ada alamat tersimpan. Tambahkan di profil.',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.black54))),
        ]),
      );
    }
    final addr = _selectedAddressRow;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (addr != null) ...[
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(4)),
                child: Text(
                    addr['label'] as String? ?? 'Rumah',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00BBA7))),
              ),
              if (addr['is_primary'] == true) ...[
                const SizedBox(width: 6),
                const Icon(Icons.star,
                    size: 12, color: Color(0xFF00BBA7)),
              ],
            ]),
            const SizedBox(height: 6),
            Text(addr['full_address'] as String? ?? '',
                style: GoogleFonts.inter(fontSize: 12)),
            Text(
              '${addr['district_name'] ?? ''}, '
              '${addr['regency_name'] ?? ''}, '
              '${addr['province_name'] ?? ''}',
              style:
                  GoogleFonts.inter(fontSize: 11, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 8),
          // FIX: Tampilkan "Ganti alamat" hanya jika punya lebih dari 1 alamat
          if (_addresses.length > 1)
            InkWell(
              onTap: () => setState(() => _isChoosingAddress = true),
              child: Text("Ganti alamat",
                  style: GoogleFonts.inter(
                      color: const Color(0xFF00BBA7),
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressList() => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: const Color(0xFFE0F2F1),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: _addresses
              .map((addr) => RadioListTile<String>(
                    value: addr['id'] as String,
                    groupValue:
                        _selectedAddressRow?['id'] as String?,
                    activeColor: const Color(0xFF00BBA7),
                    title: Text(
                      '${addr['label']} — ${addr['full_address']}',
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                    subtitle: Text(
                      '${addr['district_name']}, ${addr['regency_name']}',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.grey),
                    ),
                    onChanged: (_) => setState(() {
                      _selectedAddressRow = addr;
                      _isChoosingAddress = false;
                    }),
                  ))
              .toList(),
        ),
      );

  Widget _buildLabel(IconData i, String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Icon(i, size: 18, color: const Color(0xFF00BBA7)),
          const SizedBox(width: 8),
          Text(t,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
      );

  Widget _rowDetail(String l, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l,
                style: GoogleFonts.inter(
                    color: Colors.grey, fontSize: 13)),
            const SizedBox(width: 20),
            Flexible(
              child: Text(v,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
      );

  Widget _buildActionButtons(
          {required VoidCallback onNext,
          required String nextLabel}) =>
      Row(children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(
                () { if (_currentStep > 1) _currentStep--; }),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF00BBA7)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("Kembali",
                style: GoogleFonts.inter(
                    color: const Color(0xFF00BBA7))),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BBA7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(nextLabel,
                    style:
                        GoogleFonts.inter(color: Colors.white)),
          ),
        ),
      ]);

  // ── Date Picker ───────────────────────────────────────────────

  Future<void> _selectDate(BuildContext c) async {
    DateTime initialDate = DateTime.now();
    int tries = 0;
    while (!_isDateAvailable(initialDate) && tries < 14) {
      initialDate = initialDate.add(const Duration(days: 1));
      tries++;
    }

    final DateTime? picked = await showDatePicker(
      context: c,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      selectableDayPredicate: _isDateAvailable,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
              primary: Color(0xFF00BBA7)),
        ),
        child: child!,
      ),
    );
    if (picked != null) _onDateSelected(picked);
  }
}