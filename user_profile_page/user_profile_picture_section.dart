// TODO Implement this library.
import 'package:flutter/material.dart';

class UserProfilePictureSection extends StatelessWidget {
  final String profilePic;

  const UserProfilePictureSection({
    super.key,
    required this.profilePic,
  });

  ImageProvider _getProfileImage(String pic) {
    if (pic.isEmpty) {
      return const AssetImage(
        'assets/default_avatar.png',
      );
    }

    if (pic.startsWith('assets/')) {
      return AssetImage(pic);
    }

    return NetworkImage(pic);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.shade100,
          width: 1.5,
        ),
        image: DecorationImage(
          image: _getProfileImage(profilePic),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [

          /// LEVEL BADGE
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Text(
                '🌿',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          /// VIEW PROFILE BUTTON
          Positioned(
            bottom: 12,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility,
                    size: 16,
                    color: Colors.white,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Profile Photo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}