import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // ← untuk kIsWeb
import 'dart:io';

// ============================================================
//  MODEL
// ============================================================

class PatientModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? provinceId;
  final String? regencyId;
  final String? districtId;
  final String? villageId;
  final String? postalCode;
  final String? fullAddress;
  final double? weightKg;
  final double? heightCm;
  final String? bloodType;
  final String? allergy;
  final String? medicalHistory;

  const PatientModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.provinceId,
    this.regencyId,
    this.districtId,
    this.villageId,
    this.postalCode,
    this.fullAddress,
    this.weightKg,
    this.heightCm,
    this.bloodType,
    this.allergy,
    this.medicalHistory,
  });

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      dateOfBirth: map['date_of_birth'] as String?,
      gender: map['gender'] as String?,
      provinceId: map['province_id'] as String?,
      regencyId: map['regency_id'] as String?,
      districtId: map['district_id'] as String?,
      villageId: map['village_id'] as String?,
      postalCode: map['postal_code'] as String?,
      fullAddress: map['full_address'] as String?,
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      heightCm: (map['height_cm'] as num?)?.toDouble(),
      bloodType: map['blood_type'] as String?,
      allergy: map['allergy'] as String?,
      medicalHistory: map['medical_history'] as String?,
    );
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'province_id': provinceId,
      'regency_id': regencyId,
      'district_id': districtId,
      'village_id': villageId,
      'postal_code': postalCode,
      'full_address': fullAddress,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'blood_type': bloodType,
      'allergy': allergy,
      'medical_history': medicalHistory,
    };
  }
}

// ============================================================
//  MODEL PATIENT_ADDRESSES
//  Asumsi skema: id uuid, patient_id uuid, label text,
//  full_address text, is_primary bool, created_at timestamptz
// ============================================================

class PatientAddressModel {
  final String? id;
  final String patientId;
  final String? label;
  final String? fullAddress;
  final bool isPrimary;

  const PatientAddressModel({
    this.id,
    required this.patientId,
    this.label,
    this.fullAddress,
    this.isPrimary = false,
  });

