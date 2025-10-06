import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/animations/fade_slide_transition.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
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
                const SizedBox(height: 40),

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
                        'Welcome Back!',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue your study journey',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Login Form
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

                        const SizedBox(height: 20),

                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: Icons.lock_outlined,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
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
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          onSubmitted: (_) => _handleLogin(),
                        ),

                        const SizedBox(height: 32),

                        // Login Button
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
                                  onPressed: authProvider.isLoading ? null : _handleLogin,
                                  isLoading: authProvider.isLoading,
                                  child: const Text('Sign In'),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Register Link
                FadeSlideTransition(
                  animation: _animationController,
                  slideOffset: const Offset(0, 0.1),
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.register),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}