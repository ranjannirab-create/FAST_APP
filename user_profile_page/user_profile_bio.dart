/*import 'package:flutter/material.dart';

class UserProfileBio extends StatelessWidget {
  final String bioText;

  const UserProfileBio({
    super.key,
    required this.bioText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffF1F8EE),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.green.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TOP ROW
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.format_quote,
                  color: Colors.green,
                  size: 22,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.15),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.green,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Bio',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// BIO TEXT
          Text(
            bioText.isNotEmpty
                ? bioText
                : 'No bio added yet 🌿',
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: bioText.isEmpty
                  ? Colors.black45
                  : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          /// BOTTOM
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Text(
                  '🌿 Free Mind',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Text(
                '${bioText.length}/99',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfileBio extends StatefulWidget {
  // এখানে কনস্ট্রাক্টরের অমিলটি ঠিক করা হয়েছে কারণ bioText লোকাল স্টেটেই হ্যান্ডেল হচ্ছে
  const UserProfileBio({super.key, required bioText});

  @override
  State<UserProfileBio> createState() => _UserProfileBioState();
}

class _UserProfileBioState extends State<UserProfileBio> {
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

      // যদি ফায়ারবেস থেকে ডেটা আসার আগেই ইউজার পেজ থেকে চলে যায়, তবে এখানেই ফাংশন থামিয়ে দাও
      if (!mounted) return;

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
      // ক্যাচ ব্লকেও সেইফটি চেক
      if (!mounted) return;
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

    // ডায়ালগ বন্ধ হওয়া বা ব্যাক করার পর যেন ক্র্যাশ না করে
    if (!mounted) return;

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
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            maxLength: 99,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'নিজের মনের কথা লিখুন... 🌿',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final newBio = controller.text.trim();
                
                // প্রথমে ডায়ালগটি বন্ধ করে দিন
                Navigator.pop(context);

                // তারপর ব্যাকগ্রাউন্ডে সেভ করুন
                await saveBio(newBio);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
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
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffF1F8EE),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.green.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.format_quote,
                  color: Colors.green,
                  size: 22,
                ),
              ),
              GestureDetector(
                onTap: editBioDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.edit,
                        color: Colors.green,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          /// BIO TEXT
          Text(
            bioText.isNotEmpty ? bioText : 'নিজের মনের কথা লিখুন... 🌿',
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: bioText.isEmpty ? Colors.black45 : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          /// BOTTOM ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🌿 Positive',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${bioText.length}/99',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}