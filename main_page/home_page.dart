


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_page/post_categories.dart';
import '../home_page_ui/home_header.dart';
import '../home_page_ui/post_card.dart';
import '../communitie_page/communities_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  
  String _selectedCategory = PostCategory.all;
  
  // FIXED: পোস্টের ডাটা এবং ID আলাদা করে রাখা হচ্ছে, টাইপ কাস্টিং এর সমস্যা এড়াতে
  List<MapEntry<String, Map<String, dynamic>>> _posts = [];
  bool _loading = true;

  final Map<String, StreamSubscription<DocumentSnapshot>> _listeners = {};

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    for (var sub in _listeners.values) {
      sub.cancel();
    }
    _scrollController.dispose();
    super.dispose();
  }

  // FIXED: ফিল্টারিং সরলীকৃত
  List<MapEntry<String, Map<String, dynamic>>> _getFilteredPosts() {
    if (_selectedCategory == PostCategory.all) return _posts;
    return _posts.where((entry) => entry.value['category'] == _selectedCategory).toList();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
    });

    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      if (!mounted) return;

      // আগের সব listener বন্ধ
      for (var sub in _listeners.values) {
        await sub.cancel();
      }
      _listeners.clear();

      // নতুন পোস্ট লিস্ট তৈরি (ID ও ডাটা সহ)
      final List<MapEntry<String, Map<String, dynamic>>> newPosts = [];
      for (var doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        newPosts.add(MapEntry(doc.id, data));
        _attachPostListener(doc.id);
      }

      setState(() {
        _posts = newPosts;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading posts: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  // FIXED: সঠিক টাইপিং সহ লিসেনার
  void _attachPostListener(String postId) {
    final sub = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;
      final updatedData = snapshot.data() as Map<String, dynamic>;
      
      // পোস্টটি _posts লিস্টে খুঁজে আপডেট
      final index = _posts.indexWhere((entry) => entry.key == postId);
      if (index != -1) {
        setState(() {
          _posts[index] = MapEntry(postId, updatedData);
        });
      }
    }, onError: (error) {
      print('Listener error for post $postId: $error');
    });
    
    _listeners[postId] = sub;
  }

  void _onCategoryChanged(String newCat) {
    if (newCat == _selectedCategory) return;
    setState(() {
      _selectedCategory = newCat;
    });
  }

  void _refreshToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    Future.delayed(const Duration(milliseconds: 350), () {
      _loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredPosts = _getFilteredPosts();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: HomeHeader(
              selectedCategory: _selectedCategory,
              onCategoryChanged: _onCategoryChanged,
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 16, 18, 6),
              child: Text(
                'পোস্টসমূহ',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          if (_loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF2FA089)),
                ),
              ),
            )
          else if (filteredPosts.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.article_outlined, size: 70, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'কোনো পোস্ট নেই',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'প্রথম পোস্টটি করুন ✨',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 30),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = filteredPosts[index];
                    return PostCard(
                      key: ValueKey(entry.key),
                      post: entry.value,
                      postId: entry.key,
                    );
                  },
                  childCount: filteredPosts.length,
                ),
              ),
            ),
          if (!_loading && filteredPosts.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2FA089).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2FA089).withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF2FA089), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'লাইক/কমেন্ট রিয়েল-টাইম আপডেট হয়। নতুন পোস্ট দেখতে হোম বাটনে ট্যাপ করুন',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF2FA089).withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "homeRefresh",
            elevation: 3,
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _refreshToTop,
            child: const Icon(Icons.home_filled, color: Color(0xFF2FA089), size: 22),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "communities",
            elevation: 3,
            backgroundColor: const Color(0xFF2FA089),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CommunitiesPage()),
            ),
            child: const Icon(Icons.people, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }
}

