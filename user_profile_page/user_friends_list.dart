/*
import 'package:flutter/material.dart';
import '../services/database_service.dart';

class UserFriendsList extends StatelessWidget {
  final String userId;

  const UserFriendsList({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: StreamBuilder<List<FriendUser>>(
        stream: DatabaseService().getFriendsListForUser(userId),
        builder: (context, snapshot) {
          // 1. লোডিং অবস্থা
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // 2. এরর অবস্থা
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }
          
          // 3. ডাটা এলো
          final friends = snapshot.data ?? [];
          
          if (friends.isEmpty) {
            return const Center(
              child: Text(
                "No friends yet",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }
          
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: friends.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final friend = friends[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: friend.profilePic.isNotEmpty
                        ? NetworkImage(friend.profilePic)
                        : null,
                    child: friend.profilePic.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    friend.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Friend'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // প্রোফাইল পেজে যাওয়া (নিজের ক্লাস অনুযায়ী পরিবর্তন করুন)
                    Navigator.pushNamed(context, '/profile', arguments: friend.userId);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
*/


import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../home_page/user_profile_page.dart';
import '../home_page/image_helper.dart';   // getProfileImage() ফাংশন

class UserFriendsList extends StatelessWidget {
  final String userId;   // যে ইউজারের ফ্রেন্ড লিস্ট দেখাবেন

  const UserFriendsList({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        elevation: 0,
      ),
      body: StreamBuilder<List<FriendUser>>(
        stream: DatabaseService().getFriendsListForUser(userId), // userId অনুযায়ী ফ্রেন্ড লিস্ট
        builder: (context, snapshot) {
          // লোডিং ইন্ডিকেটর
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // এরর হ্যান্ডলিং
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final friends = snapshot.data ?? [];

          if (friends.isEmpty) {
            return const Center(
              child: Text(
                'No friends yet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          // লিস্ট ভিউ - একই স্টাইল যা FriendsListPage-এ আছে
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage: getProfileImage(friend.profilePic), // একই হেল্পার
                    child: friend.profilePic.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    friend.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text('Friend'), // অথবা friend.lastMessage থাকলে সেটি দেখান
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // ✅ এখানে সঠিকভাবে প্রোফাইল পেজে নেভিগেশন
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserProfilePage(userId: friend.userId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}