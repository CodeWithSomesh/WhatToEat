import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:what_to_eat/auth/auth_service.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback? onLogout;
  const ProfilePage({Key? key, this.onLogout}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    try {
      await authService.value.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Logged out successfully'),
          backgroundColor: const Color(0xFF3DDCFF),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back to login page
      if (onLogout != null) {
        onLogout!();
      } else {
        // Clear all routes and go to login page
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: const Color(0xFFFF5FCF),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildNeoButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.black, size: 22),
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFF4D),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: const Color(0xFFFFFF4D),
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF95E1D3),
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 4),
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Text(
                  'PROFILE',
                  style: GoogleFonts.fredoka(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User info section
                StreamBuilder<User?>(
                  stream: authService.value.authStateChanges,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final user = snapshot.data!;
                      return Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF95E1D3),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  offset: const Offset(6, 6),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            user.displayName ?? 'User',
                            style: GoogleFonts.fredoka(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.email ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Logout button
                _buildNeoButton(
                  text: 'LOG OUT',
                  color: const Color(0xFFFF5FCF),
                  icon: Icons.logout,
                  onPressed: () => _logout(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}