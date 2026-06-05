/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home_page/user_profile_page.dart';
import '../home_page/view_post.dart';
import '../home_page/image_helper.dart';
import '../services/database_service.dart';
import '../services/comment_service.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final String postId;

  const PostCard({
    super.key,
    required this.post,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    final userName = post['userName'] ?? 'Anonymous';
    final userProfilePic = post['userProfilePic'] ?? '';
    final postText = post['text'] ?? '';
    final userId = post['userId'] ?? '';
    final category = post['category'] ?? 'Mood';
    final timestamp = post['timestamp'] as Timestamp?;
    
    // ফায়ারবেস থেকে রোল ডাটা রিসিভ করা (যে কোনো একটি কী-তে থাকলেই কাজ করবে)
    final userRole = post['userRole'] ?? post['role'] ?? '';

    final likesRaw = post['likes'];

    final Map<String, dynamic> likes =
        (likesRaw is Map)
            ? Map<String, dynamic>.from(likesRaw)
            : {};

    final likeCount = (post['likeCount'] ?? 0) as int;
    final commentCount = (post['commentCount'] ?? 0) as int;

    // প্রিমিয়াম পেস্ট গ্রিন কালার থিম
    const Color primaryColor = Color(0xFF2FA089);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewPostPage(postId: postId),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF9FFFC),
              Color(0xFFF1FBF7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          borderRadius: BorderRadius.circular(22),

          border: Border.all(
            color: primaryColor.withOpacity(0.10),
          ),

          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Stack(
          children: [
            // top glow
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                height: 80,
                width: 80,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.05),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ================= HEADER =================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // নামের সাথে রোল অ্যালাইন করতে সেন্টার করা হয়েছে

                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => UserProfilePage(
                                    userId: userId,
                                  ),
                            ),
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(2),

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            border: Border.all(
                              color: primaryColor.withOpacity(0.25),
                              width: 1.5,
                            ),
                          ),

                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: primaryColor,
                            backgroundImage: getProfileImage(
                              userProfilePic,
                            ),
                            child: userProfilePic.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 18,
                                  )
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // ইউজারের নাম (নাম বড় হলে যাতে ডিজাইন ভেঙে না যায়)
                                Flexible(
                                  child: Text(
                                    userName,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),

                                // যদি ইউজারের রোল ডাটা থাকে, তবেই কেবল ব্যাজটি দেখাবে
                                if (userRole.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2, // পোস্ট কার্ডের জন্য পারফেক্ট মিনিমাল সাইজ
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.08), // হালকা ব্যাকগ্রাউন্ড
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: primaryColor.withOpacity(0.2), // বর্ডার অপাসিটি
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      userRole,
                                      style: const TextStyle(
                                        color: primaryColor,
                                        fontSize: 9.5, // টেক্সট সাইজ ছোট ও প্রিমিয়াম রাখা হয়েছে
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 2),

                            if (timestamp != null)
                              Text(
                                _getTimeAgo(timestamp),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 8),

                      // ক্যাটাগরি ট্যাগ (ডান পাশে থাকবে)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ================= POST TEXT =================

                  if (postText.isNotEmpty) ...[
                    const SizedBox(height: 12),

                    Container(
                      height: 1,

                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            primaryColor.withOpacity(0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    ExpandableText(
                      text: postText,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // ================= DIVIDER =================

                  Container(
                    height: 1,

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          primaryColor.withOpacity(0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ================= ACTIONS =================

                  Row(
                    children: [
                      _buildLikeButton(
                        context,
                        postId,
                        likes,
                        likeCount,
                      ),

                      const SizedBox(width: 10),

                      _buildCommentButton(
                        context,
                        postId,
                        commentCount,
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.all(7),

                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.bookmark_border_rounded,
                          size: 18,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),

                  // ================= VIEW COMMENTS =================

                  if (commentCount > 0) ...[
                    const SizedBox(height: 10),

                    GestureDetector(
                      onTap: () {
                        _showCommentDialog(
                          context,
                          postId,
                        );
                      },

                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 2,
                        ),

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
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // TIME
  // =====================================================

  String _getTimeAgo(Timestamp timestamp) {
    final diff = DateTime.now().difference(
      timestamp.toDate(),
    );

    if (diff.inMinutes < 1) {
      return 'Just now';
    }

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }

    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }

    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }

    return '${(diff.inDays / 7).floor()}w ago';
  }

  // =====================================================
  // LIKE BUTTON
  // =====================================================

  Widget _buildLikeButton(
    BuildContext context,
    String postId,
    Map<String, dynamic> likes,
    int likeCount,
  ) {
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? '';

    final isLiked =
        currentUserId.isNotEmpty &&
        likes.containsKey(currentUserId);

    return GestureDetector(
      onTap: () {
        _showEmojiPicker(context, postId);
      },

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),

        decoration: BoxDecoration(
          color: const Color(
            0xFF2FA089,
          ).withOpacity(0.10),

          borderRadius: BorderRadius.circular(
            30,
          ),

          border: Border.all(
            color: const Color(
              0xFF2FA089,
            ).withOpacity(0.10),
          ),
        ),

        child: Row(
          children: [
            Icon(
              isLiked
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,

              color:
                  isLiked
                      ? Colors.red
                      : const Color(
                        0xFF2FA089,
                      ),

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

  // =====================================================
  // COMMENT BUTTON
  // =====================================================

  Widget _buildCommentButton(
    BuildContext context,
    String postId,
    int commentCount,
  ) {
    return GestureDetector(
      onTap: () {
        _showCommentDialog(context, postId);
      },

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),

        decoration: BoxDecoration(
          color: const Color(
            0xFF2FA089,
          ).withOpacity(0.10),

          borderRadius: BorderRadius.circular(
            30,
          ),

          border: Border.all(
            color: const Color(
              0xFF2FA089,
            ).withOpacity(0.10),
          ),
        ),

        child: Row(
          children: [
            const Icon(
              Icons.mode_comment_outlined,
              size: 17,
              color: Color(0xFF2FA089),
            ),

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

  // =====================================================
  // EMOJI PICKER
  // =====================================================

  void _showEmojiPicker(
    BuildContext context,
    String postId,
  ) {
    final emojis = [
      '👍',
      '❤️',
      '😍',
      '😂',
      '😢',
      '😡',
    ];

    showModalBottomSheet(
      context: context,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(
              vertical: 18,
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Text(
                  'React to this post',

                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 18),

                Wrap(
                  spacing: 18,

                  children:
                      emojis.map((emoji) {
                        return GestureDetector(
                          onTap: () async {
                            await DatabaseService()
                                .toggleLike(
                                  postId,
                                  emoji,
                                );

                            if (context.mounted) {
                              Navigator.pop(
                                context,
                              );
                            }
                          },

                          child: Text(
                            emoji,
                            style: const TextStyle(
                              fontSize: 34,
                            ),
                          ),
                        );
                      }).toList(),
                ),

                const SizedBox(height: 18),
              ],
            ),
          ),
    );
  }

  // =====================================================
  // COMMENT DIALOG
  // =====================================================

  void _showCommentDialog(
    BuildContext context,
    String postId,
  ) {
    final controller = TextEditingController();

    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        MediaQuery.of(
                          context,
                        ).viewInsets.bottom +
                        18,

                    left: 16,
                    right: 16,
                    top: 18,
                  ),

                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      TextField(
                        controller: controller,

                        maxLines: 4,

                        decoration: InputDecoration(
                          hintText:
                              'Write your comment...',

                          filled: true,

                          fillColor:
                              const Color(
                                0xFFF4F7F5,
                              ),

                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                                  18,
                                ),

                            borderSide:
                                BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(
                                      0xFF2FA089,
                                    ),

                                padding:
                                    const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),

                                shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                            16,
                                          ),
                                    ),
                              ),

                          onPressed:
                              isSubmitting
                                  ? null
                                  : () async {
                                    final comment =
                                        controller
                                            .text
                                            .trim();

                                    if (comment
                                        .isEmpty) {
                                      return;
                                    }

                                    setState(() {
                                      isSubmitting =
                                          true;
                                    });

                                    try {
                                      await CommentService()
                                          .addComment(
                                            postId,
                                            comment,
                                          );

                                      if (context
                                          .mounted) {
                                        Navigator.pop(
                                          context,
                                        );
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isSubmitting =
                                            false;
                                      });
                                    }
                                  },

                          child:
                              isSubmitting
                                  ? const CircularProgressIndicator(
                                    color:
                                        Colors
                                            .white,
                                  )
                                  : const Text(
                                    'Post Comment',

                                    style: TextStyle(
                                      color:
                                          Colors
                                              .white,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}

// =====================================================
// EXPANDABLE TEXT
// =====================================================

class ExpandableText extends StatefulWidget {
  final String text;

  const ExpandableText({
    super.key,
    required this.text,
  });

  @override
  State<ExpandableText> createState() =>
      _ExpandableTextState();
}

class _ExpandableTextState
    extends State<ExpandableText> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final isLong =
        widget.text.length > 180;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          widget.text,

          maxLines:
              expanded
                  ? null
                  : 6,

          overflow:
              expanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,

          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),

        if (isLong)
          GestureDetector(
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },

            child: Padding(
              padding: const EdgeInsets.only(
                top: 4,
              ),

              child: Text(
                expanded
                    ? 'See less'
                    : '... See more',

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
*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home_page/user_profile_page.dart';
import '../home_page/view_post.dart';
import '../home_page/image_helper.dart';
import '../services/database_service.dart';
import '../services/comment_service.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final String postId;

  const PostCard({
    super.key,
    required this.post,
    required this.postId,
  });

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
        (likesRaw is Map)
            ? Map<String, dynamic>.from(likesRaw)
            : {};

    final likeCount = (post['likeCount'] ?? 0) as int;

    final commentCount = (post['commentCount'] ?? 0) as int;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewPostPage(postId: postId),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF9FFFC),
              Color(0xFFF1FBF7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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

        child: Stack(
          children: [
            // top glow
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                height: 80,
                width: 80,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(
                    0xFF2FA089,
                  ).withOpacity(0.05),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ================= HEADER =================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => UserProfilePage(
                                    userId: userId,
                                  ),
                            ),
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(2),

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            border: Border.all(
                              color: const Color(
                                0xFF2FA089,
                              ).withOpacity(0.25),

                              width: 1.5,
                            ),
                          ),

                          child: CircleAvatar(
                            radius: 20,

                            backgroundColor:
                                const Color(
                                  0xFF2FA089,
                                ),

                            backgroundImage:
                                getProfileImage(
                                  userProfilePic,
                                ),

                            child:
                                userProfilePic
                                        .isEmpty
                                    ? const Icon(
                                      Icons.person,
                                      color:
                                          Colors
                                              .white,
                                      size: 18,
                                    )
                                    : null,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    userName,

                                    style:
                                        const TextStyle(
                                          fontSize:
                                              14,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          color:
                                              Colors
                                                  .black87,
                                        ),
                                  ),
                                ),

                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal:
                                            10,
                                        vertical:
                                            5,
                                      ),

                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF2FA089,
                                    ).withOpacity(
                                      0.10,
                                    ),

                                    borderRadius:
                                        BorderRadius.circular(
                                          30,
                                        ),
                                  ),

                                  child: Text(
                                    category,

                                    style:
                                        const TextStyle(
                                          color: Color(
                                            0xFF2FA089,
                                          ),
                                          fontSize:
                                              10,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 2),

                            if (timestamp != null)
                              Text(
                                _getTimeAgo(
                                  timestamp,
                                ),

                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      Colors
                                          .grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ================= POST TEXT =================

                  if (postText.isNotEmpty) ...[
                    const SizedBox(height: 12),

                    Container(
                      height: 1,

                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,

                            const Color(
                              0xFF2FA089,
                            ).withOpacity(0.08),

                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    ExpandableText(
                      text: postText,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // ================= DIVIDER =================

                  Container(
                    height: 1,

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,

                          const Color(
                            0xFF2FA089,
                          ).withOpacity(0.08),

                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ================= ACTIONS =================

                  Row(
                    children: [
                      _buildLikeButton(
                        context,
                        postId,
                        likes,
                        likeCount,
                      ),

                      const SizedBox(width: 10),

                      _buildCommentButton(
                        context,
                        postId,
                        commentCount,
                      ),

                      const Spacer(),

                      Container(
                        padding:
                            const EdgeInsets.all(7),

                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF2FA089,
                          ).withOpacity(0.08),

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

                  // ================= VIEW COMMENTS =================

                  if (commentCount > 0) ...[
                    const SizedBox(height: 10),

                    GestureDetector(
                      onTap: () {
                        _showCommentDialog(
                          context,
                          postId,
                        );
                      },

                      child: Padding(
                        padding:
                            const EdgeInsets.only(
                              left: 2,
                            ),

                        child: Text(
                          'View all $commentCount comments',

                          style: TextStyle(
                            color:
                                Colors.grey[600],
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // TIME
  // =====================================================

  String _getTimeAgo(Timestamp timestamp) {
    final diff = DateTime.now().difference(
      timestamp.toDate(),
    );

    if (diff.inMinutes < 1) {
      return 'Just now';
    }

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }

    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }

    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }

    return '${(diff.inDays / 7).floor()}w ago';
  }

  // =====================================================
  // LIKE BUTTON
  // =====================================================

  Widget _buildLikeButton(
    BuildContext context,
    String postId,
    Map<String, dynamic> likes,
    int likeCount,
  ) {
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? '';

    final isLiked =
        currentUserId.isNotEmpty &&
        likes.containsKey(currentUserId);

    return GestureDetector(
      onTap: () {
        _showEmojiPicker(context, postId);
      },

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),

        decoration: BoxDecoration(
          color: const Color(
            0xFF2FA089,
          ).withOpacity(0.10),

          borderRadius: BorderRadius.circular(
            30,
          ),

          border: Border.all(
            color: const Color(
              0xFF2FA089,
            ).withOpacity(0.10),
          ),
        ),

        child: Row(
          children: [
            Icon(
              isLiked
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,

              color:
                  isLiked
                      ? Colors.red
                      : const Color(
                        0xFF2FA089,
                      ),

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

  // =====================================================
  // COMMENT BUTTON
  // =====================================================

  Widget _buildCommentButton(
    BuildContext context,
    String postId,
    int commentCount,
  ) {
    return GestureDetector(
      onTap: () {
        _showCommentDialog(context, postId);
      },

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),

        decoration: BoxDecoration(
          color: const Color(
            0xFF2FA089,
          ).withOpacity(0.10),

          borderRadius: BorderRadius.circular(
            30,
          ),

          border: Border.all(
            color: const Color(
              0xFF2FA089,
            ).withOpacity(0.10),
          ),
        ),

        child: Row(
          children: [
            const Icon(
              Icons.mode_comment_outlined,
              size: 17,
              color: Color(0xFF2FA089),
            ),

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

  // =====================================================
  // EMOJI PICKER
  // =====================================================

  void _showEmojiPicker(
    BuildContext context,
    String postId,
  ) {
    final emojis = [
      '👍',
      '❤️',
      '😍',
      '😂',
      '😢',
      '😡',
    ];

    showModalBottomSheet(
      context: context,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(
              vertical: 18,
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Text(
                  'React to this post',

                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 18),

                Wrap(
                  spacing: 18,

                  children:
                      emojis.map((emoji) {
                        return GestureDetector(
                          onTap: () async {
                            await DatabaseService()
                                .toggleLike(
                                  postId,
                                  emoji,
                                );

                            if (context.mounted) {
                              Navigator.pop(
                                context,
                              );
                            }
                          },

                          child: Text(
                            emoji,
                            style: const TextStyle(
                              fontSize: 34,
                            ),
                          ),
                        );
                      }).toList(),
                ),

                const SizedBox(height: 18),
              ],
            ),
          ),
    );
  }

  // =====================================================
  // COMMENT DIALOG
  // =====================================================

  void _showCommentDialog(
    BuildContext context,
    String postId,
  ) {
    final controller = TextEditingController();

    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        MediaQuery.of(
                          context,
                        ).viewInsets.bottom +
                        18,

                    left: 16,
                    right: 16,
                    top: 18,
                  ),

                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      TextField(
                        controller: controller,

                        maxLines: 4,

                        decoration: InputDecoration(
                          hintText:
                              'Write your comment...',

                          filled: true,

                          fillColor:
                              const Color(
                                0xFFF4F7F5,
                              ),

                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                                  18,
                                ),

                            borderSide:
                                BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(
                                      0xFF2FA089,
                                    ),

                                padding:
                                    const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),

                                shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                            16,
                                          ),
                                    ),
                              ),

                          onPressed:
                              isSubmitting
                                  ? null
                                  : () async {
                                    final comment =
                                        controller
                                            .text
                                            .trim();

                                    if (comment
                                        .isEmpty) {
                                      return;
                                    }

                                    setState(() {
                                      isSubmitting =
                                          true;
                                    });

                                    try {
                                      await CommentService()
                                          .addComment(
                                            postId,
                                            comment,
                                          );

                                      if (context
                                          .mounted) {
                                        Navigator.pop(
                                          context,
                                        );
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isSubmitting =
                                            false;
                                      });
                                    }
                                  },

                          child:
                              isSubmitting
                                  ? const CircularProgressIndicator(
                                    color:
                                        Colors
                                            .white,
                                  )
                                  : const Text(
                                    'Post Comment',

                                    style: TextStyle(
                                      color:
                                          Colors
                                              .white,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}

// =====================================================
// EXPANDABLE TEXT
// =====================================================

class ExpandableText extends StatefulWidget {
  final String text;

  const ExpandableText({
    super.key,
    required this.text,
  });

  @override
  State<ExpandableText> createState() =>
      _ExpandableTextState();
}

class _ExpandableTextState
    extends State<ExpandableText> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final isLong =
        widget.text.length > 180;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          widget.text,

          maxLines:
              expanded
                  ? null
                  : 6,

          overflow:
              expanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,

          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),

        if (isLong)
          GestureDetector(
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },

            child: Padding(
              padding: const EdgeInsets.only(
                top: 4,
              ),

              child: Text(
                expanded
                    ? 'See less'
                    : '... See more',

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