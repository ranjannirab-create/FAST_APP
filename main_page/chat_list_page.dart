import 'package:flutter/material.dart';
import '../chat_list_page/chat_list_header.dart';
import '../chat_list_page/chat_list_ui.dart';
import '../services/database_service.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key, required String targetUserId});
  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FBF8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ChatListHeader(db: _db),
            ChatListUI(db: _db),
          ],
        ),
      ),
    );
  }
}


