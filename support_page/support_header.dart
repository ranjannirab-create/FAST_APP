import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../support_page/support_category_filter.dart';
import 'create_support_post_page.dart';

class SupportHeader extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const SupportHeader({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  // =========================================
  // SUPPORT GREETING (NO USER DATA)
  // =========================================

  String getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 4 && hour < 11) {
      return 'শুভ সকাল 🌿';
    } else if (hour >= 11 && hour < 16) {
      return 'শুভ দুপুর ☀️';
    } else if (hour >= 16 && hour < 18) {
      return 'শুভ বিকাল 🌤️';
    } else if (hour >= 18 && hour < 20) {
      return 'শুভ সন্ধ্যা 🌙';
    } else {
      return 'শুভ রাত্রি ✨';
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: const Color(0xFFF7FAF8),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // =========================================
          // SUPPORT HEADER (ANONYMOUS)
          // =========================================

          Stack(
            clipBehavior: Clip.none,

            children: [

              Container(
                width: double.infinity,
                height: 205,

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2FA089),
                      Color(0xFF49B89D),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),

                child: Stack(
                  children: [

                    // glow
                    Positioned(
                      top: -35,
                      right: -25,
                      child: Container(
                        height: 140,
                        width: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: -25,
                      left: -20,
                      child: Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                    ),

                    // TEXT
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 22,
                        right: 22,
                        top: 36,
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Text(
                            getGreeting(),
                            style: GoogleFonts.hindSiliguri(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "নিরাপদ সহায়তা কেন্দ্র 🤝",
                            style: GoogleFonts.hindSiliguri(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "এখানে আপনি সম্পূর্ণ গোপনীয়ভাবে আপনার মনের কথা শেয়ার করতে পারবেন",
                            style: GoogleFonts.notoSansBengali(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(18),
                            ),

                            child: Text(
                              "🔒 আপনার পরিচয় সম্পূর্ণ গোপন থাকবে",
                              style: GoogleFonts.notoSansBengali(
                                color: Colors.white,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // =========================================
              // FLOATING SUPPORT POST BOX
              // =========================================

              Positioned(
                bottom: -30,
                left: 18,
                right: 18,

                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const CreateSupportPostPage(),
                      ),
                    );
                  },

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [

                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2FA089)
                                .withOpacity(0.10),
                          ),
                          child: const Icon(
                            Icons.favorite_border,
                            color: Color(0xFF2FA089),
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 10),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [
                              Text(
                                "আপনার মনের কথা লিখুন",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              SizedBox(height: 2),

                              Text(
                                "সম্পূর্ণ গোপনীয়ভাবে শেয়ার করুন",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          height: 40,
                          width: 40,

                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF2FA089),
                                Color(0xFF49B89D),
                              ],
                            ),
                          ),

                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          // =========================================
          // CATEGORY
          // =========================================

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  'সহায়তার ক্যাটাগরি',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),

                Text(
                  'সব দেখুন',
                  style: GoogleFonts.notoSansBengali(
                    color: const Color(0xFF2FA089),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.only(left: 14),

            child: SupportCategoryFilter(
              selectedCategory: selectedCategory,
              onCategoryChanged: onCategoryChanged,
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}