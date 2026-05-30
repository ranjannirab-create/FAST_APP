
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home_page/create_post_page.dart';
import 'category_filter.dart';

class HomeHeader extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const HomeHeader({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  // =========================================
  // DYNAMIC BANGLA GREETING
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
    final user = FirebaseAuth.instance.currentUser;

    final displayName =
        user?.displayName ??
        user?.email?.split('@')[0] ??
        'বন্ধু';

    return Container(
      color: const Color(0xFFF7FAF8),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // =========================================
          // PREMIUM HEADER
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
                    // =================================
                    // GLOW EFFECTS
                    // =================================

                    Positioned(
                      top: -35,
                      right: -25,

                      child: Container(
                        height: 140,
                        width: 140,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          color: Colors.white
                              .withOpacity(0.05),
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

                          color: Colors.white
                              .withOpacity(0.04),
                        ),
                      ),
                    ),

                    // =================================
                    // TEXT CONTENT
                    // =================================

                    Padding(
                      padding: const EdgeInsets.only(
                        left: 22,
                        right: 22,
                        top: 36,
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          // =========================
                          // GREETING
                          // =========================

                          Text(
                            getGreeting(),

                            style:
                                GoogleFonts.hindSiliguri(
                              color: Colors.white
                                  .withOpacity(0.88),

                              fontSize: 17,

                              fontWeight:
                                  FontWeight.w700,

                              letterSpacing: 0.2,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // =========================
                          // USER NAME
                          // =========================

                          Text(
                            displayName,

                            style:
                                GoogleFonts.hindSiliguri(
                              color: Colors.white,

                              fontSize: 30,

                              height: 1.08,

                              fontWeight:
                                  FontWeight.bold,

                              letterSpacing: 0.3,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // =========================
                          // COMMUNITY TEXT
                          // =========================

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.10),

                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                            ),

                            child: Text(
                              'আসুন আমরা নিজেদের সুখ দুঃখ ভাগাভাগি করি 🌱',

                              style:
                                  GoogleFonts.notoSansBengali(
                                color: Colors.white
                                    .withOpacity(0.92),

                                fontSize: 11.5,

                                height: 1.45,

                                fontWeight:
                                    FontWeight.w400,
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
              // FLOATING POST BOX
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
                        builder:
                            (_) =>
                                const CreatePostPage(),
                      ),
                    );
                  },

                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        24,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.05),

                          blurRadius: 16,

                          offset: const Offset(
                            0,
                            8,
                          ),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [
                        // =====================
                        // ICON
                        // =====================

                        Container(
                          padding:
                              const EdgeInsets.all(
                            10,
                          ),

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            color: const Color(
                              0xFF2FA089,
                            ).withOpacity(0.10),
                          ),

                          child: const Icon(
                            Icons.edit_rounded,

                            color: Color(
                              0xFF2FA089,
                            ),

                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 10),

                        // =====================
                        // TEXT
                        // =====================

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                "আপনার মনের কথা...",

                                style:
                                    GoogleFonts.hindSiliguri(
                                  fontSize: 13,

                                  fontWeight:
                                      FontWeight.w600,

                                  color:
                                      Colors.black87,

                                  letterSpacing: 0.1,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                'আপনার অনুভূতি আমাদের শেয়ার করুন',

                                style:
                                    GoogleFonts.notoSansBengali(
                                  fontSize: 10,

                                  color:
                                      Colors.grey[600],

                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // =====================
                        // ADD BUTTON
                        // =====================

                        Container(
                          height: 40,
                          width: 40,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            gradient:
                                const LinearGradient(
                              colors: [
                                Color(0xFF2FA089),
                                Color(0xFF49B89D),
                              ],
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF2FA089,
                                ).withOpacity(0.25),

                                blurRadius: 10,

                                offset:
                                    const Offset(
                                  0,
                                  5,
                                ),
                              ),
                            ],
                          ),

                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 23,
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
          // CATEGORY TITLE
          // =========================================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
            ),

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [
                Text(
                  'ক্যাটাগরি সমূহ',

                  style:
                      GoogleFonts.hindSiliguri(
                    fontSize: 17,

                    fontWeight:
                        FontWeight.w700,

                    color: Colors.black87,
                  ),
                ),

                Text(
                  'সব দেখুন',

                  style:
                      GoogleFonts.notoSansBengali(
                    color: const Color(
                      0xFF2FA089,
                    ),

                    fontWeight:
                        FontWeight.w600,

                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // =========================================
          // CATEGORY FILTER
          // =========================================

          Padding(
            padding: const EdgeInsets.only(
              left: 14,
            ),

            child: CategoryFilter(
              selectedCategory:
                  selectedCategory,

              onCategoryChanged:
                  onCategoryChanged,
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}