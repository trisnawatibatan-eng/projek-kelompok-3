import 'package:flutter/material.dart';
import 'fisioterapis_detail_chat_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688),
        title: const Text("Pesan"),
      ),
      body: Column(
        children: [
          // 🔍 SEARCH
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Cari pasien...",
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
            ),
          ),

          // 📊 HEADER
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF009688),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.white),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pesan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text("3 pesan belum dibaca", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 📋 LIST CHAT
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _chatItem(context, "Putri Amelia", "Terapi Lansia", "Terima kasih Pak, sampai jumpa besok", "10:30", "2"),
                _chatItem(context, "Budi Santoso", "Terapi Stroke", "Baik Pak, saya sudah siap", "09:15", ""),
                _chatItem(context, "Siti Aminah", "Terapi Nyeri Punggung", "Apakah besok bisa lebih pagi?", "Kemarin", "1"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatItem(BuildContext context, String name, String layanan, String message, String time, String unread) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(name: name),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFB2EDE7),
              child: Text(name.substring(0, 2).toUpperCase()),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(layanan, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(message, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),

            Column(
              children: [
                Text(time, style: const TextStyle(fontSize: 11)),
                if (unread.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: Text(unread, style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}