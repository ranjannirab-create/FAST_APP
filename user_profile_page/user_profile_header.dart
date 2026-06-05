
import 'package:flutter/material.dart';
import 'user_profile_picture_section.dart';
import 'user_details_box.dart';

class UserProfileHeader extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String userId;

  const UserProfileHeader({
    super.key,
    required this.userData,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final String name = userData['name'] ?? 'Unknown User';
    final String role = userData['role'] ?? 'Mind Explorer';
    
    // ডাটা সেফটি সহ লেভেল ও স্ট্র্যাক রিসিভ করা হলো
    final int level = userData['level'] ?? 1;
    final int streak = userData['streak'] ?? 0;

    // ওন প্রোফাইলের মতো সেম প্রিমিয়াম পেস্ট গ্রিন কালার থিম
    const Color primaryColor = Color(0xFF2FA089);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ওপরের ছবি এবং ডিটেইলস বক্স পাশাপাশি (হুবহু ওন প্রোফাইলের লেআউট)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 1,
                child: UserProfilePictureSection(
                  profilePic: userData['profilePic'] ?? '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: UserDetailsBox(
                  userData: userData,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // নাম, ভেরিফাইড ব্যাজ এবং রোল এখন একই লাইনে (স্মার্ট প্রিমিয়াম স্টাইল)
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

            // ডাটাবেজে ভেরিফাইড ট্রু থাকলেই কেবল ব্লু ব্যাজ দেখাবে
            if (userData['verified'] == true) ...[
              const Icon(
                Icons.verified,
                color: Colors.blue,
                size: 18,
              ),
              const SizedBox(width: 10),
            ] else ...[
              const SizedBox(width: 4),
            ],

            // নামের পাশে প্রিমিয়াম ডিজাইনের রোল (Role) ব্যাজ (লোগো ছাড়া ওন প্রোফাইল থিমে)
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

        // লেভেল এবং স্ট্র্যাক স্ট্যাটাস ট্র্যাকার (ডিজাইন নষ্ট না করে নামের ঠিক নিচে সুন্দর মিনিমাল রো-তে শিফট করা হয়েছে)
        if (level > 1 || streak > 0) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              if (level > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🌿 Level $level',
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (level > 0 && streak > 0) const SizedBox(width: 8),
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🔥 Streak $streak',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}