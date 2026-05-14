import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/booking_request_model.dart';

class LaporanFisioterapisScreen extends StatefulWidget {
  final BookingRequest request;

  const LaporanFisioterapisScreen({super.key, required this.request});

  @override
  State<LaporanFisioterapisScreen> createState() => _LaporanFisioterapisScreenState();
}

class _LaporanFisioterapisScreenState extends State<LaporanFisioterapisScreen> {
  late final TextEditingController _subjectiveController;
  late final TextEditingController _objectiveController;
  late final TextEditingController _assessmentController;
  late final TextEditingController _planController;
  late final TextEditingController _evaluationController;
  late final TextEditingController _recommendationController;
  late final TextEditingController _painScaleController;
  late final TextEditingController _nextSessionController;

  @override
  void initState() {
    super.initState();
    _subjectiveController = TextEditingController(text: widget.request.subjective);
    _objectiveController = TextEditingController(text: widget.request.objective);
    _assessmentController = TextEditingController(text: widget.request.assessment);
    _planController = TextEditingController(text: widget.request.plan);
    _evaluationController = TextEditingController(text: widget.request.evaluation);
    _recommendationController = TextEditingController(text: widget.request.recommendation);
    _painScaleController = TextEditingController(text: widget.request.painScale);
    _nextSessionController = TextEditingController(text: widget.request.nextTherapyDate);
    _isEditing = widget.request.status != BookingRequestStatus.completed;
  }

  @override
  void dispose() {
    _subjectiveController.dispose();
    _objectiveController.dispose();
    _assessmentController.dispose();
    _planController.dispose();
    _evaluationController.dispose();
    _recommendationController.dispose();
    _painScaleController.dispose();
    _nextSessionController.dispose();
    super.dispose();
  }

  bool _isEditing = false;
  int _activeTabIndex = 0;

  void _saveReport() {
    final wasAlreadyCompleted = widget.request.status == BookingRequestStatus.completed;
    setState(() {
      widget.request.subjective = _subjectiveController.text.trim().isEmpty ? null : _subjectiveController.text.trim();
      widget.request.objective = _objectiveController.text.trim().isEmpty ? null : _objectiveController.text.trim();
      widget.request.assessment = _assessmentController.text.trim().isEmpty ? null : _assessmentController.text.trim();
      widget.request.plan = _planController.text.trim().isEmpty ? null : _planController.text.trim();
      widget.request.evaluation = _evaluationController.text.trim().isEmpty ? null : _evaluationController.text.trim();
      widget.request.recommendation = _recommendationController.text.trim().isEmpty ? null : _recommendationController.text.trim();
      widget.request.painScale = _painScaleController.text.trim().isEmpty ? null : _painScaleController.text.trim();
      widget.request.nextTherapyDate = _nextSessionController.text.trim().isEmpty ? null : _nextSessionController.text.trim();
      widget.request.status = BookingRequestStatus.completed;
      widget.request.lastUpdatedText = wasAlreadyCompleted ? 'Diperbarui' : null;
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(wasAlreadyCompleted ? 'Laporan pasien diperbarui.' : 'Laporan pasien berhasil disimpan.'),
        backgroundColor: const Color(0xFF00BBA7),
      ),
    );
  }

