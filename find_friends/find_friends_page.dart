

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../home_page/user_profile_page.dart';
import '../home_page/image_helper.dart';

// ============================================================
//  FindFriendsPage - Mutual Friends Always Shown Below Button
// ============================================================
class FindFriendsPage extends StatefulWidget {
  const FindFriendsPage({super.key});

  @override
  State<FindFriendsPage> createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends State<FindFriendsPage>
    with SingleTickerProviderStateMixin {
  final DatabaseService _db = DatabaseService();
  late String _currentUserId;

  List<Map<String, dynamic>> _recommendedUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final Map<String, String> _requestStatus = {};

  String _userCountry = '';
  String _userLanguage = '';
  List<String> _userInterests = [];
  String _userRole = '';
  final Set<String> _userFriends = {};

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: 0.0, max: 1.0, period: const Duration(milliseconds: 1200));
    _loadData();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .get();
      final userData = userDoc.data()!;
      _userCountry = userData['country'] ?? '';
      _userLanguage = userData['language'] ?? '';
      _userInterests = List<String>.from(userData['interests'] ?? []);
      _userRole = userData['role'] ?? '';

      final friendRequests = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('friend_requests')
          .where('status', isEqualTo: 'accepted')
          .get();
      _userFriends.clear();
      for (var doc in friendRequests.docs) {
        final data = doc.data();
        final otherId = data['senderId'] == _currentUserId
            ? data['receiverId'] as String
            : data['senderId'] as String;
        _userFriends.add(otherId);
      }

      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      List<Map<String, dynamic>> candidates = [];
      for (var doc in usersSnapshot.docs) {
        final userId = doc.id;
        if (userId == _currentUserId || _userFriends.contains(userId)) continue;

        final data = doc.data();
        final String name = data['name'] ?? 'Unknown';
        final String profilePic = data['profilePic'] ?? '';
        final String country = data['country'] ?? '';
        final String language = data['language'] ?? '';
        final String role = data['role'] ?? '';
        final List<String> interests = List<String>.from(data['interests'] ?? []);

        double score = 0.0;
        if (_userCountry.isNotEmpty && country == _userCountry) score += 25;
        if (_userLanguage.isNotEmpty && language == _userLanguage) score += 20;
        if (_userInterests.isNotEmpty && interests.isNotEmpty) {
          final intersection = _userInterests.where((i) => interests.contains(i)).length;
          final union = _userInterests.toSet().union(interests.toSet()).length;
          final jaccard = intersection / union;
          score += jaccard * 30;
        }
        if (_userRole.isNotEmpty && role == _userRole) score += 15;

        candidates.add({
          'userId': userId,
          'name': name,
          'profilePic': profilePic,
          'country': country,
          'language': language,
          'role': role,
          'interests': interests,
          'matchScore': score,
          'mutualFriends': 0,
        });
      }

      await _loadMutualFriends(candidates);

      for (var user in candidates) {
        int mutual = user['mutualFriends'] ?? 0;
        double boost = (mutual * 5).clamp(0, 30).toDouble();
        user['matchScore'] = (user['matchScore'] as double) + boost;
      }

