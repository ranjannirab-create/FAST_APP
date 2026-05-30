
import 'package:flutter/material.dart';

class DetailsBox extends StatelessWidget {
  final Map<String, dynamic> userData;

  const DetailsBox({
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
          width: 1,
        ),
      ),
      child: Column(
        children: [

          // ================= HEADER =================
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.flag,
                  color: Colors.red,
                  size: 15,
                ),

                SizedBox(width: 6),

                Expanded(
                  child: Text(
                    'Report / Block',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Icon(
                  Icons.more_vert,
                  size: 16,
                  color: Colors.black87,
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            thickness: 0.6,
            color: Colors.black12,
          ),

          // ================= DETAILS =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  _buildInfoRow(
                    Icons.person_outline,
                    'Name',
                    userData['name'] ?? 'Nirab Paul',
                  ),

                  _buildDivider(),

                  _buildInfoRow(
                    Icons.calendar_month_outlined,
                    'Age',
                    'Private',
                    isLocked: true,
                  ),

                  _buildDivider(),

                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Address',
                    'Only Friends',
                    isLocked: true,
                  ),

                  _buildDivider(),

                  _buildInfoRow(
                    Icons.school_outlined,
                    'Study',
                    userData['workTitle'] ?? 'HSC Student',
                  ),

                  _buildDivider(),

                  _buildInfoRow(
                    Icons.eco_outlined,
                    'Hobby',
                    _getHobbies(userData),
                  ),

                  _buildDivider(),

                  _buildInfoRow(
                    Icons.star_border,
                    'Dream',
                    'Software Engineer',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HOBBIES =================
  String _getHobbies(Map<String, dynamic> userData) {
    final hobbies = userData['hobbies'] as List?;

    if (hobbies == null || hobbies.isEmpty) {
      return 'Writing, Reading';
    }

    return hobbies.join(', ');
  }

  // ================= DIVIDER =================
  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.4,
      color: Colors.black12,
    );
  }

  // ================= INFO ROW =================
  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value, {
    bool isLocked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [

          // ICON
          Icon(
            icon,
            size: 14,
            color: Colors.green.shade700,
          ),

          const SizedBox(width: 6),

          // TITLE
          SizedBox(
            width: 48,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 10.5,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // VALUE
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // LOCK
                if (isLocked) ...[
                  const SizedBox(width: 2),

                  const Icon(
                    Icons.lock,
                    size: 10,
                    color: Colors.black54,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 1),

          // ARROW
          const Icon(
            Icons.chevron_right,
            size: 14,
            color: Colors.black45,
          ),
        ],
      ),
    );
  }
}