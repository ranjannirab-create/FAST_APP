/*
import '../support_page/support_categories.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../support_page/create_support_post_page.dart';
import '../support_page/support_header.dart';
import '../support_page/support_post_card.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {

  String _selectedCategory = SupportCategory.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: CustomScrollView(
        slivers: [

          SliverToBoxAdapter(
            child: SupportHeader(
              selectedCategory: _selectedCategory,

              onCategoryChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          ),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('support_posts')
                .orderBy('timestamp', descending: true)
                .snapshots(),

            builder: (context, snapshot) {

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFF2FA089),
                      ),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData ||
                  snapshot.data!.docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Column(
                        children: [

                          Icon(
                            Icons.volunteer_activism_outlined,
                            size: 70,
                            color: Colors.grey.shade300,
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'No support posts yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Share your story and get support 🤝',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final allPosts = snapshot.data!.docs;

              final filteredPosts =
                  allPosts.where((postDoc) {

                final post =
                    postDoc.data() as Map<String, dynamic>;

                final category =
                    post['category'] ??
                        SupportCategory.lifeProblems;

                if (_selectedCategory ==
                    SupportCategory.all) {
                  return true;
                }

                return category == _selectedCategory;

              }).toList();

              if (filteredPosts.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text(
                        'No posts in this category',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 90),

                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {

                      final postData =
                          filteredPosts[index].data()
                              as Map<String, dynamic>;

                      final postId =
                          filteredPosts[index].id;

                      return SupportPostCard(
                        post: postData,
                        postId: postId,
                      );
                    },

                    childCount: filteredPosts.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        elevation: 3,

        backgroundColor: const Color(0xFF2FA089),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CreateSupportPostPage(),
            ),
          );
        },

        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
*/

