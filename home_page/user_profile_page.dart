
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
    const Color primaryColor = Color(0xFF2FA089);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Scaffold(
              body: Center(
                child: Text("User not found", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final isOwnProfile = FirebaseAuth.instance.currentUser?.uid == userId;

          return SingleChildScrollView(
            child: Column(
              children: [
                // =========================================================
                // PREMIUM TOP BAR (গ্রাডিয়েন্ট ও সার্কেল ব্যাকগ্রাউন্ড)
                // =========================================================
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF2FA089),
                        Color(0xFF49B89D),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // ব্যাকগ্রাউন্ড সার্কেল ১
                      Positioned(
                        top: -20,
                        right: -15,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                      // ব্যাকগ্রাউন্ড সার্কেল ২
                      Positioned(
                        bottom: -15,
                        left: -15,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white12,
                          ),
                        ),
                      ),
                      // ব্যাক বাটন এবং পেজ টাইটেল
                      Positioned(
                        top: 40,
                        left: 8,
                        right: 16,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Text(
                              "Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // =========================================================
                // CONTENT SECTION (Transform.translate দিয়ে ওভারল্যাপ করা)
                // =========================================================
                Transform.translate(
                  offset: const Offset(0, -25),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // پروফাইল হেডার (ছবি ও নাম)
                        UserProfileHeader(
                          userData: userData,
                          userId: userId,
                        ),

                        // =========================================================
                        // ডায়নামিক বাটন সেকশন: ফ্রেন্ড এবং মেসেজ বাটন (পাশাপাশি)
                        // =========================================================
                        if (!isOwnProfile) ...[
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FutureBuilder<bool>(
                              future: DatabaseService().isFriend(userId),
                              builder: (context, friendSnapshot) {
                                final isFriend = friendSnapshot.data == true;

                                return Row(
                                  children: [
                                    // ১. ফ্রেন্ড রিকোয়েস্ট / ফ্রেন্ড বাটন
                                    Expanded(
                                      child: SizedBox(
                                        height: 44, // প্রিমিয়াম ফিক্সড হাইট
                                        child: FriendButton(
                                          targetUserId: userId,
                                        ),
                                      ),
                                    ),
                                    
                                    // যদি অলরেডি ফ্রেন্ড হয়, তবেই পাশে মেসেজ বাটনটি আসবে
                                    if (isFriend) ...[
                                      const SizedBox(width: 12), // বাটনের মাঝের স্পেস
                                      
                                      // ২. মেসেজ বাটন (ফ্রেন্ড বাটনের সমান হাইট ও প্রিমিয়াম ডিজাইনে)
                                      Expanded(
                                        child: _buildChatButton(context, userId, primaryColor),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                        // বায়ো সেকশন
                        UserProfileBio(
                          bioText: userData['bio'] ?? '',
                        ),

                        const SizedBox(height: 16),
                        // ফ্রেন্ড কার্ডস
                        UserFriendCards(
                          userId: userId,
                        ),

                        const SizedBox(height: 16),
                        // পোস্ট সেকশন
                        UserPostSection(
                          userId: userId,
                          userData: userData,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // প্রিমিয়াম স্টাইলড চ্যাট/মেসেজ বাটন যা ফ্রেন্ড বাটনের সাথে হুবহু ম্যাচ করবে
  Widget _buildChatButton(
    BuildContext context,
    String targetUserId,
    Color primaryColor,
  ) {
    return SizedBox(
      height: 44, // ফ্রেন্ড বাটন এবং মেসেজ বাটনের হাইট একদম সমান করা হলো
      child: ElevatedButton.icon(
        icon: Icon(Icons.chat_bubble_outline, size: 18, color: primaryColor),
        label: Text(
          "Message",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          side: BorderSide(color: primaryColor.withOpacity(0.6), width: 1.5), // গ্রিন পেস্ট বর্ডার
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // মডার্ন রাউন্ডেড কর্নার
          ),
        ),
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
  }
}