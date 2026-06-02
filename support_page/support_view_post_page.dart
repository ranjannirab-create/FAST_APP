import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../services/support_comment_service.dart';
import '../home_page/image_helper.dart';
import '../home_page/user_profile_page.dart';

class SupportViewPostPage extends StatefulWidget {
  final String postId;
  const SupportViewPostPage({super.key, required this.postId});

  @override
  State<SupportViewPostPage> createState() => _ViewPostPageState();
}

class _ViewPostPageState extends State<SupportViewPostPage> {
  final TextEditingController _commentController = TextEditingController();
  final SupportCommentService _commentService = SupportCommentService();

  String? _replyToCommentId;
  String? _replyToUserName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('support_posts').doc(widget.postId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Post not found'));
          }

          final postData = snapshot.data!.data() as Map<String, dynamic>;
          // Convert to Map<String, dynamic> safely
          final post = Map<String, dynamic>.from(postData);

          final userName = post['userName'] ?? 'Anonymous';
          final userProfilePic = post['userProfilePic'] ?? '';
          final userId = post['userId'] ?? '';
          final postText = post['text'] ?? '';
          final category = post['category'] ?? 'General';
          final timestamp = post['timestamp'] as Timestamp?;
          
          // Safe casting for likes map
          final likeCount = (post['likeCount'] ?? 0) as int;
          
          // Safe casting for comments list
          final commentsRaw = post['comments'];
          final List<dynamic> rawComments = (commentsRaw is List) ? commentsRaw : [];
          final rootComments = _buildCommentTree(rawComments);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post content card (same as before)
                      Card(
                        margin: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: getProfileImage(userProfilePic),
                                    child: userProfilePic.isEmpty ? const Icon(Icons.person) : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfilePage(userId: userId))),
                                          child: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        ),
                                        if (timestamp != null)
                                          Text(_formatTime(timestamp.toDate()), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2FA089).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(category, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2FA089))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(postText, style: const TextStyle(fontSize: 16, height: 1.5)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildLikeButton(context, likeCount),
                                  const SizedBox(width: 20),
                                  Row(
                                    children: [
                                      Icon(Icons.comment_outlined, size: 20, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(rawComments.length.toString(), style: TextStyle(color: Colors.grey[600])),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rootComments.length,
                        itemBuilder: (context, index) {
                          return _buildCommentTile(rootComments[index], context);
                        },
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              // Reply indicator and input (unchanged)
              if (_replyToCommentId != null)
                Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Replying to $_replyToUserName', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() {
                            _replyToCommentId = null;
                            _replyToUserName = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, -1))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: _replyToCommentId != null ? 'Write a reply...' : 'Write a comment...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF2FA089),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: () => _submitComment(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLikeButton(BuildContext context, int likeCount) {
    return Row(
      children: [
        Icon(Icons.favorite_border, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(likeCount.toString(), style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  // Safe comment tree builder
  List<Map<String, dynamic>> _buildCommentTree(List<dynamic> flatComments) {
    Map<String, Map<String, dynamic>> commentMap = {};
    List<Map<String, dynamic>> roots = [];

    // First, convert each comment to Map<String, dynamic> and index by commentId
    for (var item in flatComments) {
      if (item is! Map) continue;
      final comment = Map<String, dynamic>.from(item);
      final commentId = comment['commentId'] as String?;
      if (commentId == null) continue; // skip comments without id
      commentMap[commentId] = {...comment, 'replies': <Map<String, dynamic>>[]};
    }

    // Build parent-child relationships
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

    // Sort roots (newest first)
    roots.sort((a, b) {
      final aTime = a['timestamp'] as Timestamp? ?? Timestamp.now();
      final bTime = b['timestamp'] as Timestamp? ?? Timestamp.now();
      return bTime.compareTo(aTime);
    });

    // Sort replies (oldest first)
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

  Widget _buildCommentTile(Map<String, dynamic> comment, BuildContext context) {
    final commentId = comment['commentId'] as String? ?? '';
    final userName = comment['userName'] ?? 'Anonymous';
    final userProfilePic = comment['userProfilePic'] ?? '';
    final text = comment['text'] ?? '';
    final timestamp = (comment['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final likeCount = comment['likeCount'] ?? 0;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final likedBy = comment['likedBy'] as List? ?? [];
    final isLiked = likedBy.contains(currentUserId);
    final replies = comment['replies'] as List<Map<String, dynamic>>? ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        elevation: 0,
        color: Colors.grey[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: getProfileImage(userProfilePic),
                    child: userProfilePic.isEmpty ? const Icon(Icons.person, size: 14) : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(_formatTime(timestamp), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _commentService.toggleCommentLike(widget.postId, commentId),
                        child: Row(
                          children: [
                            Icon(isLiked ? Icons.favorite : Icons.favorite_border, size: 16, color: isLiked ? Colors.red : Colors.grey),
                            const SizedBox(width: 4),
                            Text(likeCount.toString(), style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _replyToCommentId = commentId;
                            _replyToUserName = userName;
                          });
                        },
                        child: Text('Reply', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(text, style: const TextStyle(fontSize: 14)),
              if (replies.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Column(
                    children: replies.map((reply) => _buildCommentTile(reply, context)).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comment added!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
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