


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileBio extends StatefulWidget {
  const ProfileBio({super.key, required bioText});

  @override
  State<ProfileBio> createState() => _ProfileBioState();
}

class _ProfileBioState extends State<ProfileBio> {
  String bioText = '';
  bool isLoading = true;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    loadBio();
  }

  /// LOAD BIO FROM FIREBASE
  Future<void> loadBio() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        setState(() {
          bioText = doc['bio'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// SAVE BIO TO FIREBASE
  Future<void> saveBio(String text) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({
      'bio': text,
    }, SetOptions(merge: true));

    setState(() {
      bioText = text;
    });
  }

  /// EDIT DIALOG
  void editBioDialog() {
    final controller = TextEditingController(text: bioText);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Bio',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            maxLength: 99,
            maxLines: 4,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'নিজের মনের কথা লিখুন... 🌿',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2FA089),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final newBio = controller.text.trim();
                await saveBio(newBio);
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2FA089)),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF9FFFC), Color(0xFFF1FBF7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFF2FA089).withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2FA089).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW (এখন পজিটিভ ট্যাগ, এডিট বাটন এবং কাউন্টার উপরে চলে এসেছে)
          Row(
            children: [
              // Positive Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF2FA089).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🌿 Positive',
                  style: TextStyle(
                    color: Color(0xFF2FA089),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),

              // Edit Button (পজিটিভ এর পাশে)
              GestureDetector(
                onTap: editBioDialog,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2FA089).withOpacity(0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF2FA089),
                    size: 14,
                  ),
                ),
              ),

              const Spacer(),

              // Counter
              Text(
                '${bioText.length}/99',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// BIO TEXT (এখন নিচে থাকবে)
          Text(
            bioText.isNotEmpty ? bioText : 'নিজের মনের কথা লিখুন... 🌿',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: bioText.isEmpty ? Colors.black45 : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}