/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../support_page/support_category_filter.dart';

class CreateSupportPostPage extends StatefulWidget {
  const CreateSupportPostPage({super.key});

  @override
  State<CreateSupportPostPage> createState() =>
      _CreateSupportPostPageState();
}

class _CreateSupportPostPageState
    extends State<CreateSupportPostPage> {

  final TextEditingController postController = TextEditingController();

  bool isLoading = false;

  String selectedCategory = SupportCategory.depression;

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }

  Future<void> uploadPost() async {
    final text = postController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something 🤍'),
        ),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in'),
          ),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('support_posts')
          .add({
        // 🔐 backend identity (hidden)
        'userId': user.uid,

        // 👻 ALWAYS anonymous UI
        'userName': 'Anonymous',
        'userProfilePic': '',

        // 📌 content
        'text': text,
        'category': selectedCategory,
        'timestamp': Timestamp.now(),

        // ❤️ support system
        'likes': {},
        'likeCount': 0,

        // 💬 comments
        'comments': [],
        'commentCount': 0,

        // 🔒 safety flag
        'isAnonymous': true,
      });

      if (mounted) {
        Navigator.pop(context);
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Share Your Feelings 🤍",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ================= INFO CARD =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF2FA089),
                    child: Icon(
                      Icons.lock_outline,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Anonymous Support",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "No identity will be shown publicly",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= TEXT INPUT =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: postController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText:
                      "Share what you're feeling... you're safe here 🤍",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Select Emotion / Category",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SupportCategory.values.map((cat) {
                final selected = selectedCategory == cat;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = cat;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF2FA089)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF2FA089)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            /// ================= POST BUTTON =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : uploadPost,
                icon: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.favorite),
                label: Text(
                  isLoading ? "Sending..." : "Send Support",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2FA089),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/





import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../support_page/support_category_filter.dart';

class CreateSupportPostPage extends StatefulWidget {
  const CreateSupportPostPage({super.key});

  @override
  State<CreateSupportPostPage> createState() =>
      _CreateSupportPostPageState();
}

class _CreateSupportPostPageState extends State<CreateSupportPostPage> {
  final TextEditingController postController = TextEditingController();

  bool isLoading = false;

  String selectedCategory = SupportCategory.depression;

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }

  /// ============================
  /// UPLOAD SUPPORT POST (FIXED)
  /// ============================
  Future<void> uploadPost() async {
    final text = postController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something 🤍'),
        ),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      /// ✅ FIX: SUPPORT COLLECTION (IMPORTANT)
      await FirebaseFirestore.instance
          .collection('support_posts')
          .add({
        // 🔐 backend user id (hidden)
        'userId': user.uid,

        // 👻 always anonymous
        'userName': 'Anonymous',
        'userProfilePic': '',

        // 📝 content
        'text': text,
        'category': selectedCategory,
        'timestamp': Timestamp.now(),

        // ❤️ system
        'likes': {},
        'likeCount': 0,

        // 💬 comments
        'comments': [],
        'commentCount': 0,

        // 🔒 flag
        'isSupportPost': true,
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Share Your Feelings 🤍",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ================= INFO CARD =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF2FA089),
                    child: Icon(
                      Icons.lock_outline,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Support Post Mode",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Will appear only in Support Page",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= TEXT INPUT =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: postController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: "Share your feelings... 🤍",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Select Category",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),

            /// ================= CATEGORY =================
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SupportCategory.values.map((cat) {
                final selected = selectedCategory == cat;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedCategory = cat);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF2FA089)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            /// ================= BUTTON =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : uploadPost,

                icon: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.favorite),

                label: Text(
                  isLoading ? "Sending..." : "Send Support",
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2FA089),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}