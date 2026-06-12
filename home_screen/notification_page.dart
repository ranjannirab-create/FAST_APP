

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
  static const Color brandColor = Color(0xFF2FA089);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // প্রিমিয়াম হালকা ব্যাকগ্রাউন্ড
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: brandColor),
            onPressed: () {
              // ইচ্ছা করলে এখানে সব নোটিফিকেশন একসাথে 'isRead = true' করার লজিক দিতে পারেন
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: brandColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: brandColor.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_none_rounded, size: 70, color: brandColor.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'We will let you know when something happens.',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs;
          return ListView.builder(
            itemCount: notifications.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
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

              final bool isFriendRequest = type == 'friend_request';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(senderId).get(),
                builder: (context, userSnap) {
                  String senderPic = '';
                  if (userSnap.hasData && userSnap.data!.exists) {
                    final userData = userSnap.data!.data() as Map<String, dynamic>;
                    senderPic = userData['profilePic'] ?? '';
                  }

                  return Dismissible(
                    key: Key(id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red.shade400,
                      child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
                    ),
                    onDismissed: (direction) async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('notifications')
                            .doc(id)
                            .delete();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to delete: $e')),
                          );
                        }
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        // ১. ব্যাকগ্রাউন্ড গ্রেডিয়েন্ট (হোয়াইট থেকে আলতো গ্রিন শেড)
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            isRead ? Colors.white : brandColor.withOpacity(0.03),
                            brandColor.withOpacity(0.06),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20), // মডার্ন স্মুথ কর্নার
                        
                        // ২. গ্লাসি বর্ডার টাচ
                        border: Border.all(
                          color: isRead 
                              ? brandColor.withOpacity(0.08) 
                              : brandColor.withOpacity(0.18),
                          width: 1.2,
                        ),
                        
                        // ৩. ডাবল শ্যাডো দিয়ে তৈরি করা সফট গ্রিন গ্লো ও ব্লার ইফেক্ট
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: brandColor.withOpacity(isRead ? 0.03 : 0.09),
                            blurRadius: 14,
                            spreadRadius: -1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          // নোটিফিকেশনে ক্লিক করলে সেটা "Read" হয়ে যাবে
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('notifications')
                              .doc(id)
                              .update({'isRead': true});

                          if (postId.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ViewPostPage(postId: postId)),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // প্রোফাইল অ্যাভাটার + মডার্ন বর্ডার শ্যাডো
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        )
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: brandColor.withOpacity(0.1),
                                      backgroundImage: getProfileImage(senderPic),
                                      child: senderPic.isEmpty 
                                          ? const Icon(Icons.person_rounded, size: 26, color: brandColor) 
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // নোটিফিকেশন টাইটেল ও টাইম
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (timestamp != null)
                                          Row(
                                            children: [
                                              Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade500),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formatTimeAgo(timestamp),
                                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  // আনরিড নোটিফিকেশনের পাশে একটা ছোট্ট সবুজ ডট
                                  if (!isRead)
                                    const CircleAvatar(radius: 4, backgroundColor: brandColor),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // নোটিফিকেশনের বডি পার্ট
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  body,
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.3),
                                ),
                              ),
                              
                              // =========================================================
                              // অ্যাকশন বাটনসমূহ (যদি ফ্রেন্ড রিকোয়েস্ট পেন্ডিং থাকে)
                              // =========================================================
                              if (isFriendRequest && status == 'pending')
                                Padding(
                                  padding: const EdgeInsets.only(top: 12, left: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: brandColor,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                          ),
                                          onPressed: () => _handleFriendRequest(id, senderId, 'accepted', 'Request accepted'),
                                          child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: Colors.grey.shade300),
                                            foregroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                          ),
                                          onPressed: () => _handleFriendRequest(id, senderId, 'declined', 'Request declined'),
                                          child: const Text('Decline'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // পোস্ট লাইক/কমেন্টের জন্য প্রিমিয়াম টাচ বাটন
                              if (!isFriendRequest && postId.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _showReplyDialog(context, postId),
                                        icon: const Icon(Icons.quickreply_rounded, size: 16),
                                        label: const Text('Reply', style: TextStyle(fontWeight: FontWeight.w600)),
                                        style: TextButton.styleFrom(
                                          foregroundColor: brandColor,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          backgroundColor: brandColor.withOpacity(0.05),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // ফ্রেন্ড রিকোয়েস্ট অলরেডি এক্সেপ্ট বা ডিক্লাইন হয়ে থাকলে মডার্ন স্টাইল চিপস
                              if (isFriendRequest && status != 'pending')
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, left: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: status == 'accepted' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      status == 'accepted' ? '✓ Friends' : '✕ Declined',
                                      style: TextStyle(
                                        color: status == 'accepted' ? Colors.green.shade700 : Colors.red.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
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

  // ফ্রেন্ড রিকোয়েস্ট হ্যান্ডেল করার কমন ফাংশন
  void _handleFriendRequest(String id, String senderId, String action, String successMessage) async {
    await _db.respondToFriendRequest(
      notificationId: id,
      senderId: senderId,
      action: action,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage), backgroundColor: brandColor),
      );
    }
  }

  void _showReplyDialog(BuildContext context, String postId) {
    final TextEditingController controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 18,
          right: 18,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reply to this post',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Write a supportive reply...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                fillColor: const Color(0xFFF1F3F4),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: brandColor, width: 1.5),
                ),
              ),
              maxLines: 4,
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
                      const SnackBar(content: Text('Reply posted!'), backgroundColor: brandColor),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: brandColor,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Post Reply', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
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