import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _collegeController = TextEditingController();

  String? _selectedYear;
  String? _selectedBranch;
  bool _isEditing = false;

  final List<String> _years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Graduate',
    'Post-Graduate'
  ];

  final List<String> _branches = [
    'Computer Science',
    'Information Technology',
    'Electronics & Communication',
    'Mechanical Engineering',
    'Civil Engineering',
    'Electrical Engineering',
    'Chemical Engineering',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      _nameController.text = user.displayName;
      _collegeController.text = user.college ?? '';
      _selectedYear = user.year;
      _selectedBranch = user.branch;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.updateProfile(
      displayName: _nameController.text.trim(),
      college: _collegeController.text.trim().isNotEmpty
          ? _collegeController.text.trim()
          : null,
      year: _selectedYear,
      branch: _selectedBranch,
    );

    if (success && mounted) {
      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: const Text('Edit'),
            )
          else
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
                _loadUserData(); // Reset data
              },
              child: const Text('Cancel'),
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Form Fields
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    prefixIcon: Icons.person_outlined,
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: TextEditingController(text: user.email),
                    labelText: 'Email Address',
                    prefixIcon: Icons.email_outlined,
                    enabled: false, // Email cannot be changed
                    fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _collegeController,
                    labelText: 'College/University',
                    prefixIcon: Icons.school_outlined,
                    enabled: _isEditing,
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedYear,
                          decoration: InputDecoration(
                            labelText: 'Year',
                            prefixIcon: const Icon(Icons.calendar_today_outlined),
                            enabled: _isEditing,
                            filled: true,
                            fillColor: _isEditing
                                ? theme.colorScheme.surface
                                : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline.withOpacity(0.12),
                              ),
                            ),
                          ),
                          items: _years.map((year) => DropdownMenuItem(
                            value: year,
                            child: Text(year),
                          )).toList(),
                          onChanged: _isEditing ? (value) {
                            setState(() {
                              _selectedYear = value;
                            });
                          } : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedBranch,
                          decoration: InputDecoration(
                            labelText: 'Branch',
                            prefixIcon: const Icon(Icons.engineering_outlined),
                            enabled: _isEditing,
                            filled: true,
                            fillColor: _isEditing
                                ? theme.colorScheme.surface
                                : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline.withOpacity(0.12),
                              ),
                            ),
                          ),
                          items: _branches.map((branch) => DropdownMenuItem(
                            value: branch,
                            child: Text(branch, style: const TextStyle(fontSize: 12)),
                          )).toList(),
                          onChanged: _isEditing ? (value) {
                            setState(() {
                              _selectedBranch = value;
                            });
                          } : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  if (_isEditing) ...[
                    if (authProvider.error != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authProvider.error!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    CustomButton(
                      width: double.infinity,
                      onPressed: authProvider.isLoading ? null : _handleUpdateProfile,
                      isLoading: authProvider.isLoading,
                      child: const Text('Save Changes'),
                    ),
                  ] else ...[
                    // Profile Stats
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Information',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildInfoRow(
                              context,
                              'Member since',
                              '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                            ),

                            const SizedBox(height: 8),

                            _buildInfoRow(
                              context,
                              'Study Groups',
                              '3', // TODO: Get actual count from database
                            ),

                            const SizedBox(height: 8),

                            _buildInfoRow(
                              context,
                              'Notes Shared',
                              '12', // TODO: Get actual count from database
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}