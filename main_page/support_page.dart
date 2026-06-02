import 'package:fast_app/support_page/support_categories.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../support_page/create_support_post_page.dart';
import '../support_page/support_category_filter.dart';
import '../support_page/support_header.dart';
import '../support_page/support_post_card.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {

  String _selectedCategory = SupportCategory.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: CustomScrollView(
        slivers: [

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

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('support_posts')
                .orderBy('timestamp', descending: true)
                .snapshots(),

            builder: (context, snapshot) {

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
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

              if (!snapshot.hasData ||
                  snapshot.data!.docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Column(
                        children: [

                          Icon(
                            Icons.volunteer_activism_outlined,
                            size: 70,
                            color: Colors.grey.shade300,
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'No support posts yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Share your story and get support 🤝',
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

              final filteredPosts =
                  allPosts.where((postDoc) {

                final post =
                    postDoc.data() as Map<String, dynamic>;

                final category =
                    post['category'] ??
                        SupportCategory.lifeProblems;

                if (_selectedCategory ==
                    SupportCategory.all) {
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

              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 90),

                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {

                      final postData =
                          filteredPosts[index].data()
                              as Map<String, dynamic>;

                      final postId =
                          filteredPosts[index].id;

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

      floatingActionButton: FloatingActionButton(
        elevation: 3,

        backgroundColor: const Color(0xFF2FA089),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CreateSupportPostPage(),
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