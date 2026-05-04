import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/bottom_nav_bar.dart';
import 'janji_temu_screen.dart'; 

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentStep = 1;

  // Data Terpilih (State Management Sederhana)
  String? _selectedTherapy;
  String? _selectedPrice;
  int _therapyCost = 0;
  final int _visitCost = 50000;

  // Data Form (Step 2)
  String _selectedAddress = "Jl. Tidar No. 01, Karangrejo, Sumbersari, Jember";
  bool _isChoosingAddress = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _newAddressController = TextEditingController();

  List<String> _myAddresses = [
    "Jl. Tidar No. 01, Karangrejo, Sumbersari, Jember",
    "Jl. Pekalongan No. 01, Penanggungan, Klojen, Kota Malang",
  ];

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
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

  // --- STEPPER HEADER ---
  Widget _buildStepperHeader() {
    return Container(
      color: const Color(0xFF00BBA7),
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepCircle("1", _currentStep >= 1), _stepLine(_currentStep >= 2),
          _stepCircle("2", _currentStep >= 2), _stepLine(_currentStep >= 3),
          _stepCircle("3", _currentStep >= 3),
        ],
      ),
    );
  }

  Widget _stepCircle(String t, bool a) => Container(
    width: 28, height: 28,
    decoration: BoxDecoration(color: a ? const Color(0xFF00897B) : Colors.white24, shape: BoxShape.circle),
    child: Center(child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 12))),
  );

  Widget _stepLine(bool a) => Container(width: 40, height: 2, color: a ? const Color(0xFF00897B) : Colors.white24);

  // --- STEP 1: PILIH TERAPI ---
  Widget _buildTherapySelection() {
    final therapies = [
      {'name': 'Terapi Stroke', 'price': 'Rp 300.000', 'val': 300000},
      {'name': 'Terapi Fraktur', 'price': 'Rp 280.000', 'val': 280000},
      {'name': 'Terapi Skoliosis', 'price': 'Rp 250.000', 'val': 250000},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: therapies.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => setState(() {
          _selectedTherapy = therapies[index]['name'] as String;
          _selectedPrice = therapies[index]['price'] as String;
          _therapyCost = therapies[index]['val'] as int;
          _currentStep = 2;
        }),
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: _selectedTherapy == therapies[index]['name'] ? const Color(0xFF00BBA7) : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            const Icon(Icons.medical_services_outlined, color: Color(0xFF00BBA7)),
            const SizedBox(width: 15),
            Expanded(child: Text(therapies[index]['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold))),
            Text(therapies[index]['price'] as String, style: const TextStyle(color: Color(0xFF00BBA7), fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }

  // --- STEP 2: FORM ALAMAT & JADWAL ---
  Widget _buildBookingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectedTherapyCard(),
          const SizedBox(height: 20),
          _buildLabel(Icons.location_on, "Alamat"),
          _isChoosingAddress ? _buildAddressList() : _buildSelectedAddressCard(),
          const SizedBox(height: 20),
          _buildLabel(Icons.calendar_today, "Tanggal Kunjungan *"),
          _buildInkInput(_selectedDate == null ? 'pilih tanggal' : DateFormat('dd/MM/yyyy').format(_selectedDate!), Icons.calendar_month, () => _selectDate(context)),
          const SizedBox(height: 20),
          _buildLabel(Icons.access_time, "Waktu Kunjungan *"),
          _buildInkInput(_selectedTime == null ? 'pilih jam' : _selectedTime!.format(context), Icons.keyboard_arrow_down, () => _selectTime(context)),
          const SizedBox(height: 30),
          _buildActionButtons(
            onNext: () {
              if (_selectedDate == null || _selectedTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih tanggal dan jam dahulu")));
              } else {
                setState(() => _currentStep = 3);
              }
            },
            nextLabel: "Lanjutkan"
          ),
        ],
      ),
    );
  }

  // --- STEP 3: RINGKASAN PEMBAYARAN ---
  Widget _buildPaymentSummary() {
    // Validasi pencegahan error layar merah
    if (_selectedDate == null || _selectedTime == null) return const Center(child: Text("Data tidak lengkap"));

    int total = _therapyCost + _visitCost;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Terapis
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFF00BBA7)), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const CircleAvatar(backgroundColor: Color(0xFF00BBA7), child: Icon(Icons.person, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text("Ftr. Siti Nurhaliza, S.Tr.Kes", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("• 10 tahun pengalaman", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ])),
              const Text("Lihat Profil", style: TextStyle(color: Color(0xFF00BBA7), fontWeight: FontWeight.bold, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 25),
          // Rincian Biaya
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(15)),
            child: Column(children: [
              _rowDetail("Layanan", _selectedTherapy ?? ""),
              _rowDetail("Waktu", "${DateFormat('dd MMM yyyy').format(_selectedDate!)} - ${_selectedTime!.format(context)}"),
              const Divider(height: 30),
              _rowDetail("Biaya Terapi", _selectedPrice ?? ""),
              _rowDetail("Biaya Kunjungan", "Rp 50.000"),
              const Divider(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("Total Bayar", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Rp ${NumberFormat('#,###', 'id_ID').format(total)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00BBA7), fontSize: 18)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          // Info Cash
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
            child: Row(children: const [
              Icon(Icons.info_outline, color: Colors.orange),
              SizedBox(width: 10),
              Expanded(child: Text("Pembayaran tunai dilakukan setelah layanan selesai.", style: TextStyle(fontSize: 12, color: Colors.orange))),
            ]),
          ),
          const SizedBox(height: 30),
          _buildActionButtons(
            onNext: () {
              // Navigasi ke Janji Temu
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => JanjiTemuScreen()),
              );
            }, 
            nextLabel: "Konfirmasi Pesanan"
          ),
        ],
      ),
    );
  }

  // --- SUB WIDGETS & LOGIKA ---

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Alamat Baru"),
        content: TextField(
          controller: _newAddressController,
          decoration: const InputDecoration(hintText: "Masukkan alamat lengkap"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              if (_newAddressController.text.isNotEmpty) {
                setState(() {
                  _myAddresses.add(_newAddressController.text);
                  _selectedAddress = _newAddressController.text;
                  _isChoosingAddress = false;
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BBA7)),
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  Widget _buildSelectedTherapyCard() => Container(
    padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [const Icon(Icons.check_circle, color: Color(0xFF00BBA7)), const SizedBox(width: 10), Text(_selectedTherapy ?? ""), const Spacer(), Text(_selectedPrice ?? "", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00BBA7)))]),
  );

  Widget _buildSelectedAddressCard() => Container(
    padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
    child: Column(children: [Text(_selectedAddress, style: const TextStyle(fontSize: 12)), const SizedBox(height: 8), InkWell(onTap: () => setState(() => _isChoosingAddress = true), child: const Text("Ganti alamat", style: TextStyle(color: Color(0xFF00BBA7), fontWeight: FontWeight.bold, fontSize: 12)))]),
  );

  Widget _buildAddressList() => Container(
    padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      ..._myAddresses.map((addr) => RadioListTile<String>(value: addr, groupValue: _selectedAddress, activeColor: const Color(0xFF00BBA7), title: Text(addr, style: const TextStyle(fontSize: 12)), onChanged: (val) => setState(() { _selectedAddress = val!; _isChoosingAddress = false; }))),
      const Divider(),
      TextButton.icon(onPressed: _showAddAddressDialog, icon: const Icon(Icons.add, color: Color(0xFF00BBA7)), label: const Text("Tambah Alamat Baru", style: TextStyle(color: Color(0xFF00BBA7)))),
    ]),
  );

  Widget _buildLabel(IconData i, String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Icon(i, size: 18, color: const Color(0xFF00BBA7)), const SizedBox(width: 8), Text(t, style: const TextStyle(fontWeight: FontWeight.bold))]));

  Widget _buildInkInput(String t, IconData i, VoidCallback tap) => InkWell(onTap: tap, child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t), Icon(i, color: Colors.grey)])));

  Widget _rowDetail(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: Colors.grey, fontSize: 13)), Text(v, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))]));

  Widget _buildActionButtons({required VoidCallback onNext, required String nextLabel}) => Row(children: [
    Expanded(child: OutlinedButton(onPressed: () => setState(() { if(_currentStep > 1) _currentStep--; }), child: const Text("Kembali"))),
    const SizedBox(width: 15),
    Expanded(child: ElevatedButton(onPressed: onNext, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BBA7)), child: Text(nextLabel, style: const TextStyle(color: Colors.white)))),
  ]);

  Future<void> _selectDate(BuildContext c) async {
    final DateTime? p = await showDatePicker(context: c, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
    if (p != null) setState(() => _selectedDate = p);
  }

  Future<void> _selectTime(BuildContext c) async {
    final TimeOfDay? p = await showTimePicker(context: c, initialTime: TimeOfDay.now());
    if (p != null) setState(() => _selectedTime = p);
  }
}