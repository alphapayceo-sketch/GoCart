import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/user_repository.dart';
import 'package:shop/services/auth_service.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String _avatarUrl = '';
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await UserRepository.fetchProfile();
      final firstName = profile['first_name'] as String? ?? '';
      final lastName = profile['last_name'] as String? ?? '';
      final email = profile['email'] as String? ?? AuthService.currentUserEmail;
      final phone = profile['phone_number'] as String? ?? '';
      final imageUrl =
          profile['image_url'] as String? ?? AuthService.currentUserImage;

      if (!mounted) return;

      setState(() {
        _nameController.text =
            [firstName, lastName].where((part) => part.isNotEmpty).join(' ');
        _emailController.text = email;
        _phoneController.text = phone;
        _avatarUrl = imageUrl;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (pickedFile == null || !mounted) {
      return;
    }

    setState(() {
      _selectedImage = File(pickedFile.path);
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? imageUrl = _avatarUrl;
      if (_selectedImage != null) {
        final uploadResult =
            await UserRepository.uploadProfileImage(_selectedImage!);
        imageUrl = uploadResult['url'] as String? ?? imageUrl;
      }

      final nameParts = _nameController.text.trim().split(RegExp(r'\s+'));
      final firstName = nameParts.isEmpty ? '' : nameParts.first;
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final updatedProfile = await UserRepository.updateProfile({
        'first_name': firstName,
        'last_name': lastName,
        'email': _emailController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        if (imageUrl.isNotEmpty) 'image_url': imageUrl,
      });

      AuthService.setSessionProfile(
        firstName: updatedProfile['first_name'] as String?,
        lastName: updatedProfile['last_name'] as String?,
        email:
            updatedProfile['email'] as String? ?? _emailController.text.trim(),
        imageUrl: updatedProfile['image_url'] as String?,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Info'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 42,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!) as ImageProvider
                            : (_avatarUrl.isNotEmpty
                                ? NetworkImage(_avatarUrl)
                                : null),
                        child: _selectedImage == null && _avatarUrl.isEmpty
                            ? const Icon(Icons.person, size: 42)
                            : null,
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    TextFormField(
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: 'Full name'),
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+\$')
                            .hasMatch(value.trim())) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    TextFormField(
                      controller: _phoneController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        if (!RegExp(r'^\+?[0-9\s-]{7,15}\$')
                            .hasMatch(value.trim())) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                      decoration:
                          const InputDecoration(labelText: 'Phone number'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: defaultPadding),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        child: Text(_isSaving ? 'Saving...' : 'Save changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
