import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/comment_service.dart';

class SupportPostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final String postId;

  const SupportPostCard({
    super.key,
    required this.post,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    final postText = post['text'] ?? '';
    final category = post['category'] ?? 'Support';
    final timestamp = post['timestamp'] as Timestamp?;

    final likesRaw = post['likes'];

    final Map<String, dynamic> likes =
        (likesRaw is Map)
            ? Map<String, dynamic>.from(likesRaw)
            : {};

    final likeCount = (post['likeCount'] ?? 0) as int;
    final commentCount = (post['commentCount'] ?? 0) as int;

    // ✅ FIXED: real user id (important for like system)
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? '';

    final isLiked = likes.containsKey(currentUserId);

    return GestureDetector(
      onTap: () {
        // ❌ intentionally disabled (anonymous system)
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF9FFFC), Color(0xFFF1FBF7)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF2FA089).withOpacity(0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2FA089).withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Row(
                children: [
                  // Anonymous Avatar (NO PROFILE ACCESS)
                  Container(
                    height: 38,
                    width: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2FA089),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Anonymous",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2FA089).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2FA089),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ================= TEXT =================
              Text(
                postText,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 12),

              // ================= ACTIONS =================
              Row(
                children: [
                  _buildHelpfulButton(isLiked, likeCount),
                  const SizedBox(width: 10),
                  _buildCommentButton(commentCount),
                  const Spacer(),

                  const Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: Color(0xFF2FA089),
                  ),
                ],
              ),

              if (commentCount > 0) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    _showCommentDialog(context);
                  },
                  child: Text(
                    'View all $commentCount support replies',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ================= HELPFUL BUTTON =================
  Widget _buildHelpfulButton(bool isLiked, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2FA089).withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: Colors.redAccent,
            size: 18,
          ),
          const SizedBox(width: 5),
          Text(
            "$count Helpful",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2FA089),
            ),
          ),
        ],
      ),
    );
  }

  // ================= COMMENT =================
  Widget _buildCommentButton(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2FA089).withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.support_agent,
            size: 17,
            color: Color(0xFF2FA089),
          ),
          const SizedBox(width: 5),
          Text(
            "$count Replies",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2FA089),
            ),
          ),
        ],
      ),
    );
  }

  // ================= COMMENT SHEET =================
  void _showCommentDialog(BuildContext context) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Write supportive reply...",
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isEmpty) return;

                await CommentService().addComment(postId, text);

                Navigator.pop(context);
              },
              child: const Text("Send Support"),
            ),
          ],
        ),
      ),
    );
  }
}