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

  // ---------- নতুন ফিল্ড ----------
  String userCountry = '';
  String userLanguage = '';
  List<String> userInterests = [];

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
    postController.dispose();
    super.dispose();
  }

  /// =====================================
  /// LOAD USER DATA (আপডেটেড)
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

          // নতুন ফিল্ড লোড
          userCountry = data['country'] ?? '';
          userLanguage = data['language'] ?? '';
          userInterests = List<String>.from(data['interests'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  /// =====================================
  /// UPLOAD POST (আপডেটেড)
  /// =====================================
  Future<void> uploadPost() async {
    final text = postController.text.trim();

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

      await FirebaseFirestore.instance.collection('posts').add({
        /// USER INFO
        'userId': user.uid,
        'userName': userName,
        'userProfilePic': userProfilePic,
        'userRole': userRole,

        /// নতুন ফিল্ড
        'country': userCountry,
        'language': userLanguage,
        'interests': userInterests,

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

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
*/


import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../home_page/post_categories.dart';

/// =====================================
/// CREATE POST PAGE WITH IMAGE
/// =====================================
class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController postController = TextEditingController();
  bool isLoading = false;
  String selectedCategory = PostCategory.lifestyle;
  
  // ==================== ইমেজ সম্পর্কিত ভেরিয়েবল ====================
  File? _selectedImage;
  bool _isUploadingImage = false;
  String? _uploadedImageUrl;
  
  // ইউজার ডাটা
  String userName = 'User';
  String userProfilePic = '';
  String userRole = 'Mind Explorer';
  String userCountry = '';
  String userLanguage = '';
  List<String> userInterests = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }

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
          userCountry = data['country'] ?? '';
          userLanguage = data['language'] ?? '';
          userInterests = List<String>.from(data['interests'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  // ==================== ইমেজ পিক করার ফাংশন ====================
  
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
  
  Future<void> _takePhotoFromCamera() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
  
  Future<void> _removeImage() async {
    setState(() {
      _selectedImage = null;
      _uploadedImageUrl = null;
    });
  }
  
  // ==================== ইমেজ আপলোড করার ফাংশন ====================
  
  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      
      final fileName = 'post_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'userId': user.uid},
      );
      
      await ref.putFile(imageFile, metadata);
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Image upload error: $e');
      return null;
    }
  }

  // ==================== পোস্ট আপলোড (ইমেজ সহ) ====================
  
  Future<void> uploadPost() async {
    final text = postController.text.trim();

    if (text.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something or add an image 🌿')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
        _isUploadingImage = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      // ইমেজ আপলোড করুন (যদি থাকে)
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImageToFirebase(_selectedImage!);
        setState(() {
          _uploadedImageUrl = imageUrl;
        });
      }
      
      setState(() {
        _isUploadingImage = false;
      });

      await FirebaseFirestore.instance.collection('posts').add({
        /// USER INFO
        'userId': user.uid,
        'userName': userName,
        'userProfilePic': userProfilePic,
        'userRole': userRole,
        'country': userCountry,
        'language': userLanguage,
        'interests': userInterests,

        /// POST INFO
        'text': text,
        'imageUrl': imageUrl ?? '',  // 👈 ইমেজ URL যোগ করুন
        'category': selectedCategory,
        'timestamp': Timestamp.now(),

        /// LIKE SYSTEM
        'likes': {},
        'likeCount': 0,

        /// COMMENT SYSTEM
        'comments': [],
        'commentCount': 0,
      });

      if (mounted) {
        Navigator.pop(context, true);  // true দিয়ে indicate করুন পোস্ট হয়েছে
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          _isUploadingImage = false;
        });
      }
    }
  }

  /// ==================== ইমেজ পিকার শীট ====================
  
  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add Image to Post',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImagePickerOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromGallery();
                    },
                  ),
                  _buildImagePickerOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      _takePhotoFromCamera();
                    },
                  ),
                  if (_selectedImage != null)
                    _buildImagePickerOption(
                      icon: Icons.delete_outline,
                      label: 'Remove',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        _removeImage();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_selectedImage != null)
            IconButton(
              onPressed: _removeImage,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
        ],
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

            /// POST TEXT FIELD
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
            const SizedBox(height: 12),

            /// ==================== ইমেজ প্রিভিউ ====================
            
            if (_selectedImage != null) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _removeImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    if (_isUploadingImage)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            /// ==================== ইমেজ যোগ করার বাটন ====================
            
            GestureDetector(
              onTap: _showImagePickerSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedImage != null ? Icons.edit : Icons.add_photo_alternate_outlined,
                      color: const Color(0xFF2FA089),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedImage != null ? 'Change Image' : 'Add Image',
                      style: const TextStyle(
                        color: Color(0xFF2FA089),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// CATEGORY TITLE
            const Text(
              'Select Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            /// CATEGORY CHIPS
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PostCategory.values
                  .where((cat) => cat != PostCategory.all)
                  .map((cat) {
                final selected = selectedCategory == cat;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = cat;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF2FA089) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: selected ? const Color(0xFF2FA089) : Colors.grey.shade300,
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
                onPressed: (isLoading || _isUploadingImage) ? null : uploadPost,
                icon: isLoading || _isUploadingImage
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  isLoading ? 'Posting...' : (_isUploadingImage ? 'Uploading Image...' : 'Post'),
                ),
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