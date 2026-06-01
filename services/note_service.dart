import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    await _firestore
        .collection('users')
        .doc(currentUid)
        .update({
      'note': text.trim(),
      'noteUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// My Note Stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> get myNote {
    return _firestore
        .collection('users')
        .doc(currentUid)
        .snapshots();
  }

  /// Friends Notes
  Stream<List<UserNote>> getFriendsNotes() {
    return _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .asyncMap((snapshot) async {

      List<UserNote> notes = [];

      for (var doc in snapshot.docs) {

        final data = doc.data();

        final friendId =
            data['senderId'] == currentUid
                ? data['receiverId']
                : data['senderId'];

        final friendDoc =
            await _firestore.collection('users').doc(friendId).get();

        if (!friendDoc.exists) continue;

        final user = friendDoc.data()!;

        notes.add(
          UserNote(
            userId: friendId,
            name: user['name'] ?? '',
            profilePic: user['profilePic'] ?? '',
            note: user['note'] ?? '',
            noteUpdatedAt:
                (user['noteUpdatedAt'] as Timestamp?)?.toDate(),
            isOnline: user['isOnline'] ?? false,
          ),
        );
      }

      notes.sort((a, b) {
        if (a.isOnline && !b.isOnline) return -1;
        if (!a.isOnline && b.isOnline) return 1;
        return 0;
      });

      return notes;
    });
  }
}