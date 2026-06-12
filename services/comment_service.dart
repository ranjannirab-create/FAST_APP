import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    return user.uid;
  }

  Future<void> addComment(
    String postId,
    String commentText, {
    String? parentId,
  }) async {
    final currentUserId = _currentUserId;
    final currentUser = _auth.currentUser;

    final userDoc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .get();

    final profilePic = userDoc.exists
        ? (userDoc.data()?['profilePic'] ?? '')
        : '';

    final commentData = {
      'commentId': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': currentUserId,
      'userName': currentUser?.displayName ?? 'Anonymous',
      'userProfilePic': profilePic,
      'text': commentText.trim(),
      'timestamp': Timestamp.now(),
      'likeCount': 0,
      'likedBy': [],
      'replies': [],
      'parentId': parentId,
    };

    final postRef = _firestore.collection('posts').doc(postId);

    try {
      final doc = await postRef.get();
      if (!doc.exists) {
        throw Exception('Post not found');
      }

      List<dynamic> comments = [];
      final data = doc.data();

      if (data != null && data.containsKey('comments')) {
        comments = List.from(data['comments']);
      }

      comments.add(commentData);

      await postRef.update({
        'comments': comments,
        'commentCount': comments.length,
      });

      print('✅ Comment added successfully');

      final postOwnerId = data?['userId'];

      if (postOwnerId != null &&
          postOwnerId != currentUserId &&
          parentId == null) {
        String preview = commentText.length > 30
            ? '${commentText.substring(0, 30)}…'
            : commentText;

        await _sendNotification(
          receiverId: postOwnerId,
          body: '${currentUser?.displayName ?? 'Someone'} commented: $preview',
          postId: postId,
        );
      }
    } catch (e) {
      print('❌ AddComment error: $e');
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> toggleCommentLike(
    String postId,
    String commentId,
  ) async {
    final currentUserId = _currentUserId;
    final postRef = _firestore.collection('posts').doc(postId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(postRef);
      if (!doc.exists) return;

      List<dynamic> comments = List.from(doc.data()?['comments'] ?? []);

      final index = comments.indexWhere(
        (c) => c['commentId'] == commentId,
      );
      if (index == -1) return;

      final comment = Map<String, dynamic>.from(comments[index]);
      List<dynamic> likedBy = List.from(comment['likedBy'] ?? []);
      final isLiked = likedBy.contains(currentUserId);

      if (isLiked) {
        likedBy.remove(currentUserId);
        comment['likeCount'] = (comment['likeCount'] ?? 1) - 1;
      } else {
        likedBy.add(currentUserId);
        comment['likeCount'] = (comment['likeCount'] ?? 0) + 1;
      }

      comment['likedBy'] = likedBy;
      comments[index] = comment;

      transaction.update(postRef, {
        'comments': comments,
      });
    });
  }

  Future<void> _sendNotification({
    required String receiverId,
    required String body,
    required String postId,
  }) async {
    final ref = _firestore
        .collection('users')
        .doc(receiverId)
        .collection('notifications')
        .doc();

    await ref.set({
      'id': ref.id,
      'type': 'comment',
      'title': 'New Comment',
      'body': body,
      'senderId': _currentUserId,
      'postId': postId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'status': 'pending',
    });
  }
}