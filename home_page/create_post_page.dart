/*
library;


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home_page/post_categories.dart';

/// =====================================
/// CREATE POST PAGE
/// =====================================

class CreatePostPage extends StatefulWidget {

  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() =>
      _CreatePostPageState();
}

/// =====================================
/// STATE CLASS
/// =====================================

class _CreatePostPageState
    extends State<CreatePostPage> {

  /// =====================================
  /// CONTROLLER
  /// =====================================

  final TextEditingController postController =
      TextEditingController();

  /// =====================================
  /// LOADING
  /// =====================================

  bool isLoading = false;

  /// =====================================
  /// CATEGORY
  /// =====================================

  String selectedCategory =
      PostCategory.lifestyle;

  /// =====================================
  /// USER DATA
  /// =====================================

  String userName = 'User';

  String userProfilePic = '';

  /// =====================================
  /// INIT STATE
  /// =====================================

  @override
  void initState() {

    super.initState();

    loadUserData();
  }

  /// =====================================
  /// LOAD USER DATA
  /// =====================================

  Future<void> loadUserData() async {

    try {

      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (doc.exists) {

        final data = doc.data()!;

        setState(() {

          userName =
              data['name'] ?? 'User';

          userProfilePic =
              data['profilePic'] ?? '';
        });
      }

    } catch (e) {

      debugPrint(e.toString());
    }
  }

  /// =====================================
  /// UPLOAD POST
  /// =====================================

  Future<void> uploadPost() async {

    final text =
        postController.text.trim();

    /// EMPTY CHECK

    if (text.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            'Write something first 🌿',
          ),
        ),
      );

      return;
    }

    try {

      setState(() {
        isLoading = true;
      });

      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) return;

      /// SAVE POST

      await FirebaseFirestore.instance
          .collection('posts')
          .add({

        /// USER INFO

        'userId': user.uid,

        'userName': userName,

        'userProfilePic':
            userProfilePic,

        /// POST INFO

        'text': text,

        // ✅ no image
        'imageUrl': '',

        'category':
            selectedCategory,

        'timestamp':
            Timestamp.now(),

        /// LIKE SYSTEM

        'likes': {},

        'likeCount': 0,

        /// COMMENT SYSTEM

        'comments': [],

        'commentCount': 0,
      });

      /// SUCCESS → AUTO BACK

      if (mounted) {

        Navigator.pop(context);
      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// =====================================
  /// UI
  /// =====================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[100],

      /// =====================================
      /// APP BAR
      /// =====================================

      appBar: AppBar(

        elevation: 0,

        backgroundColor: Colors.white,

        centerTitle: true,

        iconTheme:
            const IconThemeData(
          color: Colors.black,
        ),

        title: const Text(

          'Create Post',

          style: TextStyle(

            color: Colors.black,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      /// =====================================
      /// BODY
      /// =====================================

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            /// =====================================
            /// USER CARD
            /// =====================================

            Container(

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Row(
                children: [

                  /// PROFILE IMAGE

                  CircleAvatar(

                    radius: 24,

                    backgroundImage:
                        userProfilePic.isNotEmpty
                            ? NetworkImage(
                                userProfilePic,
                              )
                            : null,

                    child:
                        userProfilePic.isEmpty
                            ? const Icon(
                                Icons.person,
                              )
                            : null,
                  ),

                  const SizedBox(width: 12),

                  /// USER INFO

                  Expanded(
                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(

                          userName,

                          style:
                              const TextStyle(

                            fontWeight:
                                FontWeight.bold,

                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(
                            height: 4),

                        Text(

                          'Share your thoughts 🌿',

                          style: TextStyle(

                            color:
                                Colors.grey[600],

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

            /// =====================================
            /// POST BOX
            /// =====================================

            Container(

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: TextField(

                controller:
                    postController,

                maxLines: 6,

                decoration:
                    InputDecoration(

                  hintText:
                      "What's on your mind today?",

                  border:
                      InputBorder.none,

                  hintStyle:
                      TextStyle(
                    color:
                        Colors.grey[500],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// =====================================
            /// CATEGORY TITLE
            /// =====================================

            const Text(

              'Select Category',

              style: TextStyle(

                fontWeight:
                    FontWeight.bold,

                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),

            /// =====================================
            /// CATEGORY CHIPS
            /// =====================================

            Wrap(

              spacing: 8,
              runSpacing: 8,

              children:
                  PostCategory.values

                      // ✅ remove all
                      .where(
                        (cat) =>
                            cat !=
                            PostCategory.all,
                      )

                      .map((cat) {

                final selected =
                    selectedCategory ==
                        cat;

                return GestureDetector(

                  onTap: () {

                    setState(() {

                      selectedCategory =
                          cat;
                    });
                  },

                  child:
                      AnimatedContainer(

                    duration:
                        const Duration(
                      milliseconds:
                          180,
                    ),

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),

                    decoration:
                        BoxDecoration(

                      color: selected
                          ? const Color(
                              0xFF2FA089)
                          : Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                              24),

                      border:
                          Border.all(

                        color: selected
                            ? const Color(
                                0xFF2FA089)
                            : Colors.grey
                                .shade300,

                        width: 1,
                      ),
                    ),

                    child: Text(

                      cat,

                      style: TextStyle(

                        color: selected
                            ? Colors.white
                            : Colors.black87,

                        fontWeight:
                            FontWeight.w600,

                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            /// =====================================
            /// POST BUTTON
            /// =====================================

            SizedBox(

              width: double.infinity,

              child:
                  ElevatedButton.icon(

                onPressed:
                    isLoading
                        ? null
                        : uploadPost,

                icon: isLoading

                    ? const SizedBox(

                        height: 18,
                        width: 18,

                        child:
                            CircularProgressIndicator(

                          strokeWidth: 2,

                          color:
                              Colors.white,
                        ),
                      )

                    : const Icon(
                        Icons.send,
                      ),

                label: Text(

                  isLoading
                      ? 'Posting...'
                      : 'Post',
                ),

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      const Color(
                          0xFF2FA089),

                  foregroundColor:
                      Colors.white,

                  elevation: 0,

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 15,
                  ),

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                            16),
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
*/

