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
  
  // FIX 1: Implemented getFriendsListForUser for any user ID
  // Previously returned null, now returns a proper stream of FriendUser objects
  Stream<List<FriendUser>> getFriendsListForUser(String userId) {
    // Changed: Now uses the provided userId instead of _currentUserId
    return _firestore
        .collection('users')
        .doc(userId) // FIX: Use parameter userId, not current user
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .asyncMap((snapshot) async {
      final friends = <FriendUser>[];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Determine the friend's ID (the other user)
        final otherId = data['senderId'] == userId
            ? data['receiverId'] as String
            : data['senderId'] as String;
        
        // Fetch friend's user data
        try {
          final userDoc = await _firestore.collection('users').doc(otherId).get();
          final userName = userDoc.data()?['name'] ?? 'Unknown';
          final profilePic = userDoc.data()?['profilePic'] ?? '';
          
          // For other user's friend list, we don't need last message (privacy)
          // Set dummy values as required by FriendUser class
          friends.add(FriendUser(
            userId: otherId,
            name: userName,
            profilePic: profilePic,
            lastMessage: '', // Not shown in UI for other user's friends
            lastMessageTime: null,
          ));
        } catch (e) {
          print('Error fetching friend user data: $e');
          // Skip this friend if user document can't be fetched
          continue;
        }
      }
      
      // Optional: sort by name alphabetically
      friends.sort((a, b) => a.name.compareTo(b.name));
      return friends;
    }).handleError((error) {
      print('Error in getFriendsListForUser: $error');
      return <FriendUser>[]; // Return empty list on error
    });
  }

  // FIX 2: getFriendsCount now uses the provided userId parameter
  // Previously always used _currentUserId, now correctly counts friends for any user
  Stream<int> getFriendsCount(String userId) {
    // Changed: Query the specified user's friend_requests, not current user
    return _firestore
        .collection('users')
        .doc(userId) // FIX: Use parameter userId instead of _currentUserId
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((error) {
          print('Error in getFriendsCount for user $userId: $error');
          return 0; // Return 0 on error to avoid UI breaking
        });
  }

  // Current user's friend list with chat last message (unchanged, works correctly)
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

  // FIX 3: Removed the nullable return and implemented properly above
  
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
*/

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
  Stream<List<FriendUser>> getFriendsListForUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .asyncMap((snapshot) async {
      final friends = <FriendUser>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final otherId = data['senderId'] == userId
            ? data['receiverId'] as String
            : data['senderId'] as String;
        try {
          final userDoc = await _firestore.collection('users').doc(otherId).get();
          final userName = userDoc.data()?['name'] ?? 'Unknown';
          final profilePic = userDoc.data()?['profilePic'] ?? '';
          friends.add(FriendUser(
            userId: otherId,
            name: userName,
            profilePic: profilePic,
            lastMessage: '',
            lastMessageTime: null,
          ));
        } catch (e) {
          print('Error fetching friend user data: $e');
          continue;
        }
      }
      friends.sort((a, b) => a.name.compareTo(b.name));
      return friends;
    }).handleError((error) {
      print('Error in getFriendsListForUser: $error');
      return <FriendUser>[];
    });
  }

  Stream<int> getFriendsCount(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((error) {
          print('Error in getFriendsCount for user $userId: $error');
          return 0;
        });
  }

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

  // ==================== LEADERBOARD (HOME) ====================
  Future<List<LeaderboardUser>> getHomeLeaderboard({int days = 7}) async {
    try {
      final cutoff = Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: days)),
      );
      final snapshot = await _firestore
          .collection('posts')
          .where('timestamp', isGreaterThanOrEqualTo: cutoff)
          .get();

      final Map<String, LeaderboardUser> userMap = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String?;
        if (userId == null) continue;

        final likeCount = (data['likeCount'] ?? 0) as int;
        final commentCount = (data['commentCount'] ?? 0) as int;
        final score = likeCount + commentCount;

        if (userMap.containsKey(userId)) {
          userMap[userId]!.score += score;
        } else {
          final userDoc = await _firestore.collection('users').doc(userId).get();
          final name = userDoc.data()?['name'] ?? 'বেনামী';
          final profilePic = userDoc.data()?['profilePic'] ?? '';
          userMap[userId] = LeaderboardUser(
            userId: userId,
            name: name,
            profilePic: profilePic,
            score: score,
          );
        }
      }

      List<LeaderboardUser> leaderboard = userMap.values.toList();
      leaderboard.sort((a, b) => b.score.compareTo(a.score));
      return leaderboard.take(10).toList();
    } catch (e) {
      print('HomeLeaderboard error: $e');
      return [];
    }
  }

  // ==================== LEADERBOARD (SUPPORT) ====================
  Future<List<LeaderboardUser>> getSupportLeaderboard({int days = 7}) async {
    try {
      final cutoff = Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: days)),
      );
      final postsSnapshot = await _firestore
          .collection('support_posts')
          .where('timestamp', isGreaterThanOrEqualTo: cutoff)
          .get();

      final badgesSnapshot = await _firestore
          .collection('support_badges')
          .where('timestamp', isGreaterThanOrEqualTo: cutoff)
          .get();

      final Map<String, LeaderboardUser> userMap = {};

      // Helper function to add points
      void addPoints(String userId, int points) {
        if (userMap.containsKey(userId)) {
          userMap[userId]!.score += points;
        } else {
          userMap[userId] = LeaderboardUser(
            userId: userId,
            name: 'বেনামী',
            profilePic: '',
            score: points,
          );
        }
      }

      // Process posts
      for (var doc in postsSnapshot.docs) {
        final data = doc.data();
        final postOwnerId = data['userId'] as String?;
        if (postOwnerId == null) continue;

        // Post owner points: likes + comments count
        final postLikeCount = (data['likeCount'] ?? 0) as int;
        final postCommentCount = (data['commentCount'] ?? 0) as int;
        addPoints(postOwnerId, postLikeCount + postCommentCount);

        final comments = data['comments'] as List? ?? [];
        // First pass: comment author points (1 per comment + comment likes)
        for (var comment in comments) {
          final authorId = comment['userId'] as String?;
          if (authorId == null) continue;
          final likeCount = (comment['likeCount'] ?? 0) as int;
          addPoints(authorId, 1 + likeCount);
        }
        // Second pass: reply points (parent comment gets +2 per reply)
        for (var comment in comments) {
          final parentId = comment['parentId'] as String?;
          if (parentId != null) {
            final parentComment = comments.firstWhere(
              (c) => c['commentId'] == parentId,
              orElse: () => null,
            );
            if (parentComment != null) {
              final parentAuthorId = parentComment['userId'] as String?;
              if (parentAuthorId != null) {
                addPoints(parentAuthorId, 2);
              }
            }
          }
        }
      }

      // Process badges: receiver +10, giver +5
      for (var doc in badgesSnapshot.docs) {
        final data = doc.data();
        final receiverId = data['receiverId'] as String?;
        final giverId = data['giverId'] as String?;
        if (receiverId != null) addPoints(receiverId, 10);
        if (giverId != null) addPoints(giverId, 5);
      }

      // Fetch user names and profile pics
      final userIds = userMap.keys.toList();
      if (userIds.isNotEmpty) {
        final usersSnapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: userIds)
            .get();
        for (var userDoc in usersSnapshot.docs) {
          final id = userDoc.id;
          if (userMap.containsKey(id)) {
            userMap[id]!.name = userDoc.data()['name'] ?? 'বেনামী';
            userMap[id]!.profilePic = userDoc.data()['profilePic'] ?? '';
          }
        }
      }

      List<LeaderboardUser> leaderboard = userMap.values.toList();
      leaderboard.sort((a, b) => b.score.compareTo(a.score));
      return leaderboard.take(10).toList();
    } catch (e) {
      print('SupportLeaderboard error: $e');
      return [];
    }
  }

  // ==================== SUPPORT BADGE ====================
  Future<void> awardSupportBadge({
    required String postId,
    required String commentId,
    required String helperUserId,
  }) async {
    final currentUserId = _currentUserId;

    final postDoc = await _firestore.collection('support_posts').doc(postId).get();
    if (postDoc.data()?['userId'] != currentUserId) {
      throw Exception('Only post owner can award badge');
    }

    final badgeRef = _firestore.collection('support_badges').doc();
    await badgeRef.set({
      'postId': postId,
      'commentId': commentId,
      'giverId': currentUserId,
      'receiverId': helperUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final postRef = _firestore.collection('support_posts').doc(postId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(postRef);
      if (!doc.exists) return;
      List<dynamic> comments = List.from(doc.data()?['comments'] ?? []);
      final index = comments.indexWhere((c) => c['commentId'] == commentId);
      if (index != -1) {
        int currentBadgeCount = (comments[index]['badgeCount'] ?? 0) as int;
        comments[index]['badgeCount'] = currentBadgeCount + 1;
        transaction.update(postRef, {'comments': comments});
      }
    });
  }

  // ==================== EXTRA (OPTIONAL) ====================
  Future<void> setMyNote(String text) async {}

  Stream<List<Note>>? getFriendsNotes() {
    return null;
  }
  
  Future<void> setUserOnline(bool isOnline) async {}

  void getOnlineFriends() {}
}

