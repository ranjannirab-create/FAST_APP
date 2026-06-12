import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // কারেন্ট ইউজারের ID নেওয়ার জন্য
import 'package:url_launcher/url_launcher.dart';
import '../home_page/image_helper.dart'; // আপনার প্রোফাইল ইমেজ হেলপার মেথড

class TreeMenu extends StatelessWidget {
  final VoidCallback onLogout;

  const TreeMenu({super.key, required this.onLogout});

  // --- সোশ্যাল মিডিয়া বা যেকোনো লিংক ওপেন করার ইউনিভার্সাল ফাংশন ---
  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
        // সফলভাবে লিংকে চলে গেছে
      } else {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('লিংকটি ওপেন করা যাচ্ছে না: $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandColor = Color(0xFF2FA089);
    
    // বর্তমান লগইন থাকা ইউজারের UID নেওয়া হচ্ছে
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Drawer(
      child: Container(
        color: const Color(0xFFF8F9FA), // মডার্ন ও স্লিক হালকা ব্যাকগ্রাউন্ড
        child: Column(
          children: [
            // =========================================================
            // ১. রিয়াল-টাইম ইউজার ডাটা হেডার (StreamBuilder)
            // =========================================================
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                // ডাটা লোড হওয়ার আগ পর্যন্ত ডিফোল্ট একটা লুক দেখাবে
                String userName = 'Loading...';
                String userEmail = 'Please wait...';
                String profilePic = '';

                if (snapshot.hasData && snapshot.data!.exists) {
                  final userData = snapshot.data!.data() as Map<String, dynamic>;
                  
                  // ফায়ারবেসের ফিল্ড নেম অনুযায়ী ডাটা অ্যাসাইন (বানান ভুল থাকলে অটো সেফটি হ্যান্ডেল করবে)
                  userName = userData['name'] ?? userData['displayName'] ?? 'No Name';
                  userEmail = userData['email'] ?? FirebaseAuth.instance.currentUser?.email ?? 'No Email';
                  profilePic = userData['profilePic'] ?? userData['image'] ?? userData['imageUrl'] ?? '';
                }

                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: brandColor,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  currentAccountPicture: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: profilePic.isNotEmpty ? getProfileImage(profilePic) : null,
                      child: profilePic.isEmpty
                          ? const Icon(Icons.person_rounded, color: brandColor, size: 45)
                          : null,
                    ),
                  ),
                  accountName: Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                  ),
                  accountEmail: Text(
                    userEmail,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                );
              },
            ),

            // =========================================================
            // ২. মেইন মেনু আইটেমসমূহ
            // =========================================================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                children: [
                  _buildSectionTitle('Social Handles'),

                  _buildMenuCard(
                    icon: Icons.facebook,
                    iconColor: const Color(0xFF1877F2),
                    title: 'Facebook Profile',
                    subtitle: 'Connect on Facebook',
                    onTap: () => _launchURL(context, 'https://facebook.com'), // আপনার অরিজিনাল লিংক দিন
                  ),

                  _buildMenuCard(
                    icon: Icons.camera_alt_rounded,
                    iconColor: const Color(0xFFE1306C),
                    title: 'Instagram',
                    subtitle: 'Follow updates',
                    onTap: () => _launchURL(context, 'https://instagram.com'), // আপনার অরিজিনাল লিংক দিন
                  ),

                  _buildMenuCard(
                    icon: Icons.g_mobiledata_rounded,
                    iconColor: const Color(0xFFEA4335),
                    title: 'Google Account',
                    subtitle: 'Manage account',
                    onTap: () => _launchURL(context, 'https://myaccount.google.com'),
                  ),

                  _buildMenuCard(
                    icon: Icons.video_library_rounded,
                    iconColor: const Color(0xFFFF0000),
                    title: 'YouTube Channel',
                    subtitle: 'Watch content',
                    onTap: () => _launchURL(context, 'https://youtube.com'),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: Colors.black12, thickness: 1),
                  ),

                  _buildSectionTitle('General'),

                  _buildMenuCard(
                    icon: Icons.settings_suggest_rounded,
                    iconColor: brandColor,
                    title: 'Settings',
                    subtitle: 'App configurations',
                    onTap: () {
                      Navigator.pop(context);
                      // সেটিংস পেজের নেভিগেশন এখানে দিতে পারেন
                    },
                  ),

                  _buildMenuCard(
                    icon: Icons.info_outline_rounded,
                    iconColor: Colors.blueGrey,
                    title: 'About App',
                    subtitle: 'Version 1.0.0',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // =========================================================
            // ৩. সবার নিচের লগআউট বাটন
            // =========================================================
            const Divider(height: 1, color: Colors.black12),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: const Text(
                    'Logout Account',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onLogout();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ছোট সেকশন টাইটেল উইজেট ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 0.5),
      ),
    );
  }

  // --- প্রিমিয়াম মেনু কার্ড ডিজাইনার ---
  Widget _buildMenuCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.black45),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.black45),
        onTap: onTap,
      ),
    );
  }
}