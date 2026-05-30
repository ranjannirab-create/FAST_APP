import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../home_page/image_helper.dart';

class OnlineFriendsWidget extends StatelessWidget {
  const OnlineFriendsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FriendUser>>(
      stream: DatabaseService().getOnlineFriends(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 95,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 95,
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        final onlineFriends = snapshot.data ?? [];
        if (onlineFriends.isEmpty) {
          return const SizedBox(
            height: 95,
            child: Center(child: Text('No online friends')),
          );
        }
        return SizedBox(
          height: 95,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: onlineFriends.length,
            itemBuilder: (context, index) {
              final friend = onlineFriends[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: getProfileImage(friend.profilePic),
                          child: friend.profilePic.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        // সবুজ অনলাইন ডট
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 60,
                      child: Text(
                        friend.name,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}