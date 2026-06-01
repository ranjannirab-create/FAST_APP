import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home_page_ui/post_card.dart';

class UserPostSection extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const UserPostSection({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where(
            'userId',
            isEqualTo: userId,
          )
          .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
            ),
          );
        }

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        List<QueryDocumentSnapshot> posts =
            snapshot.data?.docs ?? [];

        posts.sort((a, b) {
          final aTime =
              (a['timestamp'] as Timestamp?)
                      ?.millisecondsSinceEpoch ??
                  0;

          final bTime =
              (b['timestamp'] as Timestamp?)
                      ?.millisecondsSinceEpoch ??
                  0;

          return bTime.compareTo(aTime);
        });

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            /// TITLE
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                0,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      const Icon(
                        Icons.auto_stories_rounded,
                        color: Color(
                          0xFF2FA089,
                        ),
                        size: 22,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        "${userData['name'] ?? 'User'}'s Posts",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w700,
                          color: Color(
                            0xFF2FA089,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Container(
                    height: 1,
                    width: double.infinity,
                    color: const Color(
                      0xFFE7EFEC,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// EMPTY STATE
            if (posts.isEmpty)
              Container(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                width: double.infinity,
                padding:
                    const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.03),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Column(
                  children: [

                    Icon(
                      Icons.post_add,
                      size: 60,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 12),

                    Text(
                      'No Posts Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      'এই ইউজারের কোনো পোস্ট নেই 🌿',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

            /// POSTS
            if (posts.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                primary: false,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder:
                    (context, index) {

                  final post =
                      posts[index].data()
                          as Map<String,
                              dynamic>;

                  return PostCard(
                    post: post,
                    postId:
                        posts[index].id,
                  );
                },
              ),
          ],
        );
      },
    );
  }
}