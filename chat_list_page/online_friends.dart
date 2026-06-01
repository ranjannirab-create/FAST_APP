/*import 'package:flutter/material.dart';
import '../services/online_friend_service.dart';
import '../home_page/image_helper.dart';
import '../friend_user.dart';   // ✅ correct import, no hide

class OnlineFriendsWidget extends StatelessWidget {
  const OnlineFriendsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FriendUser>>(
      stream: OnlineFriendService().friendsWithStatus,   // ✅ all friends with online status
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 95,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 95,
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        final allFriends = snapshot.data ?? [];
        if (allFriends.isEmpty) {
          return const SizedBox(
            height: 95,
            child: Center(child: Text('No friends yet')),
          );
        }
        return SizedBox(
          height: 95,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: allFriends.length,
            itemBuilder: (context, index) {
              final friend = allFriends[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: getProfileImage(friend.profilePic),
                          child: friend.profilePic.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        // ✅ green dot only for online friends
                        if (friend.isOnline)
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.fromBorderSide(
                                  BorderSide(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 60,
                      child: Text(
                        friend.name,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: friend.isOnline ? FontWeight.bold : FontWeight.normal,
                          color: friend.isOnline ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
*/

/*

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_page/image_helper.dart';
import '../services/note_service.dart'; // NoteService ইম্পোর্ট

class OnlineFriendsWidget extends StatelessWidget {
  const OnlineFriendsWidget({super.key});

  void _showNoteDialog(BuildContext context, UserNote userNote, {bool isSelf = false}) {
    final noteService = NoteService();
    final controller = TextEditingController(text: isSelf ? userNote.note : '');
    final parentContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: getProfileImage(userNote.profilePic)),
            const SizedBox(width: 10),
            Text(isSelf ? 'আমার নোট' : userNote.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelf) ...[
              const Text('নোট লিখুন:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 3,
                maxLength: 99,
                decoration: InputDecoration(
                  hintText: 'আপনার চিন্তা লিখুন...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ] else ...[
              const Text('বন্ধুর নোট:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  userNote.note.isEmpty ? 'কোন নোট নেই' : userNote.note,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              const Text('(শুধু দেখার জন্য)', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('বন্ধ করুন')),
          if (isSelf)
            ElevatedButton(
              onPressed: () async {
                await noteService.setMyNote(controller.text);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(content: Text('নোট সেভ হয়েছে'), duration: Duration(seconds: 1)),
                );
              },
              child: const Text('সংরক্ষণ করুন'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<List<UserNote>>(
      stream: NoteService().getFriendsNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 115, child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final userNotes = snapshot.data ?? [];

        // নিজের ডাটা আলাদা করে নিন
        UserNote? selfNote;
        final friendsNotes = <UserNote>[];
        for (final note in userNotes) {
          if (note.userId == currentUserId) {
            selfNote = note;
          } else {
            friendsNotes.add(note);
          }
        }

        // নিজের প্রোফাইলকে সবার আগে দেখান
        final displayList = <UserNote>[];
        if (selfNote != null) displayList.add(selfNote);
        displayList.addAll(friendsNotes);

        return SizedBox(
          height: 115,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final user = displayList[index];
              final isSelf = (user.userId == currentUserId);
              return GestureDetector(
                onTap: () => _showNoteDialog(context, user, isSelf: isSelf),
                child: Container(
                  width: 72,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: getProfileImage(user.profilePic),
                            child: user.profilePic.isEmpty ? const Icon(Icons.person, size: 30) : null,
                          ),
                          if (user.isOnline)
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: user.isOnline ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.note_alt, size: 10, color: Colors.grey.shade600),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                user.note.isNotEmpty ? (user.note.length > 8 ? '${user.note.substring(0, 8)}...' : user.note) : 'নোট',
                                style: const TextStyle(fontSize: 8),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

*/

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_page/image_helper.dart';
import '../services/note_service.dart';

class OnlineFriendsWidget extends StatelessWidget {
  const OnlineFriendsWidget({super.key});

  // নিজের ইউজার ডকুমেন্টের স্ট্রিম (নিজের নোট, অনলাইন স্ট্যাটাস)
  Stream<UserNote> get _selfStream {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map((doc) {
      final data = doc.data()!;
      return UserNote(
        userId: uid,
        name: data['name'] ?? '',
        profilePic: data['profilePic'] ?? '',
        note: data['note'] ?? '',
        noteUpdatedAt: (data['noteUpdatedAt'] as Timestamp?)?.toDate(),
        isOnline: data['isOnline'] ?? false,
      );
    });
  }

  void _showNoteDialog(BuildContext context, UserNote user, {required bool isSelf}) {
    final noteService = NoteService();
    final controller = TextEditingController(text: user.note);
    final parentContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: getProfileImage(user.profilePic)),
            const SizedBox(width: 10),
            Text(isSelf ? 'আমার নোট' : user.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelf) ...[
              const Text('নোট লিখুন:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 3,
                maxLength: 99,
                decoration: InputDecoration(
                  hintText: 'আপনার চিন্তা লিখুন...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ] else ...[
              const Text('বন্ধুর নোট:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.note.isEmpty ? 'কোন নোট নেই' : user.note,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              const Text('(শুধু দেখার জন্য)', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('বন্ধ করুন')),
          if (isSelf)
            ElevatedButton(
              onPressed: () async {
                await noteService.setMyNote(controller.text);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(content: Text('নোট সেভ হয়েছে'), duration: Duration(seconds: 1)),
                );
              },
              child: const Text('সংরক্ষণ করুন'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<List<UserNote>>(
      stream: NoteService().getFriendsNotes(),
      builder: (context, friendsSnapshot) {
        if (friendsSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 115, child: Center(child: CircularProgressIndicator()));
        }
        final friendsNotes = friendsSnapshot.data ?? [];

        return StreamBuilder<UserNote>(
          stream: _selfStream,
          builder: (context, selfSnapshot) {
            if (selfSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 115, child: Center(child: CircularProgressIndicator()));
            }
            final displayList = <UserNote>[];
            if (selfSnapshot.hasData) displayList.add(selfSnapshot.data!);
            displayList.addAll(friendsNotes);

            return SizedBox(
              height: 115,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final user = displayList[index];
                  final isSelf = (user.userId == currentUserId);
                  return GestureDetector(
                    onTap: () => _showNoteDialog(context, user, isSelf: isSelf),
                    child: Container(
                      width: 72,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: getProfileImage(user.profilePic),
                                child: user.profilePic.isEmpty ? const Icon(Icons.person, size: 30) : null,
                              ),
                              if (user.isOnline)
                                Positioned(
                                  right: 2,
                                  bottom: 2,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: user.isOnline ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.note_alt, size: 10, color: Colors.grey.shade600),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    user.note.isNotEmpty
                                        ? (user.note.length > 8 ? '${user.note.substring(0, 8)}...' : user.note)
                                        : 'নোট',
                                    style: const TextStyle(fontSize: 8),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}