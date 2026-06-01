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

    final int level = userData['level'] ?? 1;
    final int streak = userData['streak'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

        const SizedBox(height: 18),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      if (userData['verified'] ==
                          true)
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 20,
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green
                          .withOpacity(0.08),
                      borderRadius:
                          BorderRadius.circular(
                              20),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.psychology,
                          color: Colors.green,
                          size: 16,
                        ),

                        const SizedBox(
                            width: 5),

                        Text(
                          role,
                          style:
                              const TextStyle(
                            color: Colors.green,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green
                        .withOpacity(0.10),
                    borderRadius:
                        BorderRadius.circular(
                            14),
                  ),
                  child: Text(
                    '🌿 Level $level',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange
                        .withOpacity(0.10),
                    borderRadius:
                        BorderRadius.circular(
                            14),
                  ),
                  child: Text(
                    '🔥 Streak $streak',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}