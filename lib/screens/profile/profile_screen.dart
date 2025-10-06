import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _collegeController;
  late TextEditingController _yearController;
  late TextEditingController _branchController;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _collegeController = TextEditingController(text: user?.college ?? '');
    _yearController = TextEditingController(text: user?.year ?? '');
    _branchController = TextEditingController(text: user?.branch ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _collegeController.dispose();
    _yearController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser!;

    try {
      await authProvider.updateProfile(
        displayName: _nameController.text,
        college: _collegeController.text,
        year: _yearController.text,
        branch: _branchController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: ${error.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Avatar
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.avatarPath != null
                            ? NetworkImage(user.avatarPath!)
                            : null,
                        child: user.avatarPath == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: () {
                              // TODO: Implement image picker
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Image picker coming soon!')),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Form Fields
                CustomTextField(
                  label: 'Full Name',
                  hintText: 'Enter your full name',  // ✅ FIXED: hintText
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Email Address',
                  hintText: 'Enter your email address',  // ✅ FIXED: hintText
                  controller: _emailController,
                  enabled: false,  // Email shouldn't be editable
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'College/University',
                  hintText: 'Enter your college or university',  // ✅ FIXED: hintText
                  controller: _collegeController,
                  prefixIcon: const Icon(Icons.school_outlined),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Year',
                        hintText: 'e.g., 2nd Year',  // ✅ FIXED: hintText
                        controller: _yearController,
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Branch',
                        hintText: 'e.g., Computer Science',  // ✅ FIXED: hintText
                        controller: _branchController,
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Column(
                  children: [
                    CustomButton(
                      text: 'Save Changes',  // ✅ FIXED: text parameter
                      onPressed: _saveProfile,
                      type: ButtonType.primary,  // ✅ FIXED: type parameter
                      icon: Icons.save,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Logout',  // ✅ FIXED: text parameter
                      onPressed: _logout,
                      type: ButtonType.secondary,  // ✅ FIXED: type parameter
                      icon: Icons.logout,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
