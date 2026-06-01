import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import '../home_page/image_helper.dart';
import 'chat_page.dart';

class ChatListUI extends StatelessWidget {
  final DatabaseService db;
  const ChatListUI({super.key, required this.db});

  // ⚠️ This is the same _formatTime logic – no changes
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FriendUser>>(
      stream: db.getFriendsList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF23967D)),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final friends = snapshot.data ?? [];
        if (friends.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80,
                      color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No chats yet',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  Text('Connect with friends and start chatting',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade500)),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 4, bottom: 16),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatPage(targetUserId: friend.userId),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF34B99A), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundImage: getProfileImage(friend.profilePic),
                            child: friend.profilePic.isEmpty
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                friend.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                friend.lastMessage.isNotEmpty
                                    ? friend.lastMessage
                                    : 'Start a conversation 🌱',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (friend.lastMessageTime != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F7F2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatTime(friend.lastMessageTime!),
                              style: const TextStyle(
                                color: Color(0xFF23967D),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 72,
                  endIndent: 16,
                  color: Colors.grey.shade200,
                ),
              ],
            );
          },
        );
      },
    );
  }
}