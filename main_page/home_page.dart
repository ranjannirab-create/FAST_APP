import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../support_page/create_support_post_page.dart';
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

