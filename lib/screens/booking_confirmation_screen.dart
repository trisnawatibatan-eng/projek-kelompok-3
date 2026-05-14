import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/bottom_nav_bar.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String therapy;
  final String price;
  final String address;
  final DateTime date;
  final TimeOfDay time;
  final String notes;

  const BookingConfirmationScreen({
    super.key,
    required this.therapy,
    required this.price,
    required this.address,
    required this.date,
    required this.time,
    required this.notes,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

enum BookingStatus { waiting }

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  BookingStatus _status = BookingStatus.waiting;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF00BBA7),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Janji Temu',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: const Color(0xFF00BBA7),
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'Jadwal jadwal terapi Anda',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: _buildBookingCard(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      ),
    );
  }

  Widget _buildBookingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Center(
              child: Text(
                'Menunggu Konfirmasi',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 13),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.therapy,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.person, 'Ftr. Siti Nurhaliza, S.Tr.Kes'),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.calendar_today,
                  '${DateFormat('dd MMM yyyy').format(widget.date)} · ${widget.time.format(context)}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.location_on, widget.address),
                if (widget.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.note_alt, widget.notes),
                ],
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text('Rincian Biaya',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Biaya Terapi',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(widget.price,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Biaya Kunjungan',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('Rp 50.000',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      'Rp ${_calculateTotal()}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00BBA7),
                          fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF00BBA7)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ),
      ],
    );
  }

  String _calculateTotal() {
    int therapy =
        int.tryParse(widget.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    int total = therapy + 50000;
    return NumberFormat('#,###', 'id_ID').format(total);
  }
}
