import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import 'edukasi_screen.dart';

/// Screen notifikasi khusus PASIEN
/// Tipe notifikasi: jadwal, medis, edukasi, pembayaran, pesan, booking_cancelled
class NotifikasiPasienScreen extends StatefulWidget {
  const NotifikasiPasienScreen({super.key});

  @override
  State<NotifikasiPasienScreen> createState() => _NotifikasiPasienScreenState();
}

class _NotifikasiPasienScreenState extends State<NotifikasiPasienScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String _filterType = 'Semua';

  // Filter yang relevan untuk pasien
  static const _filterTypes = [
    'Semua',
    'jadwal',
    'medis',
    'edukasi',
    'pembayaran',
    'booking_cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // ── Data ─────────────────────────────────────────────────────

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final data = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Gagal memuat notifikasi: $e');
      }
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
      await _loadNotifications();
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
      await _loadNotifications();
    } catch (e) {
      _showError('Gagal menandai semua: $e');
    }
  }

  // ── Filter helpers ────────────────────────────────────────────

  List<Map<String, dynamic>> get _filtered {
    if (_filterType == 'Semua') return _notifications;
    return _notifications.where((n) => n['type'] == _filterType).toList();
  }

  List<Map<String, dynamic>> _byDay(int daysAgo) {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day - daysAgo);
    return _filtered.where((n) {
      final d = DateTime.parse(n['created_at'] as String);
      final nd = DateTime(d.year, d.month, d.day);
      return nd == target;
    }).toList();
  }

  List<Map<String, dynamic>> get _older {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    return _filtered.where((n) {
      final d = DateTime.parse(n['created_at'] as String);
      return DateTime(d.year, d.month, d.day).isBefore(yesterday);
    }).toList();
  }

  int get _unreadCount => _notifications.where((n) => n['is_read'] == false).length;

  // ── Helpers tipe notifikasi ───────────────────────────────────

  IconData _iconFor(String? type) {
    switch (type) {
      case 'jadwal': return Icons.calendar_today;
      case 'medis': return Icons.assignment_turned_in_outlined;
      case 'edukasi': return Icons.lightbulb_outline;
      case 'pembayaran': return Icons.payment;
      case 'pesan': return Icons.message;
      case 'booking_cancelled': return Icons.cancel_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color _colorFor(String? type) {
    switch (type) {
      case 'jadwal': return Colors.blue;
      case 'medis': return Colors.teal;
      case 'edukasi': return Colors.orange;
      case 'pembayaran': return Colors.green;
      case 'pesan': return const Color(0xFF6366F1);
      case 'booking_cancelled': return Colors.red;
      default: return AppColors.primary;
    }
  }

  String _labelFor(String? type) {
    switch (type) {
      case 'jadwal': return 'Jadwal';
      case 'medis': return 'Medis';
      case 'edukasi': return 'Edukasi';
      case 'pembayaran': return 'Pembayaran';
      case 'pesan': return 'Pesan';
      case 'booking_cancelled': return 'Dibatalkan';
      default: return 'Info';
    }
  }

  String _timeAgo(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
      if (diff.inHours < 24) return '${diff.inHours}j lalu';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '-';
    }
  }

  void _onTap(Map<String, dynamic> notif) {
    final id = notif['id'] as String?;
    final type = notif['type'] as String?;
    if (id != null) _markAsRead(id);

    switch (type) {
      case 'jadwal':
      case 'booking_cancelled':
        Navigator.pop(context, 2);
        break;
      case 'medis':
        Navigator.pop(context, 3);
        break;
      case 'edukasi':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const EdukasiScreen()));
        break;
      default:
        break;
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBA7),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifikasi',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text('Baca Semua',
                  style: GoogleFonts.inter(
                      color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadNotifications,
              child: Column(
                children: [
                  // Badge unread
                  if (_unreadCount > 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      color: const Color(0xFFE0F2F1),
                      child: Text(
                        '$_unreadCount notifikasi belum dibaca',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF00897B),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  _buildFilterTabs(),
                  Expanded(
                    child: _filtered.isEmpty
                        ? _buildEmpty()
                        : ListView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            children: [
                              if (_byDay(0).isNotEmpty) ...[
                                _sectionHeader('Hari Ini'),
                                ..._byDay(0).map(_buildItem),
                              ],
                              if (_byDay(1).isNotEmpty) ...[
                                _sectionHeader('Kemarin'),
                                ..._byDay(1).map(_buildItem),
                              ],
                              if (_older.isNotEmpty) ...[
                                _sectionHeader('Lebih Lama'),
                                ..._older.map(_buildItem),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterTypes.map((type) {
            final active = _filterType == type;
            final label = type == 'Semua' ? 'Semua' : _labelFor(type);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _filterType = type),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF00BBA7)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(label,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color:
                              active ? Colors.white : Colors.grey.shade600,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
        child: Text(title,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700)),
      );

  Widget _buildItem(Map<String, dynamic> notif) {
    final isUnread = notif['is_read'] == false;
    final type = notif['type'] as String?;
    final judul = notif['judul'] as String? ?? 'Notifikasi';
    final pesan = notif['pesan'] as String? ?? '';
    final createdAt = notif['created_at'] as String?;

    return GestureDetector(
      onTap: () => _onTap(notif),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFF0F9F8) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread
                ? const Color(0xFF00BBA7).withOpacity(0.3)
                : Colors.grey.shade100,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon tipe
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _colorFor(type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_iconFor(type), color: _colorFor(type), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _colorFor(type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(_labelFor(type),
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _colorFor(type))),
                      ),
                      Row(children: [
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                                color: Color(0xFF00BBA7),
                                shape: BoxShape.circle),
                          ),
                        Text(_timeAgo(createdAt),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(judul,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 3),
                  Text(pesan,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                          height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(children: [
            Icon(Icons.notifications_none_outlined,
                size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Tidak ada notifikasi',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text('Notifikasi terbaru akan muncul di sini',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey.shade500)),
          ]),
        ),
      );
}