import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../home_page/user_profile_page.dart';

class UserFriendsList extends StatelessWidget {
  final String userId;

  const UserFriendsList({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FriendUser>>(
      stream: DatabaseService().getFriendsListForUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final friends = snapshot.data ?? [];

        if (friends.isEmpty) {
          return const Center(
            child: Text(
              "No friends yet",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: friends.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final friend = friends[index];

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: friend.profilePic.isNotEmpty
                      ? NetworkImage(friend.profilePic)
                      : null,
                  child: friend.profilePic.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),

                title: Text(
                  friend.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: const Text("Friend"),

                trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserProfilePage(
                        userId: friend.userId,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}