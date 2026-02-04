import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/services/event_bus.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/services/auth_service.dart';
import 'package:flexly/widgets/primary_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({super.key, required this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _gender;
  String? _goal;
  File? _profileImage;
  bool _isLoading = false;
  bool _hasChanges = false;

  final List<_GoalOption> _goalOptions = const [
    _GoalOption(
      id: 'gain_muscles',
      title: 'Gain muscles',
      subtitle: 'Gain size & strength',
      icon: Icons.fitness_center,
    ),
    _GoalOption(
      id: 'loose_fat',
      title: 'Loose fat',
      subtitle: 'Shred & define',
      icon: Icons.local_fire_department,
    ),
    _GoalOption(
      id: 'improve_endurance',
      title: 'Improve endurance',
      subtitle: 'Boost stamina',
      icon: Icons.directions_run,
    ),
    _GoalOption(
      id: 'increase_flexibility',
      title: 'Increase flexibility',
      subtitle: 'Improve mobility',
      icon: Icons.accessibility_new,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.userData['name'] ?? '');
    _usernameController =
        TextEditingController(text: widget.userData['username'] ?? '');
    _bioController = TextEditingController(text: widget.userData['bio'] ?? '');
    _emailController =
        TextEditingController(text: widget.userData['email'] ?? '');
    _ageController =
        TextEditingController(text: widget.userData['age']?.toString() ?? '');
    _heightController = TextEditingController(
        text: widget.userData['height']?.toString() ?? '');
    _weightController = TextEditingController(
        text: widget.userData['weight']?.toString() ?? '');
    _gender = widget.userData['gender'];
    _goal = widget.userData['goal'];

    _nameController.addListener(_checkForChanges);
    _usernameController.addListener(_checkForChanges);
    _bioController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _ageController.addListener(_checkForChanges);
    _heightController.addListener(_checkForChanges);
    _weightController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    final nameChanged = _nameController.text != (widget.userData['name'] ?? '');
    final usernameChanged =
        _usernameController.text != (widget.userData['username'] ?? '');
    final bioChanged = _bioController.text != (widget.userData['bio'] ?? '');
    final emailChanged =
        _emailController.text != (widget.userData['email'] ?? '');
    final ageChanged =
        _ageController.text != (widget.userData['age']?.toString() ?? '');
    final heightChanged =
        _heightController.text != (widget.userData['height']?.toString() ?? '');
    final weightChanged =
        _weightController.text != (widget.userData['weight']?.toString() ?? '');
    final genderChanged = _gender != widget.userData['gender'];
    final goalChanged = _goal != widget.userData['goal'];
    final imageChanged = _profileImage != null;

    final hasChanges = nameChanged ||
        usernameChanged ||
        bioChanged ||
        emailChanged ||
        ageChanged ||
        heightChanged ||
        weightChanged ||
        genderChanged ||
        goalChanged ||
        imageChanged;

    if (hasChanges != _hasChanges) {
      if (mounted) {
        setState(() {
          _hasChanges = hasChanges;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _checkForChanges();
      });
    }
  }

  Future<void> _selectImageSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.grayDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Choose from gallery',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.white),
                title: const Text('Take a photo',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      await _pickImage(source);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final updates = {
      'name': _nameController.text,
      'username': _usernameController.text,
      'bio': _bioController.text,
      'email': _emailController.text,
      'age': _ageController.text,
      'height': _heightController.text,
      'weight': _weightController.text,
      'gender': _gender ?? '',
      if (_goal != null) 'goal': _goal!,
    };

    final result = await _authService.updateProfile(updates,
        profilePicture: _profileImage);

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      if (mounted) {
        EventBus().fire(ProfileUpdatedEvent());
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message'] ?? 'Failed to update profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Edit Profile', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _selectImageSource,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.grayDark,
                        shape: BoxShape.circle,
                        image: _profileImage != null
                            ? DecorationImage(
                                image: FileImage(_profileImage!),
                                fit: BoxFit.cover,
                              )
                            : (widget.userData['profilePicture'] != null &&
                                    widget.userData['profilePicture'] != '')
                                ? DecorationImage(
                                    image: NetworkImage(
                                        widget.userData['profilePicture']),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                        border: Border.all(color: AppColors.primary, width: 3),
                      ),
                      child: (_profileImage == null &&
                              (widget.userData['profilePicture'] == null ||
                                  widget.userData['profilePicture'] == ''))
                          ? const Icon(Icons.person,
                              color: Colors.white, size: 48)
                          : null,
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField('Name', _nameController),
              const SizedBox(height: 16),
              _buildTextField('Username', _usernameController),
              const SizedBox(height: 16),
              _buildTextField('Bio', _bioController, maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField('Email', _emailController,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gender',
                    style: AppTextStyles.body2
                        .copyWith(color: AppColors.grayLight),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    dropdownColor: AppColors.grayDark,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.grayDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    items: ['Male', 'Female']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                        _checkForChanges();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Age', _ageController,
                        keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField('Height (cm)', _heightController,
                        keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField('Weight (kg)', _weightController,
                        keyboardType: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildGoalSelector(),
              const SizedBox(height: 32),
              PrimaryButton(
                text: _isLoading ? 'Saving...' : 'Save Changes',
                onPressed: (_hasChanges && !_isLoading) ? _saveProfile : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body2.copyWith(color: AppColors.grayLight),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.grayDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (label == 'Name' && (value == null || value.isEmpty)) {
              return 'Name is required';
            }
            if (label == 'Email' && (value == null || !value.contains('@'))) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGoalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal',
          style: AppTextStyles.body2.copyWith(color: AppColors.grayLight),
        ),
        const SizedBox(height: 8),
        ..._goalOptions.map((goal) {
          final isSelected = _goal == goal.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _goal = goal.id;
                  _checkForChanges();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.grayDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.gray,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.gray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        goal.icon,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            goal.subtitle,
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.grayLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _GoalOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const _GoalOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
