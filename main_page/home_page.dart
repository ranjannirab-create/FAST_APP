/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_page/create_post_page.dart';
import '../home_page/user_profile_page.dart';
import '../home_page/post_categories.dart';
import '../services/database_service.dart';
import '../home_page/comment_service.dart';
import '../home_page/image_helper.dart';   // image helper
import '../home_page/view_post.dart';      // detailed post view

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = PostCategory.all;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // ============ HEADER SECTION ============
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gradient header
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF2FA089), const Color(0xFF1E7A6E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 16, top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Free Mind 🌿',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Make Life Relax with Good Community',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good Morning! ☀️', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                        const SizedBox(height: 4),
                        Text(displayName, style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostPage())),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.edit_note, color: Color(0xFF2FA089), size: 22),
                                SizedBox(width: 12),
                                Text("What's on your mind today?", style: TextStyle(color: Colors.grey, fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('Filter by Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: PostCategory.values.map((category) {
                              final isSelected = _selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedCategory = category),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF2FA089) : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: isSelected ? const Color(0xFF2FA089) : Colors.grey[300]!, width: 1.5),
                                    ),
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.grey[700],
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ============ POSTS LIST ============
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(child: Center(child: Padding(padding: const EdgeInsets.all(20), child: CircularProgressIndicator(color: const Color(0xFF2FA089)))));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.article_outlined, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No posts yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                          const SizedBox(height: 8),
                          Text('Be the first to share your thoughts!', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final allPosts = snapshot.data!.docs;
              final filteredPosts = allPosts.where((postDoc) {
                final post = postDoc.data() as Map<String, dynamic>;
                final category = post['category'] ?? PostCategory.lifestyle;
                if (_selectedCategory == PostCategory.all) return true;
                return category == _selectedCategory;
              }).toList();

              if (filteredPosts.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No posts in this category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == filteredPosts.length) return const SizedBox(height: 80);
                    final post = filteredPosts[index].data() as Map<String, dynamic>;
                    final postId = filteredPosts[index].id;
                    final userName = post['userName'] ?? 'Anonymous User';
                    final userProfilePic = post['userProfilePic'] ?? '';
                    final postText = post['text'] ?? '';
                    final userId = post['userId'] ?? '';
                    final category = post['category'] ?? PostCategory.lifestyle;
                    final timestamp = post['timestamp'] as Timestamp?;

                    // SAFE CASTING for likes map
                    final likesRaw = post['likes'];
                    final Map<String, dynamic> likes = (likesRaw is Map) ? Map<String, dynamic>.from(likesRaw) : {};
                    final likeCount = (post['likeCount'] ?? 0) as int;
                    
                    // SAFE CASTING for comments list
                    final commentsRaw = post['comments'];
                    final List<dynamic> comments = (commentsRaw is List) ? commentsRaw : [];
                    final commentCount = (post['commentCount'] ?? 0) as int;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ViewPostPage(postId: postId)),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // POST HEADER with PROFILE PICTURE
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfilePage(userId: userId))),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: const Color(0xFF2FA089),
                                            backgroundImage: getProfileImage(userProfilePic),
                                            child: userProfilePic.isEmpty
                                                ? const Icon(Icons.person, color: Colors.white, size: 20)
                                                : null,
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                              if (timestamp != null)
                                                Text(_getTimeAgo(timestamp), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2FA089).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2FA089))),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (postText.isNotEmpty) Text(postText, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    _buildLikeButton(context, postId, likes, likeCount),
                                    const SizedBox(width: 16),
                                    _buildCommentButton(context, postId, commentCount),
                                    const Spacer(),
                                    Icon(Icons.bookmark_outline, size: 20, color: Colors.grey[500]),
                                  ],
                                ),
                                if (comments.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Divider(color: Colors.grey[200], height: 1),
                                  const SizedBox(height: 10),
                                  _buildCommentPreview(comments),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: filteredPosts.length,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostPage())),
        backgroundColor: const Color(0xFF2FA089),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // ---------- Helper methods ----------
  String _getTimeAgo(Timestamp timestamp) {
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  Widget _buildLikeButton(BuildContext context, String postId, Map<String, dynamic> likes, int likeCount) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isLiked = currentUserId.isNotEmpty && likes.containsKey(currentUserId);
    return GestureDetector(
      onTap: () => _showEmojiPicker(context, postId),
      child: Row(
        children: [
          Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey[600], size: 20),
          const SizedBox(width: 6),
          Text(likeCount.toString(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700])),
        ],
      ),
    );
  }

  void _showEmojiPicker(BuildContext context, String postId) {
    final emojis = ['👍', '❤️', '😍', '😂', '😢', '😡'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text('React to this post', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600])),
            ),
            Wrap(
              spacing: 20,
              runSpacing: 16,
              children: emojis.map((emoji) => GestureDetector(
                onTap: () async {
                  await DatabaseService().toggleLike(postId, emoji);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(emoji, style: const TextStyle(fontSize: 36)),
              )).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentButton(BuildContext context, String postId, int commentCount) {
    return GestureDetector(
      onTap: () => _showCommentDialog(context, postId),
      child: Row(
        children: [
          Icon(Icons.comment_outlined, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(commentCount.toString(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700])),
        ],
      ),
    );
  }

  void _showCommentDialog(BuildContext context, String postId) {
    final controller = TextEditingController();
    bool isSubmitting = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16, left: 16, right: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add a Comment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Write your comment...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2FA089), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                maxLines: 4,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2FA089),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: isSubmitting ? null : () async {
                  final comment = controller.text.trim();
                  if (comment.isEmpty) return;
                  setState(() => isSubmitting = true);
                  try {
                    await CommentService().addComment(postId, comment);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comment posted! ✨'), duration: Duration(seconds: 2)));
                    }
                  } catch (e) {
                    setState(() => isSubmitting = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                    }
                  }
                },
                child: isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Post Comment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentPreview(List<dynamic> comments) {
    final recent = comments.reversed.take(2).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: recent.map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF2FA089).withOpacity(0.2),
              backgroundImage: getProfileImage(c['userProfilePic']),
              child: (c['userProfilePic'] == null || c['userProfilePic'].isEmpty)
                  ? const Icon(Icons.person, size: 12, color: Color(0xFF2FA089))
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '${c['userName']}: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13)),
                    TextSpan(text: c['text'] ?? '', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
*/


/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_page/create_post_page.dart';
import '../home_page/post_categories.dart';
import '../home_page_ui/home_header.dart';
import '../home_page_ui/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HomeHeader(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) => setState(() => _selectedCategory = category),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: const Color(0xFF2FA089)),
                    ),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.article_outlined, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No posts yet',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to share your thoughts!',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final allPosts = snapshot.data!.docs;
              final filteredPosts = allPosts.where((postDoc) {
                final post = postDoc.data() as Map<String, dynamic>;
                final category = post['category'] ?? PostCategory.lifestyle;
                if (_selectedCategory == PostCategory.all) return true;
                return category == _selectedCategory;
              }).toList();

              if (filteredPosts.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        'No posts in this category',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == filteredPosts.length) return const SizedBox(height: 80);
                    final postData = filteredPosts[index].data() as Map<String, dynamic>;
                    final postId = filteredPosts[index].id;
                    return PostCard(post: postData, postId: postId);
                  },
                  childCount: filteredPosts.length,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostPage())),
        backgroundColor: const Color(0xFF2FA089),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home_page/create_post_page.dart';