  factory PatientAddressModel.fromMap(Map<String, dynamic> map) {
    return PatientAddressModel(
      id: map['id'] as String?,
      patientId: map['patient_id'] as String,
      label: map['label'] as String?,
      fullAddress: map['full_address'] as String?,
      isPrimary: (map['is_primary'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'patient_id': patientId,
      'label': label,
      'full_address': fullAddress,
      'is_primary': isPrimary,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'label': label,
      'full_address': fullAddress,
      'is_primary': isPrimary,
    };
  }

  PatientAddressModel copyWith({
    String? id,
    String? patientId,
    String? label,
    String? fullAddress,
    bool? isPrimary,
  }) {
    return PatientAddressModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

// ============================================================
//  SERVICE LAYER
// ============================================================

class PatientService {
  final _supabase = Supabase.instance.client;

  // --- PATIENTS ---

  /// Ambil data pasien berdasarkan user yang sedang login
  Future<PatientModel?> fetchCurrentPatient() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('patients')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return PatientModel.fromMap(response);
  }

  /// Upsert (insert atau update) data pasien
  Future<void> upsertPatient(PatientModel patient) async {
    await _supabase.from('patients').upsert({
      'id': patient.id,
      ...patient.toUpdateMap(),
    });
  }

  // --- PATIENT ADDRESSES ---

  /// Ambil semua alamat milik pasien
  Future<List<PatientAddressModel>> fetchAddresses(String patientId) async {
    final response = await _supabase
        .from('patient_addresses')
        .select()
        .eq('patient_id', patientId)
        .order('is_primary', ascending: false);

    return (response as List)
        .map((e) => PatientAddressModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Tambah alamat baru
  Future<PatientAddressModel> addAddress(PatientAddressModel address) async {
    final response = await _supabase
        .from('patient_addresses')
        .insert(address.toInsertMap())
        .select()
        .single();
    return PatientAddressModel.fromMap(response);
  }

  /// Update alamat yang sudah ada
  Future<void> updateAddress(PatientAddressModel address) async {
    if (address.id == null) return;
    await _supabase
        .from('patient_addresses')
        .update(address.toUpdateMap())
        .eq('id', address.id!);
  }

  /// Hapus alamat
  Future<void> deleteAddress(String addressId) async {
    await _supabase
        .from('patient_addresses')
        .delete()
        .eq('id', addressId);
  }

  /// Set alamat sebagai primer (reset semua dulu, baru set yang dipilih)
  Future<void> setPrimaryAddress(String patientId, String addressId) async {
    await _supabase
        .from('patient_addresses')
        .update({'is_primary': false})
        .eq('patient_id', patientId);

    await _supabase
        .from('patient_addresses')
        .update({'is_primary': true})
        .eq('id', addressId);
  }
}

// ============================================================
//  SCREEN
// ============================================================

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _service = PatientService();
  final _supabase = Supabase.instance.client;

  // -- State --
  bool _isLoading = true;
  bool _isSaving = false;
  PatientModel? _patient;
  List<PatientAddressModel> _addresses = [];
  File? _profilePhotoFile;

  // -- Controllers --
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _allergyController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodType;
  bool _isNotificationOn = true;

  static const _genderOptions = [
    {'label': 'Laki-laki', 'value': 'male'},
    {'label': 'Perempuan', 'value': 'female'},
  ];

  static const _bloodTypes = ['A', 'A+', 'A-', 'B', 'B+', 'B-', 'AB', 'AB+', 'AB-', 'O', 'O+', 'O-'];

  Future<void> _pickProfilePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _profilePhotoFile = File(picked.path));
    }
  }

  Future<String?> _uploadProfilePhoto(String userId) async {
    if (_profilePhotoFile == null) return null;
    try {
      await _supabase.storage.from('patients').upload(
        '$userId/profile_photo.jpg',
        _profilePhotoFile!,
        fileOptions: const FileOptions(upsert: true),
      );
      return _supabase.storage.from('patients').getPublicUrl('$userId/profile_photo.jpg');
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _allergyController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  // ---- Data Loading ----

  Future<void> _loadData() async {
    try {
      final patient = await _service.fetchCurrentPatient();
      if (patient != null) {
        final addresses = await _service.fetchAddresses(patient.id);
        _populateControllers(patient);
        setState(() {
          _patient = patient;
          _addresses = addresses;
          _isLoading = false;
        });
      } else {
        // Pasien belum punya record, buat dari auth user
        final user = _supabase.auth.currentUser;
        if (user != null) {
          _emailController.text = user.email ?? '';
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showError('Gagal memuat data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _populateControllers(PatientModel p) {
    _nameController.text = p.fullName;
    _emailController.text = p.email;
    _phoneController.text = p.phone ?? '';
    _dateController.text = p.dateOfBirth ?? '';
    _weightController.text = p.weightKg?.toString() ?? '';
    _heightController.text = p.heightCm?.toString() ?? '';
    _allergyController.text = p.allergy ?? '';
    _medicalHistoryController.text = p.medicalHistory ?? '';
    const validGenders = ["male", "female"];
    const validBloodTypes = ["A","A+","A-","B","B+","B-","AB","AB+","AB-","O","O+","O-"];
    _selectedGender = (p.gender != null && validGenders.contains(p.gender)) ? p.gender : null;
    _selectedBloodType = (p.bloodType != null && validBloodTypes.contains(p.bloodType)) ? p.bloodType : null;
  }

  // ---- Save ----

  Future<void> _saveProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _showError('Sesi tidak ditemukan, silakan login ulang.');
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      _showError('Nama lengkap tidak boleh kosong.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updated = PatientModel(
        id: userId,
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        dateOfBirth: _dateController.text.trim().isEmpty ? null : _dateController.text.trim(),
        gender: _selectedGender,
        bloodType: _selectedBloodType,
        weightKg: double.tryParse(_weightController.text),
        heightCm: double.tryParse(_heightController.text),
        allergy: _allergyController.text.trim().isEmpty ? null : _allergyController.text.trim(),
        medicalHistory: _medicalHistoryController.text.trim().isEmpty ? null : _medicalHistoryController.text.trim(),
        // Wilayah & alamat utama dipertahankan dari data lama
        provinceId: _patient?.provinceId,
        regencyId: _patient?.regencyId,
        districtId: _patient?.districtId,
        villageId: _patient?.villageId,
        postalCode: _patient?.postalCode,
        fullAddress: _patient?.fullAddress,
      );

      await _service.upsertPatient(updated);

      // Upload profile photo if selected
      if (_profilePhotoFile != null) {
        final photoUrl = await _uploadProfilePhoto(userId);
        if (photoUrl != null) {
          await _supabase.from('patients').update({
            'profile_photo_url': photoUrl,
          }).eq('id', userId);
        }
      }

      setState(() {
        _patient = updated;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profil berhasil disimpan!'),
            backgroundColor: const Color(0xFF00BBA7),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context, updated);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      _showError('Gagal menyimpan: $e');
    }
  }

  // ---- Address Helpers ----

  void _showAddAddressDialog({PatientAddressModel? existing}) {
    final labelCtrl = TextEditingController(text: existing?.label ?? '');
    final addressCtrl = TextEditingController(text: existing?.fullAddress ?? '');
    bool isPrimary = existing?.isPrimary ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing == null ? 'Tambah Alamat' : 'Edit Alamat',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTextField('Label (Rumah, Kantor, dll)', labelCtrl, hint: 'Contoh: Rumah'),
                _buildTextField('Alamat Lengkap', addressCtrl, hint: 'Jl. ...', maxLines: 3),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Jadikan Alamat Utama', style: GoogleFonts.inter(fontSize: 13)),
                  value: isPrimary,
                  activeColor: const Color(0xFF00BBA7),
                  onChanged: (v) => setModalState(() => isPrimary = v),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BBA7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _saveAddress(
                        existing: existing,
                        label: labelCtrl.text.trim(),
                        fullAddress: addressCtrl.text.trim(),
                        isPrimary: isPrimary,
                      );
                    },
                    child: Text(
                      'Simpan Alamat',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _saveAddress({
    PatientAddressModel? existing,
    required String label,
    required String fullAddress,
    required bool isPrimary,
  }) async {
    final patientId = _supabase.auth.currentUser?.id;
    if (patientId == null) return;

    try {
      if (existing == null) {
        // Tambah baru
        final newAddr = await _service.addAddress(PatientAddressModel(
          patientId: patientId,
          label: label.isEmpty ? null : label,
          fullAddress: fullAddress.isEmpty ? null : fullAddress,
          isPrimary: isPrimary,
        ));
        setState(() => _addresses.add(newAddr));
      } else {
        // Update
        final updated = existing.copyWith(
          label: label.isEmpty ? null : label,
          fullAddress: fullAddress.isEmpty ? null : fullAddress,
          isPrimary: isPrimary,
        );
        await _service.updateAddress(updated);
        setState(() {
          final idx = _addresses.indexWhere((a) => a.id == existing.id);
          if (idx != -1) _addresses[idx] = updated;
        });
      }

      // Jika dijadikan primary, refresh list
      if (isPrimary) {
        final refreshed = await _service.fetchAddresses(patientId);
        setState(() => _addresses = refreshed);
      }
    } catch (e) {
      _showError('Gagal menyimpan alamat: $e');
    }
  }

  Future<void> _deleteAddress(PatientAddressModel address) async {
    if (address.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Alamat', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Yakin ingin menghapus alamat ini?', style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.deleteAddress(address.id!);
      setState(() => _addresses.removeWhere((a) => a.id == address.id));
    } catch (e) {
      _showError('Gagal menghapus alamat: $e');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ============================================================
  //  BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00BBA7))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  _buildInformasiPribadi(),
                  const SizedBox(height: 20),
                  _buildDataMedis(),
                  const SizedBox(height: 20),
                  _buildAddressSection(),
                  const SizedBox(height: 20),
                  _buildPengaturan(),
                  const SizedBox(height: 30),
                  _buildSaveButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Header ----

  Widget _buildHeader(BuildContext context) {
    final initials = (_patient?.fullName.isNotEmpty == true)
        ? _patient!.fullName.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase()
        : 'BS';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 30),
      decoration: const BoxDecoration(color: Color(0xFF00BBA7)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Edit Profil',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickProfilePhoto,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFF009689),
                  child: !kIsWeb && _profilePhotoFile != null
                      ? ClipOval(
                          child: Image.file(_profilePhotoFile!, fit: BoxFit.cover),
                        )
                      : Text(
                          initials,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, size: 18, color: Color(0xFF00BBA7)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _patient?.fullName ?? 'Profil Baru',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          if (_patient != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ID : ${_patient!.id.substring(0, 8).toUpperCase()}',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  // ---- Informasi Pribadi ----

  Widget _buildInformasiPribadi() {
    return _buildCardWrapper(
      title: 'INFORMASI PRIBADI',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildTextField('Nama Lengkap', _nameController),
          _buildTextField('Tanggal Lahir', _dateController, isDate: true),
          Row(
            children: [
              Expanded(child: _buildDropdown('Jenis Kelamin', _selectedGender, _genderOptions, (v) => setState(() => _selectedGender = v))),
              const SizedBox(width: 15),
              Expanded(
                child: _buildSimpleDropdown(
                  'Golongan Darah',
                  _selectedBloodType,
                  _bloodTypes.map((e) => {'label': e, 'value': e}).toList(),
                  (v) => setState(() => _selectedBloodType = v),
                ),
              ),
            ],
          ),
          _buildTextField('Email', _emailController),
          _buildTextField('No. Telepon', _phoneController),
        ],
      ),
    );
  }

  // ---- Data Medis ----

  Widget _buildDataMedis() {
    return _buildCardWrapper(
      title: 'DATA MEDIS',
      icon: Icons.medical_services,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField('Berat Badan (kg)', _weightController)),
              const SizedBox(width: 15),
              Expanded(child: _buildTextField('Tinggi Badan (cm)', _heightController)),
            ],
          ),
          _buildTextField('Riwayat Alergi', _allergyController, hint: 'Contoh: Penisilin, Seafood...'),
          _buildTextField('Riwayat Penyakit', _medicalHistoryController, hint: 'Contoh: Diabetes, Hipertensi...'),
        ],
      ),
    );
  }

  // ---- Alamat (Multiple) ----

  Widget _buildAddressSection() {
    return _buildCardWrapper(
      title: 'DAFTAR ALAMAT',
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_addresses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Belum ada alamat tersimpan.',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
              ),
            ),
          ..._addresses.map((addr) => _buildAddressTile(addr)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _showAddAddressDialog(),
            icon: const Icon(Icons.add, size: 18, color: Color(0xFF00BBA7)),
            label: Text(
              'Tambah Alamat',
              style: GoogleFonts.inter(color: const Color(0xFF00BBA7), fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF00BBA7)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTile(PatientAddressModel addr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: addr.isPrimary ? const Color(0xFFE6F7F5) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: addr.isPrimary
            ? Border.all(color: const Color(0xFF00BBA7).withOpacity(0.5))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      addr.label ?? 'Alamat',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    if (addr.isPrimary) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BBA7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Utama',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  addr.fullAddress ?? '-',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _showAddAddressDialog(existing: addr),
                child: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF00BBA7)),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _deleteAddress(addr),
                child: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Pengaturan ----

  Widget _buildPengaturan() {
    return _buildCardWrapper(
      title: 'PENGATURAN & PREFERENSI',
      icon: Icons.settings_outlined,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          'Notifikasi Pengingat',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text('Pengingat jadwal terapi', style: GoogleFonts.inter(fontSize: 12)),
        trailing: Switch(
          value: _isNotificationOn,
          activeColor: const Color(0xFF00BBA7),
          onChanged: (val) => setState(() => _isNotificationOn = val),
        ),
      ),
    );
  }

  // ============================================================
  //  HELPERS / WIDGETS
  // ============================================================

  Widget _buildCardWrapper({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF00BBA7)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00BBA7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isDate = false,
    String? hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.inter(fontSize: 14),
            readOnly: isDate,
            onTap: isDate
                ? () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(controller.text) ?? DateTime(1990),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(primary: Color(0xFF00BBA7)),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      controller.text =
                          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                    }
                  }
                : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: isDate ? const Icon(Icons.calendar_today_outlined, size: 18) : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<Map<String, String>> options,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text('Pilih', style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13)),
                style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                items: options
                    .map((o) => DropdownMenuItem(
                          value: o['value'],
                          child: Text(o['label']!),
                        ))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleDropdown(
    String label,
    String? value,
    List<Map<String, String>> options,
    ValueChanged<String?> onChanged,
  ) =>
      _buildDropdown(label, value, options, onChanged);

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BBA7),
          disabledBackgroundColor: const Color(0xFF00BBA7).withOpacity(0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                'Simpan',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}