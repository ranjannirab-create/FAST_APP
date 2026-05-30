/*
// Dart এর File class ব্যবহার করার জন্য


// Firebase Firestore database package
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

// Firebase Authentication package
import 'package:firebase_auth/firebase_auth.dart';

// Firebase Storage package
import 'package:firebase_storage/firebase_storage.dart';

// Flutter UI package
import 'package:flutter/material.dart';

// Gallery থেকে image pick করার package
import 'package:image_picker/image_picker.dart';

/// =====================================
/// CREATE POST PAGE
/// =====================================

class CreatePostPage extends StatefulWidget {

  // Constructor
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
  /// TEXTFIELD CONTROLLER
  /// =====================================

  // Post text manage করার controller
  final TextEditingController postController =
      TextEditingController();

  /// =====================================
  /// IMAGE FILE
  /// =====================================

  // Selected image store হবে এখানে
  File? selectedImage;

  /// =====================================
  /// LOADING STATE
  /// =====================================

  // Upload চলাকালীন loading দেখানোর জন্য
  bool isLoading = false;

  /// =====================================
  /// SELECTED CATEGORY
  /// =====================================

  // Default selected category
  String selectedCategory = 'Lifestyle';

  /// =====================================
  /// USER DATA
  /// =====================================

  // User name
  String userName = 'User';

  // User profile image URL
  String userProfilePic = '';

  /// =====================================
  /// CATEGORY LIST
  /// =====================================

  // সব category list
  final List<String> categories = [

    'Lifestyle',

    'Study',

    'Motivation',

    'Gaming',

    'Writing',

    'Relax',
  ];

  /// =====================================
  /// INIT STATE
  /// =====================================

  @override
  void initState() {

    super.initState();

    // Page load হলে user data load করবে
    loadUserData();
  }

  /// =====================================
  /// LOAD USER DATA
  /// =====================================

  Future<void> loadUserData() async {

    try {

      // Current logged in user নিচ্ছে
      final user =
          FirebaseAuth.instance.currentUser;

      // User null হলে function বন্ধ
      if (user == null) return;

      // Firestore থেকে user document নিচ্ছে
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      // যদি document থাকে
      if (doc.exists) {

        // User data map নিচ্ছে
        final data = doc.data()!;

        // UI update করছে
        setState(() {

          // User name নিচ্ছে
          userName =
              data['name'] ?? 'User';

          // Profile image নিচ্ছে
          userProfilePic =
              data['profilePic'] ?? '';
        });
      }

    } catch (e) {

      // Error console এ print করবে
      debugPrint(e.toString());
    }
  }

  /// =====================================
  /// PICK IMAGE FROM GALLERY
  /// =====================================

  Future<void> pickImage() async {

    // Gallery open করবে
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery);

    // যদি image select করা হয়
    if (picked != null) {

      setState(() {

        // Selected image file save করবে
        selectedImage = File(picked.path);
      });
    }
  }

  /// =====================================
  /// UPLOAD IMAGE TO FIREBASE STORAGE
  /// =====================================

  Future<String> uploadImage(File image) async {

    // Unique filename তৈরি করছে
    final fileName =
        DateTime.now()
            .millisecondsSinceEpoch
            .toString();

    // Firebase Storage path reference
    final ref = FirebaseStorage.instance
        .ref()
        .child('post_images')
        .child('$fileName.jpg');

    // Image upload করছে
    await ref.putFile(image);

    // Uploaded image URL return করছে
    return await ref.getDownloadURL();
  }

  /// =====================================
  /// UPLOAD POST FUNCTION
  /// =====================================

  Future<void> uploadPost() async {

    // TextField এর লেখা নিচ্ছে
    final text = postController.text.trim();

    // যদি text empty হয়
    if (text.isEmpty) {

      // SnackBar show করবে
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

      // Loading start
      setState(() {
        isLoading = true;
      });

      // Current user নিচ্ছে
      final user =
          FirebaseAuth.instance.currentUser;

      // User null হলে return
      if (user == null) return;

      // Default image url empty
      String imageUrl = '';

      /// =====================================
      /// IMAGE UPLOAD
      /// =====================================

      // যদি image select করা থাকে
      if (selectedImage != null) {

        // Firebase storage এ upload করবে
        imageUrl =
            await uploadImage(selectedImage!);
      }

      /// =====================================
      /// SAVE POST TO FIRESTORE
      /// =====================================

      await FirebaseFirestore.instance
          .collection('posts')
          .add({

        /// ==========================
        /// USER INFO
        /// ==========================

        // Post owner id
        'userId': user.uid,

        // User name
        'userName': userName,

        // User profile image
        'userProfilePic':
            userProfilePic,

        /// ==========================
        /// POST DATA
        /// ==========================

        // Post text
        'text': text,

        // Image URL
        'imageUrl': imageUrl,

        // Selected category
        'category':
            selectedCategory,

        // Post upload time
        'timestamp':
            Timestamp.now(),

        /// ==========================
        /// LIKE SYSTEM
        /// ==========================

        // কে কে like দিয়েছে
        'likes': {},

        // Total like count
        'likeCount': 0,

        /// ==========================
        /// COMMENT SYSTEM
        /// ==========================

        // Comment list
        'comments': [],

        // Total comment count
        'commentCount': 0,
      });

      /// =====================================
      /// SUCCESS MESSAGE
      /// =====================================

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            'Post Uploaded 🌿',
          ),
        ),
      );

      // Previous screen এ ফিরে যাবে
      Navigator.pop(context);

    } catch (e) {

      /// =====================================
      /// ERROR MESSAGE
      /// =====================================

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );

    } finally {

      // Loading stop
      setState(() {
        isLoading = false;
      });
    }
  }

  /// =====================================
  /// UI BUILD METHOD
  /// =====================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // Background color
      backgroundColor: Colors.grey[100],

      /// =====================================
      /// APP BAR
      /// =====================================

      appBar: AppBar(

        // Shadow remove
        elevation: 0,

        // AppBar background
        backgroundColor: Colors.white,

        // Title center
        centerTitle: true,

        // Back button color
        iconTheme:
            const IconThemeData(
          color: Colors.black,
        ),

        // AppBar title
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

        // Padding
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

                  /// USER PROFILE IMAGE
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

                  Expanded(
                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        /// USER NAME
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

                        /// SUBTITLE
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

              child: Column(
                children: [

                  /// TEXTFIELD
                  TextField(

                    controller:
                        postController,

                    // Multiple line support
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

                  /// =====================================
                  /// IMAGE PREVIEW
                  /// =====================================

                  if (selectedImage != null)
                    ...[

                    const SizedBox(
                        height: 14),

                    ClipRRect(

                      borderRadius:
                          BorderRadius.circular(
                              16),

                      child: Image.file(

                        selectedImage!,

                        width:
                            double.infinity,

                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
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

              spacing: 10,

              runSpacing: 10,

              children:
                  categories.map((cat) {

                // Current category selected কিনা
                final selected =
                    selectedCategory == cat;

                return GestureDetector(

                  // Category select
                  onTap: () {

                    setState(() {

                      selectedCategory =
                          cat;
                    });
                  },

                  child: Container(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),

                    decoration:
                        BoxDecoration(

                      color: selected
                          ? Colors.green
                          : Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                              30),

                      border: Border.all(

                        color: selected
                            ? Colors.green
                            : Colors.grey
                                .shade300,
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
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 25),

            /// =====================================
            /// BUTTON SECTION
            /// =====================================

            Row(
              children: [

                /// =====================================
                /// IMAGE BUTTON
                /// =====================================

                Expanded(

                  child:
                      OutlinedButton.icon(

                    // Image picker function
                    onPressed:
                        pickImage,

                    icon: const Icon(
                      Icons.image,
                    ),

                    label: const Text(
                      'Add Image',
                    ),

                    style:
                        OutlinedButton.styleFrom(

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                                14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                /// =====================================
                /// POST BUTTON
                /// =====================================

                Expanded(

                  child:
                      ElevatedButton.icon(

                    // Loading হলে disable
                    onPressed:
                        isLoading
                            ? null
                            : uploadPost,

                    // Loading indicator অথবা send icon
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

                    // Button text
                    label: Text(

                      isLoading
                          ? 'Uploading...'
                          : 'Post',
                    ),

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          Colors.green,

                      foregroundColor:
                          Colors.white,

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                                14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/
/*
/// =====================================
/// IMPORTS
/// =====================================

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  /// CONTROLLERS
  /// =====================================

  final TextEditingController postController =
      TextEditingController();

  /// =====================================
  /// IMAGE
  /// =====================================

  File? selectedImage;

  /// =====================================
  /// LOADING
  /// =====================================

  bool isLoading = false;

  /// =====================================
  /// CATEGORY
  /// =====================================

  // ✅ default category
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
  /// PICK IMAGE
  /// =====================================

  Future<void> pickImage() async {

    final picked = await ImagePicker()
        .pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {

      setState(() {

        selectedImage =
            File(picked.path);
      });
    }
  }

  /// =====================================
  /// UPLOAD IMAGE
  /// =====================================

  Future<String> uploadImage(
      File image) async {

    final fileName =
        DateTime.now()
            .millisecondsSinceEpoch
            .toString();

    final ref = FirebaseStorage.instance
        .ref()
        .child('post_images')
        .child('$fileName.jpg');

    await ref.putFile(image);

    return await ref.getDownloadURL();
  }

  /// =====================================
  /// UPLOAD POST
  /// =====================================

  Future<void> uploadPost() async {

    final text =
        postController.text.trim();

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

      String imageUrl = '';

      /// IMAGE UPLOAD

      if (selectedImage != null) {

        imageUrl =
            await uploadImage(
          selectedImage!,
        );
      }

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

        'imageUrl': imageUrl,

        // ✅ category save
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

      /// SUCCESS

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            'Post Uploaded 🌿',
          ),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );

    } finally {

      setState(() {
        isLoading = false;
      });
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

              child: Column(
                children: [

                  TextField(

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

                  /// IMAGE PREVIEW

                  if (selectedImage != null)
                    ...[

                    const SizedBox(
                        height: 14),

                    ClipRRect(

                      borderRadius:
                          BorderRadius.circular(
                              16),

                      child: Image.file(

                        selectedImage!,

                        width:
                            double.infinity,

                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
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

                      // ✅ all বাদ
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

            const SizedBox(height: 25),

            /// =====================================
            /// BUTTONS
            /// =====================================

            Row(
              children: [

                /// IMAGE BUTTON

                Expanded(

                  child:
                      OutlinedButton.icon(

                    onPressed:
                        pickImage,

                    icon: const Icon(
                      Icons.image,
                    ),

                    label: const Text(
                      'Add Image',
                    ),

                    style:
                        OutlinedButton.styleFrom(

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                                14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                /// POST BUTTON

                Expanded(

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
                          ? 'Uploading...'
                          : 'Post',
                    ),

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          const Color(
                              0xFF2FA089),

                      foregroundColor:
                          Colors.white,

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                                14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/
/// =====================================
/// IMPORTS
/// =====================================
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