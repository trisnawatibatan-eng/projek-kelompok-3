import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  final String name;

  const ChatDetailScreen({
    super.key,
    required this.name,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {
      "text": "Selamat pagi Pak, saya ingin konfirmasi jadwal besok",
      "isMe": false,
      "time": "09:00",
    },
    {
      "text": "Selamat pagi Bu Putri, jadwal tetap jam 14:00 ya",
      "isMe": true,
      "time": "09:05",
    },
    {
      "text": "Baik Pak, apakah ada latihan hari ini?",
      "isMe": false,
      "time": "09:10",
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();

    if (text.isNotEmpty) {
      setState(() {
        messages.add({
          "text": text,
          "isMe": true,
          "time": "Now",
        });
      });

      _controller.clear();
    }
  }

  void _openMaps() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Membuka lokasi pasien..."),
        duration: Duration(seconds: 1),
      ),
    );

    // Kalau nanti sudah punya halaman maps, bisa pakai contoh ini:
    //
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => MapsScreen(),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isMobile = constraints.maxWidth < 600;
            final double horizontalPadding = isMobile ? 16 : 24;

            return Column(
              children: [
                // HEADER DETAIL CHAT
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    14,
                    horizontalPadding,
                    14,
                  ),
                  color: const Color(0xFF009688),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 12),

                      CircleAvatar(
                        radius: isMobile ? 20 : 24,
                        backgroundColor: const Color(0xFFC7FFF4),
                        child: Text(
                          _getInitial(widget.name),
                          style: TextStyle(
                            color: const Color(0xFF00897B),
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 15 : 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Online",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Ikon titik tiga sudah dihapus
                    ],
                  ),
                ),

                // LABEL HARI
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Hari ini",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // LIST PESAN
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      12,
                      horizontalPadding,
                      16,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final bool isMe = msg["isMe"];

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: isMobile
                                ? constraints.maxWidth * 0.72
                                : constraints.maxWidth * 0.45,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFF009688)
                                : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(14),
                              topRight: const Radius.circular(14),
                              bottomLeft: Radius.circular(isMe ? 14 : 2),
                              bottomRight: Radius.circular(isMe ? 2 : 14),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                msg["text"],
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white
                                      : const Color(0xFF263238),
                                  fontSize: isMobile ? 13 : 14,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg["time"],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white70 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // INPUT PESAN: LOKASI - TEXTFIELD - KIRIM
                Container(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    10,
                    horizontalPadding,
                    14,
                  ),
                  color: Colors.white,
                  child: Row(
                    children: [
                      // TOMBOL LOKASI DI KIRI
                      GestureDetector(
                        onTap: _openMaps,
                        child: Container(
                          width: isMobile ? 52 : 58,
                          height: isMobile ? 52 : 58,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFFE0E0E0),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF009688),
                            size: 28,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // KOLOM INPUT PESAN DI TENGAH
                      Expanded(
                        child: Container(
                          height: isMobile ? 52 : 58,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F6),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: TextField(
                            controller: _controller,
                            textAlignVertical: TextAlignVertical.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF263238),
                            ),
                            decoration: const InputDecoration(
                              hintText: "Ketik pesan...",
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF7E7E90),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // TOMBOL KIRIM DI KANAN
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: isMobile ? 58 : 74,
                          height: isMobile ? 52 : 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00897B),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.send_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getInitial(String name) {
    final parts = name.trim().split(" ");

    if (parts.length >= 2) {
      return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
    }

    if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    }

    return name.toUpperCase();
  }
}