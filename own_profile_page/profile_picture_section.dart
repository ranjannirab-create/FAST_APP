
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
    // Premium Paste Green Color Constants
    const Color primaryColor = Color(0xFF2FA089);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), // একটু বেশি রাউন্ডেড প্রিমিয়াম কর্নার
        border: Border.all(
          color: primaryColor.withOpacity(0.15), 
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        image: DecorationImage(
          image: _getProfileImage(profilePic),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          /// Top Left Badge (Premium Paste Green Badge with Number)
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '3', 
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          
          /// Bottom Functional Buttons (Premium Fluid Glass/Minimal Style)
          Positioned(
            bottom: 14,
            left: 10,
            right: 10,
            child: Row(
              children: [
                // Edit Picture Button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.85), // ব্লেন্ডেড মিনিমাল লুক
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_outlined, size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Edit Picture', 
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 12, 
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Camera Icon Button
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: primaryColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined, 
                    size: 16, 
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}