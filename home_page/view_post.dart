import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/comment_service.dart';
import '../services/database_service.dart';
import '../home_page/image_helper.dart';
import '../home_page/user_profile_page.dart';

class ViewPostPage extends StatefulWidget {
  final String postId;
  const ViewPostPage({super.key, required this.postId});

  @override
  State<ViewPostPage> createState() => _ViewPostPageState();
}

class _ViewPostPageState extends State<ViewPostPage> {
  final TextEditingController _commentController = TextEditingController();
  final CommentService _commentService = CommentService();

  String? _replyToCommentId;
  String? _replyToUserName;

  // ব্রান্ড কালার প্যালেট
  final Color brandPrimary = const Color(0xFF2FA089);
  final Color brandLightBg = const Color(0xFFE8F5F2);

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F8),
      appBar: AppBar(
        title: const Text(
          'Post Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[100], height: 1),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').doc(widget.postId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: brandPrimary));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Post not found 🌿', style: TextStyle(color: Colors.grey)));
          }

          final postData = snapshot.data!.data() as Map<String, dynamic>;
          final post = Map<String, dynamic>.from(postData);

          final userName = post['userName'] ?? 'Anonymous';
          final userProfilePic = post['userProfilePic'] ?? '';
          final userId = post['userId'] ?? '';
          final postText = post['text'] ?? '';
          final postImage = post['imageUrl'] ?? '';   // ✅ image url
          final category = post['category'] ?? 'General';
          final timestamp = post['timestamp'] as Timestamp?;
          final likeCount = (post['likeCount'] ?? 0) as int;
          
          final commentsRaw = post['comments'];
          final List<dynamic> rawComments = (commentsRaw is List) ? commentsRaw : [];
          final rootComments = _buildCommentTree(rawComments);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// =====================================
                      /// MAIN POST CARD (PREMIUM FLUID UI)
                      /// =====================================
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: brandPrimary.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundImage: getProfileImage(userProfilePic),
                                  child: userProfilePic.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfilePage(userId: userId))),
                                        child: Text(
                                          userName, 
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)
                                        ),
                                      ),
                                      if (timestamp != null)
                                        Text(
                                          _formatTime(timestamp.toDate()), 
                                          style: TextStyle(fontSize: 11, color: Colors.grey[400])
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: brandPrimary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    category, 
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: brandPrimary)
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              postText, 
                              style: const TextStyle(fontSize: 14, height: 1.55, color: Color(0xFF2C3E50))
                            ),
                            // ================= POST IMAGE =================
                            if (postImage.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  postImage,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 250,
                                  // ✅ ঠিক করা: ডুপ্লিকেট আন্ডারস্কোর
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Divider(color: Colors.grey[50], height: 1),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                // ✅ Interactive like button with emoji picker
                                _buildLikeButton(context, likeCount),
                                const SizedBox(width: 20),
                                Row(
                                  children: [
                                    Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Colors.grey[400]),
                                    const SizedBox(width: 6),
                                    Text(
                                      rawComments.length.toString(), 
                                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12)
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      /// =====================================
                      /// COMMENTS SECTION HEADER
                      /// =====================================
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Text(
                          'Comments (${rawComments.length})', 
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)
                        ),
                      ),

                      /// =====================================
                      /// REFACTORED CLEAN COMMENTS LIST
                      /// =====================================
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rootComments.length,
                        itemBuilder: (context, index) {
                          return _buildCommentBranch(rootComments[index], context);
                        },
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),

              /// =====================================
              /// BOTTOM REPLY BAR & BAR INPUT
              /// =====================================
              _buildBottomInputField(),
            ],
          );
        },
      ),
    );
  }

  // ✅ Updated like button with emoji picker (same as PostCard)
  Widget _buildLikeButton(BuildContext context, int likeCount) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').doc(widget.postId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final likes = data?['likes'] as Map<String, dynamic>? ?? {};
        final isLiked = likes.containsKey(currentUserId);
        final currentLikeCount = data?['likeCount'] ?? 0;

        return GestureDetector(
          onTap: () => _showEmojiPicker(context, widget.postId),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: brandPrimary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: brandPrimary.withOpacity(0.10)),
            ),
            child: Row(
              children: [
                Icon(
                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isLiked ? Colors.red : brandPrimary,
                  size: 18,
                ),
                const SizedBox(width: 5),
                Text(
                  currentLikeCount.toString(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2FA089)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Emoji picker for main post like
  void _showEmojiPicker(BuildContext context, String postId) {
    final emojis = ['👍', '❤️', '😍', '😂', '😢', '😡'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('React to this post', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
            const SizedBox(height: 18),
            Wrap(
              spacing: 18,
              children: emojis.map((emoji) => GestureDetector(
                onTap: () async {
                  await DatabaseService().toggleLike(postId, emoji);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(emoji, style: const TextStyle(fontSize: 34)),
              )).toList(),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  /// =====================================
  /// SMART WRAPPER: PREVENTS NESTING OVERFLOW
  /// =====================================
  Widget _buildCommentBranch(Map<String, dynamic> rootComment, BuildContext context) {
    final replies = rootComment['replies'] as List<Map<String, dynamic>>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentTile(rootComment, context, isReply: false),
        if (replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Column(
              children: replies.map((reply) => _buildCommentTile(reply, context, isReply: true)).toList(),
            ),
          ),
      ],
    );
  }

  /// =====================================
  /// SLICK AND MODERN COMMENT TILE
  /// =====================================
  Widget _buildCommentTile(Map<String, dynamic> comment, BuildContext context, {required bool isReply}) {
    final commentId = comment['commentId'] as String? ?? '';
    final userName = comment['userName'] ?? 'Anonymous';
    final userProfilePic = comment['userProfilePic'] ?? '';
    final text = comment['text'] ?? '';
    final timestamp = (comment['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final likeCount = comment['likeCount'] ?? 0;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final likedBy = comment['likedBy'] as List? ?? [];
    final isLiked = likedBy.contains(currentUserId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isReply ? brandPrimary.withOpacity(0.03) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isReply ? brandPrimary.withOpacity(0.08) : Colors.white,
            width: 1,
          ),
          boxShadow: isReply ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundImage: getProfileImage(userProfilePic),
                  child: userProfilePic.isEmpty ? const Icon(Icons.person, size: 12, color: Colors.white) : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName, 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: isReply ? brandPrimary : Colors.black87)
                      ),
                      Text(
                        _formatTime(timestamp), 
                        style: TextStyle(fontSize: 10, color: Colors.grey[400])
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _commentService.toggleCommentLike(widget.postId, commentId),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded, 
                          size: 14, 
                          color: isLiked ? Colors.red : Colors.grey[400]
                        ),
                      ),
                    ),
                    if (likeCount > 0) ...[
                      const SizedBox(width: 2),
                      Text(
                        likeCount.toString(), 
                        style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)
                      ),
                    ],
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _replyToCommentId = commentId;
                          _replyToUserName = userName;
                        });
                      },
                      child: Text(
                        'Reply', 
                        style: TextStyle(fontSize: 11, color: brandPrimary, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 34, top: 4),
              child: Text(
                text, 
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF34495E), height: 1.4)
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =====================================
  /// PREMIUM INPUT AREA WIDGET
  /// =====================================
  Widget _buildBottomInputField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, -6))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyToCommentId != null)
            Container(
              color: brandPrimary.withOpacity(0.06),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.reply_rounded, size: 15, color: brandPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to $_replyToUserName', 
                      style: TextStyle(fontSize: 11, color: brandPrimary, fontWeight: FontWeight.bold)
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _replyToCommentId = null;
                        _replyToUserName = null;
                      });
                    },
                    child: Icon(Icons.close_rounded, size: 16, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: _replyToCommentId != null ? 'Write a reply...' : 'Share your thoughts...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F4),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _submitComment(),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: brandPrimary,
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Safe comment tree builder (Unchanged business logic)
  List<Map<String, dynamic>> _buildCommentTree(List<dynamic> flatComments) {
    Map<String, Map<String, dynamic>> commentMap = {};
    List<Map<String, dynamic>> roots = [];

    for (var item in flatComments) {
      if (item is! Map) continue;
      final comment = Map<String, dynamic>.from(item);
      final commentId = comment['commentId'] as String?;
      if (commentId == null) continue;
      commentMap[commentId] = {...comment, 'replies': <Map<String, dynamic>>[]};
    }

    for (var item in flatComments) {
      if (item is! Map) continue;
      final comment = Map<String, dynamic>.from(item);
      final commentId = comment['commentId'] as String?;
      if (commentId == null || !commentMap.containsKey(commentId)) continue;
      final parentId = comment['parentId'] as String?;
      if (parentId != null && commentMap.containsKey(parentId)) {
        commentMap[parentId]?['replies']!.add(commentMap[commentId]!);
      } else {
        roots.add(commentMap[commentId]!);
      }
    }

    roots.sort((a, b) {
      final aTime = a['timestamp'] as Timestamp? ?? Timestamp.now();
      final bTime = b['timestamp'] as Timestamp? ?? Timestamp.now();
      return bTime.compareTo(aTime);
    });

    for (var root in roots) {
      final replies = root['replies'] as List<Map<String, dynamic>>?;
      if (replies != null) {
        replies.sort((a, b) {
          final aTime = a['timestamp'] as Timestamp? ?? Timestamp.now();
          final bTime = b['timestamp'] as Timestamp? ?? Timestamp.now();
          return aTime.compareTo(bTime);
        });
      }
    }
    return roots;
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    try {
      await _commentService.addComment(
        widget.postId,
        text,
        parentId: _replyToCommentId,
      );
      _commentController.clear();
      setState(() {
        _replyToCommentId = null;
        _replyToUserName = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}