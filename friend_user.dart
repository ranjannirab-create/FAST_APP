

import 'package:cloud_firestore/cloud_firestore.dart';

class FriendUser {
  final String userId;
  final String name;
  final String profilePic;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final bool isOnline;
  final String note;   // ✅ যোগ করুন

  FriendUser({
    required this.userId,
    required this.name,
    required this.profilePic,
    required this.lastMessage,
    this.lastMessageTime,
    required this.isOnline,
    required this.note,   // ✅ যোগ করুন
  });

  factory FriendUser.fromMap(Map<String, dynamic> map) {
    return FriendUser(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null
          ? (map['lastMessageTime'] as Timestamp).toDate()
          : null,
      isOnline: map['isOnline'] ?? false,
      note: map['note'] ?? '',   // ✅ যোগ করুন
    );
  }
}