import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  final String name;

  const ChatDetailScreen({super.key, required this.name});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> messages = [
    {"text": "Selamat pagi Pak, saya ingin konfirmasi jadwal besok", "isMe": false, "time": "09:00"},
    {"text": "Selamat pagi Bu Putri, jadwal tetap jam 14:00 ya", "isMe": true, "time": "09:05"},
    {"text": "Baik Pak, apakah ada latihan hari ini?", "isMe": false, "time": "09:10"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.name),
            const Text("Online", style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text("Hari ini", style: TextStyle(color: Colors.grey)),

          // 💬 CHAT LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];

                return Align(
                  alignment: msg["isMe"]
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 250),
                    decoration: BoxDecoration(
                      color: msg["isMe"]
                          ? const Color(0xFF009688)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg["text"],
                          style: TextStyle(
                            color: msg["isMe"] ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg["time"],
                          style: TextStyle(
                            fontSize: 10,
                            color: msg["isMe"]
                                ? Colors.white70
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ✍️ INPUT
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ketik pesan...",
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF009688),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        setState(() {
                          messages.add({
                            "text": _controller.text,
                            "isMe": true,
                            "time": "Now"
                          });
                        });
                        _controller.clear();
                      }
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}