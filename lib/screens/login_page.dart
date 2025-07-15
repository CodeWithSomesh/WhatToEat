import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:what_to_eat/auth/auth_service.dart';
import 'package:what_to_eat/screens/home_screen.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onRegisterTap;
  final VoidCallback? onGuestTap;
  final VoidCallback? onLoginSuccess;
  const LoginPage({Key? key, this.onRegisterTap, this.onGuestTap, this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? const Color(0xFFFF5FCF) : const Color(0xFF3DDCFF),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await authService.value.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _showSnackBar('Login successful!');

      // Navigate to home page after successful login
      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      } else {
        // Fallback navigation if callback is not provided
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      String errorMessage = 'Login failed. Please try again.';

      // Handle specific Firebase errors
      if (e.toString().contains('user-not-found')) {
        errorMessage = 'No account found with this email.';
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = 'Incorrect password. Please try again.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Please enter a valid email address.';
      } else if (e.toString().contains('user-disabled')) {
        errorMessage = 'This account has been disabled.';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Too many failed attempts. Please try again later.';
      }

      _showSnackBar(errorMessage, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFF4D),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome Back!',
                            style: GoogleFonts.fredoka(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildTextField(
                            hint: 'Email',
                            icon: Icons.email,
                            obscure: false,
                            controller: _emailController,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            hint: 'Password',
                            icon: Icons.lock,
                            obscure: true,
                            controller: _passwordController,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 32),
                          _buildNeoButton(
                            text: _isLoading ? 'LOGGING IN...' : 'LOG IN',
                            color: const Color(0xFF3DDCFF),
                            onPressed: _isLoading ? () {} : _login,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: widget.onRegisterTap ?? () {},
                                child: Text(
                                  'Register',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 15,
                                    color: const Color(0xFFFF5FCF),
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              //   child: _buildNeoButton(
              //     text: 'CONTINUE TO HOME',
              //     color: const Color(0xFFFFE66D),
              //     onPressed: widget.onGuestTap ?? () {},
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required bool obscure,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        style: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          prefixIcon: Icon(icon, color: Colors.black, size: 24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildNeoButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}