// fisioterapis_kelola_layanan_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import 'fisioterapis_tambah_layanan_screen.dart';

class FisioterapisKelolaLayananScreen extends StatefulWidget {
  const FisioterapisKelolaLayananScreen({super.key});

  @override
  State<FisioterapisKelolaLayananScreen> createState() =>
      _FisioterapisKelolaLayananScreenState();
}

class _FisioterapisKelolaLayananScreenState
    extends State<FisioterapisKelolaLayananScreen>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  final _hargaKunjunganCtrl = TextEditingController();

  late AnimationController _saveAnimCtrl;
  late Animation<double> _saveScaleAnim;

  List<_ServiceItem> _serviceList = [];
  String? _fisioterapisId;
  String? _fisioterapisNama;
  String? _hargaKunjunganId;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMsg;

  // ─── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _saveAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _saveScaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _saveAnimCtrl, curve: Curves.easeInOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _hargaKunjunganCtrl.dispose();
    _saveAnimCtrl.dispose();
    super.dispose();
  }

  // ─── Supabase: Load ──────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User belum login');

      // 1. Ambil data fisioterapis (id + nama)
      final profil = await _supabase
          .from('fisioterapis')
          .select('id, nama_lengkap')
          .eq('user_id', userId)
          .single();

      _fisioterapisId = profil['id'] as String;
      _fisioterapisNama = profil['nama_lengkap'] as String? ?? 'Fisioterapis';

      // 2. Load harga kunjungan dari tabel harga_kunjungan
      final hargaRow = await _supabase
          .from('harga_kunjungan')
          .select('id, harga')
          .eq('fisioterapis_id', _fisioterapisId!)
          .maybeSingle();

      if (hargaRow != null) {
        _hargaKunjunganId = hargaRow['id'] as String;
        _hargaKunjunganCtrl.text =
            (hargaRow['harga'] as num).toStringAsFixed(0);
      } else {
        _hargaKunjunganCtrl.text = '';
      }

      // 3. Load daftar layanan dari tabel services
      final servicesRows = await _supabase
          .from('services')
          .select('id, nama_layanan, harga, deskripsi, durasi_menit, is_active')
          .eq('fisioterapis_id', _fisioterapisId!)
          .eq('is_active', true)
          .order('created_at', ascending: true);

      setState(() {
        _serviceList = (servicesRows as List)
            .map((r) => _ServiceItem(
                  id: r['id'] as String,
                  namaLayanan: r['nama_layanan'] as String,
                  harga: (r['harga'] as num).toDouble(),
                  deskripsi: r['deskripsi'] as String?,
                  durasiMenit: r['durasi_menit'] as int?,
                  isNew: false,
                ))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Gagal memuat data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // ─── Supabase: Simpan ────────────────────────────────────────────────────────

  Future<void> _simpanPerubahan() async {
    if (_fisioterapisId == null) return;
    setState(() => _isSaving = true);

    try {
      // ── A. Upsert harga kunjungan ke tabel harga_kunjungan ──
      final hargaVal =
          double.tryParse(_hargaKunjunganCtrl.text.trim()) ?? 0;

      if (_hargaKunjunganId != null) {
        await _supabase
            .from('harga_kunjungan')
            .update({'harga': hargaVal})
            .eq('id', _hargaKunjunganId!);
      } else {
        final inserted = await _supabase
            .from('harga_kunjungan')
            .insert({
              'fisioterapis_id': _fisioterapisId,
              'harga': hargaVal,
            })
            .select('id')
            .single();
        _hargaKunjunganId = inserted['id'] as String;
      }

      // ── B. Insert layanan baru ke tabel services ──
      final layananBaru = _serviceList.where((l) => l.isNew).toList();
      final layananLama = _serviceList.where((l) => !l.isNew).toList();

      if (layananBaru.isNotEmpty) {
        final insertPayload = layananBaru
            .map((l) => {
                  'fisioterapis_id': _fisioterapisId,
                  'nama_layanan': l.namaLayanan,
                  'harga': l.harga,
                  if (l.deskripsi != null) 'deskripsi': l.deskripsi,
                  if (l.durasiMenit != null) 'durasi_menit': l.durasiMenit,
                  'is_active': true,
                })
            .toList();

        final inserted = await _supabase
            .from('services')
            .insert(insertPayload)
            .select('id, nama_layanan, harga, deskripsi, durasi_menit');

        // Ganti isNew item dengan data dari DB
        for (final row in inserted as List) {
          final idx = _serviceList.indexWhere(
              (l) => l.isNew && l.namaLayanan == row['nama_layanan']);
          if (idx != -1) {
            _serviceList[idx] = _ServiceItem(
              id: row['id'] as String,
              namaLayanan: row['nama_layanan'] as String,
              harga: (row['harga'] as num).toDouble(),
              deskripsi: row['deskripsi'] as String?,
              durasiMenit: row['durasi_menit'] as int?,
              isNew: false,
            );
          }
        }
      }

      // ── C. Update layanan lama yang harganya berubah ──
      for (final l in layananLama) {
        await _supabase
            .from('services')
            .update({
              'nama_layanan': l.namaLayanan,
              'harga': l.harga,
              if (l.deskripsi != null) 'deskripsi': l.deskripsi,
              if (l.durasiMenit != null) 'durasi_menit': l.durasiMenit,
            })
            .eq('id', l.id);
      }

      if (mounted) {
        setState(() => _isSaving = false);
        _showSnackbar('Perubahan berhasil disimpan!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnackbar('Gagal menyimpan: ${e.toString()}', isError: true);
      }
    }
  }

  // ─── Supabase: Hapus ─────────────────────────────────────────────────────────

  Future<void> _hapusLayanan(_ServiceItem item) async {
    if (item.isNew) {
      setState(() => _serviceList.removeWhere((l) => l.id == item.id));
      _showSnackbar('Layanan dihapus');
      return;
    }
    try {
      // Hard delete: hapus langsung dari database
      await _supabase
          .from('services')
          .delete()
          .eq('id', item.id);
      setState(() => _serviceList.removeWhere((l) => l.id == item.id));
      _showSnackbar('Layanan dihapus');
    } catch (e) {
      _showSnackbar('Gagal menghapus: ${e.toString()}', isError: true);
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  String _formatRupiah(double val) {
    final s = val.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count != 0 && count % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join('');
  }

  /// Ambil 2 inisial dari nama lengkap
  String _getInitials(String nama) {
    final parts = nama.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nama.isNotEmpty ? nama[0].toUpperCase() : 'F';
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(msg,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.errorRed : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─── Actions ─────────────────────────────────────────────────────────────────

  void _editLayanan(_ServiceItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditLayananSheet(
        item: item,
        onSave: (newNama, newHarga, newDeskripsi, newDurasi) => setState(() {
          item.namaLayanan = newNama;
          item.harga = newHarga;
          item.deskripsi = newDeskripsi;
          item.durasiMenit = newDurasi;
        }),
        onDelete: () => _hapusLayanan(item),
      ),
    );
  }

  void _showDeleteConfirm(_ServiceItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Layanan?',
            style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w700)),
        content: Text('Yakin ingin menghapus "${item.namaLayanan}"?',
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.secondaryText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style:
                    GoogleFonts.inter(color: AppColors.lightText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _hapusLayanan(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Hapus',
                style:
                    GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _tambahLayananBaru() {
    if (_fisioterapisId == null || _fisioterapisNama == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FisioterapisTambahLayananScreen(
          fisioterapisId: _fisioterapisId!,
          fisioterapisNama: _fisioterapisNama!,
        ),
      ),
    ).then((result) {
      // Refresh data jika berhasil menambahkan layanan
      if (result == true) {
        _loadData();
      }
    });
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_errorMsg != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_outlined,
                  size: 48, color: AppColors.lightText),
              const SizedBox(height: 12),
              Text(_errorMsg!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.secondaryText)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, size: 16),
                label: Text('Coba Lagi',
                    style:
                        GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHargaKunjunganCard(),
            const SizedBox(height: 20),
            _buildSectionLabel('DAFTAR LAYANAN'),
            const SizedBox(height: 10),
            ..._serviceList.map((l) => _buildLayananTile(l)),
            const SizedBox(height: 8),
            _buildTambahButton(),
            const SizedBox(height: 16),
            _buildSimpanButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

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
            // Row atas: back button + judul
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
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
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kelola Layanan',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      Text('Edit Harga Layanan',
                          style: GoogleFonts.inter(
                              color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),

            // Card nama fisioterapis
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    // Avatar inisial
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(_fisioterapisNama ?? 'F'),
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _fisioterapisNama ?? 'Fisioterapis',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Harga Kunjungan Card ────────────────────────────────────────────────────

  Widget _buildHargaKunjunganCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EDIT HARGA KUNJUNGAN',
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightText,
                  letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Text('Harga kunjungan *',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _hargaKunjunganCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText),
            decoration: InputDecoration(
              hintText: 'Rp 50.000',
              hintStyle: GoogleFonts.inter(
                  color: AppColors.lightText, fontSize: 13),
              filled: true,
              fillColor: AppColors.scaffoldBg,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Label ───────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String title) {
    return Row(
      children: [
        const Icon(Icons.star_border_rounded,
            size: 14, color: AppColors.lightText),
        const SizedBox(width: 6),
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.lightText,
                letterSpacing: 0.5)),
      ],
    );
  }

  // ─── Layanan Tile ────────────────────────────────────────────────────────────

  Widget _buildLayananTile(_ServiceItem item) {
    // Icon berdasarkan nama layanan
    IconData iconData = Icons.medical_services_outlined;
    Color iconColor = const Color(0xFF6C8EBD);
    Color iconBg = const Color(0xFFEDF2FB);

    final nama = item.namaLayanan.toLowerCase();
    if (nama.contains('stroke') || nama.contains('saraf')) {
      iconData = Icons.psychology_outlined;
      iconColor = const Color(0xFF9B59B6);
      iconBg = const Color(0xFFF5EEF8);
    } else if (nama.contains('fraktur') || nama.contains('tulang')) {
      iconData = Icons.accessibility_new_outlined;
      iconColor = const Color(0xFF5D6D7E);
      iconBg = const Color(0xFFF0F3F4);
    } else if (nama.contains('nyeri') || nama.contains('sendi')) {
      iconData = Icons.self_improvement_outlined;
      iconColor = const Color(0xFFE67E22);
      iconBg = const Color(0xFFFEF9E7);
    } else if (nama.contains('anak') || nama.contains('pediatri')) {
      iconData = Icons.child_care_outlined;
      iconColor = const Color(0xFF27AE60);
      iconBg = const Color(0xFFEAF7EE);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isNew
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.borderColor,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Ikon layanan
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            // Nama layanan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.namaLayanan,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText)),
                  if (item.deskripsi != null && item.deskripsi!.isNotEmpty)
                    Text(item.deskripsi!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.lightText,
                            fontWeight: FontWeight.w400)),
                  if (item.durasiMenit != null)
                    Text('${item.durasiMenit} menit',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.lightText,
                            fontWeight: FontWeight.w400)),
                  if (item.isNew)
                    Text('Belum disimpan',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            // Harga
            Text('Rp',
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.lightText)),
            const SizedBox(width: 4),
            Text(
              _formatRupiah(item.harga),
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText),
            ),
            const SizedBox(width: 8),
            // Tombol Edit
            GestureDetector(
              onTap: () => _editLayanan(item),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_outlined,
                    color: AppColors.primary, size: 16),
              ),
            ),
            const SizedBox(width: 8),
            // Tombol Hapus
            GestureDetector(
              onTap: () => _showDeleteConfirm(item),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline,
                    color: AppColors.errorRed, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Tambah Button ───────────────────────────────────────────────────────────

  Widget _buildTambahButton() {
    return GestureDetector(
      onTap: _tambahLayananBaru,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.5),
            width: 1.5,
            // Simulasi dashed dengan border biasa
            // Untuk dashed border sesungguhnya gunakan package 'dashed_border'
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.add,
                  color: AppColors.primary, size: 14),
            ),
            const SizedBox(width: 8),
            Text('Tambah Layanan Baru',
                style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // ─── Simpan Button ───────────────────────────────────────────────────────────

  Widget _buildSimpanButton() {
    return ScaleTransition(
      scale: _saveScaleAnim,
      child: GestureDetector(
        onTapDown: _isSaving ? null : (_) => _saveAnimCtrl.forward(),
        onTapUp: _isSaving
            ? null
            : (_) {
                _saveAnimCtrl.reverse();
                _simpanPerubahan();
              },
        onTapCancel: () => _saveAnimCtrl.reverse(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isSaving
                  ? [Colors.grey.shade400, Colors.grey.shade500]
                  : const [Color(0xFF00BBA7), Color(0xFF009689)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isSaving
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSaving)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              else
                const Icon(Icons.save_outlined,
                    color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────

class _ServiceItem {
  final String id;
  String namaLayanan;
  double harga;
  String? deskripsi;
  int? durasiMenit;
  final bool isNew;

  _ServiceItem({
    required this.id,
    required this.namaLayanan,
    required this.harga,
    this.deskripsi,
    this.durasiMenit,
    this.isNew = false,
  });
}

// ─── Edit Layanan Sheet ───────────────────────────────────────────────────────

class _EditLayananSheet extends StatefulWidget {
  final _ServiceItem item;
  final Function(String nama, double harga, String? deskripsi, int? durasi)
      onSave;
  final VoidCallback onDelete;

  const _EditLayananSheet({
    required this.item,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_EditLayananSheet> createState() => _EditLayananSheetState();
}

class _EditLayananSheetState extends State<_EditLayananSheet> {
  late TextEditingController _namaCtrl;
  late TextEditingController _hargaCtrl;
  late TextEditingController _deskripsiCtrl;
  late TextEditingController _durasiCtrl;

  @override
  void initState() {
    super.initState();
    _namaCtrl =
        TextEditingController(text: widget.item.namaLayanan);
    _hargaCtrl =
        TextEditingController(text: widget.item.harga.toStringAsFixed(0));
    _deskripsiCtrl =
        TextEditingController(text: widget.item.deskripsi ?? '');
    _durasiCtrl = TextEditingController(
        text: widget.item.durasiMenit?.toString() ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _hargaCtrl.dispose();
    _deskripsiCtrl.dispose();
    _durasiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Edit Layanan',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirm();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: AppColors.errorRed, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Nama Layanan *',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.secondaryText)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _namaCtrl,
              autofocus: true,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.scaffoldBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5)),
              ),
            ),
            const SizedBox(height: 12),
            Text('Deskripsi',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.secondaryText)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _deskripsiCtrl,
              maxLines: 3,
              style: GoogleFonts.inter(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Jelaskan detail layanan...',
                hintStyle: GoogleFonts.inter(
                    color: AppColors.lightText, fontSize: 12),
                filled: true,
                fillColor: AppColors.scaffoldBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5)),
              ),
            ),
            const SizedBox(height: 12),
            Text('Harga Layanan *',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.secondaryText)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _hargaCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                prefixText: 'Rp  ',
                prefixStyle: GoogleFonts.inter(
                    color: AppColors.secondaryText, fontSize: 14),
                filled: true,
                fillColor: AppColors.scaffoldBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5)),
              ),
            ),
            const SizedBox(height: 12),
            Text('Durasi Layanan (Menit)',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.secondaryText)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _durasiCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: '60',
                hintStyle: GoogleFonts.inter(
                    color: AppColors.lightText, fontSize: 12),
                suffixText: 'menit',
                suffixStyle: GoogleFonts.inter(
                    color: AppColors.secondaryText, fontSize: 11),
                filled: true,
                fillColor: AppColors.scaffoldBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Batal',
                        style: GoogleFonts.inter(
                            color: AppColors.lightText,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final nama = _namaCtrl.text.trim();
                      final harga = double.tryParse(_hargaCtrl.text) ?? 0;
                      final deskripsi = _deskripsiCtrl.text.trim().isEmpty
                          ? null
                          : _deskripsiCtrl.text.trim();
                      final durasi = _durasiCtrl.text.trim().isEmpty
                          ? null
                          : int.tryParse(_durasiCtrl.text.trim());

                      if (nama.isNotEmpty && harga > 0) {
                        widget.onSave(nama, harga, deskripsi, durasi);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Simpan',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Layanan?',
            style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w700)),
        content: Text('Yakin ingin menghapus layanan ini?',
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.secondaryText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.inter(color: AppColors.lightText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Hapus',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Tambah Layanan Sheet ─────────────────────────────────────────────────────

class _TambahLayananSheet extends StatefulWidget {
  final Function(String nama, double harga) onSave;

  const _TambahLayananSheet({required this.onSave});

  @override
  State<_TambahLayananSheet> createState() => _TambahLayananSheetState();
}

class _TambahLayananSheetState extends State<_TambahLayananSheet> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();

  @override
  void dispose() {
    _namaCtrl.dispose();
    _hargaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20)),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tambah Layanan Baru',
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Text('Nama Layanan',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.secondaryText)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _namaCtrl,
              autofocus: true,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Contoh: Terapi Kaki',
                hintStyle:
                    GoogleFonts.inter(color: AppColors.lightText),
                filled: true,
                fillColor: AppColors.scaffoldBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.errorRed)),
              ),
            ),
            const SizedBox(height: 12),
            Text('Harga Layanan',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.secondaryText)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _hargaCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                prefixText: 'Rp  ',
                prefixStyle: GoogleFonts.inter(
                    color: AppColors.secondaryText, fontSize: 14),
                hintText: '0',
                hintStyle:
                    GoogleFonts.inter(color: AppColors.lightText),
                filled: true,
                fillColor: AppColors.scaffoldBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.errorRed)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Batal',
                        style: GoogleFonts.inter(
                            color: AppColors.lightText,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final harga =
                            double.tryParse(_hargaCtrl.text) ?? 0;
                        widget.onSave(_namaCtrl.text.trim(), harga);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Tambah',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}