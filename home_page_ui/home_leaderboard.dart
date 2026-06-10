import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/database_service.dart';
import '../home_page/user_profile_page.dart';
import 'leaderboard_page.dart';

class HomeLeaderboard extends StatefulWidget {
  const HomeLeaderboard({super.key});

  @override
  State<HomeLeaderboard> createState() => _HomeLeaderboardState();
}

class _HomeLeaderboardState extends State<HomeLeaderboard> {
  late Future<List<LeaderboardUser>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = DatabaseService().getHomeLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🏆 সাপ্তাহিক শীর্ষ ব্যক্তি',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                  );
                },
                child: const Text('সব দেখুন →', style: TextStyle(color: Color(0xFF2FA089))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<LeaderboardUser>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2FA089)),
                  ),
                );
              }
              if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'এই সপ্তাহে কেউ পয়েন্ট অর্জন করেনি',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              final users = snapshot.data!.take(3).toList();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(users.length, (i) {
                  final user = users[i];
                  final rank = i + 1;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserProfilePage(userId: user.userId),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: rank == 1
                                  ? Colors.amber
                                  : rank == 2
                                      ? Colors.grey
                                      : Colors.brown,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: user.profilePic.isNotEmpty
                                ? CachedNetworkImageProvider(user.profilePic)
                                : null,
                            child: user.profilePic.isEmpty
                                ? const Icon(Icons.person, size: 30, color: Colors.grey)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user.name.length > 8 ? '${user.name.substring(0, 8)}...' : user.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${user.score} pts',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2FA089),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}