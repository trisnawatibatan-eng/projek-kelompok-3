import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';

class FisioterapisEditProfilScreen extends StatefulWidget {
  const FisioterapisEditProfilScreen({super.key});

  @override
  State<FisioterapisEditProfilScreen> createState() =>
      _FisioterapisEditProfilScreenState();
}

class _FisioterapisEditProfilScreenState
    extends State<FisioterapisEditProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  // Controllers - Informasi Pribadi
  final _namaController = TextEditingController();
  final _gelarController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatLengkapController = TextEditingController();
  final _postalController = TextEditingController();

  // Controllers - Informasi Profesional
  final _strController = TextEditingController();
  final _pengalamanController = TextEditingController();
  final _pendidikanController = TextEditingController();
  final _biografiController = TextEditingController();
  final _sertifikasiController = TextEditingController();

  // ── Wilayah ───────────────────────────────────────────────────
  List _provinces = [];
  List _regencies = [];
  List _districts = [];
  List _villages = [];

  // ID & label wilayah yang dipilih
  String? _provinceId, _regencyId, _districtId, _villageId;
  String? _provinceLabel, _regencyLabel, _districtLabel, _villageLabel;

  // ── Daftar sertifikasi (multi-item) ──────────────────────────
  final List<String> _sertifikasiList = [];

  // Files
  File? _fotoProfilFile;
  File? _fotoStrFile;
  List<File> _sertifikatFiles = [];
  String? _existingFotoProfilUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
    _loadProfil();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _gelarController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _alamatLengkapController.dispose();
    _postalController.dispose();
    _strController.dispose();
    _pengalamanController.dispose();
    _pendidikanController.dispose();
    _biografiController.dispose();
    _sertifikasiController.dispose();
    super.dispose();
  }

  // ── Load wilayah ──────────────────────────────────────────────

  Future<void> _loadProvinces() async {
    try {
      final res = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json'));
      final data = json.decode(res.body);
      if (mounted) setState(() => _provinces = data);
    } catch (e) {
      debugPrint('Error provinces: $e');
    }
  }

  Future<void> _loadRegencies(String provinceId) async {
    try {
      final res = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$provinceId.json'));
      final data = json.decode(res.body);
      if (mounted) {
        setState(() {
          _regencies = data;
          _regencyId = _regencyLabel = null;
          _districtId = _districtLabel = null;
          _villageId = _villageLabel = null;
          _districts = [];
          _villages = [];
        });
      }
    } catch (e) {
      debugPrint('Error regencies: $e');
    }
  }

  Future<void> _loadDistricts(String regencyId) async {
    try {
      final res = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/districts/$regencyId.json'));
      final data = json.decode(res.body);
      if (mounted) {
        setState(() {
          _districts = data;
          _districtId = _districtLabel = null;
          _villageId = _villageLabel = null;
          _villages = [];
        });
      }
    } catch (e) {
      debugPrint('Error districts: $e');
    }
  }

  Future<void> _loadVillages(String districtId) async {
    try {
      final res = await http.get(Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/api/villages/$districtId.json'));
      final data = json.decode(res.body);
      if (mounted) {
        setState(() {
          _villages = data;
          _villageId = _villageLabel = null;
        });
      }
    } catch (e) {
      debugPrint('Error villages: $e');
    }
  }

  // ── Prefill wilayah dari ID yang sudah tersimpan ──────────────

  Future<void> _prefillWilayah({
    required String? provinceId,
    required String? provinceName,
    required String? regencyId,
    required String? regencyName,
    required String? districtId,
    required String? districtName,
  }) async {
    // Langsung set dari kolom name yang sudah tersimpan di DB
    // tanpa perlu fetch ulang ke API jika name sudah ada
    if (provinceId != null) {
      setState(() {
        _provinceId = provinceId;
        _provinceLabel = provinceName;
      });

      // Load regencies agar dropdown Kab/Kota bisa dipakai
      try {
        final res = await http.get(Uri.parse(
            'https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$provinceId.json'));
        final regData = json.decode(res.body) as List;
        if (mounted) setState(() => _regencies = regData);
      } catch (_) {}
    }

    if (regencyId != null) {
      setState(() {
        _regencyId = regencyId;
        _regencyLabel = regencyName;
      });

      // Load districts
      try {
        final res = await http.get(Uri.parse(
            'https://www.emsifa.com/api-wilayah-indonesia/api/districts/$regencyId.json'));
        final distData = json.decode(res.body) as List;
        if (mounted) setState(() => _districts = distData);
      } catch (_) {}
    }

    if (districtId != null) {
      setState(() {
        _districtId = districtId;
        _districtLabel = districtName;
      });

      // Load villages agar dropdown Kelurahan bisa dipakai
      try {
        final res = await http.get(Uri.parse(
            'https://www.emsifa.com/api-wilayah-indonesia/api/villages/$districtId.json'));
        final vilData = json.decode(res.body) as List;
        if (mounted) setState(() => _villages = vilData);
      } catch (_) {}
    }
  }

  // ── Load profil ───────────────────────────────────────────────

  Future<void> _loadProfil() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('fisioterapis')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) return;

      if (mounted) {
        _namaController.text = data['nama_lengkap'] ?? '';
        _gelarController.text = data['gelar'] ?? '';
        _emailController.text = data['email'] ?? '';
        _teleponController.text = data['nomor_telepon'] ?? '';
        _strController.text = data['nomor_str_sipa'] ?? '';
        _pengalamanController.text = data['pengalaman_kerja'] ?? '';
        _pendidikanController.text = data['pendidikan_terakhir'] ?? '';
        _biografiController.text = data['biografi'] ?? '';
        _existingFotoProfilUrl = data['foto_profil_url'];
        _postalController.text = data['postal_code'] ?? '';

        // ── PERBAIKAN: Ambil alamat dari kolom 'alamat' (teks jalan saja) ──
        // dan wilayah dari kolom terpisah province_id, regency_id, dst.
        _alamatLengkapController.text = data['alamat'] ?? '';

        // Parse sertifikasi
        final raw = data['sertifikasi'] as String? ?? '';
        if (raw.isNotEmpty) {
          setState(() {
            _sertifikasiList.clear();
            _sertifikasiList.addAll(
              raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty),
            );
          });
        }

        // ── PERBAIKAN: Prefill wilayah dari kolom terpisah di DB ──────────
        await _prefillWilayah(
          provinceId: data['province_id'] as String?,
          provinceName: data['province_name'] as String?,
          regencyId: data['regency_id'] as String?,
          regencyName: data['regency_name'] as String?,
          districtId: data['district_id'] as String?,
          districtName: data['district_name'] as String?,
        );

        // Set village dari DB jika ada
        final villageId = data['village_id'] as String?;
        final villageName = data['village_name'] as String?;
        if (villageId != null && mounted) {
          setState(() {
            _villageId = villageId;
            _villageLabel = villageName;
          });
        }
      }
    } catch (e) {
      if (mounted) _showSnackError('Gagal memuat profil: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Search dialog wilayah ─────────────────────────────────────

  Future<dynamic> _showSearchDialog(List data, String title) async {
    final search = TextEditingController();
    List filtered = List.from(data);

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModal) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            maxChildSize: 0.95,
            builder: (_, sc) => Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppColors.primaryText),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: search,
                    style: GoogleFonts.inter(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Cari...',
                      hintStyle: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.lightText),
                      prefixIcon: const Icon(Icons.search, size: 18,
                          color: AppColors.primary),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: AppColors.borderColor)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: AppColors.borderColor)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5)),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                    ),
                    onChanged: (q) {
                      setModal(() {
                        filtered = data
                            .where((d) => (d['name'] as String)
                                .toLowerCase()
                                .contains(q.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: sc,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final item = filtered[i];
                      return ListTile(
                        title: Text(item['name'],
                            style: GoogleFonts.inter(
                                fontSize: 13, color: AppColors.primaryText)),
                        onTap: () => Navigator.pop(ctx, item),
                        trailing: const Icon(Icons.chevron_right,
                            size: 18, color: AppColors.lightText),
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
  }

  // ── Upload & simpan ───────────────────────────────────────────

  Future<String?> _uploadFile(File file, String bucket, String path) async {
    try {
      await _supabase.storage.from(bucket).upload(
            path, file,
            fileOptions: const FileOptions(upsert: true),
          );
      return _supabase.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }

  Future<void> _simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_provinceId == null || _regencyId == null || _districtId == null) {
      _showSnackError('Provinsi, Kab/Kota, dan Kecamatan wajib dipilih!');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      String? fotoProfilUrl;
      String? fotoStrUrl;

      if (_fotoProfilFile != null) {
        fotoProfilUrl = await _uploadFile(
          _fotoProfilFile!, 'fisioterapis', '$userId/profile_photo.jpg',
        );
      }
      if (_fotoStrFile != null) {
        fotoStrUrl = await _uploadFile(
          _fotoStrFile!, 'fisioterapis', '$userId/foto_str.jpg',
        );
      }
      List<String> sertifikatUrls = [];
      for (int i = 0; i < _sertifikatFiles.length; i++) {
        final url = await _uploadFile(
          _sertifikatFiles[i], 'fisioterapis', '$userId/sertifikat_$i.pdf',
        );
        if (url != null) sertifikatUrls.add(url);
      }

      final sertifikasiValue = _sertifikasiList.join(', ');

      // ── PERBAIKAN: Simpan wilayah ke kolom terpisah, bukan format || ──
      // Kolom 'alamat' hanya berisi detail jalan (free text)
      final payload = {
        'user_id': userId,
        'nama_lengkap': _namaController.text.trim(),
        'gelar': _gelarController.text.trim(),
        'email': _emailController.text.trim(),
        'nomor_telepon': _teleponController.text.trim(),

        // Alamat detail jalan saja (tanpa encode wilayah)
        'alamat': _alamatLengkapController.text.trim(),

        // ── Wilayah disimpan ke kolom masing-masing ──────────────────────
        'province_id': _provinceId,
        'province_name': _provinceLabel,
        'regency_id': _regencyId,
        'regency_name': _regencyLabel,
        'district_id': _districtId,
        'district_name': _districtLabel,
        'village_id': _villageId,       // nullable, boleh null
        'village_name': _villageLabel,  // nullable, boleh null

        'nomor_str_sipa': _strController.text.trim(),
        'pengalaman_kerja': _pengalamanController.text.trim(),
        'pendidikan_terakhir': _pendidikanController.text.trim(),
        'biografi': _biografiController.text.trim(),
        'sertifikasi': sertifikasiValue,
        if (fotoProfilUrl != null) 'foto_profil_url': fotoProfilUrl,
        if (fotoStrUrl != null) 'foto_str_url': fotoStrUrl,
        if (sertifikatUrls.isNotEmpty)
          'sertifikat_urls': sertifikatUrls.join(','),
      };

      await _supabase
          .from('fisioterapis')
          .upsert(payload, onConflict: 'user_id');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profil berhasil disimpan',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showSnackError('Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: AppColors.errorRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Sertifikasi helpers ───────────────────────────────────────

  void _tambahSertifikasi() {
    final value = _sertifikasiController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _sertifikasiList.add(value);
      _sertifikasiController.clear();
    });
  }

  void _hapusSertifikasi(int index) {
    setState(() => _sertifikasiList.removeAt(index));
  }

  // ── Foto picker helpers ───────────────────────────────────────

  Future<void> _pickFotoProfil() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _fotoProfilFile = File(picked.path));
  }

  Future<void> _pickFile(bool isStr) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null && isStr) setState(() => _fotoStrFile = File(picked.path));
  }

  Future<void> _pickMultipleSertifikat() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _sertifikatFiles.add(File(picked.path)));
  }

  void _removeSertifikatFile(int index) {
    setState(() => _sertifikatFiles.removeAt(index));
  }

  // ════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 16),
                          _buildSection('Informasi Pribadi', [
                            _buildField(
                              icon: Icons.person_outline,
                              label: 'Nama Lengkap',
                              hint: 'Siti Nurhaliza',
                              controller: _namaController,
                              required: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"[a-zA-Z\s\.\,\'\-]")),
                              ],
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Nama Lengkap wajib diisi';
                                }
                                if (RegExp(r'[0-9]').hasMatch(val)) {
                                  return 'Nama tidak boleh mengandung angka';
                                }
                                return null;
                              },
                            ),
                            _buildField(
                              icon: Icons.workspace_premium_outlined,
                              label: 'Gelar',
                              hint: 'S.Tr.Kes / S.Ft / Ners',
                              controller: _gelarController,
                              required: false,
                              subtitle:
                                  'Gelar akademik atau profesi (hanya huruf)',
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"[a-zA-Z\s\.\,\'\-]")),
                              ],
                              validator: (val) {
                                if (val != null && val.isNotEmpty) {
                                  if (RegExp(r'[0-9]').hasMatch(val)) {
                                    return 'Gelar tidak boleh mengandung angka';
                                  }
                                }
                                return null;
                              },
                            ),
                            _buildField(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              hint: 'siti@email.com',
                              controller: _emailController,
                              required: true,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            _buildField(
                              icon: Icons.phone_outlined,
                              label: 'Nomor Telepon',
                              hint: '+62 812 3456 7890',
                              controller: _teleponController,
                              required: true,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9\+\-\s]')),
                              ],
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Nomor Telepon wajib diisi';
                                }
                                final digitsOnly =
                                    val.replaceAll(RegExp(r'[^\d]'), '');
                                if (digitsOnly.length < 8) {
                                  return 'Nomor telepon minimal 8 digit';
                                }
                                return null;
                              },
                            ),
                          ]),
                          const SizedBox(height: 16),

                          // ── Seksi Alamat ───────────────────────
                          _buildSection('Alamat Fisioterapis', [
                            _buildWilayahRow(),
                            const SizedBox(height: 14),
                            _buildField(
                              icon: Icons.home_outlined,
                              label: 'Alamat Lengkap',
                              hint: 'Jl. Danautoba VII Blok1 No.9, RT/RW...',
                              controller: _alamatLengkapController,
                              required: true,
                              maxLines: 2,
                            ),
                            _buildField(
                              icon: Icons.markunread_mailbox_outlined,
                              label: 'Kode Pos',
                              hint: '68xxx',
                              controller: _postalController,
                              required: false,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(5),
                              ],
                            ),
                          ]),
                          const SizedBox(height: 16),

                          _buildSection('Informasi Profesional', [
                            _buildField(
                              icon: Icons.badge_outlined,
                              label: 'Nomor STR/SIPA',
                              hint: '23456898765445678',
                              controller: _strController,
                              required: true,
                              subtitle:
                                  'Surat Tanda Registrasi/Surat Izin Praktik Apoteker',
                            ),
                            _buildField(
                              icon: Icons.work_outline,
                              label: 'Pengalaman Kerja',
                              hint: '12 tahun di rs raffa',
                              controller: _pengalamanController,
                              required: false,
                            ),
                            _buildField(
                              icon: Icons.school_outlined,
                              label: 'Pendidikan Terakhir',
                              hint: 'S1 Fisioterapi, Universitas Indonesia',
                              controller: _pendidikanController,
                              required: false,
                            ),
                            _buildTextAreaField(
                              label: 'Biografi',
                              hint:
                                  'Fisioterapis berpengalaman dengan spesialisasi neurologi dan rehabilitasi pasca...',
                              controller: _biografiController,
                            ),
                            _buildSertifikasiMultiField(),
                          ]),
                          const SizedBox(height: 16),
                          _buildDokumenSection(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildSimpanButton(),
              ],
            ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  WIDGET: Wilayah
  // ════════════════════════════════════════════════════════════════

  Widget _buildWilayahRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocationTile(
          icon: Icons.map_outlined,
          label: 'Provinsi',
          value: _provinceLabel,
          required: true,
          enabled: true,
          onTap: () async {
            if (_provinces.isEmpty) {
              _showSnackError('Data provinsi belum tersedia, coba lagi.');
              return;
            }
            final val = await _showSearchDialog(_provinces, 'Pilih Provinsi');
            if (val != null) {
              setState(() {
                _provinceId = val['id'];
                _provinceLabel = val['name'];
                // Reset bawahan
                _regencyId = _regencyLabel = null;
                _districtId = _districtLabel = null;
                _villageId = _villageLabel = null;
                _regencies = [];
                _districts = [];
                _villages = [];
              });
              _loadRegencies(val['id']);
            }
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildLocationTile(
                icon: Icons.location_city_outlined,
                label: 'Kab / Kota',
                value: _regencyLabel,
                required: true,
                enabled: _provinceId != null,
                onTap: _provinceId == null
                    ? null
                    : () async {
                        final val = await _showSearchDialog(
                            _regencies, 'Pilih Kab / Kota');
                        if (val != null) {
                          setState(() {
                            _regencyId = val['id'];
                            _regencyLabel = val['name'];
                            // Reset bawahan
                            _districtId = _districtLabel = null;
                            _villageId = _villageLabel = null;
                            _districts = [];
                            _villages = [];
                          });
                          _loadDistricts(val['id']);
                        }
                      },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildLocationTile(
                icon: Icons.location_on_outlined,
                label: 'Kecamatan',
                value: _districtLabel,
                required: true,
                enabled: _regencyId != null,
                onTap: _regencyId == null
                    ? null
                    : () async {
                        final val = await _showSearchDialog(
                            _districts, 'Pilih Kecamatan');
                        if (val != null) {
                          setState(() {
                            _districtId = val['id'];
                            _districtLabel = val['name'];
                            // Reset bawahan
                            _villageId = _villageLabel = null;
                            _villages = [];
                          });
                          _loadVillages(val['id']);
                        }
                      },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildLocationTile(
          icon: Icons.holiday_village_outlined,
          label: 'Kelurahan / Desa (Opsional)',
          value: _villageLabel,
          required: false,
          enabled: _districtId != null,
          onTap: _districtId == null
              ? null
              : () async {
                  final val =
                      await _showSearchDialog(_villages, 'Pilih Kelurahan');
                  if (val != null) {
                    setState(() {
                      _villageId = val['id'];
                      _villageLabel = val['name'];
                    });
                  }
                },
        ),
      ],
    );
  }

  Widget _buildLocationTile({
    required IconData icon,
    required String label,
    String? value,
    bool required = false,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText),
            ),
            if (required)
              Text(' *',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.errorRed)),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: enabled
                  ? const Color(0xFFF9FAFB)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: value != null
                    ? AppColors.primary.withOpacity(0.5)
                    : AppColors.borderColor,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value ?? 'Pilih',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: value != null
                          ? AppColors.primaryText
                          : AppColors.lightText,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down,
                    size: 18,
                    color:
                        enabled ? AppColors.primary : AppColors.lightText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  WIDGET: Header
  // ════════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00BBA7), Color(0xFF009689)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 18),
                  ),
                  Text(
                    'Edit Profil',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickFotoProfil,
              child: Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: !kIsWeb && _fotoProfilFile != null
                        ? Image.file(_fotoProfilFile!, fit: BoxFit.cover)
                        : _existingFotoProfilUrl != null &&
                                (_existingFotoProfilUrl?.isNotEmpty ?? false)
                            ? Image.network(_existingFotoProfilUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _avatarPlaceholder())
                            : _avatarPlaceholder(),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF00BBA7), width: 1.5),
                      ),
                      child: const Icon(Icons.edit,
                          size: 13, color: Color(0xFF00BBA7)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ketuk untuk ganti foto profil',
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.85), fontSize: 11),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _avatarPlaceholder() => Container(
        color: const Color(0xFF00BBA7),
        child:
            const Center(child: Icon(Icons.person, color: Colors.white, size: 40)),
      );

  // ════════════════════════════════════════════════════════════════
  //  WIDGET: Section container
  // ════════════════════════════════════════════════════════════════

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  WIDGET: Form fields
  // ════════════════════════════════════════════════════════════════

  Widget _buildField({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
    bool required = false,
    String? subtitle,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText)),
              if (required)
                Text(' *',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.errorRed)),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle,
                style:
                    GoogleFonts.inter(fontSize: 9, color: AppColors.lightText)),
          ],
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            inputFormatters: inputFormatters,
            style:
                GoogleFonts.inter(fontSize: 13, color: AppColors.primaryText),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  GoogleFonts.inter(fontSize: 13, color: AppColors.lightText),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.borderColor)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.borderColor)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5)),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
            ),
            validator: validator ??
                (required
                    ? (val) => val == null || val.isEmpty
                        ? '$label wajib diisi'
                        : null
                    : null),
          ),
        ],
      ),
    );
  }

  Widget _buildTextAreaField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: 4,
            style:
                GoogleFonts.inter(fontSize: 13, color: AppColors.primaryText),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  GoogleFonts.inter(fontSize: 13, color: AppColors.lightText),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.borderColor)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.borderColor)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5)),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sertifikasi multi-item ────────────────────────────────────

  Widget _buildSertifikasiMultiField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Sertifikasi',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText)),
            ],
          ),
          const SizedBox(height: 8),
          if (_sertifikasiList.isNotEmpty) ...[
            ..._sertifikasiList.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6FAF8),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w500)),
                    ),
                    GestureDetector(
                      onTap: () => _hapusSertifikasi(index),
                      child: const Icon(Icons.close,
                          size: 16, color: AppColors.lightText),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _sertifikasiController,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.primaryText),
                  decoration: InputDecoration(
                    hintText: 'Tambah sertifikasi...',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.lightText),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.borderColor)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.borderColor)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5)),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                  ),
                  onFieldSubmitted: (_) => _tambahSertifikasi(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _tambahSertifikasi,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Ketuk + untuk menambah sertifikasi',
              style: GoogleFonts.inter(
                  fontSize: 9, color: AppColors.lightText)),
        ],
      ),
    );
  }

  // ── Dokumen section ───────────────────────────────────────────

  Widget _buildDokumenSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dokumen Pendukung',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderColor),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildUploadBox(
                  label: 'Foto STR/SIPA',
                  required: true,
                  subtitle: 'PNG, JPG atau PDF (Max. 5MB)',
                  file: _fotoStrFile,
                  onTap: () => _pickFile(true),
                ),
                const SizedBox(height: 14),
                _buildMultipleSertifikatBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleSertifikatBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sertifikat Kompetensi',
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText)),
        const SizedBox(height: 8),
        if (_sertifikatFiles.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCCF4EF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('File yang dipilih (${_sertifikatFiles.length}):',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
                const SizedBox(height: 8),
                ..._sertifikatFiles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  final fileName = file.path.split('/').last;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.description_outlined,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(fileName,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.primaryText,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis),
                        ),
                        GestureDetector(
                          onTap: () => _removeSertifikatFile(index),
                          child: const Icon(Icons.close,
                              size: 16, color: AppColors.lightText),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        GestureDetector(
          onTap: _pickMultipleSertifikat,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              children: [
                Icon(Icons.upload_outlined,
                    color: AppColors.lightText, size: 28),
                const SizedBox(height: 6),
                Text('Klik untuk upload sertifikat',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText)),
                const SizedBox(height: 4),
                Text(
                    'PDF atau gambar (Max. 5MB)\nTambahkan lebih dari 1 file',
                    style: GoogleFonts.inter(
                        fontSize: 9, color: AppColors.lightText),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox({
    required String label,
    required bool required,
    required String subtitle,
    required File? file,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText)),
            if (required)
              Text(' *',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.errorRed)),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    file != null ? AppColors.primary : AppColors.borderColor,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  file != null
                      ? Icons.check_circle_outline
                      : Icons.upload_outlined,
                  color:
                      file != null ? AppColors.primary : AppColors.lightText,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  file != null
                      ? 'File dipilih'
                      : 'Klik untuk upload atau drag & drop',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: file != null
                        ? AppColors.primary
                        : AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 9, color: AppColors.lightText),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Simpan button ─────────────────────────────────────────────

  Widget _buildSimpanButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _simpanPerubahan,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text('Simpan Perubahan',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
        ),
      ),
    );
  }
}