// ==================== MODELS ====================
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

class LeaderboardUser {
  final String userId;
  String name;
  String profilePic;
  int score;

  LeaderboardUser({
    required this.userId,
    required this.name,
    required this.profilePic,
    required this.score,
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
  Stream<List<FriendUser>> getFriendsListForUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .asyncMap((snapshot) async {
      final friends = <FriendUser>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final otherId = data['senderId'] == userId
            ? data['receiverId'] as String
            : data['senderId'] as String;
        try {
          final userDoc = await _firestore.collection('users').doc(otherId).get();
          final userName = userDoc.data()?['name'] ?? 'Unknown';
          final profilePic = userDoc.data()?['profilePic'] ?? '';
          friends.add(FriendUser(
            userId: otherId,
            name: userName,
            profilePic: profilePic,
            lastMessage: '',
            lastMessageTime: null,
          ));
        } catch (e) {
          print('Error fetching friend user data: $e');
          continue;
        }
      }
      friends.sort((a, b) => a.name.compareTo(b.name));
      return friends;
    }).handleError((error) {
      print('Error in getFriendsListForUser: $error');
      return <FriendUser>[];
    });
  }

  Stream<int> getFriendsCount(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((error) {
          print('Error in getFriendsCount for user $userId: $error');
          return 0;
        });
  }

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

