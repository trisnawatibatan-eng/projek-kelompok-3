import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';

class KelolLayananScreen extends StatefulWidget {
  const KelolLayananScreen({super.key});

  @override
  State<KelolLayananScreen> createState() => _KelolLayananScreenState();
}

class _KelolLayananScreenState extends State<KelolLayananScreen>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  final _hargaKunjunganCtrl = TextEditingController();

  late AnimationController _saveAnimCtrl;
  late Animation<double> _saveScaleAnim;

  List<_LayananFisio> _layananList = [];
  String? _fisioterapisId;       // uuid dari tabel fisioterapis
  String? _hargaKunjunganId;     // uuid row harga_kunjungan (untuk upsert)
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

      // 1. Ambil fisioterapis_id berdasarkan user_id
      final profil = await _supabase
          .from('fisioterapis')
          .select('id')
          .eq('user_id', userId)
          .single();

      _fisioterapisId = profil['id'] as String;

      // 2. Load harga kunjungan (boleh tidak ada dulu)
      final hargaRows = await _supabase
          .from('harga_kunjungan')
          .select('id, harga')
          .eq('fisioterapis_id', _fisioterapisId!)
          .maybeSingle();

      if (hargaRows != null) {
        _hargaKunjunganId = hargaRows['id'] as String;
        _hargaKunjunganCtrl.text =
            (hargaRows['harga'] as num).toStringAsFixed(0);
      } else {
        _hargaKunjunganCtrl.text = '150000';
      }

      // 3. Load daftar layanan, urut sesuai kolom urutan
      final layananRows = await _supabase
          .from('layanan_fisioterapis')
          .select('id, nama_layanan, emoji, harga, urutan')
          .eq('fisioterapis_id', _fisioterapisId!)
          .eq('is_active', true)
          .order('urutan', ascending: true);

      setState(() {
        _layananList = (layananRows as List)
            .map((r) => _LayananFisio(
                  id: r['id'] as String,
                  nama: r['nama_layanan'] as String,
                  emoji: r['emoji'] as String? ?? '💊',
                  harga: (r['harga'] as num).toDouble(),
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
      // ── A. Upsert harga kunjungan ──
      final hargaVal =
          double.tryParse(_hargaKunjunganCtrl.text.trim()) ?? 0;

      if (_hargaKunjunganId != null) {
        // Sudah ada → update
        await _supabase
            .from('harga_kunjungan')
            .update({'harga': hargaVal})
            .eq('id', _hargaKunjunganId!);
      } else {
        // Belum ada → insert dan simpan id-nya
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

      // ── B. Upsert layanan ──
      // Pisahkan layanan baru vs yang sudah ada
      final layananBaru =
          _layananList.where((l) => l.isNew).toList();
      final layananLama =
          _layananList.where((l) => !l.isNew).toList();

      // Insert layanan baru
      if (layananBaru.isNotEmpty) {
        final insertPayload = layananBaru
            .asMap()
            .entries
            .map((e) => {
                  'fisioterapis_id': _fisioterapisId,
                  'nama_layanan': e.value.nama,
                  'emoji': e.value.emoji,
                  'harga': e.value.harga,
                  'urutan': layananLama.length + e.key + 1,
                })
            .toList();

        final inserted = await _supabase
            .from('layanan_fisioterapis')
            .insert(insertPayload)
            .select('id, nama_layanan, emoji, harga, urutan');

        // Ganti item isNew dengan data dari DB (dapat id asli)
        for (final row in inserted as List) {
          final idx = _layananList.indexWhere(
              (l) => l.isNew && l.nama == row['nama_layanan']);
          if (idx != -1) {
            _layananList[idx] = _LayananFisio(
              id: row['id'] as String,
              nama: row['nama_layanan'] as String,
              emoji: row['emoji'] as String? ?? '💊',
              harga: (row['harga'] as num).toDouble(),
              isNew: false,
            );
          }
        }
      }

      // Update layanan lama yang mungkin harganya berubah
      for (int i = 0; i < layananLama.length; i++) {
        final l = layananLama[i];
        await _supabase
            .from('layanan_fisioterapis')
            .update({
              'harga': l.harga,
              'nama_layanan': l.nama,
              'emoji': l.emoji,
              'urutan': i + 1,
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

  Future<void> _hapusLayanan(_LayananFisio layanan) async {
    if (layanan.isNew) {
      // Belum tersimpan di DB, cukup hapus dari list lokal
      setState(
          () => _layananList.removeWhere((l) => l.id == layanan.id));
      _showSnackbar('Layanan dihapus');
      return;
    }

    try {
      // Soft delete: set is_active = false
      await _supabase
          .from('layanan_fisioterapis')
          .update({'is_active': false})
          .eq('id', layanan.id);

      setState(
          () => _layananList.removeWhere((l) => l.id == layanan.id));
      _showSnackbar('Layanan dihapus');
    } catch (e) {
      _showSnackbar('Gagal menghapus: ${e.toString()}', isError: true);
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

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

  // ─── Actions ────────────────────────────────────────────────────────────────

  void _editLayanan(_LayananFisio layanan) {
    final ctrl =
        TextEditingController(text: layanan.harga.toStringAsFixed(0));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditLayananSheet(
        layanan: layanan,
        ctrl: ctrl,
        onSave: (newHarga) =>
            setState(() => layanan.harga = newHarga),
      ),
    );
  }

  void _showDeleteConfirm(_LayananFisio layanan) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Layanan?',
            style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w700)),
        content: Text('Yakin ingin menghapus "${layanan.nama}"?',
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
              _hapusLayanan(layanan);
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

  void _tambahLayananBaru() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TambahLayananSheet(
        onSave: (nama, harga) {
          setState(() {
            _layananList.add(_LayananFisio(
              // ID sementara, akan diganti setelah disimpan ke DB
              id: 'new_${DateTime.now().millisecondsSinceEpoch}',
              nama: nama,
              emoji: '💊',
              harga: harga,
              isNew: true,
            ));
          });
          _showSnackbar(
              'Layanan ditambahkan — tekan Simpan untuk menyimpan ke server');
        },
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

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
        child: CircularProgressIndicator(color: AppColors.primary),
      );
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
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHargaKunjunganCard(),
            const SizedBox(height: 20),
            _buildSectionLabel(
                'DAFTAR LAYANAN', '${_layananList.length} layanan'),
            const SizedBox(height: 10),
            ..._layananList.map((l) => _buildLayananTile(l)),
            const SizedBox(height: 8),
            _buildTambahButton(),
            const SizedBox(height: 20),
            _buildSimpanButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

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
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kelola Layanan',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        )),
                    Text('Edit Harga Layanan',
                        style: GoogleFonts.inter(
                            color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              // Badge jumlah layanan
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services_outlined,
                        color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text('Fisiocare',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
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
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6FAF8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.home_outlined,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FISIK KUNJUNGAN',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lightText,
                          letterSpacing: 0.5)),
                  Text('Harga biaya kunjungan ke rumah',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.secondaryText)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _hargaKunjunganCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText),
            decoration: InputDecoration(
              prefixText: 'Rp  ',
              prefixStyle: GoogleFonts.inter(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
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

  Widget _buildSectionLabel(String title, String badge) {
    return Row(
      children: [
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.lightText,
                letterSpacing: 0.5)),
        const Spacer(),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20)),
          child: Text(badge,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  // ─── Layanan Tile ────────────────────────────────────────────────────────────

  Widget _buildLayananTile(_LayananFisio layanan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          // Layanan baru (belum disimpan) diberi border berbeda
          color: layanan.isNew
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.borderColor,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE6FAF8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: Text(layanan.emoji,
                      style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(layanan.nama,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText)),
                  // Label "Baru" untuk layanan yang belum disimpan
                  if (layanan.isNew)
                    Text('Belum disimpan',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Text('Rp',
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.lightText)),
            const SizedBox(width: 4),
            Text(
              _formatRupiah(layanan.harga),
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _editLayanan(layanan),
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
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _showDeleteConfirm(layanan),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.delete_outline,
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
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('+ Tambah Layanan Baru',
                style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
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
          padding: const EdgeInsets.symmetric(vertical: 15),
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
                    fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────

class _LayananFisio {
  final String id;
  final String nama;
  final String emoji;
  double harga;

  /// true = belum pernah disimpan ke Supabase
  final bool isNew;

  _LayananFisio({
    required this.id,
    required this.nama,
    required this.emoji,
    required this.harga,
    this.isNew = false,
  });
}

// ─── Edit Layanan Sheet ───────────────────────────────────────────────────────

class _EditLayananSheet extends StatelessWidget {
  final _LayananFisio layanan;
  final TextEditingController ctrl;
  final ValueChanged<double> onSave;

  const _EditLayananSheet({
    required this.layanan,
    required this.ctrl,
    required this.onSave,
  });

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
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(layanan.emoji,
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Edit Harga',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.lightText)),
                    Text(layanan.nama,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Harga Layanan',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.secondaryText)),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            autofocus: true,
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
                    final val = double.tryParse(ctrl.text) ?? 0;
                    onSave(val);
                    Navigator.pop(context);
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
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
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
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama wajib diisi'
                  : null,
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
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Harga wajib diisi'
                  : null,
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