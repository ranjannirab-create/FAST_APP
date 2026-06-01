/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../friend_user.dart';   // ✅ point to your FriendUser model

class OnlineFriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    return user.uid;
  }

  String _getChatId(String userId1, String userId2) {
    final List<String> ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Real‑time stream of ALL friends (online + offline) with live online status
  Stream<List<FriendUser>> get friendsWithStatus {
    // Step 1: get the set of accepted friend IDs (live)
    final friendIdsStream = _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return data['senderId'] == _currentUserId
            ? data['receiverId'] as String
            : data['senderId'] as String;
      }).toSet();
    });

    // Step 2: for each set of friend IDs, listen to the user documents (real‑time isOnline)
    return friendIdsStream.asyncExpand((friendIds) {
      if (friendIds.isEmpty) {
        return Stream.value(<FriendUser>[]);
      }

      final innerStream = _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds.toList())
          .snapshots()
          .asyncMap((userSnapshot) async {
        final userMap = {for (var doc in userSnapshot.docs) doc.id: doc.data()};
        final friends = <FriendUser>[];

        for (final friendId in friendIds) {
          final userData = userMap[friendId] ?? {};
          final name = userData['name'] ?? 'Unknown';
          final profilePic = userData['profilePic'] ?? '';
          final isOnline = userData['isOnline'] ?? false;

          // Optional: get last message (you can skip if you only need online status)
          final chatId = _getChatId(_currentUserId, friendId);
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
            userId: friendId,
            name: name,
            profilePic: profilePic,
            lastMessage: lastMessage,
            lastMessageTime: lastMessageTime,
            isOnline: isOnline, note: '',
          ));
        }

        // Sort: online friends first, then by last message time
        friends.sort((a, b) {
          if (a.isOnline && !b.isOnline) return -1;
          if (!a.isOnline && b.isOnline) return 1;
          return (b.lastMessageTime ?? DateTime(1970)).compareTo(a.lastMessageTime ?? DateTime(1970));
        });

        return friends;
      });
      return innerStream;
    });
  }

  /// Optional: only online friends
  Stream<List<FriendUser>> get onlineFriends {
    return friendsWithStatus.map((list) => list.where((f) => f.isOnline).toList());
  }
}
*/


import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart';
import '../friend_user.dart';

class OnlineFriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Stream<List<FriendUser>> get friendsWithStatus {
    // স্ট্রিম ১: friend IDs (accepted requests)
    final friendIdsStream = _firestore
        .collection('users')
        .doc(uid)
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return data['senderId'] == uid
                  ? data['receiverId'] as String
                  : data['senderId'] as String;
            }).toSet())
        .distinct();

    // প্রতিবার friendIds পরিবর্তিত হলে নতুন মার্জ স্ট্রিম তৈরি
    return friendIdsStream.asyncExpand((friendIds) async* {
      if (friendIds.isEmpty) {
        yield [];
        return;
      }

      // প্রতিটি friend ID এর জন্য স্ট্রিম তৈরি
      final List<Stream<FriendUser>> userStreams = [];
      for (final id in friendIds) {
        userStreams.add(
          _firestore.collection('users').doc(id).snapshots().map((doc) {
            final data = doc.data()!;
            return FriendUser(
              userId: id,
              name: data['name'] ?? '',
              profilePic: data['profilePic'] ?? '',
              lastMessage: '',
              lastMessageTime: null,
              isOnline: data['isOnline'] ?? false,
              note: data['note'] ?? '',
            );
          }),
        );
      }

      // সবগুলো স্ট্রিম মার্জ
      final merged = StreamGroup.merge(userStreams);
      // সর্বশেষ FriendUser মান সংগ্রহ করে লিস্ট তৈরি
      final latestMap = <String, FriendUser>{};
      await for (final friend in merged) {
        latestMap[friend.userId] = friend;
        final list = latestMap.values.toList();
        // অনলাইন প্রথমে সাজানো
        list.sort((a, b) {
          if (a.isOnline && !b.isOnline) return -1;
          if (!a.isOnline && b.isOnline) return 1;
          return 0;
        });
        yield list;
      }
    });
  }
}