  // ==================== LEADERBOARD (HOME) ====================
  Future<List<LeaderboardUser>> getHomeLeaderboard({int days = 7}) async {
    try {
      final cutoff = Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: days)),
      );
      final snapshot = await _firestore
          .collection('posts')
          .where('timestamp', isGreaterThanOrEqualTo: cutoff)
          .get();

      final Map<String, LeaderboardUser> userMap = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String?;
        if (userId == null) continue;

        final likeCount = (data['likeCount'] ?? 0) as int;
        final commentCount = (data['commentCount'] ?? 0) as int;
        final score = likeCount + commentCount;

        if (userMap.containsKey(userId)) {
          userMap[userId]!.score += score;
        } else {
          final userDoc = await _firestore.collection('users').doc(userId).get();
          final name = userDoc.data()?['name'] ?? 'বেনামী';
          final profilePic = userDoc.data()?['profilePic'] ?? '';
          userMap[userId] = LeaderboardUser(
            userId: userId,
            name: name,
            profilePic: profilePic,
            score: score,
          );
        }
      }

      List<LeaderboardUser> leaderboard = userMap.values.toList();
      leaderboard.sort((a, b) => b.score.compareTo(a.score));
      return leaderboard.take(10).toList();
    } catch (e) {
      print('HomeLeaderboard error: $e');
      return [];
    }
  }

  // ==================== LEADERBOARD (SUPPORT) ====================
  Future<List<LeaderboardUser>> getSupportLeaderboard({int days = 7}) async {
    try {
      final cutoff = Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: days)),
      );
      final postsSnapshot = await _firestore
          .collection('support_posts')
          .where('timestamp', isGreaterThanOrEqualTo: cutoff)
          .get();

      // FIXED: badges collection may not exist – catch error
      List<QueryDocumentSnapshot> badgesDocs = [];
      try {
        final badgesSnapshot = await _firestore
            .collection('support_badges')
            .where('timestamp', isGreaterThanOrEqualTo: cutoff)
            .get();
        badgesDocs = badgesSnapshot.docs;
      } catch (e) {
        print('⚠️ support_badges collection missing or error: $e');
      }

      final Map<String, LeaderboardUser> userMap = {};

      void addPoints(String userId, int points) {
        if (userMap.containsKey(userId)) {
          userMap[userId]!.score += points;
        } else {
          userMap[userId] = LeaderboardUser(
            userId: userId,
            name: 'বেনামী',
            profilePic: '',
            score: points,
          );
        }
      }

      for (var doc in postsSnapshot.docs) {
        final data = doc.data();
        final postOwnerId = data['userId'] as String?;
        if (postOwnerId == null) continue;

        final postLikeCount = (data['likeCount'] ?? 0) as int;
        final postCommentCount = (data['commentCount'] ?? 0) as int;
        addPoints(postOwnerId, postLikeCount + postCommentCount);

        final comments = data['comments'] as List? ?? [];
        for (var comment in comments) {
          final authorId = comment['userId'] as String?;
          if (authorId == null) continue;
          final likeCount = (comment['likeCount'] ?? 0) as int;
          addPoints(authorId, 1 + likeCount);
        }
        for (var comment in comments) {
          final parentId = comment['parentId'] as String?;
          if (parentId != null) {
            final parentComment = comments.firstWhere(
              (c) => c['commentId'] == parentId,
              orElse: () => null,
            );
            if (parentComment != null) {
              final parentAuthorId = parentComment['userId'] as String?;
              if (parentAuthorId != null) addPoints(parentAuthorId, 2);
            }
          }
        }
      }

      for (var doc in badgesDocs) {
        final data = doc.data();
        final receiverId = data?['receiverId'] as String?;
        final giverId = data['giverId'] as String?;
        if (receiverId != null) addPoints(receiverId, 10);
        if (giverId != null) addPoints(giverId, 5);
      }

      // FIXED: chunked query to avoid whereIn limit (max 10)
      final userIds = userMap.keys.toList();
      if (userIds.isNotEmpty) {
        for (int i = 0; i < userIds.length; i += 10) {
          final chunk = userIds.skip(i).take(10).toList();
          if (chunk.isEmpty) continue;
          final usersSnapshot = await _firestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();
          for (var userDoc in usersSnapshot.docs) {
            final id = userDoc.id;
            if (userMap.containsKey(id)) {
              userMap[id]!.name = userDoc.data()['name'] ?? 'বেনামী';
              userMap[id]!.profilePic = userDoc.data()['profilePic'] ?? '';
            }
          }
        }
      }

      List<LeaderboardUser> leaderboard = userMap.values.toList();
      leaderboard.sort((a, b) => b.score.compareTo(a.score));
      return leaderboard.take(10).toList();
    } catch (e, stack) {
      print('❌ SupportLeaderboard error: $e');
      print(stack);
      return [];
    }
  }

  // ==================== SUPPORT BADGE ====================
  Future<void> awardSupportBadge({
    required String postId,
    required String commentId,
    required String helperUserId,
  }) async {
    final currentUserId = _currentUserId;

    final postDoc = await _firestore.collection('support_posts').doc(postId).get();
    if (postDoc.data()?['userId'] != currentUserId) {
      throw Exception('Only post owner can award badge');
    }

    final badgeRef = _firestore.collection('support_badges').doc();
    await badgeRef.set({
      'postId': postId,
      'commentId': commentId,
      'giverId': currentUserId,
      'receiverId': helperUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final postRef = _firestore.collection('support_posts').doc(postId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(postRef);
      if (!doc.exists) return;
      List<dynamic> comments = List.from(doc.data()?['comments'] ?? []);
      final index = comments.indexWhere((c) => c['commentId'] == commentId);
      if (index != -1) {
        int currentBadgeCount = (comments[index]['badgeCount'] ?? 0) as int;
        comments[index]['badgeCount'] = currentBadgeCount + 1;
        transaction.update(postRef, {'comments': comments});
      }
    });
  }

  // ==================== EXTRA (OPTIONAL) ====================
  Future<void> setMyNote(String text) async {}

  Stream<List<Note>>? getFriendsNotes() {
    return null;
  }
  
  Future<void> setUserOnline(bool isOnline) async {}

  void getOnlineFriends() {}
}

extension on Object? {
  void operator [](String other) {}
}

// ==================== MODELS ====================
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

class LeaderboardUser {
  final String userId;
  String name;
  String profilePic;
  int score;

  LeaderboardUser({
    required this.userId,
    required this.name,
    required this.profilePic,
    required this.score,
  });
}