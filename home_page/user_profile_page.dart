
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../user_profile_page/user_profile_header.dart';
import '../user_profile_page/user_profile_bio.dart';
import '../user_profile_page/user_friend_cards.dart';
import '../user_profile_page/user_post_section.dart';
import '../user_profile_page/friend_button.dart';

import '../services/database_service.dart';
import '../main_page/chat_list_page.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;

  const UserProfilePage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.data!.exists) {
            return const Center(
              child: Text("User not found"),
            );
          }

          final userData =
              snapshot.data!.data() as Map<String, dynamic>;

          final isOwnProfile =
              FirebaseAuth.instance.currentUser?.uid ==
                  userId;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                UserProfileHeader(
                  userData: userData,
                  userId: userId,
                ),

                const SizedBox(height: 16),

                if (!isOwnProfile) ...[
                  FriendButton(
                    targetUserId: userId,
                  ),

                  const SizedBox(height: 12),

                  _buildChatButton(
                    context,
                    userId,
                  ),
                ],

                const SizedBox(height: 16),

                UserProfileBio(
                  bioText: userData['bio'] ?? '',
                ),

                const SizedBox(height: 16),

                UserFriendCards(
                  userId: userId,
                ),

                const SizedBox(height: 16),

                UserPostSection(
                  userId: userId,
                  userData: userData,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatButton(
    BuildContext context,
    String targetUserId,
  ) {
    return FutureBuilder<bool>(
      future: DatabaseService().isFriend(
        targetUserId,
      ),
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.chat),
            label: const Text("Message"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatListPage(
                    targetUserId: targetUserId,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}


