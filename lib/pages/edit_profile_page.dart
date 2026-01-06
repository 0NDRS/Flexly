import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
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
  File? _profileImage;
  bool _isLoading = false;

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
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
    };

    final result = await _authService.updateProfile(updates,
        profilePicture: _profileImage);

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate update
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
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
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
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: (_profileImage == null &&
                          (widget.userData['profilePicture'] == null ||
                              widget.userData['profilePicture'] == ''))
                      ? const Icon(Icons.camera_alt,
                          color: Colors.white, size: 40)
                      : null,
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
              const SizedBox(height: 32),
              PrimaryButton(
                text: _isLoading ? 'Saving...' : 'Save Changes',
                onPressed: _isLoading ? () {} : _saveProfile,
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
}
