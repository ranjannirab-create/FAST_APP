

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../own_profile_page/profile_header.dart';
import '../own_profile_page/profile_bio.dart';
import '../own_profile_page/friend_cards.dart';
import '../own_profile_page/post_section.dart';

class OwnProfilePage extends StatelessWidget {
  const OwnProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('কোনো ডাটা পাওয়া যায়নি'),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              children: [
                // ==========================
                // PREMIUM TOP BAR
                // ==========================
                Container(
                  height: 95,
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
                    ],
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -25),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileHeader(
                          userData: data,
                          userId: userId,
                        ),
                        const SizedBox(height: 16),
                        ProfileBio(
                          bioText: data['bio'] ?? '',
                        ),
                        const SizedBox(height: 16),
                        FriendCards(
                          userId: userId, // এখানে খালি স্ট্রিপ '' এর জায়গায় userId পাস করা হয়েছে
                        ),
                        const SizedBox(height: 16),
                        PostSection(
                          userId: userId,
                          userData: data,
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
}
