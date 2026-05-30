
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';

class FriendButton extends StatelessWidget {
  final String targetUserId;
  const FriendButton({super.key, required this.targetUserId});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();

    return StreamBuilder<DocumentSnapshot>(
      stream: db.getRequestStatus(targetUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 120, height: 36,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        String? status;
        if (snapshot.hasData && snapshot.data!.exists) {
          status = (snapshot.data!.data() as Map<String, dynamic>?)?['status'];
        }

        // No request: show Add Friend
        if (status == null) {
          return ElevatedButton(
            onPressed: () async {
              try {
                await db.sendFriendRequest(targetUserId, friendType: '');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request sent')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text('Add Friend'),
          );
        }

        // Pending request
        if (status == 'pending') {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final isSender = data['senderId'] == FirebaseAuth.instance.currentUser?.uid;
          if (isSender) {
            return OutlinedButton(
              onPressed: () async {
                try {
                  await db.cancelFriendRequest(targetUserId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request cancelled')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text('Cancel Request'),
            );
          } else {
            // Receiver: Show Accept/Decline
            return Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await db.acceptFriendRequest(targetUserId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Friend added')),
                    );
                  },
                  child: const Text('Accept'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () async {
                    await db.declineFriendRequest(targetUserId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Request declined')),
                    );
                  },
                  child: const Text('Decline'),
                ),
              ],
            );
          }
        }

        // Accepted
        if (status == 'accepted') {
          return const ElevatedButton(
            onPressed: null,
            style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green)),
            child: Text('Friends'),
          );
        }

        // Declined – show Add Friend again
        if (status == 'declined') {
          return ElevatedButton(
            onPressed: () async {
              await db.sendFriendRequest(targetUserId, friendType: '');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New request sent')),
              );
            },
            child: const Text('Add Friend'),
          );
        }

        return const SizedBox();
      },
    );
  }
}
