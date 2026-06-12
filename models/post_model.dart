import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String userProfilePic;
  final String userRole;
  final String country;
  final String language;
  final List<String> interests;
  final String category;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  final Map<String, dynamic> likes;
  final int likeCount;
  final List<dynamic> comments;
  final int commentCount;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfilePic,
    required this.userRole,
    required this.country,
    required this.language,
    required this.interests,
    required this.category,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.likes,
    required this.likeCount,
    required this.comments,
    required this.commentCount,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userProfilePic: data['userProfilePic'] ?? '',
      userRole: data['userRole'] ?? '',
      country: data['country'] ?? '',
      language: data['language'] ?? '',
      interests: List<String>.from(data['interests'] ?? []),
      category: data['category'] ?? '',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      likes: data['likes'] ?? {},
      likeCount: data['likeCount'] ?? 0,
      comments: data['comments'] ?? [],
      commentCount: data['commentCount'] ?? 0,
    );
  }
}