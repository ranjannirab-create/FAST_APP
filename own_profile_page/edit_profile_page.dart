// thik ase profile page e avter add korte cai
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

// -------------------------------------------------------------
// Avatar Picker Widget (3 built‑in avatars)
// -------------------------------------------------------------
class AvatarPicker extends StatelessWidget {
  final Function(String) onSelected;
  final String currentAvatar;

  const AvatarPicker({super.key, required this.onSelected, required this.currentAvatar});

  // Make sure these file names match exactly what you have in assets/avatars/
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

// -------------------------------------------------------------
// EditProfilePage
// -------------------------------------------------------------
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _fromLocationCtrl = TextEditingController();
  final _birthdayCtrl = TextEditingController();
  final _workTitleCtrl = TextEditingController();
  final _workCompanyCtrl = TextEditingController();
  final _workPeriodCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _newHobbyCtrl = TextEditingController();
  
  List<String> _hobbies = [];
  bool _isLoading = false;
  late String _userId;
  
  // Avatar & Cover
  String _selectedAvatarPath = '';
  File? _selectedCoverPhoto;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser!.uid;
    _loadUserData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _fromLocationCtrl.dispose();
    _birthdayCtrl.dispose();
    _workTitleCtrl.dispose();
    _workCompanyCtrl.dispose();
    _workPeriodCtrl.dispose();
    _roleCtrl.dispose();
    _newHobbyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      _nameCtrl.text = data['name'] ?? '';
      _bioCtrl.text = data['bio'] ?? '';
      _locationCtrl.text = data['location'] ?? '';
      _fromLocationCtrl.text = data['fromLocation'] ?? '';
      _birthdayCtrl.text = data['birthday'] ?? '';
      _workTitleCtrl.text = data['workTitle'] ?? '';
      _workCompanyCtrl.text = data['workCompany'] ?? '';
      _workPeriodCtrl.text = data['workPeriod'] ?? '';
      _roleCtrl.text = data['role'] ?? '';
      _hobbies = List<String>.from(data['hobbies'] ?? []);
      _selectedAvatarPath = data['profilePic'] ?? '';
      setState(() {});
    }
  }

  Future<void> _pickCoverImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedCoverPhoto = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile, String folder) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('$folder/$_userId/$fileName');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      print("✅ Cover uploaded: $url");
      return url;
    } catch (e) {
      print("❌ Cover upload failed: $e");
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    String? coverPhotoUrl;
    if (_selectedCoverPhoto != null) {
      coverPhotoUrl = await _uploadImage(_selectedCoverPhoto!, 'cover_photos');
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(_userId).set({
        'name': _nameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'fromLocation': _fromLocationCtrl.text.trim(),
        'birthday': _birthdayCtrl.text.trim(),
        'workTitle': _workTitleCtrl.text.trim(),
        'workCompany': _workCompanyCtrl.text.trim(),
        'workPeriod': _workPeriodCtrl.text.trim(),
        'role': _roleCtrl.text.trim(),
        'profilePic': _selectedAvatarPath,  // saved as asset path
        'coverPhoto': coverPhotoUrl ?? '',
        'hobbies': _hobbies,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addHobby() {
    final hobby = _newHobbyCtrl.text.trim();
    if (hobby.isNotEmpty && !_hobbies.contains(hobby)) {
      setState(() => _hobbies.add(hobby));
      _newHobbyCtrl.clear();
    }
  }

  void _removeHobby(String hobby) {
    setState(() => _hobbies.remove(hobby));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), backgroundColor: Colors.white, elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildAvatarPicker(),
                    const SizedBox(height: 16),
                    _buildCoverPicker(),
                    const SizedBox(height: 16),
                    _buildTextField(_nameCtrl, 'Full Name', Icons.person, true),
                    _buildTextField(_bioCtrl, 'Bio', Icons.comment, false, maxLines: 3),
                    _buildTextField(_locationCtrl, 'Location', Icons.location_on, false),
                    _buildTextField(_fromLocationCtrl, 'From', Icons.home, false),
                    _buildTextField(_birthdayCtrl, 'Birthday', Icons.cake, false),
                    const Divider(),
                    _buildTextField(_workTitleCtrl, 'Job Title', Icons.work, false),
                    _buildTextField(_workCompanyCtrl, 'Company', Icons.business, false),
                    _buildTextField(_workPeriodCtrl, 'Work Period', Icons.date_range, false),
                    _buildTextField(_roleCtrl, 'Role', Icons.star, false),
                    const Divider(),
                    const Text('Hobbies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _hobbies.map((h) => Chip(label: Text(h), onDeleted: () => _removeHobby(h))).toList(),
                    ),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _newHobbyCtrl, decoration: const InputDecoration(hintText: 'Add a hobby'))),
                        IconButton(onPressed: _addHobby, icon: const Icon(Icons.add_circle, color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      child: const Text('SAVE', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Profile Picture (Avatar)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AvatarPicker(
                currentAvatar: _selectedAvatarPath,
                onSelected: (path) {
                  setState(() => _selectedAvatarPath = path);
                },
              ),
            );
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              image: _selectedAvatarPath.isNotEmpty
                  ? DecorationImage(
                      image: AssetImage(_selectedAvatarPath),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _selectedAvatarPath.isEmpty
                ? const Center(child: Icon(Icons.person, size: 50, color: Colors.grey))
                : null,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AvatarPicker(
                currentAvatar: _selectedAvatarPath,
                onSelected: (path) {
                  setState(() => _selectedAvatarPath = path);
                },
              ),
            );
          },
          child: const Text('Change Avatar'),
        ),
      ],
    );
  }

  Widget _buildCoverPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cover Photo (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickCoverImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              image: _selectedCoverPhoto != null
                  ? DecorationImage(image: FileImage(_selectedCoverPhoto!), fit: BoxFit.cover)
                  : null,
            ),
            child: _selectedCoverPhoto == null
                ? const Center(child: Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey))
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, bool isRequired, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) => (isRequired && (value == null || value.isEmpty)) ? 'Required' : null,
      ),
    );
  }
}