library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home_page/post_categories.dart';

/// =====================================
/// CREATE POST PAGE
/// =====================================
class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

/// =====================================
/// STATE CLASS
/// =====================================
class _CreatePostPageState extends State<CreatePostPage> {
  /// =====================================
  /// CONTROLLER
  /// =====================================
  final TextEditingController postController = TextEditingController();

  /// =====================================
  /// LOADING
  /// =====================================
  bool isLoading = false;

  /// =====================================
  /// CATEGORY
  /// =====================================
  String selectedCategory = PostCategory.lifestyle;

  /// =====================================
  /// USER DATA
  /// =====================================
  String userName = 'User';
  String userProfilePic = '';
  String userRole = 'Mind Explorer'; 

  /// =====================================
  /// INIT & DISPOSE
  /// =====================================
  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    // ✅ Always dispose controllers to clean memory leaks
    postController.dispose();
    super.dispose();
  }

  /// =====================================
  /// LOAD USER DATA
  /// =====================================
  Future<void> loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          userName = data['name'] ?? 'User';
          userProfilePic = data['profilePic'] ?? '';
          userRole = data['role'] ?? 'Mind Explorer'; 
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  /// =====================================
  /// UPLOAD POST
  /// =====================================
  Future<void> uploadPost() async {
    final text = postController.text.trim();

    /// EMPTY CHECK
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Write something first 🌿'),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      /// SAVE POST
      await FirebaseFirestore.instance.collection('posts').add({
        /// USER INFO
        'userId': user.uid,
        'userName': userName,
        'userProfilePic': userProfilePic,
        'userRole': userRole, 

        /// POST INFO
        'text': text,
        'imageUrl': '',
        'category': selectedCategory,
        'timestamp': Timestamp.now(),

        /// LIKE SYSTEM
        'likes': {},
        'likeCount': 0,

        /// COMMENT SYSTEM
        'comments': [],
        'commentCount': 0,
      });

      /// SUCCESS → AUTO BACK
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // ✅ Guarding context check across async gap for errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// =====================================
  /// UI
  /// =====================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Create Post',
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
            /// USER CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: userProfilePic.isNotEmpty
                        ? NetworkImage(userProfilePic)
                        : null,
                    child: userProfilePic.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Share your thoughts 🌿',
                          style: TextStyle(
                            color: Colors.grey[600],
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

            /// POST BOX
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: postController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: "What's on your mind today?",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// CATEGORY TITLE
            const Text(
              'Select Category',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            /// CATEGORY CHIPS
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PostCategory.values
                  .where((cat) => cat != PostCategory.all)
                  .map((cat) {
                // Ensure correct comparison if PostCategory uses structured String objects/enums
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
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF2FA089)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF2FA089)
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            /// POST BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : uploadPost,
                icon: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(isLoading ? 'Posting...' : 'Post'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2FA089),
                  foregroundColor: Colors.white,
                  elevation: 0,
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