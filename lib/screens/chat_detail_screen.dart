import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

class ChatDetailScreen extends StatefulWidget {
  final String name;
  const ChatDetailScreen({super.key, required this.name});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'message': 'Halo Pak Budi, saya Ftr. Siti.',
      'isMe': false,
      'time': '10:00'
    },
    {
      'message': 'Halo Bu, mau tanya soal jadwal besok.',
      'isMe': true,
      'time': '10:05'
    },
  ];
  bool _isSendingLocation = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendTextMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'message': text,
        'isMe': true,
        'time': TimeOfDay.now().format(context),
      });
      _messageController.clear();
    });
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollToBottom();
  }

  Future<void> _shareLocation() async {
    setState(() => _isSendingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Izin lokasi ditolak. Aktifkan lokasi di pengaturan.')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final locationUrl =
          'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
      setState(() {
        _messages.add({
          'message': 'Lokasi saya',
          'isMe': true,
          'time': TimeOfDay.now().format(context),
          'type': 'location',
          'latitude': position.latitude,
          'longitude': position.longitude,
          'url': locationUrl,
        });
      });
      await Future.delayed(const Duration(milliseconds: 100));
      _scrollToBottom();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gagal mendapatkan lokasi. Coba lagi nanti.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingLocation = false);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBA7),
        title: Text(widget.name,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildBubble(message);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> messageData) {
    final bool isMe = messageData['isMe'] as bool;
    final String time = messageData['time'] as String;
    final String type = messageData['type'] as String? ?? 'text';
    final String message = messageData['message'] as String;

    Widget bubbleContent;
    if (type == 'location' &&
        messageData.containsKey('latitude') &&
        messageData.containsKey('longitude')) {
      bubbleContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(color: isMe ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://staticmap.openstreetmap.de/staticmap.php?center=${messageData['latitude']},${messageData['longitude']}&zoom=15&size=600x300&markers=${messageData['latitude']},${messageData['longitude']},red-pushpin',
              fit: BoxFit.cover,
              width: 220,
              height: 130,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  width: 220,
                  height: 130,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 220,
                  height: 130,
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: const Text('Tidak dapat memuat peta',
                      textAlign: TextAlign.center),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final url = messageData['url'] as String?;
              if (url == null) return;
              await Clipboard.setData(ClipboardData(text: url));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Link peta disalin ke clipboard')),
                );
              }
            },
            child: Text(
              messageData['url'] as String? ?? '',
              style: TextStyle(
                color: isMe ? Colors.white : Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      );
    } else {
      bubbleContent = Text(
        message,
        style: TextStyle(color: isMe ? Colors.white : Colors.black87),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF00BBA7) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(15),
            ),
            child: bubbleContent,
          ),
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Ink(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              icon: _isSendingLocation
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.location_on, color: Color(0xFF00BBA7)),
              onPressed: _isSendingLocation ? null : _shareLocation,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Tulis pesan...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none),
                fillColor: Colors.grey.shade100,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendTextMessage(),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: const Color(0xFF00BBA7),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendTextMessage,
            ),
          ),
        ],
      ),
    );
  }
}
