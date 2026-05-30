

import 'package:flutter/material.dart';

class FriendCards extends StatelessWidget {
  const FriendCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFriendCard('Friend', '58', Icons.group, Colors.green),
        _buildFriendCard('Junior Friend', '36', Icons.face, Colors.blueGrey),
        _buildFriendCard('Senior Friend', '21', Icons.star, Colors.orange),
      ],
    );
  }

  Widget _buildFriendCard(String title, String count, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(count, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

