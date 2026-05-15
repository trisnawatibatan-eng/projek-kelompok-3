import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBA7),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pesan',
          style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          _buildChatItem(
            context,
            name: 'Ftr. Siti Nurhaliza',
            message: 'Halo Pak Budi, untuk sesi besok apakah...',
            time: '10:30',
            unreadCount: 2,
            imageUrl: 'https://i.pravatar.cc/150?u=siti',
          ),
          _buildChatItem(
            context,
            name: 'Dr. Andi Pratama',
            message: 'Hasil pemeriksaan sudah saya lampirkan...',
            time: 'Yesterday',
            unreadCount: 0,
            imageUrl: 'https://i.pravatar.cc/150?u=andi',
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, {
    required String name, 
    required String message, 
    required String time, 
    required int unreadCount,
    required String imageUrl,
  }) {
    return ListTile(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailScreen(name: name)));
      },
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(time, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 5),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Color(0xFF00BBA7), shape: BoxShape.circle),
              child: Text('$unreadCount', style: GoogleFonts.inter(color: Colors.white, fontSize: 10)),
            ),
        ],
      ),
    );
  }
}
