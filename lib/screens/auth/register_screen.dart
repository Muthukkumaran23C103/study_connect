import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/animations/fade_slide_transition.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _collegeController = TextEditingController();

  late AnimationController _animationController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedYear;
  String? _selectedBranch;

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

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _collegeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
      college: _collegeController.text.trim().isNotEmpty
          ? _collegeController.text.trim()
          : null,
      year: _selectedYear,
      branch: _selectedBranch,
    );

    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: mediaQuery.size.height - mediaQuery.padding.top - 48,
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Header
                FadeSlideTransition(
                  animation: _animationController,
                  slideOffset: const Offset(0, -0.1),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Create Account',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join the study community',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Registration Form
                FadeSlideTransition(
                  animation: _animationController,
                  slideOffset: const Offset(0, 0.1),
                  delay: const Duration(milliseconds: 200),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          prefixIcon: Icons.person_outlined,
                          textInputAction: TextInputAction.next,
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
                          controller: _emailController,
                          labelText: 'Email Address',
                          hintText: 'Enter your email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _collegeController,
                          labelText: 'College/University',
                          hintText: 'Enter your college name (optional)',
                          prefixIcon: Icons.school_outlined,
                          textInputAction: TextInputAction.next,
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
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
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
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                items: _years.map((year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year),
                                )).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedYear = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedBranch,
                                decoration: InputDecoration(
                                  labelText: 'Branch',
                                  prefixIcon: const Icon(Icons.engineering_outlined),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
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
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                items: _branches.map((branch) => DropdownMenuItem(
                                  value: branch,
                                  child: Text(branch, style: const TextStyle(fontSize: 12)),
                                )).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedBranch = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: Icons.lock_outlined,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirm Password',
                          hintText: 'Confirm your password',
                          prefixIcon: Icons.lock_outlined,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          onSubmitted: (_) => _handleRegister(),
                        ),

                        const SizedBox(height: 32),

                        // Register Button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (authProvider.error != null) ...[
                                  Container(
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
                                  onPressed: authProvider.isLoading ? null : _handleRegister,
                                  isLoading: authProvider.isLoading,
                                  child: const Text('Create Account'),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Link
                FadeSlideTransition(
                  animation: _animationController,
                  slideOffset: const Offset(0, 0.1),
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}