// lib/services/edukasi_service.dart
//
// SETUP:
// 1. Pastikan supabase_flutter sudah ada di pubspec.yaml
// 2. Pastikan Supabase sudah diinisialisasi di main.dart:
//    await Supabase.initialize(url: 'YOUR_URL', anonKey: 'YOUR_ANON_KEY');

import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class EdukasiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --------------------------------------------------
  // HELPER: ambil fisioterapis_id dari user login
  // --------------------------------------------------
  Future<String> _getFisioterapisId() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login');

    final response = await _supabase
        .from('fisioterapis')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) throw Exception('Data fisioterapis tidak ditemukan');
    return response['id'] as String;
  }

  // --------------------------------------------------
  // UNTUK EdukasiScreen (sisi PASIEN)
  // --------------------------------------------------

  /// Ambil 3 artikel unggulan terbaru (untuk horizontal scroll)
  Future<List<Map<String, dynamic>>> fetchArtikelUnggulan() async {
    final response = await _supabase
        .from('edukasi')
        .select('''
          id,
          judul,
          kategori,
          thumbnail_url,
          created_at,
          fisioterapis:fisioterapis_id (nama_lengkap, gelar)
        ''')
        .eq('is_published', true)
        .order('created_at', ascending: false)
        .limit(3);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Ambil semua edukasi yang sudah dipublikasikan
  /// Opsional: filter by kategori
  Future<List<Map<String, dynamic>>> fetchEdukasiPublished({
    String? kategori,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _supabase
        .from('edukasi')
        .select('''
          id,
          judul,
          deskripsi_singkat,
          kategori,
          thumbnail_url,
          created_at,
          fisioterapis:fisioterapis_id (nama_lengkap, gelar)
        ''')
        .eq('is_published', true);

    if (kategori != null && kategori.isNotEmpty) {
      query = query.eq('kategori', kategori);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Ambil detail lengkap satu edukasi (untuk DetailArtikelScreen)
  Future<Map<String, dynamic>?> fetchEdukasiDetail(String id) async {
    final response = await _supabase
        .from('edukasi')
        .select('''
          id,
          judul,
          deskripsi_singkat,
          konten_utama,
          kategori,
          thumbnail_url,
          lampiran_url,
          lampiran_nama,
          lampiran_ukuran_bytes,
          lampiran_tipe,
          created_at,
          fisioterapis:fisioterapis_id (nama_lengkap, gelar, foto_profil_url)
        ''')
        .eq('id', id)
        .eq('is_published', true)
        .maybeSingle();

    return response;
  }

  // --------------------------------------------------
  // UNTUK FisioterapisTambahEdukasiScreen (sisi FISIOTERAPIS)
  // --------------------------------------------------

  /// Ambil semua edukasi milik fisioterapis yang login
  Future<List<Map<String, dynamic>>> fetchEdukasiMilikSaya() async {
    final fisioterapisId = await _getFisioterapisId();

    final response = await _supabase
        .from('edukasi')
        .select('id, judul, kategori, is_published, created_at, thumbnail_url')
        .eq('fisioterapis_id', fisioterapisId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Upload thumbnail gambar ke Supabase Storage
  /// Bisa menerima File (native) atau Uint8List (web)
  /// Mengembalikan public URL thumbnail
  Future<String> uploadThumbnail(dynamic fileOrBytes, {String? filename}) async {
    final userId = _supabase.auth.currentUser?.id ?? 'unknown';
    
    // Tentukan extension berdasarkan filename atau tipe file
    String ext = 'jpg';
    if (filename != null) {
      ext = filename.split('.').last.toLowerCase();
    } else if (fileOrBytes is File) {
      ext = fileOrBytes.path.split('.').last.toLowerCase();
    }
    
    final fileName =
        'thumb_${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _supabase.storage
        .from('edukasi-thumbnails')
        .uploadBinary(
          fileName,
          fileOrBytes is Uint8List
              ? fileOrBytes
              : await (fileOrBytes as File).readAsBytes(),
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );

    return _supabase.storage
        .from('edukasi-thumbnails')
        .getPublicUrl(fileName);
  }

  /// Upload lampiran PDF/dokumen ke Supabase Storage
  /// Bisa menerima File (native) atau Uint8List (web)
  /// Mengembalikan Map berisi url, nama, ukuran, tipe
  Future<Map<String, dynamic>> uploadLampiran(dynamic fileOrBytes, {String? filename}) async {
    final userId = _supabase.auth.currentUser?.id ?? 'unknown';
    
    // Tentukan nama dan ukuran berdasarkan tipe input
    String namaAsli;
    int ukuranBytes;
    
    if (fileOrBytes is File) {
      namaAsli = fileOrBytes.path.split('/').last;
      ukuranBytes = await fileOrBytes.length();
    } else if (fileOrBytes is Uint8List) {
      namaAsli = filename ?? 'lampiran.pdf';
      ukuranBytes = fileOrBytes.length;
    } else {
      throw Exception('Tipe file tidak didukung');
    }
    
    final ext = namaAsli.split('.').last.toUpperCase();
    final storageFileName =
        'lamp_${userId}_${DateTime.now().millisecondsSinceEpoch}_$namaAsli';

    await _supabase.storage
        .from('edukasi-lampiran')
        .uploadBinary(
          storageFileName,
          fileOrBytes is Uint8List
              ? fileOrBytes
              : await (fileOrBytes as File).readAsBytes(),
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );

    final publicUrl = _supabase.storage
        .from('edukasi-lampiran')
        .getPublicUrl(storageFileName);

    return {
      'url': publicUrl,
      'nama': namaAsli,
      'ukuran_bytes': ukuranBytes,
      'tipe': ext,
    };
  }

  /// Hapus lampiran dari storage (panggil saat user tekan tombol X lampiran)
  Future<void> hapusLampiranDariStorage(String publicUrl) async {
    // Ambil nama file dari URL
    final uri = Uri.parse(publicUrl);
    final fileName = uri.pathSegments.last;
    await _supabase.storage.from('edukasi-lampiran').remove([fileName]);
  }

  /// Publikasikan edukasi baru ke database
  Future<void> publikasikanEdukasi({
    required String judul,
    required String deskripsiSingkat,
    required String kontenUtama,
    required String kategori,
    String? thumbnailUrl,
    String? lampiranUrl,
    String? lampiranNama,
    int? lampiranUkuranBytes,
    String? lampiranTipe,
  }) async {
    final fisioterapisId = await _getFisioterapisId();

    await _supabase.from('edukasi').insert({
      'fisioterapis_id': fisioterapisId,
      'judul': judul,
      'deskripsi_singkat': deskripsiSingkat,
      'konten_utama': kontenUtama,
      'kategori': kategori,
      'thumbnail_url': thumbnailUrl,
      'lampiran_url': lampiranUrl,
      'lampiran_nama': lampiranNama,
      'lampiran_ukuran_bytes': lampiranUkuranBytes,
      'lampiran_tipe': lampiranTipe,
      'is_published': true,
      'notifikasi_pasien': false,
    });
  }

  /// Simpan sebagai draft (is_published = false)
  Future<void> simpanDraft({
    required String judul,
    required String deskripsiSingkat,
    required String kontenUtama,
    required String kategori,
    String? thumbnailUrl,
  }) async {
    final fisioterapisId = await _getFisioterapisId();

    await _supabase.from('edukasi').insert({
      'fisioterapis_id': fisioterapisId,
      'judul': judul,
      'deskripsi_singkat': deskripsiSingkat,
      'konten_utama': kontenUtama,
      'kategori': kategori,
      'thumbnail_url': thumbnailUrl,
      'is_published': false,
    });
  }

  /// Hapus edukasi beserta file-nya dari storage
  Future<void> hapusEdukasi(String id) async {
    // Ambil data dulu untuk tahu URL file yang perlu dihapus
    final data = await _supabase
        .from('edukasi')
        .select('thumbnail_url, lampiran_url')
        .eq('id', id)
        .maybeSingle();

    if (data != null) {
      // Hapus thumbnail dari storage
      if (data['thumbnail_url'] != null) {
        final thumbName = Uri.parse(data['thumbnail_url']).pathSegments.last;
        await _supabase.storage
            .from('edukasi-thumbnails')
            .remove([thumbName]);
      }
      // Hapus lampiran dari storage
      if (data['lampiran_url'] != null) {
        final lampName = Uri.parse(data['lampiran_url']).pathSegments.last;
        await _supabase.storage.from('edukasi-lampiran').remove([lampName]);
      }
    }

    // Hapus record dari database
    await _supabase.from('edukasi').delete().eq('id', id);
  }
}