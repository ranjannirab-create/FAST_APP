import 'package:flutter/material.dart';
import '/services/note_service.dart'; // আপনার NoteService এর পাথ
import '../friend_user.dart';

// আপনার NoteService এর পাথ

void _showNoteDialog(BuildContext context, FriendUser friend) {
  final noteService = NoteService();
  final TextEditingController controller = TextEditingController(text: friend.note);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('${friend.name} এর নোট'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('আপনার নিজের নোট:'),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 2,
            maxLength: 99,
            decoration: const InputDecoration(
              hintText: 'নোট লিখুন (max 99)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('বন্ধুর নোট:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(friend.note.isEmpty ? 'কোন নোট নেই' : friend.note),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('বাতিল'),
        ),
        ElevatedButton(
          onPressed: () async {
            await noteService.setMyNote(controller.text);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('নোট সংরক্ষিত')),
            );
          },
          child: const Text('সেভ করুন'),
        ),
      ],
    ),
  );
}