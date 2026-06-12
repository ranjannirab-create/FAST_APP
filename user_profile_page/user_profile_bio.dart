
import 'package:flutter/material.dart';

class UserProfileBio extends StatelessWidget {
  final String bioText;

  // প্যারেন্ট উইজেট থেকে সরাসরি bioText রিসিভ করার জন্য কনস্ট্রাক্টর ফিক্সড
  const UserProfileBio({
    super.key,
    required this.bioText,
  });

  @override
  Widget build(BuildContext context) {
    // ওন প্রোফাইলের মতো সেম প্রিমিয়াম পেস্ট গ্রিন কালার
    const Color primaryColor = Color(0xFF2FA089);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF9FFFC), Color(0xFFF1FBF7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25), // সেম প্রিমিয়াম রাউন্ডেড কর্নার
        border: Border.all(
          color: primaryColor.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW (শুধুমাত্র পজিটিভ ট্যাগ থাকবে, অন্য ইউজারের জন্য এডিট/কাউন্টার বাদ)
          Row(
            children: [
              // Positive Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🌿 Positive',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const Spacer(),

              // কোটেশন আইকন (ডিজাইন আরও একটু প্রিমিয়াম লুক দেওয়ার জন্য)
              Icon(
                Icons.format_quote_rounded,
                color: primaryColor.withOpacity(0.3),
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// BIO TEXT (অন্য ইউজারের বায়ো)
          Text(
            bioText.isNotEmpty ? bioText : 'এই ইউজার এখনও কোনো বায়ো লেখেননি... 🌿',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: bioText.isEmpty ? Colors.black38 : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}