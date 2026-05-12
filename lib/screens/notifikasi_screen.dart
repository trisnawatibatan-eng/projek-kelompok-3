import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import 'edukasi_screen.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String _filterType = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat notifikasi: $e',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredNotifications() {
    if (_filterType == 'Semua') {
      return _notifications;
    }
    return _notifications
        .where((n) => n['type'] == _filterType)
        .toList();
  }

  List<Map<String, dynamic>> _getTodayNotifications() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _getFilteredNotifications().where((n) {
      final createdAt = DateTime.parse(n['created_at'] as String? ?? '');
      final notifDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
      return notifDate == today;
    }).toList();
  }

  List<Map<String, dynamic>> _getYesterdayNotifications() {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    return _getFilteredNotifications().where((n) {
      final createdAt = DateTime.parse(n['created_at'] as String? ?? '');
      final notifDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
      return notifDate == yesterday;
    }).toList();
  }

  List<Map<String, dynamic>> _getOlderNotifications() {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    return _getFilteredNotifications().where((n) {
      final createdAt = DateTime.parse(n['created_at'] as String? ?? '');
      final notifDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
      return notifDate.isBefore(yesterday);
    }).toList();
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
      await _loadNotifications();
    } catch (e) {
      // Silent fail
    }
  }

  IconData _getIconFromType(String? type) {
    switch (type) {
      case 'jadwal':
        return Icons.calendar_today;
      case 'medis':
        return Icons.assignment_turned_in_outlined;
      case 'edukasi':
        return Icons.lightbulb_outline;
      case 'pembayaran':
        return Icons.payment;
      case 'pesan':
        return Icons.message;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getColorFromType(String? type) {
    switch (type) {
      case 'jadwal':
        return Colors.blue;
      case 'medis':
        return Colors.teal;
      case 'edukasi':
        return Colors.orange;
      case 'pembayaran':
        return Colors.green;
      case 'pesan':
        return const Color(0xFF6366F1);
      default:
        return AppColors.primary;
    }
  }

  String _getTypeLabel(String? type) {
    switch (type) {
      case 'jadwal':
        return 'Jadwal';
      case 'medis':
        return 'Medis';
      case 'edukasi':
        return 'Edukasi';
      case 'pembayaran':
        return 'Pembayaran';
      case 'pesan':
        return 'Pesan';
      default:
        return 'Notifikasi';
    }
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m lalu';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h lalu';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '-';
    }
  }

  void _handleNotificationTap(String? type, String? id) {
    if (id != null) {
      _markAsRead(id);
    }

    switch (type) {
      case 'jadwal':
        Navigator.pop(context, 2); // Kembali ke tab janji temu
        break;
      case 'medis':
        Navigator.pop(context, 3); // Kembali ke tab laporan
        break;
      case 'edukasi':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EdukasiScreen()),
        );
        break;
      default:
        break;
    }
  }

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
        title: Text(
          'Notifikasi Pasien',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadNotifications,
              child: Column(
                children: [
                  _buildFilterTabs(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      children: [
                        if (_getTodayNotifications().isNotEmpty) ...[
                          _buildSectionHeader('Hari Ini'),
                          ..._getTodayNotifications().map((notif) =>
                              _buildNotificationItem(
                                context: context,
                                notification: notif,
                              )),
                          const SizedBox(height: 20),
                        ],
                        if (_getYesterdayNotifications().isNotEmpty) ...[
                          _buildSectionHeader('Kemarin'),
                          ..._getYesterdayNotifications().map((notif) =>
                              _buildNotificationItem(
                                context: context,
                                notification: notif,
                              )),
                          const SizedBox(height: 20),
                        ],
                        if (_getOlderNotifications().isNotEmpty) ...[
                          _buildSectionHeader('Lebih Lama'),
                          ..._getOlderNotifications().map((notif) =>
                              _buildNotificationItem(
                                context: context,
                                notification: notif,
                              )),
                          const SizedBox(height: 20),
                        ],
                        if (_getFilteredNotifications().isEmpty)
                          _buildEmptyState(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14, 
          fontWeight: FontWeight.bold, 
          color: Colors.grey.shade700
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filterTypes = ['Semua', 'jadwal', 'medis', 'edukasi'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filterTypes.map((type) {
            final isSelected = _filterType == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  setState(() => _filterType = type);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00BBA7)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type == 'Semua' ? type : _getTypeLabel(type),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required BuildContext context,
    required Map<String, dynamic> notification,
  }) {
    final isUnread = notification['is_read'] == false;
    final type = notification['type'] as String?;
    final judul = notification['judul'] as String? ?? 'Notifikasi';
    final pesan = notification['pesan'] as String? ?? '';
    final createdAt = notification['created_at'] as String?;
    final id = notification['id'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _handleNotificationTap(type, id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isUnread ? const Color(0xFFF0F9F8) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread
                  ? const Color(0xFF00BBA7).withOpacity(0.3)
                  : Colors.grey.shade100
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getColorFromType(type).withOpacity(0.1), 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Icon(_getIconFromType(type),
                    color: _getColorFromType(type), size: 22),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200, 
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text(
                            _getTypeLabel(type), 
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54
                            )
                          ),
                        ),
                        Text(_formatTime(createdAt),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      judul, 
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87
                      )
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pesan, 
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.4
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada notifikasi',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda akan menerima notifikasi terbaru di sini',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }