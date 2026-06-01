//only logic of comment


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Comment related সব কাজ handle করার জন্য service class
class CommentService {

  // Firestore database instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firebase authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // বর্তমানে login করা user এর UID পাওয়ার getter
  String get _currentUserId {

    // Current logged in user নিচ্ছে
    final user = _auth.currentUser;

    // যদি user login না থাকে তাহলে error দিবে
    if (user == null) throw Exception('Not logged in');

    // User এর unique id return করবে
    return user.uid;
  }

  // ------------------------------------------------------------------
  // নতুন comment অথবা reply add করার function
  // parentId থাকলে reply হিসেবে save হবে
  // ------------------------------------------------------------------
  Future<void> addComment(
    String postId,
    String commentText, {
    String? parentId,
  }) async {

    // Current user এর uid নিচ্ছে
    final currentUserId = _currentUserId;

    // Current user object নিচ্ছে
    final currentUser = _auth.currentUser;

    // Firestore থেকে current user এর profile data নিচ্ছে
    final userDoc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .get();

    // Profile picture বের করছে
    // যদি না থাকে তাহলে empty string
    final profilePic = userDoc.exists
        ? (userDoc.data()?['profilePic'] ?? '')
        : '';

    // নতুন comment এর data object
    final commentData = {

      // Unique comment ID তৈরি করছে
      'commentId': DateTime.now()
          .millisecondsSinceEpoch
          .toString(),

      // Comment কে করেছে তার user id
      'userId': currentUserId,

      // User এর নাম
      'userName': currentUser?.displayName ?? 'Anonymous',

      // User profile picture
      'userProfilePic': profilePic,

      // Comment text
      'text': commentText.trim(),

      // Comment করার সময়
      'timestamp': Timestamp.now(),

      // Initial like count
      'likeCount': 0,

      // কারা like করেছে তাদের uid list
      'likedBy': [],

      // ভবিষ্যতে nested replies রাখার জন্য
      'replies': [],

      // যদি reply হয় তাহলে parent comment id থাকবে
      // root comment হলে null থাকবে
      'parentId': parentId,
    };

    // যে post এ comment হবে সেই post reference
    final postRef = _firestore
        .collection('posts')
        .doc(postId);

    try {

      // Post document নিচ্ছে
      final doc = await postRef.get();

      // যদি post না থাকে তাহলে error
      if (!doc.exists) {
        throw Exception('Post not found');
      }

      // Comment list initialize করছে
      List<dynamic> comments = [];

      // Post data নিচ্ছে
      final data = doc.data();

      // যদি আগের comments থাকে তাহলে load করবে
      if (data != null && data.containsKey('comments')) {
        comments = List.from(data['comments']);
      }

      // নতুন comment add করছে
      comments.add(commentData);

      // Firestore এ updated comments save করছে
      await postRef.update({

        // Updated comments list
        'comments': comments,

        // Total comment count
        'commentCount': comments.length,
      });

      // Console এ success message
      print('✅ Comment added successfully');

      // Post owner এর user id নিচ্ছে
      final postOwnerId = data?['userId'];

      // Notification শুধুমাত্র তখন যাবে যদি:
      // 1. Post owner থাকে
      // 2. নিজে নিজের post এ comment না করে
      // 3. এটা root comment হয় (reply না)
      if (postOwnerId != null &&
          postOwnerId != currentUserId &&
          parentId == null) {

        // Comment preview তৈরি করছে
        // ৩০ character এর বেশি হলে ছোট করে দেখাবে
        String preview = commentText.length > 30
            ? '${commentText.substring(0, 30)}…'
            : commentText;

        // Notification function call
        await _sendNotification(
          receiverId: postOwnerId,

          // Notification body text
          body:
              '${currentUser?.displayName ?? 'Someone'} commented: $preview',

          // কোন post এ comment হয়েছে
          postId: postId,
        );
      }

    } catch (e) {

      // Error console এ print করবে
      print('❌ AddComment error: $e');

      // Custom error throw করবে
      throw Exception('Failed to add comment: $e');
    }
  }

  // ------------------------------------------------------------------
  // Comment like/unlike করার function
  // ------------------------------------------------------------------
  Future<void> toggleCommentLike(
    String postId,
    String commentId,
  ) async {

    // Current user id নিচ্ছে
    final currentUserId = _currentUserId;

    // Post reference নিচ্ছে
    final postRef = _firestore
        .collection('posts')
        .doc(postId);

    // Transaction ব্যবহার করা হচ্ছে
    // যাতে multiple user একই সাথে like দিলেও data conflict না হয়
    await _firestore.runTransaction((transaction) async {

      // Post document নিচ্ছে
      final doc = await transaction.get(postRef);

      // Post না থাকলে return
      if (!doc.exists) return;

      // সব comments list নিচ্ছে
      List<dynamic> comments =
          List.from(doc.data()?['comments'] ?? []);

      // যে comment like/unlike হবে সেটা খুঁজছে
      final index = comments.indexWhere(
        (c) => c['commentId'] == commentId,
      );

      // Comment না পেলে return
      if (index == -1) return;

      // Specific comment copy করছে
      final comment =
          Map<String, dynamic>.from(comments[index]);

      // likedBy list নিচ্ছে
      List<dynamic> likedBy =
          List.from(comment['likedBy'] ?? []);

      // Current user already like দিয়েছে কিনা check করছে
      final isLiked = likedBy.contains(currentUserId);

      // যদি already like দেওয়া থাকে
      if (isLiked) {

        // Unlike করবে
        likedBy.remove(currentUserId);

        // Like count কমাবে
        comment['likeCount'] =
            (comment['likeCount'] ?? 1) - 1;

      } else {

        // নতুন like add করবে
        likedBy.add(currentUserId);

        // Like count বাড়াবে
        comment['likeCount'] =
            (comment['likeCount'] ?? 0) + 1;
      }

      // Updated likedBy list save করছে
      comment['likedBy'] = likedBy;

      // Updated comment আবার comments list এ বসাচ্ছে
      comments[index] = comment;

      // Firestore update করছে
      transaction.update(postRef, {
        'comments': comments,
      });
    });
  }

  // ------------------------------------------------------------------
  // Internal notification send helper function
  // ------------------------------------------------------------------
  Future<void> _sendNotification({
    required String receiverId,
    required String body,
    required String postId,
  }) async {

    // Notification document reference তৈরি করছে
    final ref = _firestore
        .collection('users')
        .doc(receiverId)
        .collection('notifications')
        .doc();

    // Firestore এ notification save করছে
    await ref.set({

      // Notification id
      'id': ref.id,

      // Notification type
      'type': 'comment',

      // Notification title
      'title': 'New Comment',

      // Notification body
      'body': body,

      // কে notification পাঠিয়েছে
      'senderId': _currentUserId,

      // কোন post related notification
      'postId': postId,

      // Notification time
      'timestamp': FieldValue.serverTimestamp(),

      // User notification পড়েছে কিনা
      'isRead': false,

      // Notification status
      'status': 'pending',
    });
  }
}


