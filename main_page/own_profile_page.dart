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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Clean background like the image
      appBar: AppBar(
        title: const Text('Free Mind \u{1F33F}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('কোনো ডাটা পাওয়া যায়নি'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Pic + Details + Name Row)
                ProfileHeader(userData: data, userId: userId),
                const SizedBox(height: 16),
                
                // Bio Section
                ProfileBio(bioText: data['bio'] ?? ''),
                const SizedBox(height: 16),
                
                // Friends Section
                FriendCards(userId: '',), // Database backend pore add korben
                const SizedBox(height: 16),
                
                // Post Section
                PostSection(userId: userId, userData: data),
              ],
            ),
          );
        },
      ),
    );
  }
}