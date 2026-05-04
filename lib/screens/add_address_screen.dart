import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _supabase = Supabase.instance.client;

  // ── State Data Wilayah ─────────────────────────────────
  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _regencies = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _villages = [];

  List<Map<String, dynamic>> _filteredProvinces = [];
  List<Map<String, dynamic>> _filteredRegencies = [];
  List<Map<String, dynamic>> _filteredDistricts = [];
  List<Map<String, dynamic>> _filteredVillages = [];

  String? _selectedProvinceId;
  String? _selectedProvinceName;
  String? _selectedRegencyId;
  String? _selectedRegencyName;
  String? _selectedDistrictId;
  String? _selectedDistrictName;
  String? _selectedVillageId;
  String? _selectedVillageName;

  // ── State Form ─────────────────────────────────────────
  final _postalController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _labelController = TextEditingController(text: 'Rumah');
  bool _isPrimary = false;
  bool _isLoadingProvinces = false;
  bool _isLoadingRegencies = false;
  bool _isLoadingDistricts = false;
  bool _isLoadingVillages = false;
  bool _isSaving = false;

  // ── State Profil ───────────────────────────────────────
  String _patientName = '';
  String _patientId = '';
  String _patientInitials = '';

  // ── State Daftar Alamat ────────────────────────────────
  List<Map<String, dynamic>> _allAddresses = [];
  bool _loadingAddresses = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _postalController.dispose();
    _fullAddressController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _fetchPatientProfile(),
      _fetchAllAddresses(),
      _fetchProvinces(),
    ]);
  }

  Future<void> _fetchPatientProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      final data = await _supabase
          .from('patients')
          .select('full_name, created_at')
          .eq('id', user.id)
          .single();
      final name = data['full_name'] as String? ?? '';
      final raw = data['created_at'] as String? ?? '';
      final dt = DateTime.tryParse(raw);
      final month = dt != null ? dt.month.toString().padLeft(2, '0') : '00';
      final year = dt?.year ?? 0;
      final parts = name.trim().split(' ');
      final initials = parts.length >= 2
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
      if (mounted) {
        setState(() {
          _patientName = name;
          _patientId = 'FSC-$year-$month';
          _patientInitials = initials;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchAllAddresses() async {
    setState(() => _loadingAddresses = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      final data = await _supabase
          .from('patient_addresses')
          .select()
          .eq('patient_id', user.id)
          .order('is_primary', ascending: false)
          .order('created_at');
      if (mounted) {
        setState(() {
          _allAddresses = List<Map<String, dynamic>>.from(data);
          _loadingAddresses = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAddresses = false);
    }
  }

  // ── API Wilayah ────────────────────────────────────────

  Future<void> _fetchProvinces() async {
    setState(() => _isLoadingProvinces = true);
    try {
      final res = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json'));
      if (res.statusCode == 200 && mounted) {
        final list = List<Map<String, dynamic>>.from(jsonDecode(res.body));
        setState(() {
          _provinces = list;
          _filteredProvinces = list;
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _isLoadingProvinces = false);
    }
  }

  Future<void> _fetchRegencies(String provinceId) async {
    setState(() {
      _isLoadingRegencies = true;
      _regencies = [];
      _filteredRegencies = [];
      _districts = [];
      _filteredDistricts = [];
      _villages = [];
      _filteredVillages = [];
      _selectedRegencyId = null;
      _selectedRegencyName = null;
      _selectedDistrictId = null;
      _selectedDistrictName = null;
      _selectedVillageId = null;
      _selectedVillageName = null;
    });
    try {
      final res = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$provinceId.json'));
      if (res.statusCode == 200 && mounted) {
        final list = List<Map<String, dynamic>>.from(jsonDecode(res.body));
        setState(() {
          _regencies = list;
          _filteredRegencies = list;
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _isLoadingRegencies = false);
    }
  }

  Future<void> _fetchDistricts(String regencyId) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _filteredDistricts = [];
      _villages = [];
      _filteredVillages = [];
      _selectedDistrictId = null;
      _selectedDistrictName = null;
      _selectedVillageId = null;
      _selectedVillageName = null;
    });
    try {
      final res = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/districts/$regencyId.json'));
      if (res.statusCode == 200 && mounted) {
        final list = List<Map<String, dynamic>>.from(jsonDecode(res.body));
        setState(() {
          _districts = list;
          _filteredDistricts = list;
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _isLoadingDistricts = false);
    }
  }

  Future<void> _fetchVillages(String districtId) async {
    setState(() {
      _isLoadingVillages = true;
      _villages = [];
      _filteredVillages = [];
      _selectedVillageId = null;
      _selectedVillageName = null;
    });
    try {
      final res = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/villages/$districtId.json'));
      if (res.statusCode == 200 && mounted) {
        final list = List<Map<String, dynamic>>.from(jsonDecode(res.body));
        setState(() {
          _villages = list;
          _filteredVillages = list;
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _isLoadingVillages = false);
    }
  }

  // ── Bottom Sheet Pencarian Wilayah ─────────────────────

  Future<void> _showSearchSheet({
    required String title,
    required List<Map<String, dynamic>> items,
    required String? selectedId,
    required ValueChanged<Map<String, dynamic>> onSelected,
    bool isLoading = false,
  }) async {
    List<Map<String, dynamic>> filtered = List.from(items);
    final searchCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          void filterItems(String query) {
            setModalState(() {
              filtered = items
                  .where((e) => (e['name'] as String)
                      .toLowerCase()
                      .contains(query.toLowerCase()))
                  .toList();
            });
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      Text('Pilih $title',
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    onChanged: filterItems,
                    decoration: InputDecoration(
                      hintText: 'Cari $title...',
                      hintStyle: GoogleFonts.inter(
                          color: Colors.grey[400], fontSize: 13),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFF00BBA7), size: 20),
                      suffixIcon: searchCtrl.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                searchCtrl.clear();
                                filterItems('');
                              },
                              child: const Icon(Icons.clear,
                                  size: 18, color: Colors.grey),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                if (isLoading)
                  const Expanded(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF00BBA7))),
                  )
                else if (filtered.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text('Tidak ditemukan',
                          style: GoogleFonts.inter(
                              color: Colors.grey, fontSize: 13)),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(
                          height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (_, i) {
                        final item = filtered[i];
                        final isSelected = item['id'] == selectedId;
                        return ListTile(
                          onTap: () {
                            onSelected(item);
                            Navigator.pop(ctx);
                          },
                          title: Text(
                            item['name'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF00BBA7)
                                  : Colors.black87,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: Color(0xFF00BBA7), size: 20)
                              : null,
                          dense: true,
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
    searchCtrl.dispose();
  }

  // ── Set Alamat Utama ───────────────────────────────────

  Future<void> _setPrimaryAddress(String addressId) async {
    try {
      final user = _supabase.auth.currentUser!;
      await _supabase
          .from('patient_addresses')
          .update({'is_primary': false})
          .eq('patient_id', user.id);
      await _supabase
          .from('patient_addresses')
          .update({'is_primary': true})
          .eq('id', addressId);
      final addr = _allAddresses.firstWhere((a) => a['id'] == addressId);
      await _supabase.from('patients').update({
        'province_id': addr['province_id'],
        'regency_id': addr['regency_id'],
        'district_id': addr['district_id'],
        'village_id': addr['village_id'],
        'postal_code': addr['postal_code'],
        'full_address': addr['full_address'],
      }).eq('id', user.id);
      _showSnack('Alamat utama berhasil diubah!');
      await _fetchAllAddresses();
    } catch (e) {
      _showSnack('Gagal mengubah alamat utama: $e', isError: true);
    }
  }

  // ── Save Alamat ────────────────────────────────────────

  Future<void> _saveAddress() async {
    final String finalLabel = _labelController.text.trim();
    if (finalLabel.isEmpty) {
      _showSnack('Masukkan tipe alamat.', isError: true);
      return;
    }
    if (_selectedProvinceId == null ||
        _selectedRegencyId == null ||
        _selectedDistrictId == null ||
        _fullAddressController.text.trim().isEmpty) {
      _showSnack(
          'Lengkapi Provinsi, Kab/Kota, Kecamatan, dan Alamat Lengkap.',
          isError: true);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final user = _supabase.auth.currentUser!;
      if (_isPrimary) {
        await _supabase
            .from('patient_addresses')
            .update({'is_primary': false})
            .eq('patient_id', user.id);
        await _supabase.from('patients').update({
          'province_id': _selectedProvinceId,
          'regency_id': _selectedRegencyId,
          'district_id': _selectedDistrictId,
          'village_id': _selectedVillageId,
          'postal_code': _postalController.text.trim(),
          'full_address': _fullAddressController.text.trim(),
        }).eq('id', user.id);
      }
      await _supabase.from('patient_addresses').insert({
        'patient_id': user.id,
        'label': finalLabel,
        'province_id': _selectedProvinceId,
        'province_name': _selectedProvinceName,
        'regency_id': _selectedRegencyId,
        'regency_name': _selectedRegencyName,
        'district_id': _selectedDistrictId,
        'district_name': _selectedDistrictName,
        'village_id': _selectedVillageId,
        'village_name': _selectedVillageName,
        'postal_code': _postalController.text.trim(),
        'full_address': _fullAddressController.text.trim(),
        'is_primary': _isPrimary,
      });
      _showSnack('Alamat berhasil disimpan!');
      await _fetchAllAddresses();
      _resetForm();
    } catch (e) {
      _showSnack('Gagal menyimpan: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteAddress(String addressId,
      {bool isPrimary = false}) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Alamat',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text(
          isPrimary
              ? 'Ini adalah alamat utama. Yakin ingin menghapusnya?'
              : 'Yakin ingin menghapus alamat ini?',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Batal',
                  style: GoogleFonts.inter(color: Colors.grey))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Hapus',
                  style: GoogleFonts.inter(
                      color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _supabase
          .from('patient_addresses')
          .delete()
          .eq('id', addressId);
      if (isPrimary) {
        final user = _supabase.auth.currentUser!;
        await _supabase.from('patients').update({
          'province_id': null,
          'regency_id': null,
          'district_id': null,
          'village_id': null,
          'postal_code': null,
          'full_address': null,
        }).eq('id', user.id);
      }
      _showSnack('Alamat dihapus.');
      await _fetchAllAddresses();
    } catch (e) {
      _showSnack('Gagal menghapus: $e', isError: true);
    }
  }

  void _resetForm() {
    _postalController.clear();
    _fullAddressController.clear();
    _labelController.text = 'Rumah';
    setState(() {
      _selectedProvinceId = null;
      _selectedProvinceName = null;
      _selectedRegencyId = null;
      _selectedRegencyName = null;
      _selectedDistrictId = null;
      _selectedDistrictName = null;
      _selectedVillageId = null;
      _selectedVillageName = null;
      _regencies = [];
      _filteredRegencies = [];
      _districts = [];
      _filteredDistricts = [];
      _villages = [];
      _filteredVillages = [];
      _isPrimary = false;
    });
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: isError ? Colors.red : const Color(0xFF00BBA7),
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── BUILD ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDaftarAlamat(),
                  const SizedBox(height: 20),
                  _buildFormAlamatBaru(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF00BBA7),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.only(top: 55, bottom: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context, true),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
          Column(
            children: [
              Text('Tambah Alamat',
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 38,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xFF009689),
                  child: Text(
                    _patientInitials.isEmpty ? '??' : _patientInitials,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _patientName.isEmpty ? 'Memuat...' : _patientName,
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('ID : $_patientId',
                    style:
                        GoogleFonts.inter(color: Colors.white, fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── DAFTAR ALAMAT ──────────────────────────────────────

  Widget _buildDaftarAlamat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: Color(0xFF00BBA7), size: 18),
                const SizedBox(width: 6),
                Text('DAFTAR ALAMAT',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00BBA7),
                        letterSpacing: 0.6)),
              ],
            ),
            Text('${_allAddresses.length} ALAMAT TERSIMPAN',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 12),
        if (_loadingAddresses)
          const Center(
              child: CircularProgressIndicator(color: Color(0xFF00BBA7)))
        else if (_allAddresses.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14)),
            child: Center(
              child: Text('Belum ada alamat tersimpan.',
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)),
            ),
          )
        else
          ..._allAddresses.map((addr) => _buildAddressCard(addr)),
      ],
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> addr) {
    final id = addr['id'] as String;
    final isPrimary = addr['is_primary'] == true;
    final label = addr['label'] as String? ?? 'Rumah';
    final fullAddress = addr['full_address'] as String? ?? '';
    final districtName = addr['district_name'] as String? ?? '';
    final regencyName = addr['regency_name'] as String? ?? '';
    final provinceName = addr['province_name'] as String? ?? '';
    final postalCode = addr['postal_code'] as String? ?? '';

    final parts = <String>[];
    if (fullAddress.isNotEmpty) parts.add(fullAddress);
    if (districtName.isNotEmpty) parts.add('Kec. $districtName');
    if (regencyName.isNotEmpty) parts.add(regencyName);
    if (provinceName.isNotEmpty) parts.add(provinceName);
    if (postalCode.isNotEmpty) parts.add(postalCode);
    final addressText = parts.join(', ');

    IconData labelIcon = Icons.home_outlined;
    if (label == 'Kosan') labelIcon = Icons.apartment_outlined;
    if (label == 'Kantor') labelIcon = Icons.business_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isPrimary
            ? Border.all(color: const Color(0xFF00BBA7), width: 1.5)
            : Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF00BBA7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(labelIcon,
                    color: const Color(0xFF00BBA7), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPrimary
                                ? const Color(0xFF00BBA7)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            label.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isPrimary
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        if (isPrimary) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: Colors.amber.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star,
                                    size: 10, color: Colors.amber[700]),
                                const SizedBox(width: 3),
                                Text('UTAMA',
                                    style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber[700])),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      addressText.isNotEmpty
                          ? addressText
                          : 'Alamat tidak tersedia',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              if (!isPrimary)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _setPrimaryAddress(id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF00BBA7).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF00BBA7)
                                .withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star_border,
                              size: 14, color: Color(0xFF00BBA7)),
                          const SizedBox(width: 4),
                          Text('Jadikan Utama',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF00BBA7))),
                        ],
                      ),
                    ),
                  ),
                ),
              if (!isPrimary) const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      _deleteAddress(id, isPrimary: isPrimary),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_outline,
                            color: Colors.red, size: 14),
                        const SizedBox(width: 4),
                        Text('Hapus',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.red)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── FORM ALAMAT BARU ───────────────────────────────────

  Widget _buildFormAlamatBaru() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDFB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_location_alt_outlined,
                    color: Color(0xFF00BBA7), size: 18),
                const SizedBox(width: 8),
                Text('ALAMAT BARU',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00BBA7),
                        letterSpacing: 0.6)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Tipe Alamat (ketik bebas) ────────────
                _buildLabel('Tipe Alamat', required: true),
                const SizedBox(height: 6),
                TextField(
                  controller: _labelController,
                  maxLength: 30,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(
                      hint: 'cth: Rumah, Kosan, Kantor, Klinik...'),
                ),

                const SizedBox(height: 4),
                Center(
                  child: Text('Detail Lokasi',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600])),
                ),
                const SizedBox(height: 16),

                // ── Provinsi ─────────────────────────────
                _buildLabel('Provinsi', required: true),
                const SizedBox(height: 6),
                _buildSearchField(
                  hint: 'Pilih Provinsi',
                  value: _selectedProvinceName,
                  isLoading: _isLoadingProvinces,
                  enabled: _provinces.isNotEmpty,
                  onTap: () => _showSearchSheet(
                    title: 'Provinsi',
                    items: _provinces,
                    selectedId: _selectedProvinceId,
                    onSelected: (item) {
                      setState(() {
                        _selectedProvinceId = item['id'];
                        _selectedProvinceName = item['name'];
                      });
                      _fetchRegencies(item['id']);
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // ── Kab/Kota & Kecamatan ─────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Kab / Kota', required: true),
                          const SizedBox(height: 6),
                          _buildSearchField(
                            hint: 'Pilih',
                            value: _selectedRegencyName,
                            isLoading: _isLoadingRegencies,
                            enabled: _regencies.isNotEmpty,
                            onTap: () => _showSearchSheet(
                              title: 'Kab/Kota',
                              items: _regencies,
                              selectedId: _selectedRegencyId,
                              onSelected: (item) {
                                setState(() {
                                  _selectedRegencyId = item['id'];
                                  _selectedRegencyName = item['name'];
                                });
                                _fetchDistricts(item['id']);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Kecamatan', required: true),
                          const SizedBox(height: 6),
                          _buildSearchField(
                            hint: 'Pilih',
                            value: _selectedDistrictName,
                            isLoading: _isLoadingDistricts,
                            enabled: _districts.isNotEmpty,
                            onTap: () => _showSearchSheet(
                              title: 'Kecamatan',
                              items: _districts,
                              selectedId: _selectedDistrictId,
                              onSelected: (item) {
                                setState(() {
                                  _selectedDistrictId = item['id'];
                                  _selectedDistrictName = item['name'];
                                });
                                _fetchVillages(item['id']);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Kelurahan & Kode Pos ──────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Kelurahan'),
                          const SizedBox(height: 6),
                          _buildSearchField(
                            hint: 'Pilih',
                            value: _selectedVillageName,
                            isLoading: _isLoadingVillages,
                            enabled: _villages.isNotEmpty,
                            onTap: () => _showSearchSheet(
                              title: 'Kelurahan',
                              items: _villages,
                              selectedId: _selectedVillageId,
                              onSelected: (item) {
                                setState(() {
                                  _selectedVillageId = item['id'];
                                  _selectedVillageName = item['name'];
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Kode Pos'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _postalController,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            decoration: _inputDecoration(hint: '4xxxx'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _buildLabel('Alamat Lengkap', required: true),
                const SizedBox(height: 6),
                TextField(
                  controller: _fullAddressController,
                  maxLines: 3,
                  decoration: _inputDecoration(
                      hint:
                          'Jl. Nama Jalan No. xx, RT/RW, Detailnya...'),
                ),

                const SizedBox(height: 18),

                // ── Toggle Alamat Utama ───────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FFFE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                            const Color(0xFF00BBA7).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jadikan Alamat Utama',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            Text('Digunakan sebagai alamat default',
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isPrimary,
                        onChanged: (v) =>
                            setState(() => _isPrimary = v),
                        activeColor: const Color(0xFF00BBA7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TOMBOL ACTION ──────────────────────────────────────

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context, true),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF00BBA7)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text('Batal',
                style: GoogleFonts.inter(
                    color: const Color(0xFF00BBA7),
                    fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BBA7),
              disabledBackgroundColor:
                  const Color(0xFF00BBA7).withOpacity(0.6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text('Simpan Alamat',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
          ),
        ),
      ],
    );
  }

  // ── HELPER WIDGETS ─────────────────────────────────────

  Widget _buildSearchField({
    required String hint,
    required String? value,
    required VoidCallback onTap,
    bool enabled = true,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: enabled && !isLoading ? onTap : null,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFFF9FAFB)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                enabled ? Colors.grey.shade200 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF00BBA7)),
                    )
                  : Text(
                      value ?? hint,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: value != null
                            ? Colors.black87
                            : Colors.grey[400],
                      ),
                    ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: enabled
                  ? const Color(0xFF00BBA7)
                  : Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87),
        children: [
          TextSpan(text: text),
          if (required)
            const TextSpan(
                text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String hint = ''}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.inter(color: Colors.grey[400], fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      counterText: '',
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: Color(0xFF00BBA7), width: 1.5),
      ),
    );
  }
}