import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class LatihanScreen extends StatefulWidget {
  const LatihanScreen({super.key});

  @override
  State<LatihanScreen> createState() => _LatihanScreenState();
}

class _LatihanScreenState extends State<LatihanScreen> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'Lumbal', 'Bahu', 'Lutut', 'Leher'];

  final List<Map<String, dynamic>> _exercises = [
    {
      'title': 'Stretching Lumbal Dasar',
      'category': 'Lumbal',
      'duration': '10 menit',
      'difficulty': 'Mudah',
      'image': '🏃',
      'description': 'Peregangan dasar untuk area lumbal',
      'instructions': [
        'Berbaring telentang dengan lutut ditekuk',
        'Tarik lutut ke arah dada perlahan',
        'Tahan selama 30 detik',
        'Ulangi 3 kali untuk setiap kaki'
      ]
    },
    {
      'title': 'Strengthening Rotator Cuff',
      'category': 'Bahu',
      'duration': '15 menit',
      'difficulty': 'Sedang',
      'image': '💪',
      'description': 'Latihan penguatan otot bahu',
      'instructions': [
        'Berdiri tegak dengan bahu santai',
        'Angkat lengan ke samping sampai sejajar bahu',
        'Tahan 2 detik di posisi atas',
        'Turunkan perlahan, ulangi 10 kali'
      ]
    },
    {
      'title': 'Knee Flexion Extension',
      'category': 'Lutut',
      'duration': '12 menit',
      'difficulty': 'Sedang',
      'image': '🦵',
      'description': 'Latihan fleksi dan ekstensi lutut',
      'instructions': [
        'Duduk di kursi dengan punggung tegak',
        'Luruskan satu kaki ke depan',
        'Tahan 5 detik di posisi atas',
        'Turunkan perlahan, ulangi 10 kali'
      ]
    },
    {
      'title': 'Neck Stretch & Rotation',
      'category': 'Leher',
      'duration': '8 menit',
      'difficulty': 'Mudah',
      'image': '🤸',
      'description': 'Peregangan dan rotasi leher',
      'instructions': [
        'Duduk tegak dengan bahu rileks',
        'Miringkan kepala ke samping sampai terasa tegang',
        'Tahan 20 detik, kemudian ulangi ke sisi lain',
        'Lakukan rotasi kepala dengan perlahan'
      ]
    },
    {
      'title': 'Core Stabilization',
      'category': 'Lumbal',
      'duration': '20 menit',
      'difficulty': 'Berat',
      'image': '🏋️',
      'description': 'Latihan stabilisasi inti tubuh',
      'instructions': [
        'Posisi plank dengan lengan lurus',
        'Pertahankan tubuh tetap lurus dari kepala hingga kaki',
        'Tahan 30 detik, istirahat, ulangi 3 kali',
        'Tingkatkan durasi secara bertahap'
      ]
    },
  ];

  List<Map<String, dynamic>> get _filteredExercises {
    if (_selectedCategory == 'Semua') {
      return _exercises;
    }
    return _exercises.where((e) => e['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('Program Latihan', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari latihan...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),

            // Category Filter
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        category,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _selectedCategory == category ? Colors.white : AppColors.primary,
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.primary,
                      side: BorderSide(
                        color: _selectedCategory == category ? AppColors.primary : AppColors.borderColor,
                        width: 1.5,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Exercise Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: _filteredExercises.map((exercise) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildExerciseCard(exercise, context),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LatihanDetailScreen(exercise: exercise),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00BBA7), Color(0xFF009689)],
                  ),
                ),
                child: Center(
                  child: Text(exercise['image'], style: GoogleFonts.inter(fontSize: 60)),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      exercise['title'],
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Description
                    Text(
                      exercise['description'],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Info row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: AppColors.lightText),
                            const SizedBox(width: 4),
                            Text(
                              exercise['duration'],
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.lightText,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(exercise['difficulty']),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            exercise['difficulty'],
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Mudah':
        return const Color(0xFF10B981);
      case 'Sedang':
        return const Color(0xFFF59E0B);
      case 'Berat':
        return const Color(0xFFEF4444);
      default:
        return AppColors.primary;
    }
  }
}

// ─── Detail Screen ───────────────────────────────────────────────────────────

class LatihanDetailScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const LatihanDetailScreen({
    super.key,
    required this.exercise,
  });

  @override
  State<LatihanDetailScreen> createState() => _LatihanDetailScreenState();
}

class _LatihanDetailScreenState extends State<LatihanDetailScreen> {
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('Detail Latihan', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00BBA7), Color(0xFF009689)],
                ),
              ),
              child: Center(
                child: Text(widget.exercise['image'], style: GoogleFonts.inter(fontSize: 100)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.exercise['title'],
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Info badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              widget.exercise['duration'],
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getDifficultyBgColor(widget.exercise['difficulty']),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.exercise['difficulty'],
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _getDifficultyColor(widget.exercise['difficulty']),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Divider(color: AppColors.borderColor),
                  const SizedBox(height: 20),

                  // Instructions
                  Text(
                    'Cara Melakukan',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...List.generate(
                    (widget.exercise['instructions'] as List).length,
                    (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  widget.exercise['instructions'][index],
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.secondaryText,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Completion checkbox
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isCompleted ? const Color(0xFFD1FAE5) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isCompleted ? const Color(0xFF10B981) : AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isCompleted = !_isCompleted;
                            });
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _isCompleted ? const Color(0xFF10B981) : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _isCompleted ? const Color(0xFF10B981) : AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: _isCompleted
                                ? const Center(
                                    child: Icon(Icons.check, color: Colors.white, size: 14),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Saya telah menyelesaikan latihan ini',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Submit button
                  if (_isCompleted)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✅ Latihan berhasil dicatat!',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: const Color(0xFF10B981),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Simpan Latihan',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Mudah':
        return const Color(0xFF10B981);
      case 'Sedang':
        return const Color(0xFFF59E0B);
      case 'Berat':
        return const Color(0xFFEF4444);
      default:
        return AppColors.primary;
    }
  }

  Color _getDifficultyBgColor(String difficulty) {
    switch (difficulty) {
      case 'Mudah':
        return const Color(0xFFD1FAE5);
      case 'Sedang':
        return const Color(0xFFFEF3C7);
      case 'Berat':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFEFF6FF);
    }
  }
}
