

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home_page/user_profile_page.dart';
import '../support_page/support_view_post_page.dart';
import '../home_page/image_helper.dart';
import '../services/support_comment_service.dart';
import '../services/database_service.dart'; // ✅ DatabaseService যোগ করা হয়েছে (ব্যাজ দেওয়ার জন্য)

class SupportPostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final String postId;

  const SupportPostCard({
    super.key,
    required this.post,
    required this.postId,
  });
  
  Object? get currentUserId => null;

  @override
  Widget build(BuildContext context) {
    final userName = post['userName'] ?? 'Anonymous';
    final userProfilePic = post['userProfilePic'] ?? '';
    final postText = post['text'] ?? '';
    final userId = post['userId'] ?? '';
    final category = post['category'] ?? 'Mood';
    final timestamp = post['timestamp'] as Timestamp?;

    final likesRaw = post['likes'];
    final Map<String, dynamic> likes =
        (likesRaw is Map) ? Map<String, dynamic>.from(likesRaw) : {};
    final likeCount = (post['likeCount'] ?? 0) as int;
    final commentCount = (post['commentCount'] ?? 0) as int;

    // ✅ পোস্টের মালিকের আইডি বের করা (ব্যাজ দেওয়ার অনুমতি যাচাই)
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isPostOwner = currentUserId == userId;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SupportViewPostPage(postId: postId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF9FFFC), Color(0xFFF1FBF7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF2FA089).withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2FA089).withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2FA089).withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header (অপরিবর্তিত)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserProfilePage(userId: userId),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF2FA089).withOpacity(0.25),
                              width: 1.5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF2FA089),
                            backgroundImage: getProfileImage(userProfilePic),
                            child: userProfilePic.isEmpty
                                ? const Icon(Icons.person, color: Colors.white, size: 18)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    userName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2FA089).withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      color: Color(0xFF2FA089),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            if (timestamp != null)
                              Text(
                                _getTimeAgo(timestamp),
                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (postText.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFF2FA089).withOpacity(0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ExpandableText(text: postText),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFF2FA089).withOpacity(0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildLikeButton(context, postId, likes, likeCount),
                      const SizedBox(width: 10),
                      _buildCommentButton(context, postId, commentCount),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2FA089).withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_border_rounded,
                          size: 18,
                          color: Color(0xFF2FA089),
                        ),
                      ),
                    ],
                  ),
                  if (commentCount > 0) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _showCommentDialog(context, postId),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(
                          'View all $commentCount comments',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    // ✅ কমেন্ট লিস্ট প্রিভিউ (ঐচ্ছিক – এখানে কমেন্ট দেখানোর দরকার নেই, কারণ ডায়ালগেই দেখাবে)
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(Timestamp timestamp) {
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  Widget _buildLikeButton(
    BuildContext context,
    String postId,
    Map<String, dynamic> likes,
    int likeCount,
  ) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isLiked = currentUserId.isNotEmpty && likes.containsKey(currentUserId);

    return GestureDetector(
      onTap: () => _showEmojiPicker(context, postId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF2FA089).withOpacity(0.10),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF2FA089).withOpacity(0.10)),
        ),
        child: Row(
          children: [
            Icon(
              isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isLiked ? Colors.red : const Color(0xFF2FA089),
              size: 18,
            ),
            const SizedBox(width: 5),
            Text(
              likeCount.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2FA089),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentButton(BuildContext context, String postId, int commentCount) {
    return GestureDetector(
      onTap: () => _showCommentDialog(context, postId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF2FA089).withOpacity(0.10),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF2FA089).withOpacity(0.10)),
        ),
        child: Row(
          children: [
            const Icon(Icons.mode_comment_outlined, size: 17, color: Color(0xFF2FA089)),
            const SizedBox(width: 5),
            Text(
              commentCount.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2FA089),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleSupportLike(String postId, String emoji) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final postRef = FirebaseFirestore.instance.collection('support_posts').doc(postId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final doc = await transaction.get(postRef);
      if (!doc.exists) return;

      Map<String, dynamic> likes = Map.from(doc.data()?['likes'] ?? {});
      if (likes.containsKey(userId)) {
        likes.remove(userId);
      } else {
        likes[userId] = emoji;
      }
      final likeCount = likes.length;
      transaction.update(postRef, {'likes': likes, 'likeCount': likeCount});
    });
  }

  void _showEmojiPicker(BuildContext context, String postId) {
    const emojis = ['👍', '❤️', '😍', '😂', '😢', '😡'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'React to this post',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 18,
              children: emojis.map((emoji) {
                return GestureDetector(
                  onTap: () async {
                    await _toggleSupportLike(postId, emoji);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(emoji, style: const TextStyle(fontSize: 34)),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  // ✅ পরিবর্তিত কমেন্ট ডায়ালগ – এখন কমেন্টের পাশে ব্যাজ বাটন দেখাবে (শুধু পোস্টের মালিকের জন্য)
  void _showCommentDialog(BuildContext context, String postId) {
    final controller = TextEditingController();
    bool isSubmitting = false;

    // কমেন্ট লোড করার জন্য StreamBuilder
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // কমেন্ট ইনপুট ফিল্ড
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 16,
                      right: 16,
                      top: 18,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Write your comment...',
                              filled: true,
                              fillColor: const Color(0xFFF4F7F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2FA089),
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final comment = controller.text.trim();
                                  if (comment.isEmpty) return;
                                  setState(() => isSubmitting = true);
                                  try {
                                    await SupportCommentService().addComment(postId, comment);
                                    controller.clear();
                                    if (context.mounted) setState(() => isSubmitting = false);
                                  } catch (e) {
                                    setState(() => isSubmitting = false);
                                  }
                                },
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // কমেন্ট লিস্ট
                  Expanded(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('support_posts')
                          .doc(postId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final postData = snapshot.data!.data() as Map<String, dynamic>?;
                        final comments = List.from(postData?['comments'] ?? []);
                        if (comments.isEmpty) {
                          return const Center(child: Text('No comments yet'));
                        }
                        return ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.all(12),
                          itemCount: comments.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            final commentUser = comment['userName'] ?? 'Anonymous';
                            final commentText = comment['text'] ?? '';
                            final commentUserId = comment['userId'] ?? '';
                            final commentProfilePic = comment['userProfilePic'] ?? '';
                            final timestamp = comment['timestamp'] as Timestamp?;
                            final likeCount = comment['likeCount'] ?? 0;
                            final badgeCount = comment['badgeCount'] ?? 0;
                            final isCommentOwner = currentUserId == commentUserId;
                            final currentPostOwnerId = postData?['userId'] ?? '';

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: commentProfilePic.isNotEmpty
                                      ? NetworkImage(commentProfilePic)
                                      : null,
                                  child: commentProfilePic.isEmpty
                                      ? const Icon(Icons.person, size: 16)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        commentUser,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(commentText, style: const TextStyle(fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            _getTimeAgo(timestamp ?? Timestamp.now()),
                                            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                                          ),
                                          const SizedBox(width: 12),
                                          // লাইক বাটন (কমেন্ট লাইক)
                                          GestureDetector(
                                            onTap: () async {
                                              await SupportCommentService().toggleCommentLike(postId, comment['commentId']);
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.favorite_border,
                                                  size: 14,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  likeCount.toString(),
                                                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // ব্যাজ আইকন (শুধু পোস্টের মালিকের জন্য এবং কমেন্টের মালিক নন)
                                          if (currentPostOwnerId == currentUserId && !isCommentOwner)
                                            GestureDetector(
                                              onTap: () async {
                                                try {
                                                  await DatabaseService().awardSupportBadge(
                                                    postId: postId,
                                                    commentId: comment['commentId'],
                                                    helperUserId: commentUserId,
                                                  );
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('সাপোর্ট ব্যাজ দেওয়া হয়েছে!')),
                                                    );
                                                  }
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('ব্যাজ দেওয়া যায়নি: $e')),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber.shade100,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.verified, size: 12, color: Colors.amber[700]),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      '$badgeCount',
                                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber[800]),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ExpandableText উইজেট (আপনার আগের মতোই)
class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText({super.key, required this.text});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final isLong = widget.text.length > 180;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: expanded ? null : 6,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isLong)
          GestureDetector(
            onTap: () => setState(() => expanded = !expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                expanded ? 'See less' : '... See more',
                style: const TextStyle(
                  color: Color(0xFF2FA089),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}