      candidates.sort((a, b) => (b['matchScore'] as double).compareTo(a['matchScore'] as double));
      _recommendedUsers = candidates;
      await _loadRequestStatuses();
    } catch (e) {
      debugPrint('Error loading users: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMutualFriends(List<Map<String, dynamic>> candidates) async {
    for (var user in candidates) {
      final userId = user['userId'];
      try {
        final friendRequests = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('friend_requests')
            .where('status', isEqualTo: 'accepted')
            .get();

        Set<String> candidateFriends = {};
        for (var doc in friendRequests.docs) {
          final data = doc.data();
          final otherId = data['senderId'] == userId
              ? data['receiverId'] as String
              : data['senderId'] as String;
          candidateFriends.add(otherId);
        }

        int mutual = _userFriends.intersection(candidateFriends).length;
        user['mutualFriends'] = mutual;
        print('👉 ${user['name']} → mutual friends: $mutual');
      } catch (e) {
        debugPrint('Error loading mutual friends for $userId: $e');
        user['mutualFriends'] = 0;
      }
    }
  }

  Future<void> _loadRequestStatuses() async {
    for (var user in _recommendedUsers) {
      final userId = user['userId'];
      final status = await _getFriendRequestStatus(userId);
      _requestStatus[userId] = status;
    }
    setState(() {});
  }

  Future<String> _getFriendRequestStatus(String targetUserId) async {
    final requestId = _getRequestId(_currentUserId, targetUserId);
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .collection('friend_requests')
        .doc(requestId)
        .get();
    if (!doc.exists) return 'none';
    return doc.data()?['status'] ?? 'none';
  }

  String _getRequestId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> _sendRequest(String userId) async {
    try {
      await _db.sendFriendRequest(userId, friendType: 'friend');
      _requestStatus[userId] = 'pending';
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('বন্ধুর অনুরোধ পাঠানো হয়েছে'),
            backgroundColor: Color(0xFF2FA089),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ত্রুটি: $e')),
        );
      }
    }
  }

  Future<void> _cancelRequest(String userId) async {
    try {
      await _db.cancelFriendRequest(userId);
      _requestStatus[userId] = 'none';
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('অনুরোধ বাতিল করা হয়েছে'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ত্রুটি: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _recommendedUsers;
    return _recommendedUsers.where((u) => u['name']
        .toLowerCase()
        .contains(_searchQuery.toLowerCase())).toList();
  }

  String _getFlagEmoji(String country) {
    const countryMap = {
      'Bangladesh': '🇧🇩',
      'India': '🇮🇳',
      'United States': '🇺🇸',
      'UK': '🇬🇧',
      'Canada': '🇨🇦',
      'Australia': '🇦🇺',
      'Germany': '🇩🇪',
      'France': '🇫🇷',
      'Japan': '🇯🇵',
      'China': '🇨🇳',
      'Brazil': '🇧🇷',
      'South Africa': '🇿🇦',
    };
    return countryMap[country] ?? '🌍';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: Column(
        children: [
          _buildGradientHeader(),
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? _buildSkeletonLoader()
                : _filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return _buildBalancedCard(user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2FA089), Color(0xFF49B89D)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.arrow_back, size: 16, color: Colors.white),
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'বন্ধু খুঁজুন',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            'আপনার আগ্রহের সাথে মিলে এমন মানুষদের খুঁজুন',
            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'বন্ধুর নাম লিখুন',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF2FA089)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }

  // কার্ড - মিউচুয়াল ফ্রেন্ড সবসময় দেখাবে বাটনের নিচে
  Widget _buildBalancedCard(Map<String, dynamic> user) {
    final userId = user['userId'];
    final status = _requestStatus[userId] ?? 'none';
    final matchScore = user['matchScore'] as double;
    final interests = user['interests'] as List<String>;
    final country = user['country'] as String;
    final language = user['language'] as String;
    final mutualFriends = user['mutualFriends'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF9FFFC), Color(0xFFF1FBF7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2FA089).withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2FA089).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserProfilePage(userId: userId)),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2FA089), width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: getProfileImage(user['profilePic']),
                      child: user['profilePic'].isEmpty
                          ? const Icon(Icons.person, size: 24)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (matchScore > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2FA089).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.whatshot, size: 11, color: Color(0xFF2FA089)),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${matchScore.toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2FA089),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (country.isNotEmpty || language.isNotEmpty)
                        Text(
                          '${country.isNotEmpty ? '${_getFlagEmoji(country)} $country' : ''}${country.isNotEmpty && language.isNotEmpty ? ' • ' : ''}${language.isNotEmpty ? language : ''}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF5A6B6B)),
                        ),
                    ],
                  ),
                ),
                // Right-aligned button
                _buildBalancedButton(status, userId),
              ],
            ),
            // Interests chips
            if (interests.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: interests.take(3).map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2FA089).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      interest,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2FA089),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            // ✅ মিউচুয়াল ফ্রেন্ড সবসময় দেখানো হবে (শূন্য হলেও)
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people_alt, size: 14, color: Color(0xFF5A6B6B)),
                const SizedBox(width: 4),
                Text(
                  '$mutualFriends জন মিউচুয়াল বন্ধু',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF5A6B6B)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalancedButton(String status, String userId) {
    if (status == 'accepted') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF2FA089).withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 14, color: Color(0xFF2FA089)),
            SizedBox(width: 4),
            Text('Friends', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2FA089))),
          ],
        ),
      );
    } else if (status == 'pending') {
      return GestureDetector(
        onTap: () => _cancelRequest(userId),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFF59E0B)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_empty, size: 14, color: Color(0xFFF59E0B)),
              SizedBox(width: 4),
              Text('Pending', style: TextStyle(fontSize: 11, color: Color(0xFFF59E0B))),
            ],
          ),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: () => _sendRequest(userId),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2FA089),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          minimumSize: const Size(0, 32),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add_alt_1, size: 13),
            SizedBox(width: 5),
            Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      itemCount: 4,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2FA089).withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200])),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14, width: double.infinity, color: Colors.grey[200]),
                        const SizedBox(height: 6),
                        Container(height: 11, width: 80, color: Colors.grey[200]),
                      ],
                    ),
                  ),
                  Container(width: 60, height: 32, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(24))),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF2FA089).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline, size: 48, color: Color(0xFF2FA089)),
          ),
          const SizedBox(height: 20),
          const Text(
            'কোনো বন্ধু পাওয়া যায়নি',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E3E)),
          ),
          const SizedBox(height: 6),
          Text('আপনার আগ্রহী ব্যক্তিরা এখানে দেখাবে', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
