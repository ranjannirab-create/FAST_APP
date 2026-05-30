import '../user_profile_page/friend_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../main_page/chat_list_page.dart';          // ✅ Correct chat page (not ChatListPage)

class UserProfilePage extends StatelessWidget {
  final String userId;
  const UserProfilePage({super.key, required this.userId});

  // Helper to load profile image from asset or network
  ImageProvider? _getProfileImage(String imagePath) {
    if (imagePath.isEmpty) return null;
    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    } else {
      return NetworkImage(imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final name = userData['name'] ?? 'No Name';
          final email = userData['email'] ?? '';
          final bio = userData['bio'] ?? '';
          final profilePic = userData['profilePic'] ?? '';
          final followersCount = userData['followersCount'] ?? 0;
          final followingCount = userData['followingCount'] ?? 0;
          final isOwnProfile = FirebaseAuth.instance.currentUser?.uid == userId;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Cover photo placeholder
                    Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.photo_camera, size: 50, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Profile picture (supports asset & network)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _getProfileImage(profilePic),
                      child: profilePic.isEmpty
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    if (email.isNotEmpty) Text(email, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    if (bio.isNotEmpty) Text(bio, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStat('Followers', followersCount),
                        const SizedBox(width: 24),
                        _buildStat('Following', followingCount),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (!isOwnProfile) ...[
                      FriendButton(targetUserId: userId),
                      const SizedBox(height: 10),
                      _buildChatButton(context, userId),
                    ],
                    const SizedBox(height: 20),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Posts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: _buildPostsList(userId),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStat(String label, int count) {
    return Column(
      children: [
        Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildChatButton(BuildContext context, String targetUserId) {
    return FutureBuilder<bool>(
      future: DatabaseService().isFriend(targetUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data != true) return const SizedBox.shrink();
        return ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatListPage(targetUserId: targetUserId), // ✅ Go to chat with this specific user
            ),
          ),
          icon: const Icon(Icons.chat),
          label: const Text('Message'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        );
      },
    );
  }

  Widget _buildPostsList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final posts = snapshot.data?.docs ?? [];
        if (posts.isEmpty) {
          return const Center(child: Text('No posts yet', style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(post['text'] ?? ''),
                subtitle: Text(
                  post['timestamp'] != null
                      ? (post['timestamp'] as Timestamp).toDate().toString()
                      : '',
                ),
              ),
            );
          },
        );
      },
    );
  }
}