import 'package:flutter/material.dart';

class TreeMenu extends StatelessWidget {
  final VoidCallback onLogout;

  const TreeMenu({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    const Color brandColor = Color(0xFF2FA089);

    return Drawer(
      child: Container(
        color: const Color(0xFFEEEEEE), // আপনার দেওয়া ব্যাকগ্রাউন্ড কালার
        child: Column(
          children: [
            // --- Drawer Header (Facebook ID/Profile Info) ---
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: brandColor,
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: brandColor, size: 40),
              ),
              accountName: const Text(
                'Your Facebook Name',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
              accountEmail: const Text(
                'facebook.id@example.com',
                style: TextStyle(color: Colors.white70),
              ),
            ),

            // --- অন্যান্য মেনু আইটেম ---
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.facebook, color: Colors.blue),
                    title: const Text('Facebook Profile'),
                    onTap: () {
                      // ফেসবুক আইডি ওপেন করার লজিক এখানে দিতে পারেন
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.link, color: Colors.black87),
                    title: const Text('Instagram ID'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
                    title: const Text('Google Account'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.black87),
                    title: const Text('Settings'),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // --- সবার নিচের লগআউট অপশন ---
            const Divider(height: 1, color: Colors.black12),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context); // প্রথমে মেনুটা বন্ধ হবে
                onLogout(); // তারপর লগআউট লজিক কাজ করবে
              },
            ),
            const SizedBox(height: 12), // নিচে কিছুটা মার্জিন রাখার জন্য
          ],
        ),
      ),
    );
  }
}
