import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../home_page/user_profile_page.dart';
import '../home_page/image_helper.dart'; // getProfileImage()

class FriendsListPage extends StatelessWidget {
  const FriendsListPage({super.key, required String userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Friends'),
        elevation: 0,
      ),
      body: StreamBuilder<List<FriendUser>>(
        stream: DatabaseService().getFriendsList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No friends found',
              ),
            );
          }

          final friends = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage:
                        getProfileImage(friend.profilePic),
                    child: friend.profilePic.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),

                  title: Text(
                    friend.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  subtitle: friend.lastMessage.isNotEmpty
                      ? Text(
                          friend.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const Text('Friend'),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),

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
      ),
    );
  }
}
