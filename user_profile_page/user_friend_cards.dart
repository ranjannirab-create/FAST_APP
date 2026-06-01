import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'user_friends_list.dart';

class UserFriendCards extends StatelessWidget {
  final String userId;

  const UserFriendCards({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: DatabaseService().getFriendsCount(userId),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserFriendsList(userId: userId),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.group, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Friends',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        count.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        );
      },
    );
  }
}