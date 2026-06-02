/*
import 'package:fast_app/chat_list_page/online_friends.dart';
import 'package:fast_app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ChatListHeader extends StatelessWidget {
  const ChatListHeader({super.key, required DatabaseService db});

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'শুভ সকাল 🌿';
    if (hour >= 11 && hour < 16) return 'শুভ দুপুর ☀️';
    if (hour >= 16 && hour < 18) return 'শুভ বিকাল 🌤️';
    if (hour >= 18 && hour < 20) return 'শুভ সন্ধ্যা 🌙';
    return 'শুভ রাত্রি ✨';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? user?.email?.split('@')[0] ?? 'বন্ধু';

    return Column(
      children: [
        // =========================================
        // PREMIUM GREEN HEADER
        // =========================================
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2FA089), Color(0xFF49B89D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -30, right: -20,
                    child: Container(
                      height: 120, width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20, left: -15,
                    child: Container(
                      height: 80, width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 22, right: 22, top: 44),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_back_rounded,
                                    color: Colors.white, size: 22),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              getGreeting(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Text(
                            'আপনার কথোপকথন 🌱',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // FLOATING SEARCH BAR
            Positioned(
              bottom: -22, left: 18, right: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2FA089).withOpacity(0.10),
                      ),
                      child: const Icon(Icons.search_rounded,
                          color: Color(0xFF2FA089), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search messages...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      height: 36, width: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2FA089), Color(0xFF49B89D)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2FA089).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.mic_rounded, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),

        // ✅ Online Friends Section (logic unchanged)
        const OnlineFriendsWidget(),
      ],
    );
  }
}
*/

/*
import 'package:fast_app/chat_list_page/online_friends.dart';
import 'package:fast_app/services/database_service.dart';
import 'package:flutter/material.dart';

class ChatListHeader extends StatelessWidget {
  const ChatListHeader({super.key, required DatabaseService db});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // =========================================================
        // PREMIUM COMPACT GREEN HEADER (Profile Page Style Size)
        // =========================================================
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 95, // প্রোফাইল পেজের হেডার সাইজ অনুযায়ী ৯৫ করা হলো
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
                  // ব্যাক বাটন এবং টাইটেল টেক্সট
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 40),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'মেসেজসমূহ',
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
                  
                  // ব্যাকগ্রাউন্ড প্রিমিয়াম সার্কেল ডিজাইন ১
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
                  
                  // ব্যাকগ্রাউন্ড প্রিমিয়াম সার্কেল ডিজাইন ২
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

            // FLOATING SEARCH BAR (যথাযথ পজিশনে সেট করা হয়েছে)
            Positioned(
              bottom: -22,
              left: 18,
              right: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2FA089).withOpacity(0.10),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF2FA089),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search messages...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2FA089), Color(0xFF49B89D)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2FA089).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        // সার্চবারের নিচের স্পেসিং ব্যালেন্স করার জন্য
        const SizedBox(height: 36),

        // ✅ Online Friends Section (অপরিবর্তিত রাখা হয়েছে)
        const OnlineFriendsWidget(),
      ],
    );
  }
}
*/

import 'package:fast_app/chat_list_page/online_friends.dart';
import 'package:fast_app/services/database_service.dart';
import 'package:flutter/material.dart';

class ChatListHeader extends StatelessWidget {
  const ChatListHeader({super.key, required DatabaseService db});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // =========================================================
        // PREMIUM COMPACT GREEN HEADER (Clean Minimal Style)
        // =========================================================
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 95, // প্রোফাইল পেজের সাইজ অনুযায়ী ৯৫ রাখা হয়েছে
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
                  // ব্যাকগ্রাউন্ড প্রিমিয়াম সার্কেল ডিজাইন ১
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
                  
                  // ব্যাকগ্রাউন্ড প্রিমিয়াম সার্কেল ডিজাইন ২
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

            // FLOATING SEARCH BAR
            Positioned(
              bottom: -22,
              left: 18,
              right: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2FA089).withOpacity(0.10),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF2FA089),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search messages...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2FA089), Color(0xFF49B89D)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2FA089).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        // সার্চবারের নিচের স্পেসিং ব্যালেন্স করার জন্য
        const SizedBox(height: 36),

        // ✅ Online Friends Section (অপরিবর্তিত)
        const OnlineFriendsWidget(),
      ],
    );
  }
}