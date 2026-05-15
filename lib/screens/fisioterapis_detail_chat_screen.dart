import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
                          style: GoogleFonts.inter(
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
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: isMobile ? 15 : 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Online",
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  child: Text(
                    "Hari ini",
                    style: GoogleFonts.inter(
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
                      final bool isMe = msg["isMe"] == true;

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
                                style: GoogleFonts.inter(
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
                                style: GoogleFonts.inter(
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

                // INPUT PESAN
                Container(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    12,
                    horizontalPadding,
                    14,
                  ),
                  color: Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // FIELD INPUT PESAN
                      Expanded(
                        child: Container(
                          height: isMobile ? 52 : 56,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF009688),
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _controller,
                            textAlignVertical: TextAlignVertical.center,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: Color(0xFF263238),
                            ),
                            decoration: InputDecoration(
                              hintText: "Ketik pesan...",
                              hintStyle: GoogleFonts.inter(
                                fontSize: 15,
                                color: Color(0xFF8A8A8A),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              filled: false,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // TOMBOL KIRIM
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: isMobile ? 52 : 56,
                          height: isMobile ? 52 : 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00897B),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.send_outlined,
                            color: Colors.white,
                            size: 27,
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
