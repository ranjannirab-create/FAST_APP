import 'package:flutter/material.dart';

class UserDetailsBox extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserDetailsBox({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFDFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.shade200,
        ),
      ),
      child: Column(
        children: [

          /// HEADER
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius:
                  const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.person,
                  size: 15,
                  color: Colors.green,
                ),

                SizedBox(width: 6),

                Expanded(
                  child: Text(
                    'User Information',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            thickness: 0.6,
          ),

          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [

                  _buildInfoRow(
                    Icons.person_outline,
                    'Name',
                    userData['name'] ??
                        'Unknown',
                  ),

                  _divider(),

                  _buildInfoRow(
                    Icons.school_outlined,
                    'Study',
                    userData['workTitle'] ??
                        'Student',
                  ),

                  _divider(),

                  _buildInfoRow(
                    Icons.eco_outlined,
                    'Hobby',
                    _getHobbies(),
                  ),

                  _divider(),

                  _buildInfoRow(
                    Icons.star_border,
                    'Dream',
                    userData['dream'] ??
                        'Big Dream',
                  ),

                  _divider(),

                  _buildInfoRow(
                    Icons.groups_outlined,
                    'Friends',
                    '${userData['friendsCount'] ?? 0}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 0.4,
      color: Colors.black12,
    );
  }

  String _getHobbies() {
    final hobbies =
        userData['hobbies'] as List?;

    if (hobbies == null ||
        hobbies.isEmpty) {
      return 'Writing';
    }

    return hobbies.join(', ');
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.green,
        ),

        const SizedBox(width: 6),

        SizedBox(
          width: 48,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}