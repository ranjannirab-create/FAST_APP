

import 'package:fast_app/user_profile_page/user_friends_list.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';

class UserFriendListCard extends StatelessWidget {
  final String userId;

  const UserFriendListCard({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FriendUser>>(
      stream: DatabaseService().getFriendsListForUser(userId),
      builder: (context, snapshot) {
        final friends = snapshot.data ?? [];

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
                    children: const [
                      Text(
                        'Friends',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'View all friends',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  friends.length.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(width: 6),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        );
      },
    );
  }
}