  Future<void> _exportReport() async {
    final reportText = '''Laporan Terapi Pasien: ${widget.request.patientName}

Subjective (Keluhan Pasien): ${widget.request.subjective ?? '-'}
Objective (Data Pemeriksaan): ${widget.request.objective ?? '-'}
Assessment (Diagnosis): ${widget.request.assessment ?? '-'}
Plan (Perencanaan Tindakan): ${widget.request.plan ?? '-'}
Evaluasi Terapi: ${widget.request.evaluation ?? '-'}
Skala Nyeri: ${widget.request.painScale ?? '-'}
Rekomendasi Latihan: ${widget.request.recommendation ?? '-'}
Terapi Berikutnya: ${widget.request.nextTherapyDate ?? '-'}
''';

    await Clipboard.setData(ClipboardData(text: reportText));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil diekspor dan disalin ke clipboard.'),
          backgroundColor: Color(0xFF00BBA7),
        ),
      );
    }
  }

  Future<void> _editHistoryReport(int historyIndex) async {
    final history = BookingRequestRepository.requests[historyIndex];
    final subjectiveController = TextEditingController(text: history.subjective);
    final objectiveController = TextEditingController(text: history.objective);
    final assessmentController = TextEditingController(text: history.assessment);
    final planController = TextEditingController(text: history.plan);
    final evaluationController = TextEditingController(text: history.evaluation);
    final recommendationController = TextEditingController(text: history.recommendation);
    final painScaleController = TextEditingController(text: history.painScale);
    final nextSessionController = TextEditingController(text: history.nextTherapyDate);

    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 64,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Edit Riwayat Terapi', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  _buildSection('Subjective (Keluhan Pasien)', subjectiveController, enabled: true, maxLines: 3),
                  _buildSection('Objective (Data Pemeriksaan)', objectiveController, enabled: true, maxLines: 3),
                  _buildSection('Assessment (Diagnosis)', assessmentController, enabled: true, maxLines: 3),
                  _buildSection('Plan (Perencanaan Tindakan)', planController, enabled: true, maxLines: 3),
                  _buildSection('Evaluasi Terapi', evaluationController, enabled: true, maxLines: 3),
                  _buildSection('Skala Nyeri', painScaleController, enabled: true, maxLines: 1),
                  _buildSection('Rekomendasi Latihan', recommendationController, enabled: true, maxLines: 3),
                  _buildSection('Terapi Berikutnya', nextSessionController, enabled: true, maxLines: 1),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          history.subjective = subjectiveController.text.trim().isEmpty ? null : subjectiveController.text.trim();
                          history.objective = objectiveController.text.trim().isEmpty ? null : objectiveController.text.trim();
                          history.assessment = assessmentController.text.trim().isEmpty ? null : assessmentController.text.trim();
                          history.plan = planController.text.trim().isEmpty ? null : planController.text.trim();
                          history.evaluation = evaluationController.text.trim().isEmpty ? null : evaluationController.text.trim();
                          history.recommendation = recommendationController.text.trim().isEmpty ? null : recommendationController.text.trim();
                          history.painScale = painScaleController.text.trim().isEmpty ? null : painScaleController.text.trim();
                          history.nextTherapyDate = nextSessionController.text.trim().isEmpty ? null : nextSessionController.text.trim();
                          history.lastUpdatedText = 'Diperbarui';
                        });
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Riwayat laporan berhasil diperbarui.'),
                            backgroundColor: Color(0xFF00BBA7),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BBA7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Simpan Perubahan', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      );
    } finally {
      subjectiveController.dispose();
      objectiveController.dispose();
      assessmentController.dispose();
      planController.dispose();
      evaluationController.dispose();
      recommendationController.dispose();
      painScaleController.dispose();
      nextSessionController.dispose();
    }
  }

  Widget _buildSection(String title, TextEditingController controller, {int maxLines = 4, bool enabled = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            enabled: enabled,
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? const Color(0xFFF6FBFA) : const Color(0xFFECEFF1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: enabled ? 'Masukkan $title pasien' : 'Masukkan $title pasien',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final historyItems = BookingRequestRepository.requests.asMap().entries
        .where((entry) => entry.value != widget.request && entry.value.patientName == widget.request.patientName && entry.value.status == BookingRequestStatus.completed)
        .toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBA7),
        title: Text('Detail Pasien', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF00BBA7),
                    child: Text(widget.request.patientName.substring(0, 1), style: const TextStyle(fontSize: 24, color: Colors.white)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.request.patientName,
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(widget.request.therapy, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700])),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('${widget.request.date} • ${widget.request.time}', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                            if (widget.request.lastUpdatedText != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF9F7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(widget.request.lastUpdatedText!, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF00BBA7), fontWeight: FontWeight.w600)),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _activeTabIndex == 0 ? const Color(0xFF00BBA7) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00BBA7)),
                      ),
                      child: Center(
                        child: Text(
                          'Catatan Medis',
                          style: GoogleFonts.inter(
                            color: _activeTabIndex == 0 ? Colors.white : const Color(0xFF00BBA7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _activeTabIndex == 1 ? const Color(0xFF00BBA7) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00BBA7)),
                      ),
                      child: Center(
                        child: Text(
                          'Riwayat',
                          style: GoogleFonts.inter(
                            color: _activeTabIndex == 1 ? Colors.white : const Color(0xFF00BBA7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_activeTabIndex == 0) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Catatan Medis', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                        if (widget.request.status == BookingRequestStatus.completed)
                          TextButton.icon(
                            onPressed: () => setState(() => _isEditing = !_isEditing),
                            icon: Icon(_isEditing ? Icons.close : Icons.edit, color: const Color(0xFF00BBA7)),
                            label: Text(_isEditing ? 'Batal' : 'Edit', style: const TextStyle(color: Color(0xFF00BBA7))),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildSection('Subjective (Keluhan Pasien)', _subjectiveController, enabled: _isEditing, maxLines: 3),
                    _buildSection('Objective (Data Pemeriksaan)', _objectiveController, enabled: _isEditing, maxLines: 3),
                    _buildSection('Assessment (Diagnosis)', _assessmentController, enabled: _isEditing, maxLines: 3),
                    _buildSection('Plan (Perencanaan Tindakan)', _planController, enabled: _isEditing, maxLines: 3),
                    _buildSection('Evaluasi Terapi', _evaluationController, enabled: _isEditing, maxLines: 3),
                    _buildSection('Skala Nyeri', _painScaleController, enabled: _isEditing, maxLines: 1),
                    _buildSection('Rekomendasi Latihan', _recommendationController, enabled: _isEditing, maxLines: 3),
                    _buildSection('Terapi Berikutnya', _nextSessionController, enabled: _isEditing, maxLines: 1),
                    if (widget.request.status != BookingRequestStatus.completed || _isEditing)
                      const SizedBox(height: 8),
                    if (widget.request.status != BookingRequestStatus.completed || _isEditing)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _saveReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BBA7),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Simpan', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        ),
                      ),
                  ],
                ),
              ),
            ] else ...[
              Column(
                children: [
                  if (historyItems.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'Riwayat belum tersedia untuk saat ini.',
                        style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
                      ),
                    )
                  else ...historyItems.asMap().entries.map((entry) {
                    final listIndex = entry.key;
                    final repoEntry = entry.value;
                    final repoIndex = repoEntry.key;
                    final history = repoEntry.value;
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00BBA7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${listIndex + 1}',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pertemuan ${listIndex + 1}',
                                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        history.date,
                                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _editHistoryReport(repoIndex),
                                    icon: const Icon(Icons.edit, size: 18, color: Color(0xFF00BBA7)),
                                    label: Text('Edit', style: GoogleFonts.inter(color: const Color(0xFF00BBA7), fontSize: 12, fontWeight: FontWeight.w600)),
                                  ),
                                  if (history.lastUpdatedText != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF9F7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(history.lastUpdatedText!, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF00BBA7), fontWeight: FontWeight.w600)),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                    Text(
                      history.subjective ?? 'Tidak ada catatan subjective.',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4FCFB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Objective (Data Pemeriksaan)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text(
                            history.objective ?? 'Tidak ada catatan objective.',
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800]),
                          ),
                          const SizedBox(height: 12),
                          Text('Assessment (Diagnosis)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text(
                            history.assessment ?? 'Tidak ada catatan assessment.',
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800]),
                          ),
                          const SizedBox(height: 12),
                          Text('Plan (Perencanaan Tindakan)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text(
                            history.plan ?? 'Tidak ada catatan plan.',
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      history.evaluation ?? 'Tidak ada catatan evaluasi.',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Skala Nyeri: ${history.painScale ?? '-'}',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Terapi Selanjutnya: ${history.nextTherapyDate ?? '-'}',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
