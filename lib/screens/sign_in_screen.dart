import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Hardcoded demo users for sign-in (no real auth needed)
  static const _validUsers = {
    'nnamdi@atlas.dev': 'password123',
    'admin@atlas.dev': 'admin123',
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate a brief loading delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_validUsers[email] == password) {
        Navigator.pushReplacementNamed(context, '/dashboard', arguments: email);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: const Text(
          'Sign in',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                // App icon
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D5BE3),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_outlined,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Center(
                  child: Text(
                    'SLA Task Tracker',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'Keep projects on track. Deliver on time.',
                    style: TextStyle(fontSize: 13, color: Colors.black45),
                  ),
                ),
                const SizedBox(height: 36),
                // Welcome text
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sign in to your team workspace.',
                  style: TextStyle(fontSize: 13, color: Colors.black45),
                ),
                const SizedBox(height: 24),
                // Email field
                const Text(
                  'Email address',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'nnamdi@atlas.dev',
                    hintStyle: const TextStyle(color: Colors.black38),
                    suffixIcon: const Icon(Icons.email_outlined, color: Colors.black38),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF2D5BE3)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email address.';
                    }
                    final emailRegex = RegExp(r'^[\w\-.]+@[\w\-]+\.\w+$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Password field
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••••••',
                    hintStyle: const TextStyle(color: Colors.black38),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.black38,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF2D5BE3)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password.';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contact your team administrator to reset your password.')),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: Color(0xFF2D5BE3), fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Sign In button
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _signIn,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward, color: Colors.white),
                    label: Text(
                      _isLoading ? 'Signing in...' : 'Sign In',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5BE3),
                      disabledBackgroundColor: const Color(0xFF2D5BE3).withValues(alpha: 0.7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Info banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_user_outlined, color: Color(0xFF2D5BE3), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'One workspace. Clear priorities.\nEvery deadline accounted for.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF1A1A2E), height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Footer
                const Column(
                  children: [
                    Text(
                      'Need access? Contact your team administrator.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.black38),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Secure sign-in for the Atlas development team',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.black26),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}