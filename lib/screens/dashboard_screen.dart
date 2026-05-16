import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav_bar.dart';
import 'edukasi_screen.dart';
import 'booking_screen.dart';
import 'login_screen.dart';
import 'chat_list_screen.dart';
import 'notifikasi_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _supabase = Supabase.instance.client;

  Map<String, dynamic>? _patientData;
  bool _isLoading = true;

  // ── State edukasi ────────────────────────────────────────────
  List<Map<String, dynamic>> _edukasiList = [];
  bool _isLoadingEdukasi = false;

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
    _fetchEdukasi();
  }

  Future<void> _fetchPatientData() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
        return;
      }

      final data = await _supabase
          .from('patients')
          .select('full_name, gender')
          .eq('id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _patientData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ── Supabase: fetch edukasi yang sudah dipublish ──────────────

  Future<void> _fetchEdukasi() async {
    if (_isLoadingEdukasi) return;
    if (mounted) setState(() => _isLoadingEdukasi = true);
    try {
      final response = await _supabase
          .from('edukasi')
          .select('id, judul, kategori, thumbnail_url, created_at')
          .eq('is_published', true)
          .order('created_at', ascending: false)
          .limit(3);

      if (mounted) {
        setState(() {
          _edukasiList = List<Map<String, dynamic>>.from(response as List);
        });
      }
    } catch (e) {
      debugPrint('Error fetching edukasi: $e');
    } finally {
      if (mounted) setState(() => _isLoadingEdukasi = false);
    }
  }

  // ── Helpers kategori ─────────────────────────────────────────

  Color _getKategoriColor(String? kategori) {
    const Map<String, Color> colors = {
      'Stroke': Color(0xFF3B82F6),
      'Nyeri Punggung': Color(0xFF10B981),
      'Nutrisi': Color(0xFFF59E0B),
      'Cedera Olahraga': Color(0xFF8B5CF6),
      'Mental': Color(0xFFF87171),
      'Latihan': Color(0xFF06B6D4),
      'Neurologi': Color(0xFFEC4899),
      'Geriatri': Color(0xFF14B8A6),
      'Pediatri': Color(0xFFF97316),
    };
    return colors[kategori] ?? const Color(0xFF00BBA7);
  }

  Color _getKategoriBgColor(String? kategori) {
    const Map<String, Color> colors = {
      'Stroke': Color(0xFFEFF6FF),
      'Nyeri Punggung': Color(0xFFD1FAE5),
      'Nutrisi': Color(0xFFFEF3C7),
      'Cedera Olahraga': Color(0xFFEDE9FE),
      'Mental': Color(0xFFFEE2E2),
      'Latihan': Color(0xFFCFFAFE),
      'Neurologi': Color(0xFFFCE7F3),
      'Geriatri': Color(0xFFCCFBF1),
      'Pediatri': Color(0xFFFEEDDA),
    };
    return colors[kategori] ?? const Color(0xFF00BBA7).withOpacity(0.1);
  }

  String _getEmojiForKategori(String? kategori) {
    const Map<String, String> emojis = {
      'Stroke': '🧠',
      'Nyeri Punggung': '🫁',
      'Nutrisi': '🥗',
      'Cedera Olahraga': '🏋️',
      'Mental': '🧘',
      'Latihan': '🏃',
      'Neurologi': '⚡',
      'Geriatri': '👴',
      'Pediatri': '👶',
    };
    return emojis[kategori] ?? '📄';
  }

  String _formatTanggal(String? createdAt) {
    if (createdAt == null) return '';
    try {
      final date = DateTime.parse(createdAt);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return '';
    }
  }

  // ── Greeting & name ──────────────────────────────────────────

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String get _firstName {
    final fullName = _patientData?['full_name'] as String?;
    if (fullName == null || fullName.isEmpty) return 'Pasien';
    return fullName.split(' ').first;
  }

  // ════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00BBA7)),
            )
          : _buildHomeContent(),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainPromoCard(),
                const SizedBox(height: 25),
                Text(
                  'Jadwal Terapi Terdekat',
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                _buildScheduleCard(),
                const SizedBox(height: 25),
                _buildEdukasiSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF00BBA7),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting,',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              ),
              Text(
                '$_firstName 👋',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatListScreen()),
                ),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotifikasiPasienScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainPromoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 15)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pesan Home Care',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BBA7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Pesan Sekarang',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF00BBA7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ftr. Siti Nurhaliza',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                'Besok, 10:00 WIB',
                style:
                    GoogleFonts.inter(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Edukasi Section ──────────────────────────────────────────

  Widget _buildEdukasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Edukasi',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EdukasiScreen()),
              ),
              child: Text(
                'Lihat Semua →',
                style: GoogleFonts.inter(
                  color: const Color(0xFF00BBA7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Loading state
        if (_isLoadingEdukasi)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(
                color: Color(0xFF00BBA7),
                strokeWidth: 2,
              ),
            ),
          )

        // Empty state
        else if (_edukasiList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                Icon(Icons.article_outlined,
                    size: 40, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text(
                  'Belum ada artikel edukasi',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )

        // List edukasi dari Supabase
        else
          ...List.generate(_edukasiList.length, (index) {
            return _buildEdukasiCard(_edukasiList[index]);
          }),
      ],
    );
  }

  Widget _buildEdukasiCard(Map<String, dynamic> item) {
    final judul = item['judul'] as String? ?? 'Tanpa Judul';
    final kategori = item['kategori'] as String?;
    final createdAt = item['created_at'] as String?;

    final kategoriColor = _getKategoriColor(kategori);
    final kategoriBgColor = _getKategoriBgColor(kategori);
    final emoji = _getEmojiForKategori(kategori);
    final tanggal = _formatTanggal(createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail / emoji
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: kategoriBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),

          // Konten teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (kategori != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: kategoriBgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      kategori,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: kategoriColor,
                      ),
                    ),
                  ),
                Text(
                  judul,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tanggal.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      tanggal,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}