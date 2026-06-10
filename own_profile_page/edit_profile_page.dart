
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// -------------------------------------------------------------
// Avatar Picker Widget (Unchanged)
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Select Profile Picture',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      content: SizedBox(
        width: 250,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
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
                  border: isSelected ? Border.all(color: const Color(0xFF2FA089), width: 3) : null,
                  boxShadow: isSelected ? [
                    BoxShadow(color: const Color(0xFF2FA089).withOpacity(0.3), blurRadius: 8)
                  ] : null,
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
// EditProfilePage with Country & Language
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

  // Country & Language
  String _selectedCountry = '';
  String _selectedLanguage = '';

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
  String _agePrivacy = "public";   
  String _addressPrivacy = "public";

  // Interests
  final List<String> _allInterests = [
    "Singing", "Writing", "Dancing", "Acting", "Painting",
    "Photography", "Playing Guitar", "Playing Piano", "Drums", "Violin",
    "Coding", "Gaming", "Reading", "Traveling", "Cooking",
    "Baking", "Yoga", "Meditation", "Running", "Swimming",
    "Football", "Cricket", "Basketball", "Badminton", "Chess",
    "Gardening", "Fishing", "Calligraphy", "Blogging", "Podcasting"
  ];
  List<String> _selectedInterests = [];  

  // Avatar
  String _selectedAvatarPath = '';

  late String _uid;
  bool _isLoading = true;

  final Color primaryColor = const Color(0xFF2FA089);

  // ------------------- Country List (30 main countries) -------------------
  final List<String> _countries = [
    "Afghanistan", "Australia", "Bangladesh", "Brazil", "Canada", "China",
    "Egypt", "France", "Germany", "India", "Indonesia", "Iran", "Iraq",
    "Italy", "Japan", "Malaysia", "Mexico", "Nepal", "Netherlands",
    "Nigeria", "Pakistan", "Philippines", "Russia", "Saudi Arabia",
    "South Africa", "South Korea", "Spain", "Turkey", "United Kingdom",
    "United States"
  ];

  // ------------------- Language List (15 main languages) -------------------
  final List<String> _languages = [
    "Arabic", "Bengali", "Chinese", "English", "French", "German",
    "Hindi", "Italian", "Japanese", "Korean", "Portuguese", "Russian",
    "Spanish", "Turkish", "Urdu"
  ];

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
        
        // Load country & language
        _selectedCountry = data['country'] ?? '';
        _selectedLanguage = data['language'] ?? '';

        _selectedInterests = List<String>.from(data['interests'] ?? []);
        if (_selectedInterests.length > 6) _selectedInterests = _selectedInterests.sublist(0, 6);
        if (data['birthday'] != null) {
          _birthday = DateTime.tryParse(data['birthday']);
        }
        _selectedAvatarPath = data['profilePic'] ?? '';
        
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
  // LOCATION (unchanged)
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
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
  // COUNTRY SELECTOR DIALOG
  // ----------------------------------------------------------------------
  Future<void> _selectCountry() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Country'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: _countries.length,
              itemBuilder: (context, index) {
                final country = _countries[index];
                return ListTile(
                  title: Text(country),
                  trailing: _selectedCountry == country ? Icon(Icons.check, color: primaryColor) : null,
                  onTap: () {
                    setState(() {
                      _selectedCountry = country;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------------------------
  // LANGUAGE SELECTOR DIALOG
  // ----------------------------------------------------------------------
  Future<void> _selectLanguage() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: ListView.builder(
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                return ListTile(
                  title: Text(language),
                  trailing: _selectedLanguage == language ? Icon(Icons.check, color: primaryColor) : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------------------------
  // INTEREST SELECTOR DIALOG
  // ----------------------------------------------------------------------
  Future<void> _openInterestSelector() async {
    List<String> tempSelected = List.from(_selectedInterests);
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Select Interests (Max 6)', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _allInterests.length,
                  itemBuilder: (context, index) {
                    final interest = _allInterests[index];
                    final isSelected = tempSelected.contains(interest);
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setStateDialog(() {
                          if (isSelected) {
                            tempSelected.remove(interest);
                          } else {
                            if (tempSelected.length < 6) {
                              tempSelected.add(interest);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('You can select maximum 6 interests')),
                              );
                            }
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor.withOpacity(0.08) : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? primaryColor : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isSelected)
                                Icon(Icons.check_circle_rounded, color: primaryColor, size: 18),
                              if (isSelected) const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  interest,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelected ? primaryColor : Colors.black87,
                                  ),
                                ),
                              ),
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
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedInterests = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeInterest(String interest) {
    setState(() {
      _selectedInterests.remove(interest);
    });
  }

  // ----------------------------------------------------------------------
  // PRIVACY SELECTOR
  // ----------------------------------------------------------------------
  Widget _buildPrivacySelector(String title, String currentValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.security_outlined, size: 16, color: Colors.black54),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F5F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _privacyOption('Public', Icons.public, currentValue == 'public', () => onChanged('public')),
              _privacyOption('Friends', Icons.people_outline, currentValue == 'friends', () => onChanged('friends')),
              _privacyOption('Private', Icons.lock_outline, currentValue == 'private', () => onChanged('private')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _privacyOption(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))
            ] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? primaryColor : Colors.black45, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? primaryColor : Colors.black45,
                ),
              ),
            ],
          ),
        ),
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
      'country': _selectedCountry,
      'language': _selectedLanguage,
      'interests': _selectedInterests,
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
  // UI COMPONENTS
  // ----------------------------------------------------------------------
  Widget _buildSectionBox({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: primaryColor.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, bool required, {int maxLines = 1, IconData? prefixIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black45, fontSize: 14),
          floatingLabelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: primaryColor.withOpacity(0.7), size: 20) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
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

  // Helper for selection fields (Country/Language)
  Widget _buildSelectionField(String label, String value, VoidCallback onTap, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Icon(icon, color: primaryColor.withOpacity(0.7), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value.isEmpty ? 'Select $label' : value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: value.isEmpty ? FontWeight.normal : FontWeight.w500,
                        color: value.isEmpty ? Colors.black54 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_drop_down, color: primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFEFF),
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 20)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // --- AVATAR SECTION (unchanged) ---
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: primaryColor.withOpacity(0.15), width: 4),
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: const Color(0xFFF4F5F6),
                              backgroundImage: _selectedAvatarPath.isNotEmpty
                                  ? AssetImage(_selectedAvatarPath)
                                  : null,
                              child: _selectedAvatarPath.isEmpty
                                  ? const Icon(Icons.person_outline, size: 45, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: GestureDetector(
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
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 6)
                                  ],
                                ),
                                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // --- SECTION 1: BASIC INFO BOX (added Country & Language) ---
                    _buildSectionBox(
                      children: [
                        _buildTextField(_nameCtrl, 'Full Name', true, prefixIcon: Icons.person_outline),
                        _buildTextField(_bioCtrl, 'Bio', false, maxLines: 3, prefixIcon: Icons.article_outlined),
                        _buildTextField(_fromCtrl, 'From (Hometown)', false, prefixIcon: Icons.home_outlined),
                        _buildSelectionField('Country', _selectedCountry, _selectCountry, Icons.public),
                        _buildSelectionField('Language', _selectedLanguage, _selectLanguage, Icons.language),
                      ],
                    ),

                    // --- SECTION 2: CURRENT LOCATION BOX (unchanged) ---
                    _buildSectionBox(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: _buildTextField(_currentAddrCtrl, 'Current Address', false, prefixIcon: Icons.location_on_outlined),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: IconButton(
                                  onPressed: _getCurrentLocation,
                                  icon: Icon(Icons.my_location, color: primaryColor),
                                  tooltip: 'Use current location',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildPrivacySelector('Address Privacy', _addressPrivacy, (val) {
                          setState(() => _addressPrivacy = val);
                        }),
                      ],
                    ),

                    // --- SECTION 3: BIRTHDAY BOX (unchanged) ---
                    _buildSectionBox(
                      children: [
                        InkWell(
                          onTap: _selectBirthday,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.withOpacity(0.15)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, color: primaryColor, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _birthday == null
                                            ? 'Select Birthday'
                                            : 'Birthday: ${_birthday!.toLocal().toString().split(' ')[0]}',
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                                      ),
                                      if (_birthday != null) const SizedBox(height: 4),
                                      if (_birthday != null)
                                        Text('Age: ${_calculateAge()} years', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black38),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildPrivacySelector('Age Privacy', _agePrivacy, (val) {
                          setState(() => _agePrivacy = val);
                        }),
                      ],
                    ),

                    // --- SECTION 4: WORK & DREAM BOX (unchanged) ---
                    _buildSectionBox(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _workType,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Work Type',
                            prefixIcon: Icon(Icons.work_outline, color: primaryColor, size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: primaryColor),
                            ),
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
                        if (_workType == 'study' || _workType == 'job') const SizedBox(height: 12),
                        if (_workType == 'study')
                          TextFormField(
                            initialValue: _classLevel,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: 'Class / Level (e.g., 10, B.Sc)',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onChanged: (val) => _classLevel = val,
                          ),
                        if (_workType == 'job')
                          DropdownButtonFormField<String>(
                            initialValue: _jobCategory.isEmpty ? null : _jobCategory,
                            decoration: InputDecoration(
                              labelText: 'Job Category',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
                        const SizedBox(height: 4),
                        _buildTextField(_dreamCtrl, 'Your Dream', false, prefixIcon: Icons.auto_awesome_outlined),
                        const SizedBox(height: 4),
                        
                        // Role Dropdown
                        DropdownButtonFormField<String>(
                          initialValue: _roleOptions.contains(_selectedRole) ? _selectedRole : null,
                          hint: const Text('Select your role'),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Role',
                            prefixIcon: Icon(Icons.stars_outlined, color: primaryColor, size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: primaryColor),
                            ),
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
                        if (_selectedRole == "Other") const SizedBox(height: 12),
                        if (_selectedRole == "Other")
                          TextFormField(
                            controller: _otherRoleCtrl,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: 'Write your role',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            validator: (value) {
                              if (_selectedRole == "Other" && (value == null || value.isEmpty)) {
                                  return 'Please enter your role';
                              }
                              return null;
                            },
                          ),
                      ],
                    ),

                    // --- SECTION 5: INTERESTS BOX (unchanged) ---
                    _buildSectionBox(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Interests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                            TextButton.icon(
                              onPressed: _openInterestSelector,
                              icon: Icon(Icons.add, size: 16, color: primaryColor),
                              label: Text('Select (${_selectedInterests.length}/6)', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_selectedInterests.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('No interests selected. Tap "Select" to add.', style: TextStyle(color: Colors.black38, fontSize: 13)),
                          ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _selectedInterests.map((interest) => Chip(
                            label: Text(interest, style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500, fontSize: 13)),
                            backgroundColor: primaryColor.withOpacity(0.06),
                            deleteIconColor: primaryColor.withOpacity(0.6),
                            side: BorderSide(color: primaryColor.withOpacity(0.15)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onDeleted: () => _removeInterest(interest),
                          )).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Save Button
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 2,
                        shadowColor: primaryColor.withOpacity(0.25),
                      ),
                      child: const Text('SAVE PROFILE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
    );
  }
}
