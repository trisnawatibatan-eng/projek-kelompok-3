import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentStep = 1;
  final Color primaryColor = const Color(0xFF009688);
  String? _selectedBank = "Bank BCA";

  // State untuk menyimpan layanan yang dipilih user
  Map<String, String> _selectedService = {
    "emoji": "🦷",
    "name": "Terapi Skoliosis",
    "price": "Rp 290.000",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _currentStep > 1 ? setState(() => _currentStep--) : Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pesan Home Care', 
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(_getSubtitle(), 
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildCurrentContent(),
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  String _getSubtitle() {
    if (_currentStep == 1) return "Pilih layanan fisioterapi";
    if (_currentStep == 2) return "Atur jadwal kunjungan";
    if (_currentStep == 3) return "Ringkasan pesanan";
    if (_currentStep == 4) return "Pilih cara pembayaran";
    return "Konfirmasi pembayaran";
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Row(children: List.generate(5, (i) {
        bool active = _currentStep >= (i + 1);
        return Expanded(child: Row(children: [
          CircleAvatar(
            radius: 12, 
            backgroundColor: active ? primaryColor : Colors.grey[200], 
            child: Text("${i+1}", style: TextStyle(color: active?Colors.white:Colors.grey, fontSize: 10))),
          if (i < 4) Expanded(child: Container(height: 2, color: _currentStep > (i + 1) ? primaryColor : Colors.grey[200]))
        ]));
      })),
    );
  }

  Widget _buildCurrentContent() {
    switch (_currentStep) {
      case 1: return _buildStep1();
      case 2: return _buildStep2();
      case 3: return _buildStep3();
      case 4: return _buildStep4();
      case 5: return _buildStep5();
      default: return const SizedBox();
    }
  }

  // --- STEP 1: PILIH LAYANAN ---
  Widget _buildStep1() {
    return Column(children: [
      _buildInfoBox("Pilih jenis terapi yang sesuai dengan kondisi Anda untuk mendapatkan penanganan terbaik."),
      const SizedBox(height: 16),
      _buildServiceCard("🧠", "Terapi Stroke", "Neurologi", "Rehabilitasi fungsi motorik pasca stroke", "Rp 300.000"),
      _buildServiceCard("🦴", "Terapi Fraktur", "Ortopedi", "Pemulihan setelah patah tulang", "Rp 280.000"),
      _buildServiceCard("🦷", "Terapi Skoliosis", "Ortopedi", "Koreksi kelainan tulang belakang", "Rp 290.000"),
      _buildServiceCard("🔧", "Terapi Dislokasi", "Ortopedi", "Pemulihan sendi yang bergeser", "Rp 280.000"),
      _buildServiceCard("⚽", "Terapi Cedera Olahraga", "Sport", "Rehabilitasi cedera aktivitas fisik", "Rp 320.000"),
      _buildServiceCard("💢", "Terapi Nyeri Punggung", "Pain Management", "Mengatasi nyeri punggung kronis", "Rp 260.000"),
      _buildServiceCard("🏥", "Terapi Pasca Operasi", "Rehabilitasi", "Pemulihan optimal setelah prosedur operasi", "Rp 280.000"),
      _buildServiceCard("👴", "Terapi Lansia", "Geriatri", "Perawatan mobilitas khusus lansia", "Rp 275.000"),
      _buildServiceCard("💪", "Terapi Osteoartritis", "Pain Management", "Mengurangi nyeri sendi lutut/tangan", "Rp 270.000"),
      const SizedBox(height: 20),
    ]);
  }

  // --- STEP 2: JADWAL & LOKASI ---
  Widget _buildStep2() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _buildHeaderBox(_selectedService["emoji"]!, _selectedService["name"]!, "60 menit • ${_selectedService["price"]}"),
    _label("Alamat"),
    _field("Jl. Tidar No. 01, Sumbersari, Jember", Icons.location_on),
    _label("Tanggal Kunjungan *"),
    _field("Pilih tanggal", Icons.calendar_today),
    _label("Waktu Kunjungan *"),
    _field("Pilih jam terapi", Icons.access_time),
    _label("Terapis"),
    _buildTherapistCard(),
    const SizedBox(height: 20),
  ]);

  // --- STEP 3: RINGKASAN ---
  Widget _buildStep3() => _buildSummaryCard("Ringkasan Pesanan", _selectedService["name"]!, _calculateTotal());

  // --- STEP 4: PILIH METODE PEMBAYARAN ---
  Widget _buildStep4() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _buildInfoBox("Pilih metode pembayaran transfer bank."),
    _label("Transfer Bank *"),
    _buildBankOption("Bank BCA"),
    _buildBankOption("Bank Mandiri"),
    _buildBankOption("Bank BNI"),
    _buildBankOption("Bank BRI"),
    const SizedBox(height: 20),
  ]);

  // --- STEP 5: DETAIL PEMBAYARAN ---
  Widget _buildStep5() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _buildBankDetailCard(),
    const SizedBox(height: 16),
    _buildInstructionBox(),
    const SizedBox(height: 16),
    _buildSummaryCard("Total Pembayaran", _selectedService["name"]!, _calculateTotal()),
    const SizedBox(height: 16),
    _buildUploadBox(),
    const SizedBox(height: 20),
  ]);

  // --- LOGIKA HITUNG TOTAL ---
  String _calculateTotal() {
    // Mengambil angka dari string harga (misal "Rp 280.000" -> 280000)
    int servicePrice = int.parse(_selectedService["price"]!.replaceAll(RegExp(r'[^0-9]'), ''));
    int visitFee = 50000;
    int total = servicePrice + visitFee;
    return "Rp ${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  // --- KOMPONEN PENDUKUNG ---

  Widget _buildInfoBox(String t) => Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.info_outline, color: Colors.blue, size: 20), const SizedBox(width: 10), Expanded(child: Text(t, style: const TextStyle(fontSize: 12, color: Colors.blue)))]));

  Widget _buildServiceCard(String e, String n, String c, String d, String p) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedService = {"emoji": e, "name": n, "price": p};
          _currentStep = 2; // Langsung pindah ke step 2 saat diklik
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12), color: Colors.white),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(8)), child: Text(e, style: const TextStyle(fontSize: 20))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(c, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ])),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ]),
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Estimasi 60 mnt", style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(p, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildHeaderBox(String e, String n, String s) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(12)), child: Row(children: [Text(e, style: const TextStyle(fontSize: 20)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n, style: const TextStyle(fontWeight: FontWeight.bold)), Text(s, style: const TextStyle(fontSize: 12, color: Colors.grey))])]));

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(top: 15, bottom: 8), child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)));

  Widget _field(String h, IconData i) => TextField(decoration: InputDecoration(hintText: h, suffixIcon: Icon(i, size: 20), filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)));

  Widget _buildTherapistCard() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(border: Border.all(color: primaryColor.withOpacity(0.2)), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      const CircleAvatar(backgroundColor: Colors.teal, child: Text("AR", style: TextStyle(color: Colors.white))),
      const SizedBox(width: 12),
      const Expanded(child: Text("Ftr. Ahmad Rizki, S.Tr.Kes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
      const Icon(Icons.check_circle, color: Colors.green, size: 20),
    ]),
  );

  Widget _buildBankOption(String n) => RadioListTile(value: n, groupValue: _selectedBank, title: Text(n), activeColor: primaryColor, onChanged: (v) => setState(() => _selectedBank = v as String?));

  Widget _buildBankDetailCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFFF0FDFA), border: Border.all(color: primaryColor.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Row(children: [const Icon(Icons.account_balance, color: Colors.teal), const SizedBox(width: 10), Text(_selectedBank!, style: const TextStyle(fontWeight: FontWeight.bold)), const Spacer(), const Icon(Icons.copy, size: 18, color: Colors.blue)]),
      const Divider(height: 24),
      const Text("1234567890", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const Text("Atas Nama: PT Fisioterapi Home Care", style: TextStyle(color: Colors.grey, fontSize: 12)),
    ]),
  );

  Widget _buildInstructionBox() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
    child: const Text("1. Transfer nominal sesuai total\n2. Upload bukti di bawah", style: TextStyle(fontSize: 12, height: 1.5)),
  );

  Widget _buildUploadBox() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
    child: const Column(children: [
      Icon(Icons.cloud_upload_outlined, size: 30, color: Colors.grey),
      Text("Upload Bukti Transfer", style: TextStyle(fontSize: 12, color: Colors.grey)),
    ]),
  );

  Widget _buildSummaryCard(String title, String service, String total) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFFF0FDFA), borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      const Divider(),
      _sumRow("Layanan", service),
      _sumRow("Biaya Terapi", _selectedService["price"]!),
      _sumRow("Biaya Kunjungan", "Rp 50.000"),
      const Divider(),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("Total Bayar", style: TextStyle(fontWeight: FontWeight.bold)),
        Text(total, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor)),
      ]),
    ]),
  );

  Widget _sumRow(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(fontSize: 13, color: Colors.grey)), Text(v, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))]));

  Widget _buildBottomAction() => Container(
    padding: const EdgeInsets.all(20),
    child: Row(children: [
      if (_currentStep > 1) Expanded(child: OutlinedButton(onPressed: () => setState(() => _currentStep--), child: const Text("Kembali"))),
      if (_currentStep > 1) const SizedBox(width: 12),
      Expanded(child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
        onPressed: () => _currentStep < 5 ? setState(() => _currentStep++) : null,
        child: Text(_currentStep < 5 ? "Lanjutkan" : "Konfirmasi Pesanan", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      )),
    ]),
  );
}