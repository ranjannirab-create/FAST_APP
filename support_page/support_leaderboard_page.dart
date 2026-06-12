/*
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/database_service.dart';

class SupportLeaderboardPage extends StatefulWidget {
  const SupportLeaderboardPage({super.key});

  @override
  State<SupportLeaderboardPage> createState() => _SupportLeaderboardPageState();
}

class _SupportLeaderboardPageState extends State<SupportLeaderboardPage> {
  late Future<List<LeaderboardUser>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = DatabaseService().getSupportLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('সাপোর্ট লিডারবোর্ড'),
        backgroundColor: const Color(0xFF2FA089),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'রিফ্রেশ',
          ),
        ],
      ),
      body: FutureBuilder<List<LeaderboardUser>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2FA089)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _load,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2FA089),
                    ),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volunteer_activism, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'এই সপ্তাহে কেউ সাহায্য করেনি',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'আপনিই প্রথম হোন! 🤝',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              final rank = index + 1;
              return _buildTile(user, rank);
            },
          );
        },
      ),
    );
  }

  Widget _buildTile(LeaderboardUser user, int rank) {
    Color rankColor;
    IconData rankIcon;
    if (rank == 1) {
      rankColor = Colors.amber.shade700;
      rankIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = Colors.grey.shade600;
      rankIcon = Icons.emoji_events;
    } else if (rank == 3) {
      rankColor = Colors.brown.shade400;
      rankIcon = Icons.emoji_events;
    } else {
      rankColor = Colors.grey.shade500;
      rankIcon = Icons.star_outline;
    }

    return ListTile(
      leading: Container(
        width: 50,
        alignment: Alignment.center,
        child: rank <= 3
            ? Icon(rankIcon, color: rankColor, size: 32)
            : Text(
                '$rank',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
      ),
      minLeadingWidth: 50,
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${user.score} পয়েন্ট (সাহায্য স্কোর)',
        style: TextStyle(color: Colors.grey[700]),
      ),
      trailing: CircleAvatar(
        radius: 22,
        backgroundImage: user.profilePic.isNotEmpty
            ? CachedNetworkImageProvider(user.profilePic)
            : null,
        child: user.profilePic.isEmpty
            ? const Icon(Icons.person, size: 22)
            : null,
      ),
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/database_service.dart';
import '../home_page/user_profile_page.dart'; // ✅ প্রোফাইল পেজ ইম্পোর্ট

class SupportLeaderboardPage extends StatefulWidget {
  const SupportLeaderboardPage({super.key});

  @override
  State<SupportLeaderboardPage> createState() => _SupportLeaderboardPageState();
}

class _SupportLeaderboardPageState extends State<SupportLeaderboardPage> {
  late Future<List<LeaderboardUser>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = DatabaseService().getSupportLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('সাপোর্ট লিডারবোর্ড'),
        backgroundColor: const Color(0xFF2FA089),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'রিফ্রেশ',
          ),
        ],
      ),
      body: FutureBuilder<List<LeaderboardUser>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2FA089)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _load,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2FA089),
                    ),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volunteer_activism, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'এই সপ্তাহে কেউ সাহায্য করেনি',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'আপনিই প্রথম হোন! 🤝',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              final rank = index + 1;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserProfilePage(userId: user.userId),
                    ),
                  );
                },
                child: _buildTile(user, rank),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTile(LeaderboardUser user, int rank) {
    Color rankColor;
    IconData rankIcon;
    if (rank == 1) {
      rankColor = Colors.amber.shade700;
      rankIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = Colors.grey.shade600;
      rankIcon = Icons.emoji_events;
    } else if (rank == 3) {
      rankColor = Colors.brown.shade400;
      rankIcon = Icons.emoji_events;
    } else {
      rankColor = Colors.grey.shade500;
      rankIcon = Icons.star_outline;
    }

    return ListTile(
      leading: Container(
        width: 50,
        alignment: Alignment.center,
        child: rank <= 3
            ? Icon(rankIcon, color: rankColor, size: 32)
            : Text(
                '$rank',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
      ),
      minLeadingWidth: 50,
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${user.score} পয়েন্ট (সাহায্য স্কোর)',
        style: TextStyle(color: Colors.grey[700]),
      ),
      trailing: CircleAvatar(
        radius: 22,
        backgroundImage: user.profilePic.isNotEmpty
            ? CachedNetworkImageProvider(user.profilePic)
            : null,
        child: user.profilePic.isEmpty
            ? const Icon(Icons.person, size: 22)
            : null,
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/database_service.dart';
import '../home_page/user_profile_page.dart';

class SupportLeaderboardPage extends StatefulWidget {
  const SupportLeaderboardPage({super.key});

  @override
  State<SupportLeaderboardPage> createState() => _SupportLeaderboardPageState();
}

class _SupportLeaderboardPageState extends State<SupportLeaderboardPage> {
  late Future<List<LeaderboardUser>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = DatabaseService().getSupportLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('সাপোর্ট লিডারবোর্ড'),
        backgroundColor: const Color(0xFF2FA089),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'রিফ্রেশ',
          ),
        ],
      ),
      body: FutureBuilder<List<LeaderboardUser>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2FA089)),
            );
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('ত্রুটি: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _load,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2FA089)),
                    child: const Text('রিফ্রেশ'),
                  ),
                ],
              ),
            );
          }
          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volunteer_activism, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('এই সপ্তাহে এখনও কেউ সাহায্য করেনি'),
                  SizedBox(height: 8),
                  Text('আপনিই প্রথম হোন 🤝'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final rank = index + 1;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserProfilePage(userId: user.userId),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        // Rank
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: rank <= 3
                              ? _buildMedal(rank)
                              : Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2FA089).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$rank',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2FA089),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: user.profilePic.isNotEmpty
                              ? CachedNetworkImageProvider(user.profilePic)
                              : null,
                          child: user.profilePic.isEmpty
                              ? const Icon(Icons.person, size: 30, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.volunteer_activism, size: 14, color: Color(0xFF2FA089)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${user.score} সাহায্য পয়েন্ট',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF2FA089),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMedal(int rank) {
    Map<int, Color> medalColors = {
      1: Colors.amber.shade600,
      2: Colors.grey.shade500,
      3: Colors.brown.shade400,
    };
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: medalColors[rank]!.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉',
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}