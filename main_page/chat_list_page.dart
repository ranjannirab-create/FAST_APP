/*

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../chat_list_page/chat_page.dart';   // ✅ correct import (adjust path if needed)
import '../home_page/image_helper.dart';   // ✅ import the helper

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key, required String targetUserId});   // ✅ removed unnecessary targetUserId

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<List<FriendUser>>(
        stream: _db.getFriendsList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final friends = snapshot.data ?? [];
          if (friends.isEmpty) {
            return const Center(
              child: Text('No friends yet. Send some requests!'),
            );
          }
          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: getProfileImage(friend.profilePic), // ✅ fixed
                  child: friend.profilePic.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(friend.name),
                subtitle: Text(
                  friend.lastMessage.isNotEmpty
                      ? friend.lastMessage
                      : 'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: friend.lastMessageTime != null
                    ? Text(_formatTime(friend.lastMessageTime!))
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(targetUserId: friend.userId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}

*/


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../home_page/image_helper.dart';
import '../chat_list_page/chat_page.dart';
import '../chat_list_page/online_friends.dart';   // ✅ নতুন ইম্পোর্ট

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
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ অনলাইন ফ্রেন্ডস সেকশন
          const OnlineFriendsWidget(),
          const Divider(),
          // ✅ বিদ্যমান চ্যাট লিস্ট (সব বন্ধু)
          Expanded(
            child: StreamBuilder<List<FriendUser>>(
              stream: _db.getFriendsList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final friends = snapshot.data ?? [];
                if (friends.isEmpty) {
                  return const Center(
                    child: Text('No friends yet. Send some requests!'),
                  );
                }
                return ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: getProfileImage(friend.profilePic),
                        child: friend.profilePic.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(friend.name),
                      subtitle: Text(
                        friend.lastMessage.isNotEmpty
                            ? friend.lastMessage
                            : 'No messages yet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: friend.lastMessageTime != null
                          ? Text(_formatTime(friend.lastMessageTime!))
                          : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(targetUserId: friend.userId),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}