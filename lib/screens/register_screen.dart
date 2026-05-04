import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
//  THEME CONSTANTS
// ============================================================
const _teal = Color(0xFF2BB5A0);
const _tealDark = Color(0xFF1E9E8B);
const _tealLight = Color(0xFFE8F7F5);
const _grey = Color(0xFF9E9E9E);
const _border = Color(0xFFDDDDDD);
const _text = Color(0xFF212121);
const _label = Color(0xFF757575);
const _bg = Color(0xFFF5F5F5);

// ============================================================
//  REGISTER SCREEN
// ============================================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final supabase = Supabase.instance.client;

  // Controllers
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _dobC = TextEditingController();
  final _addressC = TextEditingController();
  final _postalC = TextEditingController();
  final _weightC = TextEditingController();
  final _heightC = TextEditingController();
  final _bloodTypeC = TextEditingController();
  final _allergyC = TextEditingController();
  final _historyC = TextEditingController();
  final _passwordC = TextEditingController();
  final _confirmPassC = TextEditingController();

  // Location
  List _provinces = [];
  List _regencies = [];
  List _districts = [];
  List _villages = [];

  String? _provinceId, _regencyId, _districtId, _villageId;
  String? _provinceLabel, _regencyLabel, _districtLabel, _villageLabel;
  String? _gender;

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _dobC.dispose();
    _addressC.dispose();
    _postalC.dispose();
    _weightC.dispose();
    _heightC.dispose();
    _bloodTypeC.dispose();
    _allergyC.dispose();
    _historyC.dispose();
    _passwordC.dispose();
    _confirmPassC.dispose();
    super.dispose();
  }

 // ============================================================
//  LOCATION LOGIC (UPDATED: FULL API)
// ============================================================

Future<void> _loadProvinces() async {
  try {
    final res = await http.get(Uri.parse(
        'https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json'));

    final data = json.decode(res.body);

    setState(() {
      _provinces = data;
    });
  } catch (e) {
    print("Error provinces: $e");
  }
}

Future<void> _loadRegencies(String provinceId) async {
  try {
    final res = await http.get(Uri.parse(
        'https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$provinceId.json'));

    final data = json.decode(res.body);

    setState(() {
      _regencies = data;

      // reset bawah
      _regencyId = _regencyLabel = null;
      _districtId = _districtLabel = null;
      _villageId = _villageLabel = null;
      _districts = [];
      _villages = [];
    });
  } catch (e) {
    print("Error regencies: $e");
  }
}

Future<void> _loadDistricts(String regencyId) async {
  try {
    final res = await http.get(Uri.parse(
        'https://www.emsifa.com/api-wilayah-indonesia/api/districts/$regencyId.json'));

    final data = json.decode(res.body);

    setState(() {
      _districts = data;

      _districtId = _districtLabel = null;
      _villageId = _villageLabel = null;
      _villages = [];
    });
  } catch (e) {
    print("Error districts: $e");
  }
}

