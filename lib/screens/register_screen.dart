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
//  CUSTOM INPUT FORMATTERS
// ============================================================

/// Hanya huruf (A-Z, a-z) dan spasi
class _LettersOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered =
        newValue.text.replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

/// Hanya kalimat: huruf, angka, spasi, dan tanda baca umum
class _SentenceOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Izinkan huruf, angka, spasi, dan tanda baca: , . ! ? - ( ) / ;
    final filtered =
        newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9\s\.,!\?\-()/;]'), '');
    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

/// Nomor telepon Indonesia: hanya angka, maksimal 13 digit
class _PhoneIndonesiaFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String filtered = newValue.text;
    filtered = filtered.replaceAll(RegExp(r'[^\d+]'), '');
    if (filtered.contains('+')) {
      filtered = '+' + filtered.replaceAll('+', '');
    }
    int maxLen = filtered.startsWith('+') ? 14 : 13;
    if (filtered.length > maxLen) {
      filtered = filtered.substring(0, maxLen);
    }
    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

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

  // Golongan darah dropdown
  String? _bloodType;
  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // Password strength state
  bool _passHasMinLength = false;
  bool _passHasUppercase = false;
  bool _passHasNumber = false;
  bool _passHasSpecial = false;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
    _passwordC.addListener(_checkPasswordStrength);
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
    _allergyC.dispose();
    _historyC.dispose();
    _passwordC.dispose();
    _confirmPassC.dispose();
    super.dispose();
  }

  // ============================================================
  //  PASSWORD STRENGTH CHECKER
  // ============================================================
  void _checkPasswordStrength() {
    final pass = _passwordC.text;
    setState(() {
      _passHasMinLength = pass.length >= 8;
      _passHasUppercase = pass.contains(RegExp(r'[A-Z]'));
      _passHasNumber = pass.contains(RegExp(r'[0-9]'));
      _passHasSpecial =
          pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]'));
    });
  }

  bool get _isPasswordValid =>
      _passHasMinLength &&
      _passHasUppercase &&
      _passHasNumber &&
      _passHasSpecial;

  // ============================================================
  //  PHONE VALIDATOR
  // ============================================================
  String? _validatePhone(String phone) {
    if (phone.isEmpty) return null;
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    if (phone.startsWith('+62')) {
      if (!phone.startsWith('+628')) return 'Nomor harus diawali +628 atau 08';
      if (digitsOnly.length < 10 || digitsOnly.length > 13) {
        return 'Nomor tidak valid (10-13 digit setelah kode negara)';
      }
    } else if (phone.startsWith('08')) {
      if (digitsOnly.length < 10 || digitsOnly.length > 13) {
        return 'Nomor harus 10–13 digit (contoh: 081234567890)';
      }
    } else {
      return 'Nomor harus diawali 08 atau +628';
    }
    return null;
  }

  // ============================================================
  //  LOCATION LOGIC
  // ============================================================
  Future<void> _loadProvinces() async {
    try {
      final res = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json'));
      final data = json.decode(res.body);
      setState(() => _provinces = data);
    } catch (e) {
      debugPrint("Error provinces: $e");
    }
  }

  Future<void> _loadRegencies(String provinceId) async {
    try {
      final res = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$provinceId.json'));
      final data = json.decode(res.body);
      setState(() {
        _regencies = data;
        _regencyId = _regencyLabel = null;
        _districtId = _districtLabel = null;
        _villageId = _villageLabel = null;
        _districts = [];
        _villages = [];
      });
    } catch (e) {
      debugPrint("Error regencies: $e");
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
      debugPrint("Error districts: $e");
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
      debugPrint("Error villages: $e");
    }
  }

  // ============================================================
  //  REGISTER LOGIC
  // ============================================================
  Future<void> _register() async {
    // Validasi nama
    if (_nameC.text.trim().isEmpty) {
      _showSnack("Nama lengkap wajib diisi!", isError: true);
      return;
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(_nameC.text.trim())) {
      _showSnack("Nama hanya boleh berisi huruf!", isError: true);
      return;
    }

    // Validasi email
    if (_emailC.text.trim().isEmpty) {
      _showSnack("Email wajib diisi!", isError: true);
      return;
    }

    // Validasi telepon
    if (_phoneC.text.trim().isNotEmpty) {
      final phoneError = _validatePhone(_phoneC.text.trim());
      if (phoneError != null) {
        _showSnack(phoneError, isError: true);
        return;
      }
    }

    // Validasi alamat & lokasi wajib untuk patient_addresses
    if (_addressC.text.trim().isEmpty) {
      _showSnack("Alamat lengkap wajib diisi!", isError: true);
      return;
    }
    if (_provinceId == null || _regencyId == null || _districtId == null) {
      _showSnack("Provinsi, Kab/Kota, dan Kecamatan wajib dipilih!", isError: true);
      return;
    }

    // Validasi password
    if (!_isPasswordValid) {
      _showSnack("Password tidak memenuhi syarat keamanan!", isError: true);
      return;
    }
    if (_passwordC.text != _confirmPassC.text) {
      _showSnack("Konfirmasi password tidak sama!", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Daftar ke Supabase Auth
      final auth = await supabase.auth.signUp(
        email: _emailC.text.trim(),
        password: _passwordC.text,
        data: {'role': 'patient'},
      );

      final userId = auth.user?.id;
      if (userId == null) {
        _showSnack("Gagal mendapatkan user ID!", isError: true);
        return;
      }

      // 2. Insert ke tabel patients
      await supabase.from('patients').insert({
        'id': userId,
        'full_name': _nameC.text.trim(),
        'email': _emailC.text.trim(),
        'phone': _phoneC.text.trim().isNotEmpty ? _phoneC.text.trim() : null,
        'date_of_birth': _dobC.text.isNotEmpty ? _dobC.text : null,
        'gender': _gender,
        'province_id': _provinceId,
        'regency_id': _regencyId,
        'district_id': _districtId,
        'village_id': _villageId,
        'postal_code':
            _postalC.text.trim().isNotEmpty ? _postalC.text.trim() : null,
        'full_address': _addressC.text.trim(),
        'weight_kg':
            _weightC.text.isNotEmpty ? double.tryParse(_weightC.text) : null,
        'height_cm':
            _heightC.text.isNotEmpty ? double.tryParse(_heightC.text) : null,
        'blood_type': _bloodType,
        'allergy':
            _allergyC.text.trim().isNotEmpty ? _allergyC.text.trim() : null,
        'medical_history':
            _historyC.text.trim().isNotEmpty ? _historyC.text.trim() : null,
      });

      // 3. Insert ke tabel patient_addresses
      //    label default 'Rumah', is_primary = true
      await supabase.from('patient_addresses').insert({
        'patient_id': userId,
        'label': 'Rumah',
        'province_id': _provinceId!,
        'province_name': _provinceLabel!,
        'regency_id': _regencyId!,
        'regency_name': _regencyLabel!,
        'district_id': _districtId!,
        'district_name': _districtLabel!,
        'village_id': _villageId,
        'village_name': _villageLabel,
        'postal_code':
            _postalC.text.trim().isNotEmpty ? _postalC.text.trim() : null,
        'full_address': _addressC.text.trim(),
        'is_primary': true,
      });

      if (mounted) {
        _showSnack("Pendaftaran berhasil! Silakan cek email untuk verifikasi.");
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      _showSnack("Auth error: ${e.message}", isError: true);
    } on PostgrestException catch (e) {
      _showSnack("Database error: ${e.message}", isError: true);
    } catch (e) {
      _showSnack("Gagal daftar: ${e.toString()}", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                    style: GoogleFonts.inter(
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
                          style: GoogleFonts.inter(fontSize: 13)),
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
                        inputFormatters: [_LettersOnlyFormatter()],
                        keyboardType: TextInputType.name,
                        helperText:
                            "Hanya huruf, tidak boleh ada angka atau simbol",
                      ),
                      _inputField(
                        controller: _emailC,
                        label: "Email",
                        hint: "nama@email.com",
                        required: true,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _phoneField(),
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
                      // Info label alamat
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _tealLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.home_outlined,
                                size: 14, color: _tealDark),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Alamat ini akan disimpan dengan label "Rumah" dan dapat diubah nanti di profil Anda.',
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: _tealDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionCard(
                    title: "Informasi Medis",
                    children: [
                      _inputField(
                        controller: _weightC,
                        label: "Berat Badan (kg)",
                        hint: "Contoh : 72",
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]')),
                        ],
                      ),
                      _inputField(
                        controller: _heightC,
                        label: "Tinggi Badan (cm)",
                        hint: "Contoh : 170",
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]')),
                        ],
                      ),
                      // ── Golongan Darah: dropdown ──
                      _bloodTypeDropdown(),
                      // ── Alergi: hanya kalimat ──
                      _inputField(
                        controller: _allergyC,
                        label: "Alergi",
                        hint: "Contoh: Debu, Seafood, Penisilin",
                        maxLines: 2,
                        inputFormatters: [_SentenceOnlyFormatter()],
                        helperText:
                            "Pisahkan dengan koma jika lebih dari satu",
                      ),
                      // ── Riwayat Penyakit: hanya kalimat ──
                      _inputField(
                        controller: _historyC,
                        label: "Riwayat Penyakit (Opsional)",
                        hint:
                            "Contoh: Diabetes, Hipertensi, Alergi obat, dll.",
                        maxLines: 3,
                        inputFormatters: [_SentenceOnlyFormatter()],
                        helperText:
                            "Hanya huruf, angka, dan tanda baca umum",
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _tealLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Informasi ini membantu terapis memberikan perawatan terbaik",
                          style: GoogleFonts.inter(
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
                      _passwordStrengthIndicator(),
                      const SizedBox(height: 8),
                      _passwordField(
                        controller: _confirmPassC,
                        label: "Konfirmasi Password",
                        hint: "Masukkan ulang password",
                        required: true,
                        obscure: _obscureConfirm,
                        onToggle: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
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
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Sudah punya akun? ",
                          style: GoogleFonts.inter(
                              fontSize: 13, color: _label)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text("Masuk",
                            style: GoogleFonts.inter(
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
  //  PASSWORD STRENGTH INDICATOR
  // ============================================================
  Widget _passwordStrengthIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _strengthRow(_passHasMinLength, "Minimal 8 karakter"),
          _strengthRow(_passHasUppercase, "Mengandung huruf kapital (A-Z)"),
          _strengthRow(_passHasNumber, "Mengandung angka (0-9)"),
          _strengthRow(
              _passHasSpecial, "Mengandung karakter spesial (!@#\$%^&*)"),
        ],
      ),
    );
  }

  Widget _strengthRow(bool passed, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: passed ? _teal : _grey,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: passed ? _tealDark : _grey,
              fontWeight: passed ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  PHONE FIELD
  // ============================================================
  Widget _phoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: "Nomor Telepon",
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w500, color: _text),
              children: [
                TextSpan(text: ' *', style: GoogleFonts.inter(color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _phoneC,
            keyboardType: TextInputType.phone,
            inputFormatters: [_PhoneIndonesiaFormatter()],
            style: GoogleFonts.inter(fontSize: 13, color: _text),
            decoration: InputDecoration(
              hintText: "08xx atau +628xx",
              hintStyle: GoogleFonts.inter(fontSize: 13, color: _grey),
              prefixIcon:
                  const Icon(Icons.phone_outlined, size: 18, color: _grey),
              helperText:
                  "Format: 08xxxxxxxxxx atau +628xxxxxxxxxx (10–13 digit)",
              helperStyle: GoogleFonts.inter(fontSize: 10, color: _grey),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
  //  BLOOD TYPE DROPDOWN
  // ============================================================
  Widget _bloodTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Golongan Darah",
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w500, color: _text)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _bloodType,
            hint: Text("Pilih golongan darah",
                style: GoogleFonts.inter(fontSize: 13, color: _grey)),
            items: _bloodTypes
                .map((bt) => DropdownMenuItem(
                      value: bt,
                      child:
                          Text(bt, style: GoogleFonts.inter(fontSize: 13)),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _bloodType = val),
            style: GoogleFonts.inter(fontSize: 13, color: _text),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.bloodtype_outlined,
                  size: 18, color: _grey),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  Text("Buat akun untuk layanan fisioterapi",
                      style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _text)),
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
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w500, color: _text),
              children: required
                  ? [
                      TextSpan(
                          text: ' *', style: GoogleFonts.inter(color: Colors.red))
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
            style: GoogleFonts.inter(fontSize: 13, color: _text),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 13, color: _grey),
              helperText: helperText,
              helperStyle: GoogleFonts.inter(fontSize: 10, color: _grey),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, size: 18, color: _grey)
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w500, color: _text),
              children: required
                  ? [
                      TextSpan(
                          text: ' *', style: GoogleFonts.inter(color: Colors.red))
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: obscure,
            style: GoogleFonts.inter(fontSize: 13, color: _text),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 13, color: _grey),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w500, color: _text)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDate,
            child: AbsorbPointer(
              child: TextField(
                controller: _dobC,
                style: GoogleFonts.inter(fontSize: 13, color: _text),
                decoration: InputDecoration(
                  hintText: "dd/mm/yyyy",
                  hintStyle:
                      GoogleFonts.inter(fontSize: 13, color: _grey),
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
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w500, color: _text)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _gender,
            hint: Text("Pilih jenis kelamin",
                style: GoogleFonts.inter(fontSize: 13, color: _grey)),
            items: [
              DropdownMenuItem(
                  value: 'male',
                  child: Text("Laki-laki",
                      style: GoogleFonts.inter(fontSize: 13))),
              DropdownMenuItem(
                  value: 'female',
                  child: Text("Perempuan",
                      style: GoogleFonts.inter(fontSize: 13))),
            ],
            onChanged: (val) => setState(() => _gender = val),
            style: GoogleFonts.inter(fontSize: 13, color: _text),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w500, color: _text),
              children: required
                  ? [
                      TextSpan(
                          text: ' *', style: GoogleFonts.inter(color: Colors.red))
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: disabled ? const Color(0xFFF5F5F5) : Colors.white,
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
                      style: GoogleFonts.inter(
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
