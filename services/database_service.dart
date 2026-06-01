/*
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal()
      : _firestore = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    return user.uid;
  }

  String _getRequestId(String senderId, String receiverId) {
    final List<String> ids = [senderId, receiverId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  String _getChatId(String userId1, String userId2) {
    final List<String> ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  // ==================== FRIEND REQUESTS ====================
  Future<String> sendFriendRequest(String targetUserId, {required String friendType}) async {
    try {
      final senderId = _currentUserId;
      final requestId = _getRequestId(senderId, targetUserId);
      final requestDoc = _firestore
          .collection('users')
          .doc(senderId)
          .collection('friend_requests')
          .doc(requestId);
      final docSnap = await requestDoc.get();
      if (docSnap.exists) throw Exception('Already sent.');
      final requestData = {
        'senderId': senderId,
        'receiverId': targetUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      };
      await _firestore.runTransaction((transaction) async {
        transaction.set(requestDoc, requestData);
        transaction.set(
          _firestore
              .collection('users')
              .doc(targetUserId)
              .collection('friend_requests')
              .doc(requestId),
          requestData,
        );
      });
      final senderName = _auth.currentUser?.displayName ?? 'Someone';
      await sendNotification(
        receiverId: targetUserId,
        type: 'friend_request',
        title: 'New Friend Request',
        body: '$senderName sent you a friend request.',
        senderId: senderId,
      );
      return requestId;
    } catch (e) {
      throw Exception('Failed to send request: $e');
    }
  }

  Future<void> cancelFriendRequest(String targetUserId) async {
    try {
      final senderId = _currentUserId;
      final requestId = _getRequestId(senderId, targetUserId);
      final senderRef = _firestore
          .collection('users')
          .doc(senderId)
          .collection('friend_requests')
          .doc(requestId);
      final receiverRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('friend_requests')
          .doc(requestId);
      final docSnap = await senderRef.get();
      if (!docSnap.exists) throw Exception('No request to cancel.');
      await _firestore.runTransaction((transaction) async {
        transaction.delete(senderRef);
        transaction.delete(receiverRef);
      });
    } catch (e) {
      throw Exception('Failed to cancel: $e');
    }
  }

  Stream<DocumentSnapshot> getRequestStatus(String targetUserId) {
    final currentId = _currentUserId;
    final requestId = _getRequestId(currentId, targetUserId);
    return _firestore
        .collection('users')
        .doc(currentId)
        .collection('friend_requests')
        .doc(requestId)
        .snapshots();
  }

  Future<void> acceptFriendRequest(String targetUserId) async {
    try {
      final currentId = _currentUserId;
      final requestId = _getRequestId(currentId, targetUserId);
      final currentRef = _firestore
          .collection('users')
          .doc(currentId)
          .collection('friend_requests')
          .doc(requestId);
      final targetRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('friend_requests')
          .doc(requestId);
      await _firestore.runTransaction((transaction) async {
        transaction.update(currentRef, {'status': 'accepted'});
        transaction.update(targetRef, {'status': 'accepted'});
      });
    } catch (e) {
      throw Exception('Failed to accept: $e');
    }
  }

  Future<void> declineFriendRequest(String targetUserId) async {
    try {
      final currentId = _currentUserId;
      final requestId = _getRequestId(currentId, targetUserId);
      final currentRef = _firestore
          .collection('users')
          .doc(currentId)
          .collection('friend_requests')
          .doc(requestId);
      final targetRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('friend_requests')
          .doc(requestId);
      await _firestore.runTransaction((transaction) async {
        transaction.update(currentRef, {'status': 'declined'});
        transaction.update(targetRef, {'status': 'declined'});
      });
    } catch (e) {
      throw Exception('Failed to decline: $e');
    }
  }

  // ==================== CHAT ====================
  Future<void> sendMessage(String receiverId, String message) async {
    final senderId = _currentUserId;
    final chatId = _getChatId(senderId, receiverId);
    final msgRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();
    await msgRef.set({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  Stream<QuerySnapshot> getMessages(String otherUserId) {
    final currentId = _currentUserId;
    final chatId = _getChatId(currentId, otherUserId);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<bool> isFriend(String otherUserId) async {
    final currentId = _currentUserId;
    final requestId = _getRequestId(currentId, otherUserId);
    final doc = await _firestore
        .collection('users')
        .doc(currentId)
        .collection('friend_requests')
        .doc(requestId)
        .get();
    return doc.exists && doc.data()?['status'] == 'accepted';
  }

  // ==================== NOTIFICATIONS ====================
  Future<void> sendNotification({
    required String receiverId,
    required String type,
    required String title,
    required String body,
    String? senderId,
    String? postId,
    String? commentId,
  }) async {
    try {
      final ref = _firestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .doc();
      await ref.set({
        'id': ref.id,
        'type': type,
        'title': title,
        'body': body,
        'senderId': senderId ?? _currentUserId,
        'postId': postId,
        'commentId': commentId,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'status': 'pending',
      });
    } catch (e) {
      print('Send notif error: $e');
    }
  }

  Stream<QuerySnapshot> getNotifications() {
    final currentId = _currentUserId;
    return _firestore
        .collection('users')
        .doc(currentId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final currentId = _currentUserId;
    await _firestore
        .collection('users')
        .doc(currentId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> respondToFriendRequest({
    required String notificationId,
    required String senderId,
    required String action,
  }) async {
    if (action == 'accepted') {
      await acceptFriendRequest(senderId);
    } else {
      await declineFriendRequest(senderId);
    }
    final currentId = _currentUserId;
    await _firestore
        .collection('users')
        .doc(currentId)
        .collection('notifications')
        .doc(notificationId)
        .update({'status': action == 'accepted' ? 'accepted' : 'declined'});
  }

  // ==================== FRIEND LIST & COUNT ====================
  Stream<List<FriendUser>> getFriendsList() {
    final currentId = _currentUserId;
    return _firestore
        .collection('users')
        .doc(currentId)
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .asyncMap((snapshot) async {
      final friends = <FriendUser>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final otherId = data['senderId'] == currentId
            ? data['receiverId'] as String
            : data['senderId'] as String;
        final userDoc = await _firestore.collection('users').doc(otherId).get();
        final userName = userDoc.data()?['name'] ?? 'Unknown';
        final profilePic = userDoc.data()?['profilePic'] ?? '';
        final chatId = _getChatId(currentId, otherId);
        final lastMsgSnapshot = await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
        String lastMessage = '';
        DateTime? lastMessageTime;
        if (lastMsgSnapshot.docs.isNotEmpty) {
          final msgData = lastMsgSnapshot.docs.first.data();
          lastMessage = msgData['message'] ?? '';
          lastMessageTime = (msgData['timestamp'] as Timestamp?)?.toDate();
        }
        friends.add(FriendUser(
          userId: otherId,
          name: userName,
          profilePic: profilePic,
          lastMessage: lastMessage,
          lastMessageTime: lastMessageTime,
        ));
      }
      friends.sort((a, b) => (b.lastMessageTime ?? DateTime(1970))
          .compareTo(a.lastMessageTime ?? DateTime(1970)));
      return friends;
    });
  }

  Stream<int> getFriendsCount(String userId) {
    final currentId = _currentUserId;
    return _firestore
        .collection('users')
        .doc(currentId)
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ==================== LIKES & COMMENTS ====================
  Future<void> toggleLike(String postId, String emoji) async {
    final currentUserId = _currentUserId;
    final postRef = _firestore.collection('posts').doc(postId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(postRef);
      if (!doc.exists) return;
      Map<String, dynamic> likes = Map<String, dynamic>.from(doc.data()?['likes'] ?? {});
      if (likes.containsKey(currentUserId)) {
        likes.remove(currentUserId);
      } else {
        likes[currentUserId] = emoji;
      }
      final likeCount = likes.length;
      transaction.update(postRef, {'likes': likes, 'likeCount': likeCount});
    });
    final postDoc = await postRef.get();
    final postOwnerId = postDoc.data()?['userId'];
    if (postOwnerId != null && postOwnerId != currentUserId) {
      final wasAlreadyLiked = (postDoc.data()?['likes'] as Map?)?.containsKey(currentUserId) ?? false;
      if (!wasAlreadyLiked) {
        await sendNotification(
          receiverId: postOwnerId,
          type: 'like',
          title: 'New Like',
          body: '${_auth.currentUser?.displayName ?? 'Someone'} liked your post',
          postId: postId,
        );
      }
    }
  }

  Future<void> addComment(String postId, String commentText, {String? parentId}) async {
    final currentUserId = _currentUserId;
    final currentUser = _auth.currentUser;
    final commentId = DateTime.now().millisecondsSinceEpoch.toString();
    final commentData = {
      'commentId': commentId,
      'userId': currentUserId,
      'userName': currentUser?.displayName ?? 'Anonymous',
      'userProfilePic': currentUser?.photoURL ?? '',
      'text': commentText.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'likeCount': 0,
      'likedBy': [],
      'parentId': parentId,
    };
    final postRef = _firestore.collection('posts').doc(postId);
    try {
      final doc = await postRef.get();
      if (!doc.exists) throw Exception('Post not found');
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
      final postOwnerId = data?['userId'];
      if (postOwnerId != null && postOwnerId != currentUserId && parentId == null) {
        String preview = commentText.length > 50 ? '${commentText.substring(0, 50)}…' : commentText;
        await sendNotification(
          receiverId: postOwnerId,
          type: 'comment',
          title: 'New comment from ${currentUser?.displayName ?? 'Someone'}',
          body: preview,
          postId: postId,
          commentId: commentId,
        );
      }
    } catch (e) {
      print('❌ AddComment error: $e');
      throw Exception('Failed to add comment: $e');
    }
  }

  // ==================== ONLINE STATUS ====================
  Future<void> setUserOnline(bool isOnline) async {
    try {
      await _firestore.collection('users').doc(_currentUserId).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Set online status error: $e');
    }
  }

  Stream<List<FriendUser>> getOnlineFriends() {
    final currentId = _currentUserId;
    return _firestore
        .collection('users')
        .doc(currentId)
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .asyncMap((snapshot) async {
      final friendIds = <String>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final otherId = data['senderId'] == currentId
            ? data['receiverId'] as String
            : data['senderId'] as String;
        friendIds.add(otherId);
      }
      if (friendIds.isEmpty) return [];
      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds)
          .where('isOnline', isEqualTo: true)
          .get();
      return usersSnapshot.docs.map((doc) {
        final data = doc.data();
        return FriendUser(
          userId: doc.id,
          name: data['name'] ?? 'Unknown',
          profilePic: data['profilePic'] ?? '',
          lastMessage: '',
          lastMessageTime: null,
        );
      }).toList();
    });
  }

  Stream<List<FriendUser>>? getFriendsListForUser(String userId) {
    return null;
  }

  Future<void> setMyNote(String text) async {}

  Stream<List<Note>>? getFriendsNotes() {
    return null;
  }

  Stream<Set<String>>? getOnlineUserIds() {
    return null;
  }
}

class Note {
  final String text;
  final DateTime timestamp;
  Note({
    required this.text,
    required this.timestamp,
  });
}

class FriendUser {
  final String userId;
  final String name;
  final String profilePic;
  final String lastMessage;
  final DateTime? lastMessageTime;
  FriendUser({
    required this.userId,
    required this.name,
    required this.profilePic,
    required this.lastMessage,
    this.lastMessageTime,
  });
}

*/




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal()
      : _firestore = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    return user.uid;
  }

  String _getRequestId(String senderId, String receiverId) {
    final List<String> ids = [senderId, receiverId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  String _getChatId(String userId1, String userId2) {
    final List<String> ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  // ==================== FRIEND REQUESTS ====================
  Future<String> sendFriendRequest(String targetUserId, {required String friendType}) async {
    try {
      final senderId = _currentUserId;
      final requestId = _getRequestId(senderId, targetUserId);
      final requestDoc = _firestore
          .collection('users')
          .doc(senderId)
          .collection('friend_requests')
          .doc(requestId);
      final docSnap = await requestDoc.get();
      if (docSnap.exists) throw Exception('Already sent.');
      final requestData = {
        'senderId': senderId,
        'receiverId': targetUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      };
      await _firestore.runTransaction((transaction) async {
        transaction.set(requestDoc, requestData);
        transaction.set(
          _firestore
              .collection('users')
              .doc(targetUserId)
              .collection('friend_requests')
              .doc(requestId),
          requestData,
        );
      });
      final senderName = _auth.currentUser?.displayName ?? 'Someone';
      await sendNotification(
        receiverId: targetUserId,
        type: 'friend_request',
        title: 'New Friend Request',
        body: '$senderName sent you a friend request.',
        senderId: senderId,
      );
      return requestId;
    } catch (e) {
      throw Exception('Failed to send request: $e');
    }
  }

  Future<void> cancelFriendRequest(String targetUserId) async {
    try {
      final senderId = _currentUserId;
      final requestId = _getRequestId(senderId, targetUserId);
      final senderRef = _firestore
          .collection('users')
          .doc(senderId)
          .collection('friend_requests')
          .doc(requestId);
      final receiverRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('friend_requests')
          .doc(requestId);
      final docSnap = await senderRef.get();
      if (!docSnap.exists) throw Exception('No request to cancel.');
      await _firestore.runTransaction((transaction) async {
        transaction.delete(senderRef);
        transaction.delete(receiverRef);
      });
    } catch (e) {
      throw Exception('Failed to cancel: $e');
    }
  }

  Stream<DocumentSnapshot> getRequestStatus(String targetUserId) {
    final currentId = _currentUserId;
    final requestId = _getRequestId(currentId, targetUserId);
    return _firestore
        .collection('users')
        .doc(currentId)
        .collection('friend_requests')
        .doc(requestId)
        .snapshots();
  }

  Future<void> acceptFriendRequest(String targetUserId) async {
    try {
      final currentId = _currentUserId;
      final requestId = _getRequestId(currentId, targetUserId);
      final currentRef = _firestore
          .collection('users')
          .doc(currentId)
          .collection('friend_requests')
          .doc(requestId);
      final targetRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('friend_requests')
          .doc(requestId);
      await _firestore.runTransaction((transaction) async {
        transaction.update(currentRef, {'status': 'accepted'});
        transaction.update(targetRef, {'status': 'accepted'});
      });
    } catch (e) {
      throw Exception('Failed to accept: $e');
    }
  }

  Future<void> declineFriendRequest(String targetUserId) async {
    try {
      final currentId = _currentUserId;
      final requestId = _getRequestId(currentId, targetUserId);
      final currentRef = _firestore
          .collection('users')
          .doc(currentId)
          .collection('friend_requests')
          .doc(requestId);
      final targetRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('friend_requests')
          .doc(requestId);
      await _firestore.runTransaction((transaction) async {
        transaction.update(currentRef, {'status': 'declined'});
        transaction.update(targetRef, {'status': 'declined'});
      });
    } catch (e) {
      throw Exception('Failed to decline: $e');
    }
  }

  // ==================== CHAT ====================
  Future<void> sendMessage(String receiverId, String message) async {
    final senderId = _currentUserId;
    final chatId = _getChatId(senderId, receiverId);
    final msgRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();
    await msgRef.set({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  Stream<QuerySnapshot> getMessages(String otherUserId) {
    final currentId = _currentUserId;
    final chatId = _getChatId(currentId, otherUserId);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<bool> isFriend(String otherUserId) async {
    final currentId = _currentUserId;
    final requestId = _getRequestId(currentId, otherUserId);
    final doc = await _firestore
        .collection('users')
        .doc(currentId)
        .collection('friend_requests')
        .doc(requestId)
        .get();
    return doc.exists && doc.data()?['status'] == 'accepted';
  }

  // ==================== NOTIFICATIONS ====================
  Future<void> sendNotification({
    required String receiverId,
    required String type,
    required String title,
    required String body,
    String? senderId,
    String? postId,
    String? commentId,
  }) async {
    try {
      final ref = _firestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .doc();
      await ref.set({
        'id': ref.id,
        'type': type,
        'title': title,
        'body': body,
        'senderId': senderId ?? _currentUserId,
        'postId': postId,
        'commentId': commentId,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'status': 'pending',
      });
    } catch (e) {
      print('Send notif error: $e');
    }
  }

  Stream<QuerySnapshot> getNotifications() {
    final currentId = _currentUserId;
    return _firestore
        .collection('users')
        .doc(currentId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final currentId = _currentUserId;
    await _firestore
        .collection('users')
        .doc(currentId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> respondToFriendRequest({
    required String notificationId,
    required String senderId,
    required String action,
  }) async {
    if (action == 'accepted') {
      await acceptFriendRequest(senderId);
    } else {
      await declineFriendRequest(senderId);
    }
    final currentId = _currentUserId;
    await _firestore
        .collection('users')
        .doc(currentId)
        .collection('notifications')
        .doc(notificationId)
        .update({'status': action == 'accepted' ? 'accepted' : 'declined'});
  }

  // ==================== FRIEND LIST & COUNT ====================
  Stream<List<FriendUser>> getFriendsList() {
    final currentId = _currentUserId;
    return _firestore
        .collection('users')
        .doc(currentId)
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .asyncMap((snapshot) async {
      final friends = <FriendUser>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final otherId = data['senderId'] == currentId
            ? data['receiverId'] as String
            : data['senderId'] as String;
        final userDoc = await _firestore.collection('users').doc(otherId).get();
        final userName = userDoc.data()?['name'] ?? 'Unknown';
        final profilePic = userDoc.data()?['profilePic'] ?? '';
        final chatId = _getChatId(currentId, otherId);
        final lastMsgSnapshot = await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
        String lastMessage = '';
        DateTime? lastMessageTime;
        if (lastMsgSnapshot.docs.isNotEmpty) {
          final msgData = lastMsgSnapshot.docs.first.data();
          lastMessage = msgData['message'] ?? '';
          lastMessageTime = (msgData['timestamp'] as Timestamp?)?.toDate();
        }
        friends.add(FriendUser(
          userId: otherId,
          name: userName,
          profilePic: profilePic,
          lastMessage: lastMessage,
          lastMessageTime: lastMessageTime,
        ));
      }
      friends.sort((a, b) => (b.lastMessageTime ?? DateTime(1970))
          .compareTo(a.lastMessageTime ?? DateTime(1970)));
      return friends;
    });
  }

  Stream<int> getFriendsCount(String userId) {
    final currentId = _currentUserId;
    return _firestore
        .collection('users')
        .doc(currentId)
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ==================== LIKES & COMMENTS ====================
  Future<void> toggleLike(String postId, String emoji) async {
    final currentUserId = _currentUserId;
    final postRef = _firestore.collection('posts').doc(postId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(postRef);
      if (!doc.exists) return;
      Map<String, dynamic> likes = Map<String, dynamic>.from(doc.data()?['likes'] ?? {});
      if (likes.containsKey(currentUserId)) {
        likes.remove(currentUserId);
      } else {
        likes[currentUserId] = emoji;
      }
      final likeCount = likes.length;
      transaction.update(postRef, {'likes': likes, 'likeCount': likeCount});
    });
    final postDoc = await postRef.get();
    final postOwnerId = postDoc.data()?['userId'];
    if (postOwnerId != null && postOwnerId != currentUserId) {
      final wasAlreadyLiked = (postDoc.data()?['likes'] as Map?)?.containsKey(currentUserId) ?? false;
      if (!wasAlreadyLiked) {
        await sendNotification(
          receiverId: postOwnerId,
          type: 'like',
          title: 'New Like',
          body: '${_auth.currentUser?.displayName ?? 'Someone'} liked your post',
          postId: postId,
        );
      }
    }
  }

  Future<void> addComment(String postId, String commentText, {String? parentId}) async {
    final currentUserId = _currentUserId;
    final currentUser = _auth.currentUser;
    final commentId = DateTime.now().millisecondsSinceEpoch.toString();
    final commentData = {
      'commentId': commentId,
      'userId': currentUserId,
      'userName': currentUser?.displayName ?? 'Anonymous',
      'userProfilePic': currentUser?.photoURL ?? '',
      'text': commentText.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'likeCount': 0,
      'likedBy': [],
      'parentId': parentId,
    };
    final postRef = _firestore.collection('posts').doc(postId);
    try {
      final doc = await postRef.get();
      if (!doc.exists) throw Exception('Post not found');
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
      final postOwnerId = data?['userId'];
      if (postOwnerId != null && postOwnerId != currentUserId && parentId == null) {
        String preview = commentText.length > 50 ? '${commentText.substring(0, 50)}…' : commentText;
        await sendNotification(
          receiverId: postOwnerId,
          type: 'comment',
          title: 'New comment from ${currentUser?.displayName ?? 'Someone'}',
          body: preview,
          postId: postId,
          commentId: commentId,
        );
      }
    } catch (e) {
      print('❌ AddComment error: $e');
      throw Exception('Failed to add comment: $e');
    }
  }

  // ==================== EXTRA (OPTIONAL) ====================
  Future<void> setMyNote(String text) async {}

  Stream<List<Note>>? getFriendsNotes() {
    return null;
  }

  Stream<List<FriendUser>>? getFriendsListForUser(String userId) {
    return null;
  }

  Future<void> setUserOnline(bool isOnline) async {}

  void getOnlineFriends() {}
}

class Note {
  final String text;
  final DateTime timestamp;
  Note({
    required this.text,
    required this.timestamp,
  });
}

class FriendUser {
  final String userId;
  final String name;
  final String profilePic;
  final String lastMessage;
  final DateTime? lastMessageTime;
  FriendUser({
    required this.userId,
    required this.name,
    required this.profilePic,
    required this.lastMessage,
    this.lastMessageTime,
  });
}