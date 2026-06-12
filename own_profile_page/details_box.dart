
import 'package:flutter/material.dart';

class DetailsBox extends StatelessWidget {
  final Map<String, dynamic> userData;

  const DetailsBox({super.key, required this.userData});

  // Calculate age from birthday string
  String _calculateAge() {
    final birthdayStr = userData['birthday'] as String?;
    if (birthdayStr == null || birthdayStr.isEmpty) return 'Not set';
    try {
      final birthday = DateTime.parse(birthdayStr);
      final today = DateTime.now();
      int age = today.year - birthday.year;
      if (today.month < birthday.month ||
          (today.month == birthday.month && today.day < birthday.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return 'Invalid';
    }
  }

  // Get display value for age based on privacy
  String _getAgeDisplay() {
    final privacy = userData['agePrivacy'] ?? 'public';
    if (privacy == 'private') return 'Private';
    if (privacy == 'friends') return 'Only Friends';
    return _calculateAge();
  }

  // Get display value for address based on privacy
  String _getAddressDisplay() {
    final privacy = userData['addressPrivacy'] ?? 'public';
    if (privacy == 'private') return 'Private';
    if (privacy == 'friends') return 'Only Friends';
    return userData['currentAddress'] ?? 'Not set';
  }

  // Get study/work info
  String _getStudyWork() {
    final workType = userData['workType'] as String? ?? 'none';
    if (workType == 'study') {
      final classLevel = userData['classLevel'] as String? ?? '';
      return classLevel.isEmpty ? 'Student' : classLevel;
    } else if (workType == 'job') {
      final jobCategory = userData['jobCategory'] as String? ?? '';
      return jobCategory.isEmpty ? 'Working' : jobCategory;
    }
    return 'Not specified';
  }

  // Get interests as comma-separated string (changed from hobbies)
  String _getInterests() {
    final interests = userData['interests'] as List?;
    if (interests == null || interests.isEmpty) return 'Not added';
    return interests.join(', ');
  }

  // Show detailed dialog
  void _showDetailDialog(BuildContext context, String title, String value, Color primaryColor, {bool isLocked = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(isLocked ? Icons.lock_outline : Icons.info_outline, size: 20, color: primaryColor),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (isLocked && (title == 'Age' || title == 'Address'))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  value == 'Only Friends'
                      ? 'This information is only visible to friends.'
                      : 'This information is private.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2FA089);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFDFA),
        borderRadius: BorderRadius.circular(16),
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
      ),
      child: Column(
        children: [
          // Header (Report/Block)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: const [
                Icon(Icons.flag, color: Colors.red, size: 15),
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
                Icon(Icons.more_vert, size: 16, color: Colors.black87),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.6, color: Colors.black12),

          // Details rows
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTappableInfoRow(
                    context,
                    Icons.person_outline,
                    'Name',
                    userData['name'] ?? 'Not set',
                    primaryColor,
                  ),
                  _buildDivider(),
                  _buildTappableInfoRow(
                    context,
                    Icons.calendar_month_outlined,
                    'Age',
                    _getAgeDisplay(),
                    primaryColor,
                    isLocked: userData['agePrivacy'] != 'public',
                  ),
                  _buildDivider(),
                  _buildTappableInfoRow(
                    context,
                    Icons.location_on_outlined,
                    'Address',
                    _getAddressDisplay(),
                    primaryColor,
                    isLocked: userData['addressPrivacy'] != 'public',
                  ),
                  _buildDivider(),
                  _buildTappableInfoRow(
                    context,
                    Icons.school_outlined,
                    'Study/Work',
                    _getStudyWork(),
                    primaryColor,
                  ),
                  _buildDivider(),
                  _buildTappableInfoRow(
                    context,
                    Icons.favorite_outline, // নতুন আইকন (আগে ছিল Icons.eco_outlined)
                    'Interest',             // লেবেল 'Hobby' → 'Interest'
                    _getInterests(),        // hobbies → interests
                    primaryColor,
                  ),
                  _buildDivider(),
                  _buildTappableInfoRow(
                    context,
                    Icons.star_border,
                    'Dream',
                    userData['dream'] ?? 'Not set',
                    primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.4, color: Colors.black12);
  }

  Widget _buildTappableInfoRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color primaryColor, {
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: () => _showDetailDialog(context, title, value, primaryColor, isLocked: isLocked),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 14, color: primaryColor),
            const SizedBox(width: 6),
            SizedBox(
              width: 68,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
                  if (isLocked) ...[
                    const SizedBox(width: 2),
                    const Icon(Icons.lock, size: 10, color: Colors.black54),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 1),
            const Icon(Icons.chevron_right, size: 14, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}