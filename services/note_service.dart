import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart';

import 'database_service.dart';

class UserNote {
  final String userId;
  final String name;
  final String profilePic;
  final String note;
  final DateTime? noteUpdatedAt;
  final bool isOnline;

  UserNote({
    required this.userId,
    required this.name,
    required this.profilePic,
    required this.note,
    required this.noteUpdatedAt,
    required this.isOnline,
  });
}

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser!.uid;

  /// My Note Save
  Future<void> setMyNote(String text) async {
    if (text.length > 99) {
      text = text.substring(0, 99);
    }

    await _firestore.collection('users').doc(currentUid).update({
      'note': text.trim(),
      'noteUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// My Note Stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> get myNote {
    return _firestore.collection('users').doc(currentUid).snapshots();
  }

  /// Friends Notes
  Stream<List<UserNote>> getFriendsNotes() {
    return _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .asyncExpand((snapshot) async* {
          final friendIds = snapshot.docs.map((doc) {
            final data = doc.data();
            return data['senderId'] == currentUid
                ? data['receiverId'] as String
                : data['senderId'] as String;
          }).toSet();

          if (friendIds.isEmpty) {
            yield <UserNote>[];
            return;
          }

          final userStreams = friendIds.map((friendId) {
            return _firestore.collection('users').doc(friendId).snapshots().map(
              (friendDoc) {
                final user = friendDoc.data();
                if (user == null) {
                  return null;
                }

                final isOnline = DatabaseService.isEffectivelyOnline(user);
                return UserNote(
                  userId: friendId,
                  name: user['name'] ?? '',
                  profilePic: user['profilePic'] ?? '',
                  note: user['note'] ?? '',
                  noteUpdatedAt: (user['noteUpdatedAt'] as Timestamp?)
                      ?.toDate(),
                  isOnline: isOnline,
                );
              },
            );
          }).toList();

          final merged = StreamGroup.merge(userStreams);
          final latest = <String, UserNote>{};
          await for (final friend in merged) {
            if (friend != null) {
              latest[friend.userId] = friend;
              final notes = latest.values.toList()
                ..sort((a, b) {
                  if (a.isOnline && !b.isOnline) return -1;
                  if (!a.isOnline && b.isOnline) return 1;
                  return 0;
                });
              yield notes;
            }
          }
        });
  }
}
