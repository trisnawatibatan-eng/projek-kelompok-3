import 'package:flutter/material.dart';
import 'fisioterapi_detail_chat_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();

  String searchQuery = "";

  final List<Map<String, dynamic>> chatList = [
    {
      "name": "Putri Amelia",
      "layanan": "Terapi Lansia",
      "message": "Terima kasih Pak, sampai jumpa besok",
      "time": "10:30",
      "unread": "2",
      "isOnline": true,
    },
    {
      "name": "Budi Santoso",
      "layanan": "Terapi Stroke",
      "message": "Baik Pak, saya sudah siap",
      "time": "09:15",
      "unread": "",
      "isOnline": false,
    },
    {
      "name": "Siti Aminah",
      "layanan": "Terapi Nyeri Punggung",
      "message": "Apakah besok bisa lebih pagi?",
      "time": "Kemarin",
      "unread": "1",
      "isOnline": true,
    },
    {
      "name": "Ahmad Rizki",
      "layanan": "Terapi Cedera Olahraga",
      "message": "Oke terima kasih infonya",
      "time": "2 hari lalu",
      "unread": "",
      "isOnline": false,
    },
    {
      "name": "Andi Wijaya",
      "layanan": "Terapi Pasca Operasi",
      "message": "Saya sedang dalam perjalanan",
      "time": "3 hari lalu",
      "unread": "",
      "isOnline": false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredChatList {
    if (searchQuery.isEmpty) {
      return chatList;
    }

    return chatList.where((chat) {
      final name = chat["name"].toString().toLowerCase();
      final layanan = chat["layanan"].toString().toLowerCase();
      final message = chat["message"].toString().toLowerCase();
      final query = searchQuery.toLowerCase();

      return name.contains(query) ||
          layanan.contains(query) ||
          message.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chats = filteredChatList;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isMobile = constraints.maxWidth < 600;

            final double horizontalPadding = isMobile ? 16 : 24;
            final double headerPaddingTop = isMobile ? 18 : 24;
            final double cardRadius = isMobile ? 13 : 14;

            return Column(
              children: [
                // HEADER ATAS
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    headerPaddingTop,
                    horizontalPadding,
                    14,
                  ),
                  color: const Color(0xFF00A896),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // JUDUL HEADER
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const CircleAvatar(
                              radius: 14,
                              backgroundColor: Color(0xFF22B8A8),
                              child: Icon(
                                Icons.arrow_back,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pesan",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "3 pesan belum dibaca",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // SEARCH BAR
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: TextField(
                          controller: _searchController,
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF263238),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Cari pasien...",
                            hintStyle: const TextStyle(
                              color: Color(0xFF7A8CA0),
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 21,
                              color: Color(0xFF7A8CA0),
                            ),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Color(0xFF7A8CA0),
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        searchQuery = "";
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // LIST CHAT
                Expanded(
                  child: chats.isEmpty
                      ? const Center(
                          child: Text(
                            "Pasien tidak ditemukan",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            14,
                            horizontalPadding,
                            18,
                          ),
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            final chat = chats[index];

                            return _chatItem(
                              context,
                              name: chat["name"],
                              layanan: chat["layanan"],
                              message: chat["message"],
                              time: chat["time"],
                              unread: chat["unread"],
                              isOnline: chat["isOnline"],
                              isMobile: isMobile,
                              cardRadius: cardRadius,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _chatItem(
    BuildContext context, {
    required String name,
    required String layanan,
    required String message,
    required String time,
    required String unread,
    required bool isOnline,
    required bool isMobile,
    required double cardRadius,
  }) {
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
        margin: const EdgeInsets.only(bottom: 11),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 14,
          vertical: isMobile ? 11 : 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: isMobile ? 23 : 28,
                  backgroundColor: const Color(0xFFC7FFF4),
                  child: Text(
                    _getInitial(name),
                    style: TextStyle(
                      color: const Color(0xFF00897B),
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 13 : 15,
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    right: 1,
                    bottom: 2,
                    child: Container(
                      width: isMobile ? 8 : 9,
                      height: isMobile ? 8 : 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(width: isMobile ? 10 : 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 13 : 15,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    layanan,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: const Color(0xFF8A8A8A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isMobile ? 11.5 : 13,
                      color: const Color(0xFF455A64),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: isMobile ? 10.5 : 12,
                    color: const Color(0xFF607D8B),
                  ),
                ),
                SizedBox(height: isMobile ? 14 : 18),
                if (unread.isNotEmpty)
                  Container(
                    width: isMobile ? 18 : 20,
                    height: isMobile ? 18 : 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF009688),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unread,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 10 : 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: isMobile ? 18 : 20,
                    height: isMobile ? 18 : 20,
                  ),
              ],
            ),
          ],
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