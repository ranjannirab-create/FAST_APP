import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home_page/post_categories.dart';
import '../support_page/support_header.dart';
import '../support_page/support_post_card.dart';
import '../support_page/create_support_post_page.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {

  // ✅ default category
  String _selectedCategory = PostCategory.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: CustomScrollView(
        slivers: [

          // ✅ Support Header (HomeHeader converted)
          SliverToBoxAdapter(
            child: SupportHeader(
              selectedCategory: _selectedCategory,

              onCategoryChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          ),

          // ✅ Support Posts Stream
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('support_posts')
                .orderBy('timestamp', descending: true)
                .snapshots(),

            builder: (context, snapshot) {

              // loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2FA089),
                      ),
                    ),
                  ),
                );
              }

              // empty state
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 70,
                            color: Colors.grey.shade300,
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'এখনো কোনো সহায়তা পোস্ট নেই',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'আপনি প্রথমে আপনার মনের কথা শেয়ার করুন 🤍',
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

              final allPosts = snapshot.data!.docs;

              // ✅ filter support category
              final filteredPosts = allPosts.where((doc) {
                final post = doc.data() as Map<String, dynamic>;
                final category = post['category'] ?? PostCategory.lifestyle;

                if (_selectedCategory == PostCategory.all) {
                  return true;
                }

                return category == _selectedCategory;
              }).toList();

              if (filteredPosts.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text(
                        'এই ক্যাটাগরিতে কোনো সহায়তা নেই',
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

              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 90),

                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {

                      final postData =
                          filteredPosts[index].data()
                              as Map<String, dynamic>;

                      final postId = filteredPosts[index].id;

                      return SupportPostCard(
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

      // ✅ Create Support Post Button
      floatingActionButton: FloatingActionButton(
        elevation: 3,
        backgroundColor: const Color(0xFF2FA089),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateSupportPostPage(),
            ),
          );
        },

        child: const Icon(
          Icons.favorite,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}