import '../home_page/post_categories.dart';
import '../home_page_ui/home_header.dart';
import '../home_page_ui/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // ✅ default selected category
  String _selectedCategory = PostCategory.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: CustomScrollView(
        slivers: [

          // ✅ Header Section
          SliverToBoxAdapter(
            child: HomeHeader(
              selectedCategory: _selectedCategory,

              onCategoryChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          ),

          // ✅ Posts Section
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('timestamp', descending: true)
                .snapshots(),

            builder: (context, snapshot) {

              // ✅ Loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFF2FA089),
                      ),
                    ),
                  ),
                );
              }

              // ✅ No Data
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Column(
                        children: [

                          Icon(
                            Icons.article_outlined,
                            size: 70,
                            color: Colors.grey.shade300,
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'No posts yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Be the first to share something ✨',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // ✅ All Posts
              final allPosts = snapshot.data!.docs;

              // ✅ Filter Posts
              final filteredPosts = allPosts.where((postDoc) {

                final post = postDoc.data() as Map<String, dynamic>;

                final category =
                    post['category'] ?? PostCategory.lifestyle;

                // ✅ Show all posts
                if (_selectedCategory == PostCategory.all) {
                  return true;
                }

                // ✅ Filter by category
                return category == _selectedCategory;

              }).toList();

              // ✅ No posts in selected category
              if (filteredPosts.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text(
                        'No posts in this category',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                );
              }

              // ✅ Post List
              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 90),

                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {

                      final postData =
                          filteredPosts[index].data()
                              as Map<String, dynamic>;

                      final postId = filteredPosts[index].id;

                      return PostCard(
                        post: postData,
                        postId: postId,
                      );
                    },

                    childCount: filteredPosts.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // ✅ Floating Button
      floatingActionButton: FloatingActionButton(
        elevation: 3,

        backgroundColor: const Color(0xFF2FA089),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreatePostPage(),
            ),
          );
        },

        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}