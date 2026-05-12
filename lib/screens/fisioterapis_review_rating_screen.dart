import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../widgets/fisioterapis_bottom_navbar.dart';
import 'fisioterapis_dashboard_screen.dart';
import 'fisioterapis_jadwal_praktik.dart';
import 'fisioterapis_pasien_tab.dart';
import 'fisioterapis_profil_tab.dart';

class FisioterapisReviewRatingScreen extends StatefulWidget {
  final String? fisioterapisId;
  const FisioterapisReviewRatingScreen({super.key, this.fisioterapisId});

  @override
  State<FisioterapisReviewRatingScreen> createState() =>
      _FisioterapisReviewRatingScreenState();
}

class _FisioterapisReviewRatingScreenState
    extends State<FisioterapisReviewRatingScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  double _averageRating = 0.0;
  String _filterRating = 'Semua Rating';
  String _sortBy = 'Terbaru';
  int _totalPasien = 0;
  double _repeatRate = 0.0;
  double _avgSessions = 0.0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Get fisioterapis ID from current user
      final fisioData = await _supabase
          .from('fisioterapis')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (fisioData == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final fisioId = fisioData['id'];

      // Load reviews for this fisioterapis
      final reviewsData = await _supabase
          .from('reviews')
          .select('''
            id,
            rating,
            komentar,
            created_at,
            patient_id,
            booking_id
          ''')
          .eq('fisioterapis_id', fisioId)
          .order('created_at', ascending: false);

      // Load additional statistics
      final bookingsData = await _supabase
          .from('bookings')
          .select('patient_id')
          .eq('fisioterapis_id', fisioId);

      if (mounted) {
        setState(() {
          _reviews = List<Map<String, dynamic>>.from(reviewsData);
          _calculateAverageRating();
          _totalPasien = bookingsData.length > 0
              ? Set.from(bookingsData.map((b) => b['patient_id'])).length
              : 0;
          _repeatRate = _calculateRepeatRate(bookingsData);
          _avgSessions = _calculateAvgSessions(bookingsData);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat ulasan: $e',
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

  double _calculateRepeatRate(List<dynamic> bookings) {
    if (bookings.isEmpty) return 0.0;
    final patientBookingCounts = <String, int>{};
    for (var booking in bookings) {
      final patientId = booking['patient_id'] as String;
      patientBookingCounts[patientId] = (patientBookingCounts[patientId] ?? 0) + 1;
    }
    final repeatCount = patientBookingCounts.values
        .where((count) => count > 1)
        .length;
    return (repeatCount / patientBookingCounts.length * 100);
  }

  double _calculateAvgSessions(List<dynamic> bookings) {
    if (bookings.isEmpty) return 0.0;
    final patientBookingCounts = <String, int>{};
    for (var booking in bookings) {
      final patientId = booking['patient_id'] as String;
      patientBookingCounts[patientId] = (patientBookingCounts[patientId] ?? 0) + 1;
    }
    final totalSessions = patientBookingCounts.values.fold<int>(
        0, (sum, count) => sum + count);
    return totalSessions / patientBookingCounts.length;
  }

  List<Map<String, dynamic>> _getFilteredReviews() {
    List<Map<String, dynamic>> filtered = _reviews;

    if (_filterRating != 'Semua Rating') {
      final rating = int.tryParse(_filterRating.split(' ')[0]) ?? 0;
      filtered = filtered.where((r) => r['rating'] == rating).toList();
    }

    if (_sortBy == 'Terbaru') {
      filtered.sort((a, b) =>
          DateTime.parse(b['created_at'] ?? '').compareTo(
              DateTime.parse(a['created_at'] ?? '')));
    } else if (_sortBy == 'Rating Tertinggi') {
      filtered.sort((a, b) => (b['rating'] as int).compareTo(a['rating'] as int));
    } else if (_sortBy == 'Rating Terendah') {
      filtered.sort((a, b) => (a['rating'] as int).compareTo(b['rating'] as int));
    }

    return filtered;
  }

  Map<int, int> _calculateRatingBreakdown() {
    final breakdown = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in _reviews) {
      final rating = review['rating'] as int;
      breakdown[rating] = (breakdown[rating] ?? 0) + 1;
    }
    return breakdown;
  }

  void _calculateAverageRating() {
    if (_reviews.isEmpty) {
      _averageRating = 0.0;
      return;
    }

    final total = _reviews.fold<int>(
        0, (sum, review) => sum + (review['rating'] as int));
    _averageRating = total / _reviews.length;
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
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
        currentIndex: 3,
        onTap: _onNavTap,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadReviews,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRatingSummary(),
                          const SizedBox(height: 20),
                          _buildStatisticsSection(),
                          const SizedBox(height: 20),
                          _buildFilterSection(),
                          const SizedBox(height: 16),
                          Text(
                            'Menampilkan ${_getFilteredReviews().length} ulasan',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.lightText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildReviewsList(),
                          const SizedBox(height: 20),
                          _buildTipsSection(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rating & Ulasan',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Feedback dari pasien Anda',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSummary() {
    final ratingBreakdown = _calculateRatingBreakdown();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCD34D), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(
                        index < _averageRating.round()
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: const Color(0xFFF59E0B),
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'dari ${_reviews.length} ulasan',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.lightText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: List.generate(5, (index) {
                final stars = 5 - index;
                final count = ratingBreakdown[stars] ?? 0;
                final percentage = _reviews.isNotEmpty
                    ? (count / _reviews.length)
                    : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        child: Text(
                          '$stars',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.star_rounded,
                          color: const Color(0xFFF59E0B), size: 12),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: percentage,
                            minHeight: 5,
                            backgroundColor: AppColors.borderColor,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFF59E0B)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 20,
                        child: Text(
                          count.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.people_outline,
            '${_totalPasien}',
            'Total Pasien',
            const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.trending_up,
            '${_repeatRate.toStringAsFixed(0)}%',
            'Repeat Rate',
            const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.assessment_outlined,
            _avgSessions.toStringAsFixed(1),
            'Avg. Sessions',
            const Color(0xFF3B82F6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.lightText,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_outlined, size: 16, color: AppColors.lightText),
              const SizedBox(width: 6),
              Text(
                'Filter & Urutkan',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Filter Rating',
                  value: _filterRating,
                  items: [
                    'Semua Rating',
                    '5 Bintang',
                    '4 Bintang',
                    '3 Bintang',
                    '2 Bintang',
                    '1 Bintang',
                  ],
                  onChanged: (value) {
                    setState(() => _filterRating = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Urutkan',
                  value: _sortBy,
                  items: ['Terbaru', 'Rating Tertinggi', 'Rating Terendah'],
                  onChanged: (value) {
                    setState(() => _sortBy = value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: AppColors.lightText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) onChanged(newValue);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection() {
    final tips = [
      'Berikan layanan yang konsisten profesional',
      'Komunikasi yang baik dengan pasien',
      'Follow up progress pasien secara rutin',
      'Tepat waktu dan responsif pada pertanyaan',
      'Berikan edukasi dan home exercise program',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.lightbulb, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                'Tips Meningkatkan Rating',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3, right: 8),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tip,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    final filteredReviews = _getFilteredReviews();

    if (filteredReviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 48,
                color: AppColors.lightText,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada ulasan',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Menunggu pasien memberikan ulasan',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.lightText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(filteredReviews.length, (index) {
          final review = filteredReviews[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildReviewCard(review),
          );
        }),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = review['rating'] as int;
    final komentar = review['komentar'] as String?;
    final createdAt = review['created_at'] as String?;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Icon(
                      index < rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: index < rating
                          ? const Color(0xFFF59E0B)
                          : AppColors.borderColor,
                      size: 14,
                    ),
                  ),
                ),
              ),
              Text(
                _formatDate(createdAt),
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: AppColors.lightText,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          if (komentar != null && komentar.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              komentar,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
