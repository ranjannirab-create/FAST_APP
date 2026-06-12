
import 'package:flutter/material.dart';
import 'profile_picture_section.dart';
import 'details_box.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String userId;
  final bool isOwnProfile;

  const ProfileHeader({
    super.key,
    required this.userData,
    required this.userId,
    this.isOwnProfile = true,
  });

  @override
  Widget build(BuildContext context) {
    final String name = userData['name'] ?? 'Unknown User';
    final String role = userData['role'] ?? 'Mind Explorer';

    // প্রিমিয়াম পেস্ট গ্রিন কালার থিম
    const Color primaryColor = Color(0xFF2FA089);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ওপরের ছবি এবং ডিটেইলস বক্স পাশাপাশি
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 1,
                child: ProfilePictureSection(
                  profilePic: userData['profilePic'] ?? '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: DetailsBox(
                  userData: userData,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // নাম এবং রোল এখন একই লাইনে (মাইন্ড লোগো ছাড়া)
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ইউজারের নাম
            Flexible(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            
            const SizedBox(width: 6),

            // ভেরিফাইড ব্লু ব্যাজ
            const Icon(
              Icons.verified,
              color: Colors.blue,
              size: 18,
            ),

            const SizedBox(width: 10),

            // নামের পাশে প্রিমিয়াম ডিজাইনের রোল (Role) ব্যাজ (লোগো ছাড়া)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08), // হালকা পেস্ট গ্রিন ব্যাকগ্রাউন্ড
                borderRadius: BorderRadius.circular(30), // ওভাল ক্যাপসুল শেইপ
                border: Border.all(
                  color: primaryColor.withOpacity(0.25), // হালকা সুন্দর বর্ডার
                  width: 1,
                ),
              ),
              child: Text(
                role,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}