/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../support_page/support_categories.dart';
import '../support_page/create_support_post_page.dart';
import '../support_page/support_header.dart';
import '../support_page/support_post_card.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final ScrollController _scrollController = ScrollController();

  String _selectedCategory = SupportCategory.all;

  final List<QueryDocumentSnapshot> _allPosts = [];
  final List<QueryDocumentSnapshot> _displayedPosts = [];
  final List<QueryDocumentSnapshot> _queue = [];

  bool _loading = true;
  bool _showBanner = false;

  StreamSubscription<QuerySnapshot>? _sub;
  Timestamp? _latestTimestamp;
  final Set<String> _knownIds = {};

  @override
  void initState() {
    super.initState();
    _fetchInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot> _filterByCategory(List<QueryDocumentSnapshot> posts) {
    if (_selectedCategory == SupportCategory.all) return posts;
    return posts.where((doc) => doc['category'] == _selectedCategory).toList();
  }

  Future<void> _fetchInitial() async {
    _sub?.cancel();
    setState(() {
      _loading = true;
      _allPosts.clear();
      _displayedPosts.clear();
      _queue.clear();
      _knownIds.clear();
      _showBanner = false;
      _latestTimestamp = null;
    });

    try {
      Query q = FirebaseFirestore.instance
          .collection('support_posts')
          .orderBy('timestamp', descending: true)
          .limit(30);

      final snap = await q.get();

      if (!mounted) return;

      setState(() {
        _allPosts.addAll(snap.docs);
        for (final d in snap.docs) {
          _knownIds.add(d.id);
        }
        if (snap.docs.isNotEmpty) {
          _latestTimestamp = snap.docs.first['timestamp'] as Timestamp?;
        }
        _displayedPosts.addAll(_filterByCategory(_allPosts));
        _loading = false;
      });

      _startLiveListener();
    } catch (e) {
      debugPrint('Initial fetch error on support: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startLiveListener() {
    _sub?.cancel();

    Query q = FirebaseFirestore.instance
        .collection('support_posts')
        .orderBy('timestamp', descending: true);

    if (_latestTimestamp != null) {
      q = q.where('timestamp', isGreaterThan: _latestTimestamp);
    }

    _sub = q.snapshots().listen((snap) {
      if (!mounted) return;
      final fresh = snap.docs.where((d) => !_knownIds.contains(d.id)).toList();
      if (fresh.isEmpty) return;

      setState(() {
        for (final d in fresh) {
          _knownIds.add(d.id);
          _allPosts.add(d);
          final cat = d['category'] as String?;
          if (_selectedCategory == SupportCategory.all || cat == _selectedCategory) {
            if (!_queue.any((q) => q.id == d.id)) {
              _queue.add(d);
            }
          }
        }
        if (fresh.isNotEmpty && fresh.first['timestamp'] != null) {
          _latestTimestamp = fresh.first['timestamp'] as Timestamp;
        }
        if (_queue.isNotEmpty) _showBanner = true;
      });
    }, onError: (error) {
      debugPrint('Live listener error on support: $error');
    });
  }

  void _flushQueue() {
    if (_queue.isEmpty) return;
    setState(() {
      _displayedPosts.addAll(_queue.reversed);
      _queue.clear();
      _showBanner = false;
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      if (_showBanner) _flushQueue();
    }
  }

  void _onCategoryChanged(String newCat) {
    if (newCat == _selectedCategory) return;
    setState(() {
      _selectedCategory = newCat;
      _displayedPosts.clear();
      _displayedPosts.addAll(_filterByCategory(_allPosts));
      _queue.removeWhere((doc) {
        final cat = doc['category'] as String?;
        return (_selectedCategory != SupportCategory.all && cat != _selectedCategory);
      });
      if (_queue.isEmpty) _showBanner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: SupportHeader(
                  selectedCategory: _selectedCategory,
                  onCategoryChanged: _onCategoryChanged,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
                  child: Row(
                    children: [
                      const Text('সাপোর্ট পোস্টসমূহ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      if (_queue.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2FA089).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${_queue.length} নতুন ↓', style: const TextStyle(fontSize: 12, color: Color(0xFF2FA089), fontWeight: FontWeight.w700)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF2FA089))),
                  ),
                )
              else if (_displayedPosts.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.volunteer_activism_outlined, size: 70, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('No support posts yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
                          const SizedBox(height: 8),
                          Text('Share your story and get support 🤝', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 110),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = _displayedPosts[index];
                        return SupportPostCard(
                          post: doc.data() as Map<String, dynamic>,
                          postId: doc.id,
                        );
                      },
                      childCount: _displayedPosts.length,
                    ),
                  ),
                ),
            ],
          ),
          if (_showBanner)
            Positioned(
              bottom: 90,
              left: 24,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  _flushQueue();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF2FA089), Color(0xFF49B89D)]),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: const Color(0xFF2FA089).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text('${_queue.length} টি নতুন সাপোর্ট পোস্ট — দেখতে ট্যাপ করুন ↓', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 3,
        backgroundColor: const Color(0xFF2FA089),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateSupportPostPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../support_page/support_categories.dart';
import '../support_page/create_support_post_page.dart';
import '../support_page/support_header.dart';
import '../support_page/support_post_card.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final ScrollController _scrollController = ScrollController();
  
  String _selectedCategory = SupportCategory.all;
  
  List<QueryDocumentSnapshot> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot> _getFilteredPosts() {
    if (_selectedCategory == SupportCategory.all) return _posts;
    return _posts.where((doc) => doc['category'] == _selectedCategory).toList();
  }

  // ৫০টি সাপোর্ট পোস্ট লোড করে
  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
    });

    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('support_posts')
          .orderBy('timestamp', descending: true)
          .limit(50)  // ← সর্বশেষ ৫০টি পোস্ট
          .get();

      if (!mounted) return;

      setState(() {
        _posts = snap.docs;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading support posts: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onCategoryChanged(String newCat) {
    if (newCat == _selectedCategory) return;
    setState(() {
      _selectedCategory = newCat;
    });
  }

  // রিফ্রেশ বাটন – উপরে স্ক্রল করে নতুন ৫০টি পোস্ট লোড করে
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
            child: SupportHeader(
              selectedCategory: _selectedCategory,
              onCategoryChanged: _onCategoryChanged,
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 16, 18, 6),
              child: Text(
                'সাপোর্ট পোস্টসমূহ',
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
                      Icon(Icons.volunteer_activism_outlined, size: 70, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'কোনো সাপোর্ট পোস্ট নেই',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'আপনার গল্প শেয়ার করুন 🤝',
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
                    final doc = filteredPosts[index];
                    return SupportPostCard(
                      post: doc.data() as Map<String, dynamic>,
                      postId: doc.id,
                    );
                  },
                  childCount: filteredPosts.length,
                ),
              ),
            ),
          // ✅ পোস্ট শেষে গাইডলাইন মেসেজ (শুধু পোস্ট থাকলে দেখাবে)
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
                          'এখানেই শেষ। নতুন সাপোর্ট পোস্ট দেখতে ⬆️ রিফ্রেশ বাটনে ট্যাপ করুন',
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
      // 🔘 ডাবল FAB: রিফ্রেশ + ক্রিয়েট পোস্ট
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // রিফ্রেশ বাটন (ছোট, সাদা)
          FloatingActionButton(
            heroTag: "supportRefresh",
            elevation: 3,
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _refreshToTop,
            child: const Icon(Icons.refresh, color: Color(0xFF2FA089), size: 22),
          ),
          const SizedBox(height: 12),
          // ক্রিয়েট পোস্ট বাটন (বড়, সবুজ)
          FloatingActionButton(
            heroTag: "supportCreate",
            elevation: 3,
            backgroundColor: const Color(0xFF2FA089),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateSupportPostPage()),
              );
            },
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}
*/


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../support_page/support_categories.dart';
import '../support_page/create_support_post_page.dart';
import '../support_page/support_header.dart';
import '../support_page/support_post_card.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final ScrollController _scrollController = ScrollController();
  
  String _selectedCategory = SupportCategory.all;
  
  // FIXED: QueryDocumentSnapshot এর পরিবর্তে DocumentSnapshot ব্যবহার করছি (কারণ লিসেনার DocumentSnapshot দেয়)
  List<DocumentSnapshot> _posts = [];
  bool _loading = true;

  // লিসেনার রাখার জন্য Map
  final Map<String, StreamSubscription<DocumentSnapshot>> _listeners = {};

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    // সব লিসেনার বন্ধ
    for (var sub in _listeners.values) {
      sub.cancel();
    }
    _scrollController.dispose();
    super.dispose();
  }

  // ক্যাটাগরি অনুযায়ী ফিল্টার (ক্লায়েন্ট সাইড)
  List<DocumentSnapshot> _getFilteredPosts() {
    if (_selectedCategory == SupportCategory.all) return _posts;
    return _posts.where((doc) {
      final category = doc['category'] as String?;
      return category == _selectedCategory;
    }).toList();
  }

  // ৫০টি পোস্ট লোড এবং প্রতিটির জন্য রিয়েল টাইম লিসেনার যোগ
  Future<void> _loadPosts() async {
    setState(() => _loading = true);

    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('support_posts')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      if (!mounted) return;

      // পুরনো লিসেনার বন্ধ
      for (var sub in _listeners.values) {
        await sub.cancel();
      }
      _listeners.clear();

      // নতুন পোস্টের লিসেনার যোগ (এখন snap.docs হচ্ছে List<QueryDocumentSnapshot>, কিন্তু আমরা DocumentSnapshot হিসেবে রাখছি)
      final List<DocumentSnapshot> newPosts = [];
      for (var doc in snap.docs) {
        newPosts.add(doc); // QueryDocumentSnapshot DocumentSnapshot-এ অ্যাসাইন করা যায়
        _attachPostListener(doc.id);
      }

      setState(() {
        _posts = newPosts;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading support posts: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  // একক পোস্টের রিয়েল টাইম লিসেনার – শুধু ওই পোস্টের ডাটা আপডেট করবে
  void _attachPostListener(String postId) {
    final sub = FirebaseFirestore.instance
        .collection('support_posts')
        .doc(postId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;
      
      final index = _posts.indexWhere((doc) => doc.id == postId);
      if (index != -1) {
        // FIXED: সরাসরি DocumentSnapshot রিপ্লেস করুন – কোনো কাস্টিং দরকার নেই
        setState(() {
          _posts[index] = snapshot; // snapshot হচ্ছে DocumentSnapshot
        });
      }
    }, onError: (error) {
      print('Listener error for support post $postId: $error');
    });
    
    _listeners[postId] = sub;
  }

  void _onCategoryChanged(String newCat) {
    if (newCat == _selectedCategory) return;
    setState(() => _selectedCategory = newCat);
  }

  void _refreshToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    Future.delayed(const Duration(milliseconds: 350), () => _loadPosts());
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
            child: SupportHeader(
              selectedCategory: _selectedCategory,
              onCategoryChanged: _onCategoryChanged,
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 16, 18, 6),
              child: Text(
                'সাপোর্ট পোস্টসমূহ',
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
                      Icon(Icons.volunteer_activism_outlined, size: 70, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'কোনো সাপোর্ট পোস্ট নেই',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'আপনার গল্প শেয়ার করুন 🤝',
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
                    final doc = filteredPosts[index];
                    // FIXED: ValueKey দেওয়া হয়েছে যাতে শুধু পরিবর্তিত পোস্ট রি-বিল্ড হয়
                    return SupportPostCard(
                      key: ValueKey(doc.id),
                      post: doc.data() as Map<String, dynamic>,
                      postId: doc.id,
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
                          'লাইক/কমেন্ট রিয়েল-টাইম আপডেট হয়। নতুন পোস্ট দেখতে রিফ্রেশ বাটনে ট্যাপ করুন',
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
            heroTag: "supportRefresh",
            elevation: 3,
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _refreshToTop,
            child: const Icon(Icons.refresh, color: Color(0xFF2FA089), size: 22),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "supportCreate",
            elevation: 3,
            backgroundColor: const Color(0xFF2FA089),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateSupportPostPage()),
              );
            },
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}