

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../home_page/image_helper.dart';
import '../home_page/view_post.dart';
import '../services/comment_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final DatabaseService _db = DatabaseService();
  final CommentService _commentService = CommentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;
              final id = notifications[index].id;
              final type = data['type'] ?? '';
              final title = data['title'] ?? '';
              final body = data['body'] ?? '';
              final isRead = data['isRead'] ?? false;
              final status = data['status'];
              final senderId = data['senderId'] ?? '';
              final postId = data['postId'] ?? '';
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

              // For friend requests, show Accept/Decline buttons; for others, show Reply/View
              final bool isFriendRequest = type == 'friend_request';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(senderId).get(),
                builder: (context, userSnap) {
                  String senderPic = '';
                  if (userSnap.hasData && userSnap.data!.exists) {
                    final userData = userSnap.data!.data() as Map<String, dynamic>;
                    senderPic = userData['profilePic'] ?? '';
                  }

                  // Build the notification tile
                  return Dismissible(
                    key: Key(id),
                    background: Container(color: Colors.red),
                    onDismissed: (direction) async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('notifications')
                            .doc(id)
                            .delete();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notification removed')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to delete: $e')),
                          );
                        }
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      color: isRead ? Colors.white : const Color(0xFFE8F0FE),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row with avatar, title, and timestamp
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundImage: getProfileImage(senderPic),
                                  child: senderPic.isEmpty ? const Icon(Icons.person, size: 24) : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (timestamp != null)
                                        Text(
                                          _formatTimeAgo(timestamp),
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                    ],
                                  ),
                                ),
                                if (isFriendRequest && status == 'pending')
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        onPressed: () async {
                                          await _db.respondToFriendRequest(
                                            notificationId: id,
                                            senderId: senderId,
                                            action: 'accepted',
                                          );
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Request accepted')),
                                            );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () async {
                                          await _db.respondToFriendRequest(
                                            notificationId: id,
                                            senderId: senderId,
                                            action: 'declined',
                                          );
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Request declined')),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Notification body (comment preview or like text)
                            Text(
                              body,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            // Buttons for reply and view (only for comment/like notifications)
                            if (!isFriendRequest && postId.isNotEmpty)
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _showReplyDialog(context, postId),
                                    icon: const Icon(Icons.reply, size: 18),
                                    label: const Text('Reply'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF2FA089),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewPostPage(postId: postId),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.visibility, size: 18),
                                    label: const Text('View'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF2FA089),
                                    ),
                                  ),
                                ],
                              ),
                            // For friend request that are already accepted/declined, show status chip
                            if (isFriendRequest && status != 'pending')
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Chip(
                                  label: Text(status == 'accepted' ? 'Accepted' : 'Declined'),
                                  backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
                                  labelStyle: const TextStyle(color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showReplyDialog(BuildContext context, String postId) {
    final TextEditingController controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Reply to this post',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Write your reply...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final comment = controller.text.trim();
                if (comment.isEmpty) return;
                try {
                  await _commentService.addComment(postId, comment);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reply posted!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2FA089),
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('Post Reply'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
