
import 'package:flutter/material.dart';

class UserProfilePictureSection extends StatelessWidget {
  final String profilePic;

  const UserProfilePictureSection({
    super.key,
    required this.profilePic,
  });

  ImageProvider _getProfileImage(String pic) {
    if (pic.isEmpty) return const AssetImage('assets/default_avatar.png');
    if (pic.startsWith('assets/')) return AssetImage(pic);
    return NetworkImage(pic);
  }

  // ফুল ফটো দেখার জন্য একটি ডায়ালগ বা মেথড (অপশনাল ফিচার ট্র্রিগার)
  void _viewFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image(
                  image: _getProfileImage(profilePic),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // আপনার ওন প্রোফাইলের মতো সেম প্রিমিয়াম পেস্ট গ্রিন থিম
    const Color primaryColor = Color(0xFF2FA089);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), // ওন প্রোফাইলের মতো একটু বেশি রাউন্ডেড প্রিমিয়াম কর্নার
        border: Border.all(
          color: primaryColor.withOpacity(0.15), // সেম বর্ডার কালার ও অপাসিটি
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.04), // সেম শ্যাডো ইফেক্ট
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
          
          /// Top Left Badge (Premium Paste Green Badge with Leaf/Level)
          Positioned(
            top: 14, // ওন প্রোফাইলের মতো অ্যালাইনমেন্ট ফিক্সড
            left: 14,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: primaryColor, // গ্রিন শেডের বদলে প্রিমিয়াম পেস্ট গ্রিন
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
                  '🌿', // আপনার ইমোজি লেভেল ব্যাজটি অক্ষুণ্ণ রাখা হলো
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),

          /// Bottom Functional Button (Premium Fluid Glass Styles - Match with Own Profile)
          Positioned(
            bottom: 14, // ওন প্রোফাইলের মতো বটম স্পেসিং ফিক্সড
            left: 10,
            right: 10,
            child: GestureDetector(
              onTap: () => _viewFullImage(context), // ছবিতে বা বাটনে ক্লিক করলে ফুল ছবি পপআপ হবে
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.85), // ব্লেন্ডেড মিনিমাল ফ্লুইড লুক
                  borderRadius: BorderRadius.circular(16), // বাটন বর্ডার রাউন্ড ফিক্সড
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
                    Icon(Icons.visibility_outlined, size: 14, color: Colors.white), // আউটলাইন আইকন
                    SizedBox(width: 6),
                    Text(
                      'View Full Photo', // 'Profile Photo' টেক্সট পরিবর্তন করে স্ট্যান্ডার্ড করা হলো
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
        ],
      ),
    );
  }
}