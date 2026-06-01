
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// -------------------------------------------------------------
// Avatar Picker Widget (unchanged)
// -------------------------------------------------------------
class AvatarPicker extends StatelessWidget {
  final Function(String) onSelected;
  final String currentAvatar;
  const AvatarPicker({super.key, required this.onSelected, required this.currentAvatar});
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
                child: ClipOval(child: Image.asset(path, fit: BoxFit.cover)),
              ),
            );
          },
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// EditProfilePage – with privacy settings for Age & Address
// -------------------------------------------------------------
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _fromCtrl = TextEditingController();
  final _currentAddrCtrl = TextEditingController();
  final _dreamCtrl = TextEditingController();

  // Role dropdown
  String _selectedRole = "";
  final TextEditingController _otherRoleCtrl = TextEditingController();
  final List<String> _roleOptions = [
    "Singer", "Actor", "Dancer", "Writer", "Student", "Teacher",
    "Engineer", "Doctor", "Businessman", "Freelancer", "Developer",
    "Designer", "YouTuber", "Influencer", "Gamer", "Model", "Other"
  ];

  // Work type
  String _workType = "none";
  String _classLevel = "";
  String _jobCategory = "";

  // Date of birth
  DateTime? _birthday;

  // Privacy settings
  String _agePrivacy = "public";   // 'public', 'friends', 'private'
  String _addressPrivacy = "public";

  // Hobbies
  final List<String> _allHobbies = [
    "Singing", "Writing", "Dancing", "Acting", "Painting",
    "Photography", "Playing Guitar", "Playing Piano", "Drums", "Violin",
    "Coding", "Gaming", "Reading", "Traveling", "Cooking",
    "Baking", "Yoga", "Meditation", "Running", "Swimming",
    "Football", "Cricket", "Basketball", "Badminton", "Chess",
    "Gardening", "Fishing", "Calligraphy", "Blogging", "Podcasting"
  ];
  List<String> _selectedHobbies = [];  // max 6

  // Avatar
  String _selectedAvatarPath = '';

  late String _uid;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _loadUserData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _fromCtrl.dispose();
    _currentAddrCtrl.dispose();
    _dreamCtrl.dispose();
    _otherRoleCtrl.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------------
  // LOAD DATA
  // ----------------------------------------------------------------------
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameCtrl.text = data['name'] ?? '';
        _bioCtrl.text = data['bio'] ?? '';
        _fromCtrl.text = data['from'] ?? '';
        _currentAddrCtrl.text = data['currentAddress'] ?? '';
        _dreamCtrl.text = data['dream'] ?? '';
        _workType = data['workType'] ?? 'none';
        _classLevel = data['classLevel'] ?? '';
        _jobCategory = data['jobCategory'] ?? '';
        _selectedHobbies = List<String>.from(data['hobbies'] ?? []);
        if (_selectedHobbies.length > 6) _selectedHobbies = _selectedHobbies.sublist(0, 6);
        if (data['birthday'] != null) {
          _birthday = DateTime.tryParse(data['birthday']);
        }
        _selectedAvatarPath = data['profilePic'] ?? '';
        
        // Load privacy settings
        _agePrivacy = data['agePrivacy'] ?? 'public';
        _addressPrivacy = data['addressPrivacy'] ?? 'public';

        String savedRole = data['role'] ?? '';
        if (_roleOptions.contains(savedRole)) {
          _selectedRole = savedRole;
        } else if (savedRole.isNotEmpty) {
          _selectedRole = "Other";
          _otherRoleCtrl.text = savedRole;
        }
      }
    } catch (e) {
      debugPrint("Load error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ----------------------------------------------------------------------
  // LOCATION
  // ----------------------------------------------------------------------
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services')),
      );
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permanently denied')),
      );
      return;
    }
    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      String address = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}'
          .replaceAll(RegExp(r'^, |, ,'), '')
          .trim();
      setState(() {
        _currentAddrCtrl.text = address;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get address')),
      );
    }
  }

  // ----------------------------------------------------------------------
  // DATE OF BIRTH & AGE
  // ----------------------------------------------------------------------
  Future<void> _selectBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthday = picked);
    }
  }

  int _calculateAge() {
    if (_birthday == null) return 0;
    final today = DateTime.now();
    int age = today.year - _birthday!.year;
    if (today.month < _birthday!.month ||
        (today.month == _birthday!.month && today.day < _birthday!.day)) {
      age--;
    }
    return age;
  }

  // ----------------------------------------------------------------------
  // HOBBY SELECTION DIALOG (max 6)
  // ----------------------------------------------------------------------
  Future<void> _openHobbySelector() async {
    List<String> tempSelected = List.from(_selectedHobbies);
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Select Hobbies (Max 6)'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _allHobbies.length,
                  itemBuilder: (context, index) {
                    final hobby = _allHobbies[index];
                    final isSelected = tempSelected.contains(hobby);
                    return InkWell(
                      onTap: () {
                        setStateDialog(() {
                          if (isSelected) {
                            tempSelected.remove(hobby);
                          } else {
                            if (tempSelected.length < 6) {
                              tempSelected.add(hobby);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('You can select maximum 6 hobbies')),
                              );
                            }
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green.shade100 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isSelected)
                                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                              const SizedBox(width: 4),
                              Flexible(child: Text(hobby, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedHobbies = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeHobby(String hobby) {
    setState(() {
      _selectedHobbies.remove(hobby);
    });
  }

  // ----------------------------------------------------------------------
  // PRIVACY SELECTOR WIDGET
  // ----------------------------------------------------------------------
  Widget _buildPrivacySelector(String title, String currentValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Row(
          children: [
            _privacyOption('Public', Icons.public, currentValue == 'public', () => onChanged('public')),
            const SizedBox(width: 12),
            _privacyOption('Friends', Icons.people, currentValue == 'friends', () => onChanged('friends')),
            const SizedBox(width: 12),
            _privacyOption('Private', Icons.lock, currentValue == 'private', () => onChanged('private')),
          ],
        ),
      ],
    );
  }

  Widget _privacyOption(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: isSelected ? Colors.green : Colors.grey, size: 28),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: isSelected ? Colors.green : Colors.grey)),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // SAVE PROFILE
  // ----------------------------------------------------------------------
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    String finalRole = _selectedRole == "Other" ? _otherRoleCtrl.text.trim() : _selectedRole;

    final data = {
      'name': _nameCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'from': _fromCtrl.text.trim(),
      'currentAddress': _currentAddrCtrl.text.trim(),
      'dream': _dreamCtrl.text.trim(),
      'role': finalRole,
      'workType': _workType,
      'classLevel': _workType == 'study' ? _classLevel : '',
      'jobCategory': _workType == 'job' ? _jobCategory : '',
      'hobbies': _selectedHobbies,
      'birthday': _birthday?.toIso8601String(),
      'profilePic': _selectedAvatarPath,
      'agePrivacy': _agePrivacy,
      'addressPrivacy': _addressPrivacy,
    };

    try {
      await FirebaseFirestore.instance.collection('users').doc(_uid).set(
        data,
        SetOptions(merge: true),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ----------------------------------------------------------------------
  // UI BUILD
  // ----------------------------------------------------------------------
  Widget _buildTextField(TextEditingController ctrl, String label, bool required,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar
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
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _selectedAvatarPath.isNotEmpty
                            ? AssetImage(_selectedAvatarPath)
                            : null,
                        child: _selectedAvatarPath.isEmpty
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
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
                      icon: const Icon(Icons.edit),
                      label: const Text('Change Avatar'),
                    ),
                    const SizedBox(height: 20),

                    // Basic fields
                    _buildTextField(_nameCtrl, 'Full Name', true),
                    _buildTextField(_bioCtrl, 'Bio', false, maxLines: 3),
                    _buildTextField(_fromCtrl, 'From (Hometown)', false),

                    // Current address with GPS + Privacy
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _buildTextField(_currentAddrCtrl, 'Current Address', false),
                        ),
                        IconButton(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          tooltip: 'Use my current location',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildPrivacySelector('Address Privacy', _addressPrivacy, (val) {
                      setState(() => _addressPrivacy = val);
                    }),
                    const SizedBox(height: 16),

                    // Birthday & Age + Privacy
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _birthday == null
                            ? 'Select Birthday'
                            : 'Birthday: ${_birthday!.toLocal().toString().split(' ')[0]}',
                      ),
                      subtitle: _birthday != null
                          ? Text('Age: ${_calculateAge()} years')
                          : null,
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectBirthday,
                    ),
                    const SizedBox(height: 8),
                    _buildPrivacySelector('Age Privacy', _agePrivacy, (val) {
                      setState(() => _agePrivacy = val);
                    }),
                    const SizedBox(height: 16),

                    // Work Type
                    DropdownButtonFormField<String>(
                      initialValue: _workType,
                      decoration: const InputDecoration(
                        labelText: 'Work Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'none', child: Text('None')),
                        DropdownMenuItem(value: 'study', child: Text('Student')),
                        DropdownMenuItem(value: 'job', child: Text('Working Professional')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _workType = val!;
                          if (_workType != 'study') _classLevel = '';
                          if (_workType != 'job') _jobCategory = '';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_workType == 'study')
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Class / Level (e.g., 10, B.Sc)',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _classLevel,
                        onChanged: (val) => _classLevel = val,
                      ),
                    if (_workType == 'job')
                      DropdownButtonFormField<String>(
                        initialValue: _jobCategory.isEmpty ? null : _jobCategory,
                        decoration: const InputDecoration(
                          labelText: 'Job Category',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                          DropdownMenuItem(value: 'engineer', child: Text('Engineer')),
                          DropdownMenuItem(value: 'business', child: Text('Business')),
                          DropdownMenuItem(value: 'freelancer', child: Text('Freelancer')),
                          DropdownMenuItem(value: 'other', child: Text('Other')),
                        ],
                        onChanged: (val) => setState(() => _jobCategory = val!),
                      ),
                    const SizedBox(height: 16),
                    _buildTextField(_dreamCtrl, 'Your Dream', false),

                    // Role Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _roleOptions.contains(_selectedRole) ? _selectedRole : null,
                      hint: const Text('Select your role'),
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                      items: _roleOptions.map((role) {
                        return DropdownMenuItem(value: role, child: Text(role));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                          if (_selectedRole != "Other") {
                            _otherRoleCtrl.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    if (_selectedRole == "Other")
                      TextFormField(
                        controller: _otherRoleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Write your role',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_selectedRole == "Other" && (value == null || value.isEmpty)) {
                            return 'Please enter your role';
                          }
                          return null;
                        },
                      ),

                    const Divider(height: 32),

                    // Hobbies
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Hobbies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: _openHobbySelector,
                          icon: const Icon(Icons.add),
                          label: Text('Select (${_selectedHobbies.length}/6)'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_selectedHobbies.isEmpty)
                      const Text('No hobbies selected. Tap "Select" to add.',
                          style: TextStyle(color: Colors.grey)),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedHobbies.map((h) => Chip(
                        label: Text(h),
                        onDeleted: () => _removeHobby(h),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Save button
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('SAVE PROFILE', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}