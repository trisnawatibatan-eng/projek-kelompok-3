import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../widgets/fisioterapis_bottom_navbar.dart';
import 'fisioterapis_dashboard_screen.dart';
import 'fisioterapis_jadwal_praktik.dart';
import 'fisioterapis_pasien_tab.dart';
import 'fisioterapis_profil_tab.dart';

class FisioterapisNotifikasiScreen extends StatefulWidget {
  const FisioterapisNotifikasiScreen({super.key});

  @override
  State<FisioterapisNotifikasiScreen> createState() =>
      _FisioterapisNotifikasiScreenState();
}

class _FisioterapisNotifikasiScreenState
    extends State<FisioterapisNotifikasiScreen> {
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
      case 'booking':
        return Icons.calendar_today;
      case 'review':
        return Icons.star_outline;
      case 'pembayaran':
        return Icons.payment;
      case 'pesan':
        return Icons.message;
      case 'sistem':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getColorFromType(String? type) {
    switch (type) {
      case 'booking':
        return Colors.blue;
      case 'review':
        return const Color(0xFFF59E0B);
      case 'pembayaran':
        return Colors.green;
      case 'pesan':
        return const Color(0xFF6366F1);
      case 'sistem':
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  String _getTypeLabel(String? type) {
    switch (type) {
      case 'booking':
        return 'Booking';
      case 'review':
        return 'Review';
      case 'pembayaran':
        return 'Pembayaran';
      case 'pesan':
        return 'Pesan';
      case 'sistem':
        return 'Sistem';
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

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const FisioterapisDashboardScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const JadwalPraktikScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const FisioterapisPasienTab(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => FisioterapisProfilTab(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      bottomNavigationBar: FisioterapisBottomNavbar(
        currentIndex: 0,
        onTap: _onNavTap,
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBA7),
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Notifikasi',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadNotifications,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildFilterTabs(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_getTodayNotifications().isNotEmpty) ...[
                            _buildSectionHeader('Hari Ini'),
                            ..._getTodayNotifications().map((notif) =>
                                _buildNotificationItem(notif)),
                            const SizedBox(height: 16),
                          ],
                          if (_getYesterdayNotifications().isNotEmpty) ...[
                            _buildSectionHeader('Kemarin'),
                            ..._getYesterdayNotifications().map((notif) =>
                                _buildNotificationItem(notif)),
                            const SizedBox(height: 16),
                          ],
                          if (_getOlderNotifications().isNotEmpty) ...[
                            _buildSectionHeader('Lebih Lama'),
                            ..._getOlderNotifications().map((notif) =>
                                _buildNotificationItem(notif)),
                            const SizedBox(height: 16),
                          ],
                          if (_getFilteredNotifications().isEmpty)
                            _buildEmptyState(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFilterTabs() {
    final filterTypes = ['Semua', 'booking', 'review', 'pembayaran', 'pesan'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderColor,
                    ),
                  ),
                  child: Text(
                    type == 'Semua' ? type : _getTypeLabel(type),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.primaryText,
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryText,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final isUnread = notification['is_read'] == false;
    final type = notification['type'] as String?;
    final judul = notification['judul'] as String? ?? 'Notifikasi';
    final pesan = notification['pesan'] as String? ?? '';
    final createdAt = notification['created_at'] as String?;
    final id = notification['id'] as String?;

    return InkWell(
      onTap: () {
        if (id != null) {
          _markAsRead(id);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFF0F9F8) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.borderColor,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getColorFromType(type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconFromType(type),
                color: _getColorFromType(type),
                size: 18,
              ),
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
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getColorFromType(type).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getTypeLabel(type),
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _getColorFromType(type),
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: AppColors.lightText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    judul,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  if (pesan.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      pesan,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.lightText,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ],
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
              color: AppColors.lightText,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada notifikasi',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda akan menerima notifikasi terbaru di sini',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
