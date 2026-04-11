import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<AuthProvider>().login(
            _emailController.text.trim(),
            _passwordController.text,
          );

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect email or password')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              Color(0xFF001F3B),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / Branding
                const Icon(Icons.blur_on, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'ATELIER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const Text(
                  'PREMIUM FABRIC CARE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 48),

                // Login Card
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Welcome back',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const Text(
                          'Please enter your credentials to proceed.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 32),

                        // Email Field
                        const Text('EMAIL ADDRESS',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined, size: 20),
                            hintText: 'email@example.com',
                          ),
                          validator: (value) => (value == null || !value.contains('@')) ? 'Invalid email' : null,
                        ),
                        const SizedBox(height: 24),

                        // Password Field
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('PASSWORD',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                            TextButton(
                              onPressed: () {},
                              child: const Text('FORGOT?', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            hintText: '••••••••',
                          ),
                          validator: (value) => (value == null || value.length < 6) ? 'Password too short' : null,
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        Consumer<AuthProvider>(
                          builder: (context, auth, child) {
                            return ElevatedButton(
                              onPressed: auth.isLoading ? null : _handleLogin,
                              child: auth.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Sign In'),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 16),
                                      ],
                                    ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: 'New to the facility? ',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              children: [
                                TextSpan(
                                  text: 'Request Access',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'V2.1.0  •  ENCRYPTED ATELIER NODE',
                  style: TextStyle(color: Colors.white24, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
