import 'package:flutter/material.dart';

class AvatarPicker extends StatelessWidget {
  final Function(String) onSelected;
  final String currentAvatar;

  const AvatarPicker({super.key, required this.onSelected, required this.currentAvatar});

  // ✅ Use the actual image file names you have in assets/avatars/
  static const List<String> avatarList = [
    'assets/pfp1.jpg',
    'assets/pfp2.jpg',
    'assets/pfp3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Profile Picture'),
      content: SizedBox(
        width: 250,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( 
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: avatarList.length,
          itemBuilder: (context, index) {
            final path = avatarList[index];
            final isSelected = currentAvatar == path;
            return GestureDetector(
              onTap: () {
                onSelected(path);
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: Colors.green, width: 3) : null,
                ),
                child: ClipOval(
                  child: Image.asset(path, fit: BoxFit.cover),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

