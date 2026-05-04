class EdukasiModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final String content;
  final int viewCount;
  final String author;
  final DateTime createdAt;
  final String imageUrl;

  EdukasiModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.content,
    required this.viewCount,
    required this.author,
    required this.createdAt,
    required this.imageUrl,
  });

  // Sample data
  static List<EdukasiModel> sampleEdukasi = [
    EdukasiModel(
      id: '1',
      title: 'Teknik Peregangan yang Benar',
      category: 'Peregangan',
      description: 'Pelajari cara melakukan peregangan dengan aman dan efektif',
      content: 'Peregangan adalah bagian penting dari rutinitas fitness Anda. Melakukan peregangan sebelum dan sesudah olahraga dapat membantu meningkatkan fleksibilitas, mengurangi risiko cedera, dan mempercepat pemulihan.',
      viewCount: 1250,
      author: 'Dr. Fisioterapi',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      imageUrl: 'assets/images/peregangan.png',
    ),
    EdukasiModel(
      id: '2',
      title: 'Postur Tubuh Saat Bekerja',
      category: 'Ergonomi',
      description: 'Tips menjaga postur tubuh yang baik selama bekerja',
      content: 'Postur tubuh yang buruk dapat menyebabkan nyeri punggung, leher, dan bahu. Pastikan meja dan kursi Anda sesuai dengan tinggi badan, monitor berada pada tingkat mata, dan kaki menyentuh lantai.',
      viewCount: 2150,
      author: 'Dr. Kesehatan',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      imageUrl: 'assets/images/postur.png',
    ),
    EdukasiModel(
      id: '3',
      title: 'Latihan Penguatan Otot Inti',
      category: 'Latihan',
      description: 'Latihan sederhana untuk menguatkan otot inti',
      content: 'Otot inti yang kuat sangat penting untuk stabilitas tubuh dan kesehatan punggung. Beberapa latihan efektif termasuk plank, dead bug, dan bird dog.',
      viewCount: 1890,
      author: 'Trainer Profesional',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      imageUrl: 'assets/images/core.png',
    ),
    EdukasiModel(
      id: '4',
      title: 'Manajemen Nyeri Kronis',
      category: 'Kesehatan',
      description: 'Strategi mengelola nyeri kronis dengan fisioterapi',
      content: 'Nyeri kronis dapat mempengaruhi kualitas hidup. Fisioterapi, olahraga teratur, dan teknik relaksasi dapat membantu mengelola nyeri dengan efektif.',
      viewCount: 3200,
      author: 'Dr. Spesialis',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      imageUrl: 'assets/images/pain.png',
    ),
  ];
}