Future<void> _loadVillages(String districtId) async {
  try {
    final res = await http.get(Uri.parse(
        'https://www.emsifa.com/api-wilayah-indonesia/api/villages/$districtId.json'));

    final data = json.decode(res.body);

    setState(() {
      _villages = data;

      _villageId = _villageLabel = null;
    });
  } catch (e) {
    print("Error villages: $e");
  }
}

  // ============================================================
  //  REGISTER LOGIC
  // ============================================================
  Future<void> _register() async {
    if (_passwordC.text != _confirmPassC.text) {
      _showSnack("Password tidak sama!", isError: true);
      return;
    }
    if (_passwordC.text.length < 8) {
      _showSnack("Password minimal 8 karakter!", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = await supabase.auth.signUp(
        email: _emailC.text.trim(),
        password: _passwordC.text,
      );

      final userId = auth.user!.id;

      await supabase.from('patients').insert({
        'id': userId,
        'full_name': _nameC.text.trim(),
        'email': _emailC.text.trim(),
        'phone': _phoneC.text.trim(),
        'date_of_birth': _dobC.text.isNotEmpty ? _dobC.text : null,
        'gender': _gender,
        'province_id': _provinceId,
        'regency_id': _regencyId,
        'district_id': _districtId,
        'village_id': _villageId,
        'postal_code': _postalC.text.trim(),
        'full_address': _addressC.text.trim(),
        'weight_kg': _weightC.text.isNotEmpty
            ? double.tryParse(_weightC.text)
            : null,
        'height_cm': _heightC.text.isNotEmpty
            ? double.tryParse(_heightC.text)
            : null,
        'blood_type': _bloodTypeC.text.trim().isNotEmpty
            ? _bloodTypeC.text.trim()
            : null,
        'allergy': _allergyC.text.trim().isNotEmpty
            ? _allergyC.text.trim()
            : null,
        'medical_history': _historyC.text.trim().isNotEmpty
            ? _historyC.text.trim()
            : null,
      });

      _showSnack("Pendaftaran berhasil! Silakan cek email untuk verifikasi.");
    } catch (e) {
      _showSnack("Gagal daftar: ${e.toString()}", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade600 : _teal,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ============================================================
  //  DATE PICKER
  // ============================================================
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: _teal),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dobC.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  // ============================================================
  //  SEARCH DIALOG
  // ============================================================
  Future<dynamic> _showSearchDialog(List data, String title) async {
    final search = TextEditingController();
    List filtered = List.from(data);

    return showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, ss) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextField(
                  controller: search,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Cari...",
                    prefixIcon:
                        const Icon(Icons.search, color: _teal, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _teal)),
                  ),
                  onChanged: (val) {
                    ss(() {
                      filtered = data
                          .where((e) => e['name']
                              .toString()
                              .toLowerCase()
                              .contains(val.toLowerCase()))
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 280,
                  width: double.maxFinite,
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) => ListTile(
                      dense: true,
                      title: Text(filtered[i]['name'],
                          style: GoogleFonts.poppins(fontSize: 13)),
                      onTap: () => Navigator.pop(ctx, filtered[i]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ============================================================
  //  BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                children: [
                  _sectionCard(
                    title: "Informasi Pribadi",
                    children: [
                      _inputField(
                        controller: _nameC,
                        label: "Nama Lengkap",
                        hint: "Masukkan nama lengkap",
                        required: true,
                        prefixIcon: Icons.person_outline,
                      ),
                      _inputField(
                        controller: _emailC,
                        label: "Email",
                        hint: "nama@email.com",
                        required: true,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _inputField(
                        controller: _phoneC,
                        label: "Nomor Telepon",
                        hint: "+62 812 3456 7890",
                        required: true,
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      _dateField(),
                      _genderDropdown(),
                      _sectionTitle("Alamat"),
                      _locationField(
                        label: "Provinsi",
                        value: _provinceLabel,
                        required: true,
                        onTap: () async {
                          final val = await _showSearchDialog(
                              _provinces, "Pilih Provinsi");
                          if (val != null) {
                            setState(() {
                              _provinceId = val['id'];
                              _provinceLabel = val['name'];
                            });
                            _loadRegencies(val['id']);
                          }
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _locationField(
                              label: "Kab / Kota",
                              value: _regencyLabel,
                              required: true,
                              onTap: _provinceId == null
                                  ? null
                                  : () async {
                                      final val = await _showSearchDialog(
                                          _regencies, "Pilih Kota");
                                      if (val != null) {
                                        setState(() {
                                          _regencyId = val['id'];
                                          _regencyLabel = val['name'];
                                        });
                                        _loadDistricts(val['id']);
                                      }
                                    },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _locationField(
                              label: "Kecamatan",
                              value: _districtLabel,
                              required: true,
                              onTap: _regencyId == null
                                  ? null
                                  : () async {
                                      final val = await _showSearchDialog(
                                          _districts, "Pilih Kecamatan");
                                      if (val != null) {
                                        setState(() {
                                          _districtId = val['id'];
                                          _districtLabel = val['name'];
                                        });
                                        _loadVillages(val['id']);
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _locationField(
                              label: "Kelurahan",
                              value: _villageLabel,
                              onTap: _districtId == null
                                  ? null
                                  : () async {
                                      final val = await _showSearchDialog(
                                          _villages, "Pilih Kelurahan");
                                      if (val != null) {
                                        setState(() {
                                          _villageId = val['id'];
                                          _villageLabel = val['name'];
                                        });
                                      }
                                    },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _inputField(
                              controller: _postalC,
                              label: "Kode Pos",
                              hint: "46xxx",
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(5),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _inputField(
                        controller: _addressC,
                        label: "Alamat Lengkap",
                        hint:
                            "Jl. Nama Jalan No. xx, RT/RW, Detail lainnya...",
                        required: true,
                        maxLines: 3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionCard(
                    title: "Informasi Medis",
                    children: [
                      _inputField(
                        controller: _weightC,
                        label: "Berat Badan",
                        hint: "Contoh : 72 kg",
                        keyboardType: TextInputType.number,
                      ),
                      _inputField(
                        controller: _heightC,
                        label: "Tinggi Badan",
                        hint: "Contoh : 170 cm",
                        keyboardType: TextInputType.number,
                      ),
                      _inputField(
                        controller: _bloodTypeC,
                        label: "Golongan Darah",
                        hint: "Contoh : O+",
                      ),
                      _inputField(
                        controller: _allergyC,
                        label: "Alergi",
                        hint: "Contoh :",
                      ),
                      _inputField(
                        controller: _historyC,
                        label: "Riwayat Penyakit (Opsional)",
                        hint:
                            "Contoh: Diabetes, Hipertensi, Alergi obat, dll.",
                        maxLines: 3,
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _tealLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Informasi ini membantu terapis memberikan perawatan terbaik",
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: _tealDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionCard(
                    title: "Keamanan Akun",
                    children: [
                      _passwordField(
                        controller: _passwordC,
                        label: "Password",
                        hint: "Minimal 8 karakter",
                        required: true,
                        obscure: _obscurePass,
                        onToggle: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                      _passwordField(
                        controller: _confirmPassC,
                        label: "Konfirmasi Password",
                        hint: "Masukkan ulang password",
                        required: true,
                        obscure: _obscureConfirm,
                        onToggle: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _teal.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(
                                      Colors.white)),
                            )
                          : Text("Daftar Sekarang",
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Sudah punya akun? ",
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: _label)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text("Masuk",
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: _teal,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  HEADER
  // ============================================================
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_teal, _tealDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Daftar Pasien",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  Text("Buat akun untuk layanan fisioterapi",
                      style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  //  SECTION CARD
  // ============================================================
  Widget _sectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w600, color: _text)),
          const SizedBox(height: 4),
          Container(height: 2, width: 40, color: _teal),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 16, color: _teal),
          const SizedBox(width: 6),
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _text)),
        ],
      ),
    );
  }

  // ============================================================
  //  INPUT FIELD
  // ============================================================
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    IconData? prefixIcon,
    bool obscure = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _text),
              children: required
                  ? [
                      const TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red))
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            maxLines: maxLines,
            inputFormatters: inputFormatters,
            style: GoogleFonts.poppins(fontSize: 13, color: _text),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  GoogleFonts.poppins(fontSize: 13, color: _grey),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, size: 18, color: _grey)
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _teal, width: 1.5)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  PASSWORD FIELD
  // ============================================================
  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _text),
              children: required
                  ? [
                      const TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red))
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: obscure,
            style: GoogleFonts.poppins(fontSize: 13, color: _text),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  GoogleFonts.poppins(fontSize: 13, color: _grey),
              prefixIcon:
                  const Icon(Icons.lock_outline, size: 18, color: _grey),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: _grey),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _teal, width: 1.5)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  DATE FIELD
  // ============================================================
  Widget _dateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Tanggal Lahir",
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _text)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDate,
            child: AbsorbPointer(
              child: TextField(
                controller: _dobC,
                style: GoogleFonts.poppins(fontSize: 13, color: _text),
                decoration: InputDecoration(
                  hintText: "dd/mm/yyyy",
                  hintStyle:
                      GoogleFonts.poppins(fontSize: 13, color: _grey),
                  prefixIcon: const Icon(Icons.calendar_today_outlined,
                      size: 18, color: _grey),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: _teal, width: 1.5)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  GENDER DROPDOWN
  // ============================================================
  Widget _genderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Jenis Kelamin",
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _text)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _gender,
            hint: Text("Pilih jenis kelamin",
                style: GoogleFonts.poppins(fontSize: 13, color: _grey)),
            items: [
              DropdownMenuItem(
                  value: 'male',
                  child: Text("Laki-laki",
                      style: GoogleFonts.poppins(fontSize: 13))),
              DropdownMenuItem(
                  value: 'female',
                  child: Text("Perempuan",
                      style: GoogleFonts.poppins(fontSize: 13))),
            ],
            onChanged: (val) => setState(() => _gender = val),
            style: GoogleFonts.poppins(fontSize: 13, color: _text),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _teal, width: 1.5)),
              filled: true,
              fillColor: Colors.white,
            ),
            icon: const Icon(Icons.keyboard_arrow_down, color: _teal),
            dropdownColor: Colors.white,
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  LOCATION FIELD
  // ============================================================
  Widget _locationField({
    required String label,
    String? value,
    bool required = false,
    VoidCallback? onTap,
  }) {
    final bool disabled = onTap == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _text),
              children: required
                  ? [
                      const TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red))
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: disabled
                    ? const Color(0xFFF5F5F5)
                    : Colors.white,
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value ?? "Pilih",
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: value != null ? _text : _grey),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down,
                      color: disabled ? _border : _teal, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}