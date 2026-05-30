
import 'package:flutter/material.dart';
import '../own_profile_page/edit_profile_page.dart'; 

class ProfilePictureSection extends StatelessWidget {
  final String profilePic;

  const ProfilePictureSection({super.key, required this.profilePic});

  ImageProvider _getProfileImage(String pic) {
    if (pic.isEmpty) return const AssetImage('assets/default_avatar.png'); 
    if (pic.startsWith('assets/')) return AssetImage(pic);
    return NetworkImage(pic);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100, width: 1.5), // Halka sobuj border
        image: DecorationImage(
          image: _getProfileImage(profilePic),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Top Left Green Badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Text(
                '3', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          // Bottom Buttons
          Positioned(
            bottom: 12,
            left: 8,
            right: 8,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade300, width: 1),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Edit Picture', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Camera Icon Button
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.camera_alt, size: 16, color: Colors.green.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

