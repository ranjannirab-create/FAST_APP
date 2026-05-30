
import 'package:flutter/material.dart';
import 'profile_picture_section.dart';
import 'details_box.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String userId;

  const ProfileHeader({super.key, required this.userData, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // IntrinsicHeight ensures both children take exactly the same height!
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Side: Profile Picture (Flex 1 ensures 50% width)
              Expanded(
                flex: 1,
                child: ProfilePictureSection(
                  profilePic: userData['profilePic'] ?? '',
                ),
              ),
              const SizedBox(width: 12),
              // Right Side: Details Box (Flex 1 ensures 50% width)
              Expanded(
                flex: 1,
                child: DetailsBox(userData: userData),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Name and Level Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userData['name'] ?? 'Nirab Paul',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Colors.blue, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.psychology, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(userData['role'] ?? 'Mind Explorer', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                  ],
                )
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Text('\u{1F33F} Level 12', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Text('\u{1F525} Streak 21', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}


