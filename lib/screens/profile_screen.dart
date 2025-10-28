import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'dashboard_screen.dart';

/// Profile screen for editing user information
/// Allows users to update name, bio, skills, and profile photo
class ProfileScreen extends StatefulWidget {
  final bool isInitialSetup;
  
  const ProfileScreen({super.key, this.isInitialSetup = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _teachSkillController = TextEditingController();
  final _learnSkillController = TextEditingController();
  
  final ImagePicker _imagePicker = ImagePicker();
  
  List<String> _skillsToTeach = [];
  List<String> _skillsToLearn = [];
  File? _profileImage;
  String? _profileImageUrl;
  bool _isLoading = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// Load current user profile data
  Future<void> _loadUserProfile() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    
    final user = authService.currentUser;
    if (user != null) {
      final profile = await dbService.getUserProfile(user.uid);
      if (profile != null && mounted) {
        setState(() {
          _currentUser = profile;
          _nameController.text = profile.name;
          _bioController.text = profile.bio;
          _skillsToTeach = List.from(profile.skillsToTeach);
          _skillsToLearn = List.from(profile.skillsToLearn);
          _profileImageUrl = profile.photoUrl;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _teachSkillController.dispose();
    _learnSkillController.dispose();
    super.dispose();
  }

  /// Pick profile photo from gallery
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  /// Add skill to teach list
  void _addTeachSkill() {
    if (_teachSkillController.text.isNotEmpty) {
      setState(() {
        _skillsToTeach.add(_teachSkillController.text.trim());
        _teachSkillController.clear();
      });
    }
  }

  /// Add skill to learn list
  void _addLearnSkill() {
    if (_learnSkillController.text.isNotEmpty) {
      setState(() {
        _skillsToLearn.add(_learnSkillController.text.trim());
        _learnSkillController.clear();
      });
    }
  }

  /// Save profile changes
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_skillsToTeach.isEmpty || _skillsToLearn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one skill to teach and learn'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      
      final user = authService.currentUser;
      if (user == null) return;

      String? photoUrl = _profileImageUrl;

      // Upload profile photo if selected
      if (_profileImage != null) {
        photoUrl = await dbService.uploadProfilePhoto(user.uid, _profileImage!);
      }

      // Create updated user model
      UserModel updatedUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        skillsToTeach: _skillsToTeach,
        skillsToLearn: _skillsToLearn,
        photoUrl: photoUrl,
        createdAt: _currentUser?.createdAt ?? DateTime.now(),
        lastActive: DateTime.now(),
      );

      // Update profile in Firestore
      await dbService.updateUserProfile(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        // Navigate to dashboard if initial setup
        if (widget.isInitialSetup) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isInitialSetup ? 'Setup Profile' : 'Edit Profile'),
        automaticallyImplyLeading: !widget.isInitialSetup,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile photo
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (_profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!) as ImageProvider
                                : null),
                        child: _profileImage == null && _profileImageUrl == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Name field
              CustomTextField(
                controller: _nameController,
                label: 'Name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Bio field
              CustomTextField(
                controller: _bioController,
                label: 'Bio',
                hint: 'Tell others about yourself',
                prefixIcon: Icons.info_outline,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Skills to teach section
              Text(
                'Skills I Can Teach',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _teachSkillController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Python, Guitar, Cooking',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (_) => _addTeachSkill(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addTeachSkill,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _skillsToTeach
                    .map((skill) => Chip(
                          label: Text(skill),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() => _skillsToTeach.remove(skill));
                          },
                          backgroundColor: Colors.green.shade100,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),

              // Skills to learn section
              Text(
                'Skills I Want to Learn',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _learnSkillController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Piano, Photography, Spanish',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (_) => _addLearnSkill(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addLearnSkill,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _skillsToLearn
                    .map((skill) => Chip(
                          label: Text(skill),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() => _skillsToLearn.remove(skill));
                          },
                          backgroundColor: Colors.blue.shade100,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 32),

              // Save button
              CustomButton(
                text: widget.isInitialSetup ? 'Get Started' : 'Save Changes',
                onPressed: _saveProfile,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
