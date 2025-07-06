import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manual_spin_screen.dart';
import 'restaurant_finder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFF4D), // Bright yellow
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 32),
                    // Enhanced header with subtle animation feel
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            'What To Eat?!',
                            style: GoogleFonts.luckiestGuy(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.1),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '🥞 Stop overthinking, start eating! 🍽️',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          _FeatureCard(
                            color: const Color(0xFFFF5FCF),
                            shadowColor: Colors.pink.shade700,
                            icon: Icons.shuffle,
                            title: 'MANUAL WHEEL',
                            description:
                                'Add your own food options and spin the wheel to decide!',
                            buttonText: 'START SPINNING →',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ManualSpinScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _FeatureCard(
                            color: const Color(0xFF3DDCFF),
                            shadowColor: Colors.blue.shade700,
                            icon: Icons.favorite_border,
                            title: 'RESTAURANT FINDER',
                            description:
                                'Swipe through restaurants and let us pick from your favorites!',
                            buttonText: 'DISCOVER FOOD →',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RestaurantFinderScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Enhanced bottom section with better proportions and visual hierarchy
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0, left: 16.0, right: 16.0, top: 16.0),
                  child: Column(
                    children: [
                      // Main call-to-action with better visual balance
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF39FF6A),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.shade700.withOpacity(0.3),
                              offset: const Offset(0, 6),
                              blurRadius: 12,
                            ),
                          ],
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '🍕',
                                  style: TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  '🍔',
                                  style: TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  '🍩',
                                  style: TextStyle(fontSize: 32),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                double fontSize = 16;
                                if (constraints.maxWidth < 350) fontSize = 12;
                                else if (constraints.maxWidth < 400) fontSize = 14;
                                return Text(
                                  'Tired of the "I don\'t know, what do you want?" debate?',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Let WhatToEat spin, swipe, and solve it for you!',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final Color color;
  final Color shadowColor;
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;

  const _FeatureCard({
    required this.color,
    required this.shadowColor,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16), // More rounded corners
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 6), // Softer shadow
            blurRadius: 12,
          ),
        ],
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: Colors.black),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: onPressed,
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}