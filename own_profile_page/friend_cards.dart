
import 'package:flutter/material.dart';
import '../services/database_service.dart'; // আপনার ডাটাবেজ সার্ভিস
import 'friend_list_page.dart';
import '../home_page/user_profile_page.dart';
import '../home_page/image_helper.dart'; // getProfileImage এর জন্য

class FriendCards extends StatelessWidget {
  final String userId;

  const FriendCards({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2FA089);

    // আপনার অরিজিনাল ডাটাবেজ মেথডটিই এখানে কল করা হলো যা ১০০% ডাটা দেয়
    return StreamBuilder<List<FriendUser>>(
      stream: DatabaseService().getFriendsList(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 125,
            child: Center(child: CircularProgressIndicator(color: primaryColor)),
          );
        }

        // ডাটা লিস্ট রিসিভ করা হচ্ছে
        final allFriends = snapshot.data ?? [];

        // লজিক: মেইন লিস্ট থেকে শুধুমাত্র প্রথম ৪ জন নতুন ফ্রেন্ডকে ফিল্টার করা হলো
        final recentFriends = allFriends.take(4).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================================================
            // হেডার অংশ: Friends টাইটেল এবং See all বাটন
            // =========================================================
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
                        '(${allFriends.length})', // মোট ফ্রেন্ড সংখ্যা দেখাবে
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FriendsListPage(userId: userId),
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

            // =========================================================
            // ফ্রেন্ডস লিস্ট বডি (শুধুমাত্র নতুন ৪ জন ফ্রেন্ড গোল আকারে দেখাবে)
            // =========================================================
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
                  itemCount: recentFriends.length, // এখানে সর্বোচ্চ ৪ জন দেখাবে
                  itemBuilder: (context, index) {
                    final friend = recentFriends[index];

                    return GestureDetector(
                      onTap: () {
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

