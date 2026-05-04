import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav_bar.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'login_screen.dart';
import 'add_address_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;

  Map<String, dynamic>? _patient;
  List<Map<String, dynamic>> _extraAddresses = [];
  bool _isLoading = true;
  bool _notifEnabled = true;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    await Future.wait([_fetchProfile(), _fetchExtraAddresses()]);
  }

  Future<void> _fetchProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) { _redirectToLogin(); return; }

      final data = await _supabase
          .from('patients')
          .select(
            'full_name, email, phone, date_of_birth, gender, '
            'province_id, regency_id, district_id, village_id, '
            'postal_code, full_address, weight_kg, height_cm, '
            'blood_type, allergy, medical_history, created_at',
          )
          .eq('id', user.id)
          .single();

      if (mounted) setState(() { _patient = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchExtraAddresses() async {
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
          _extraAddresses = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (_) {}
  }

  void _redirectToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<void> _goToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    if (result == true) _fetchAll();
  }

  Future<void> _goToAddAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );
    _fetchAll();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar dari Akun',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin keluar?',
            style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Keluar',
                style: GoogleFonts.inter(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _supabase.auth.signOut();
      _redirectToLogin();
    }
  }

  // ── Helpers ──────────────────────────────────────────────

  String get _initials {
    final name = _patient?['full_name'] as String? ?? '';
    if (name.isEmpty) return '??';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String get _displayName => _patient?['full_name'] as String? ?? '-';
  String get _displayEmail => _patient?['email'] as String? ?? '-';

  String get _patientId {
    final raw = _patient?['created_at'] as String?;
    if (raw == null) return 'FSC-0000-00';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return 'FSC-0000-00';
    return 'FSC-${dt.year}-${dt.month.toString().padLeft(2, '0')}';
  }

  String _formatGender(String? g) {
    if (g == 'male') return 'Laki-laki';
    if (g == 'female') return 'Perempuan';
    return '-';
  }

  String _formatDob(String? dob) {
    if (dob == null || dob.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dob);
      const months = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) { return dob; }
  }

  String _orDash(dynamic v) {
    if (v == null) return 'Tidak ada';
    final s = v.toString().trim();
    return s.isEmpty ? 'Tidak ada' : s;
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: isError ? Colors.red : const Color(0xFF00BBA7),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00BBA7)))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSectionDataDiri(),
                      const SizedBox(height: 16),
                      _buildSectionDataMedis(),
                      const SizedBox(height: 16),
                      _buildSectionPengaturan(),
                      const SizedBox(height: 30),
                    ]),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }

  // ── HEADER ───────────────────────────────────────────────

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF00BBA7),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.only(top: 60, bottom: 30),
          child: Column(
            children: [
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 38,
                  backgroundColor: const Color(0xFF009689),
                  child: Text(_initials,
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              Text(_displayName,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('ID : $_patientId',
                    style: GoogleFonts.inter(
                        color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ),
        Positioned(
          top: 55, left: 0, right: 0,
          child: Center(
            child: Text('Profil Saya',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        Positioned(
          top: 48, right: 16,
          child: GestureDetector(
            onTap: _goToEditProfile,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_note,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text('Edit',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── CARDS ────────────────────────────────────────────────

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF00BBA7)),
          const SizedBox(width: 8),
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00BBA7),
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── DATA DIRI ────────────────────────────────────────────

  Widget _buildSectionDataDiri() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('DATA DIRI', Icons.person_outline),
          _buildRow('Nama Lengkap', _displayName),
          _buildRow('Tanggal Lahir', _formatDob(_patient?['date_of_birth'])),
          _buildRow('Jenis Kelamin', _formatGender(_patient?['gender'])),
          _buildRow('Nomor HP', _orDash(_patient?['phone'])),
          _buildRow('Email', _displayEmail),

          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 15, color: Color(0xFF00BBA7)),
              const SizedBox(width: 6),
              Text('ALAMAT',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00BBA7),
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 8),

          // Tampilkan semua dari patient_addresses
          if (_extraAddresses.isEmpty &&
              (_patient?['full_address'] == null ||
                  (_patient!['full_address'] as String).isEmpty))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text('Belum ada alamat tersimpan.',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.grey)),
            )
          else
            ..._extraAddresses.map((addr) => _buildAddressTile(
                  addressId: addr['id'] as String,
                  label: addr['label'] as String? ?? 'Rumah',
                  address: _buildAddressString(addr),
                  isPrimary: addr['is_primary'] == true,
                )),

          const SizedBox(height: 8),
          GestureDetector(
            onTap: _goToAddAddress,
            child: Row(
              children: [
                const Icon(Icons.add, size: 16, color: Color(0xFF00BBA7)),
                const SizedBox(width: 4),
                Text('Tambah Alamat Lain',
                    style: GoogleFonts.inter(
                        color: const Color(0xFF00BBA7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildAddressString(Map<String, dynamic> addr) {
    final parts = <String>[];
    final full = addr['full_address'] as String? ?? '';
    final district = addr['district_name'] as String? ?? '';
    final regency = addr['regency_name'] as String? ?? '';
    final province = addr['province_name'] as String? ?? '';
    final postal = addr['postal_code'] as String? ?? '';
    if (full.isNotEmpty) parts.add(full);
    if (district.isNotEmpty) parts.add('Kec. $district');
    if (regency.isNotEmpty) parts.add(regency);
    if (province.isNotEmpty) parts.add(province);
    if (postal.isNotEmpty) parts.add(postal);
    return parts.join(', ');
  }

  Widget _buildAddressTile({
    required String addressId,
    required String label,
    required String address,
    required bool isPrimary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isPrimary
            ? const Color(0xFFF0FDFB)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPrimary
              ? const Color(0xFF00BBA7).withOpacity(0.4)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.home_outlined,
                  size: 16, color: Color(0xFF00BBA7)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Badge label
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPrimary
                                ? const Color(0xFF00BBA7)
                                : const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            label.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isPrimary
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        if (isPrimary) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.amber.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star,
                                    size: 9, color: Colors.amber[700]),
                                const SizedBox(width: 2),
                                Text('UTAMA',
                                    style: GoogleFonts.inter(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber[700])),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(address,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),

          // Action buttons
          const SizedBox(height: 8),
          Row(
            children: [
              // Tombol Jadikan Utama (hanya jika bukan primary)
              if (!isPrimary)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _setPrimaryAddress(addressId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BBA7).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                            color: const Color(0xFF00BBA7).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star_border,
                              size: 13, color: Color(0xFF00BBA7)),
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
              if (!isPrimary) const SizedBox(width: 6),
              // Tombol Hapus
              Expanded(
                child: GestureDetector(
                  onTap: () => _deleteAddress(addressId, isPrimary: isPrimary),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(7),
                      border:
                          Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_outline,
                            color: Colors.red, size: 13),
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

  // ── Set Alamat Utama ──────────────────────────────────────

  Future<void> _setPrimaryAddress(String addressId) async {
    try {
      final user = _supabase.auth.currentUser!;

      // Reset semua is_primary
      await _supabase
          .from('patient_addresses')
          .update({'is_primary': false})
          .eq('patient_id', user.id);

      // Set yang dipilih jadi primary
      await _supabase
          .from('patient_addresses')
          .update({'is_primary': true})
          .eq('id', addressId);

      // Sync ke tabel patients
      final addr =
          _extraAddresses.firstWhere((a) => a['id'] == addressId);
      await _supabase.from('patients').update({
        'province_id': addr['province_id'],
        'regency_id': addr['regency_id'],
        'district_id': addr['district_id'],
        'village_id': addr['village_id'],
        'postal_code': addr['postal_code'],
        'full_address': addr['full_address'],
      }).eq('id', user.id);

      _showSnack('Alamat utama berhasil diubah!');
      await _fetchAll();
    } catch (e) {
      _showSnack('Gagal mengubah alamat utama: $e', isError: true);
    }
  }

  // ── Hapus Alamat ──────────────────────────────────────────

  Future<void> _deleteAddress(String addressId,
      {bool isPrimary = false}) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
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
            child:
                Text('Batal', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus',
                style: GoogleFonts.inter(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _supabase
          .from('patient_addresses')
          .delete()
          .eq('id', addressId);

      // Jika alamat utama dihapus, kosongkan juga di tabel patients
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
      await _fetchAll();
    } catch (e) {
      _showSnack('Gagal menghapus: $e', isError: true);
    }
  }

  // ── DATA MEDIS ───────────────────────────────────────────

  Widget _buildSectionDataMedis() {
    final weight = _patient?['weight_kg'];
    final height = _patient?['height_cm'];
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('DATA MEDIS', Icons.favorite_border),
          _buildRow('Berat Badan',
              weight != null ? '$weight kg' : 'Tidak ada'),
          _buildRow('Tinggi Badan',
              height != null ? '$height cm' : 'Tidak ada'),
          _buildRow('Golongan Darah', _orDash(_patient?['blood_type'])),
          _buildRow('Alergi', _orDash(_patient?['allergy'])),
          _buildRow('Riwayat Penyakit',
              _orDash(_patient?['medical_history'])),
        ],
      ),
    );
  }

  // ── PENGATURAN ───────────────────────────────────────────

  Widget _buildSectionPengaturan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 4),
          child: Text('PENGATURAN & PREFERENSI',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                  letterSpacing: 0.8)),
        ),
        _buildCard(
          child: Column(
            children: [
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen()),
                ),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BBA7).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.lock_outline,
                            color: Color(0xFF00BBA7), size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ubah Password',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            Text('Secara ubah Sandi kamu',
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const Divider(height: 20, color: Color(0xFFF1F5F9)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BBA7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_none,
                          color: Color(0xFF00BBA7), size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('Notifikasi',
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    Switch(
                      value: _notifEnabled,
                      onChanged: (v) => setState(() => _notifEnabled = v),
                      activeColor: const Color(0xFF00BBA7),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildCard(
          child: InkWell(
            onTap: _logout,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.logout, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Text('Keluar dari Akun',
                        style: GoogleFonts.inter(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}