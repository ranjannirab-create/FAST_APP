/*
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'user_friends_list.dart';

class UserFriendCards extends StatelessWidget {
  final String userId;

  const UserFriendCards({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: DatabaseService().getFriendsCount(userId),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserFriendsList(userId: userId),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.group, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Friends',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        count.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        );
      },
    );
  }
}
*/

import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'user_friends_list.dart';          // আপনার ফ্রেন্ড লিস্ট পেজ (যেখানে সব ফ্রেন্ড দেখাবে)
import '../home_page/user_profile_page.dart';
import '../home_page/image_helper.dart';  // getProfileImage() ফাংশন

class UserFriendCards extends StatelessWidget {
  final String userId;  // যে প্রোফাইল ইউজারের ফ্রেন্ড দেখাতে চান

  const UserFriendCards({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2FA089);

    // স্ট্রিম: ওই নির্দিষ্ট ইউজারের ফ্রেন্ড লিস্ট
    // যদি আপনার ডাটাবেজ মেথড getFriendsList() প্যারামিটার নেয়, তাহলে সেটি কল করুন।
    // নিচে ধরে নিচ্ছি getFriendsListForUser(userId) নামে একটি মেথড আছে।
    // যদি getFriendsList() ই সব ফ্রেন্ড দেয়, তাহলে অ্যাপার্টমেন্টে ফিল্টার করে নিতে পারেন।
    return StreamBuilder<List<FriendUser>>(
      stream: DatabaseService().getFriendsListForUser(userId), // 👈 গুরুত্বপূর্ণ: এই মেথডটি অবশ্যই userId অনুযায়ী লিস্ট দেবে
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 125,
            child: Center(child: CircularProgressIndicator(color: primaryColor)),
          );
        }

        final allFriends = snapshot.data ?? [];
        final recentFriends = allFriends.take(4).toList(); // শুধু প্রথম ৪ জন

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- হেডার: ফ্রেন্ডস টাইটেল + কাউন্ট + সি অল বাটন ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Friends',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${allFriends.length})',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // "See all" বাটনে ক্লিক করলে সম্পূর্ণ ফ্রেন্ড লিস্ট পেজে যাবে
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserFriendsList(userId: userId),
                        ),
                      );
                    },
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---------- ফ্রেন্ড কার্ডগুলোর হরাইজন্টাল লিস্ট (সর্বোচ্চ ৪ জন) ----------
            if (allFriends.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'No friends to show',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              )
            else
              SizedBox(
                height: 125,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: recentFriends.length,
                  itemBuilder: (context, index) {
                    final friend = recentFriends[index];
                    return GestureDetector(
                      onTap: () {
                        // কার্ডে ক্লিক করলে ওই ফ্রেন্ডের প্রোফাইল পেজে যাবে
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfilePage(userId: friend.userId),
                          ),
                        );
                      },
                      child: Container(
                        width: 85,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 32,
                                backgroundColor: primaryColor.withOpacity(0.1),
                                backgroundImage: getProfileImage(friend.profilePic),
                                child: friend.profilePic.isEmpty
                                    ? const Icon(Icons.person, size: 30, color: primaryColor)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              friend.name,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}