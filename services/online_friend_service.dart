import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart';
import 'database_service.dart';

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
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return data['senderId'] == uid
                ? data['receiverId'] as String
                : data['senderId'] as String;
          }).toSet(),
        )
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
              isOnline: DatabaseService.isEffectivelyOnline(data),
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

extension on Object? {
  bool? get isOnline => null;
}
