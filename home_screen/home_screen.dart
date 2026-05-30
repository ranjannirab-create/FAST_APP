/*
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main_page/home_page.dart';
import '../main_page/word_page.dart';
import '../main_page/ai_chat_page.dart';
import "../main_page/chat_list_page.dart";
import '../main_page/own_profile_page.dart';
import '../home_screen/tree_menu.dart';
import '../login/login.dart';
import '../home_screen/notification_page.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  int _unreadCount = 0;
  late StreamSubscription _notificationSubscription;

  final List<Widget> _pages = [
    const HomePage(),
    const WordPage(),
    const AiChatPage(),
    const ChatListPage(targetUserId: '',),      // ✅ No parameter needed
    const OwnProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenToNotifications();
    _setUserOnline(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationSubscription.cancel();
    _setUserOnline(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setUserOnline(true);
    } else if (state == AppLifecycleState.paused) {
      _setUserOnline(false);
    }
  }

  void _setUserOnline(bool isOnline) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await DatabaseService().setUserOnline(isOnline);
    }
  }

  void _listenToNotifications() {
    final db = DatabaseService();
    _notificationSubscription = db.getNotifications().listen((snapshot) {
      int count = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['isRead'] == false) count++;
      }
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    });
  }

  void _handleLogout() {
    _setUserOnline(false);  // mark offline before logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color brandColor = Color(0xFF2FA089);

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      drawer: TreeMenu(onLogout: _handleLogout),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Image.asset(
          'assets/logo.jpg',
          height: 45,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black87),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationPage()),
                  );
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: brandColor,
          unselectedItemColor: Colors.black38,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.sports_esports_outlined), activeIcon: Icon(Icons.sports_esports), label: 'Game World'),
            BottomNavigationBarItem(icon: Icon(Icons.psychology_outlined), activeIcon: Icon(Icons.psychology), label: 'AI Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main_page/home_page.dart';
import '../main_page/word_page.dart';
import '../main_page/ai_chat_page.dart';
import "../main_page/chat_list_page.dart";
import '../main_page/own_profile_page.dart';
import '../home_screen/tree_menu.dart';
import '../login/login.dart';
import '../home_screen/notification_page.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  int _unreadCount = 0;
  late StreamSubscription _notificationSubscription;

  final List<Widget> _pages = [
    const HomePage(),
    const WordPage(),
    const AiChatPage(),
    const ChatListPage(targetUserId: '',),
    const OwnProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenToNotifications();
    _setUserOnline(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationSubscription.cancel();
    _setUserOnline(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setUserOnline(true);
    } else if (state == AppLifecycleState.paused) {
      _setUserOnline(false);
    }
  }

  void _setUserOnline(bool isOnline) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await DatabaseService().setUserOnline(isOnline);
    }
  }

  void _listenToNotifications() {
    final db = DatabaseService();
    _notificationSubscription = db.getNotifications().listen((snapshot) {
      int count = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['isRead'] == false) count++;
      }
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    });
  }

  void _handleLogout() {
    _setUserOnline(false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color brandColor = Color(0xFF2FA089);

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),

      drawer: TreeMenu(onLogout: _handleLogout),

      // =========================
      // 🌿 CALM PREMIUM APP BAR
      // =========================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),

        title: Text(
          'FreeMind ',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            height: 1.0,        // 🔥 line spacing ঠিক করে

            color: const Color(0xFF2FA089),
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),

          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none,
                    color: Colors.black87),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const NotificationPage()),
                  );
                },
              ),

              if (_unreadCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                        minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body: _pages[_currentIndex],

      // =========================
      // 🌿 BOTTOM NAV CLEAN STYLE
      // =========================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: brandColor,
          unselectedItemColor: Colors.black38,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_esports_outlined),
              activeIcon: Icon(Icons.sports_esports),
              label: 'Game World',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_outlined),
              activeIcon: Icon(Icons.psychology),
              label: 'AI Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}