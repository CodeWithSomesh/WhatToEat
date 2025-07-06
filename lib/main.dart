import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding.dart';
import 'screens/search_restaurants_page.dart';
import 'screens/favourites_page.dart';
import 'screens/profile_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'package:provider/provider.dart';
import 'providers/options_provider.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainNavScaffold extends StatefulWidget {
  @override
  State<MainNavScaffold> createState() => _MainNavScaffoldState();
}

class _MainNavScaffoldState extends State<MainNavScaffold> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  
  final List<Widget> _pages = [
    HomeScreen(),
    RestaurantSearchScreen(),
    const FavouritesPage(),
    const ProfilePage(),
  ];

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.home_rounded, label: 'Home', color: Color(0xFFFF6B6B)),
    NavItem(icon: Icons.search_rounded, label: 'Restaurants', color: Color(0xFF4ECDC4)),
    NavItem(icon: Icons.favorite_rounded, label: 'Favourites', color: Color(0xFFFFE66D)),
    NavItem(icon: Icons.person_rounded, label: 'Profile', color: Color(0xFF95E1D3)),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0x00000000),
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 100,
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _navItems[_selectedIndex].color,
              offset: Offset(8, 8),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_navItems.length, (index) {
              final isSelected = index == _selectedIndex;
              final item = _navItems[index];
              
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedIndex = index);
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });
                },
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final scale = isSelected ? 1.0 + (_animationController.value * 0.1) : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? item.color : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ] : [],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected ? Colors.black : Colors.black54,
                              size: 24,
                            ),
                            SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.black54,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final Color color;

  NavItem({required this.icon, required this.label, required this.color});
}

class AppRoot extends StatefulWidget {
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _onboardingComplete = false;
  bool _loading = true;
  bool _showLogin = true;
  bool _showMainApp = false;

  @override
  void initState() {
    super.initState();
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
      _loading = false;
    });
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    setState(() {
      _onboardingComplete = true;
    });
  }

  void _continueToHome() {
    setState(() {
      _showMainApp = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Material(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_onboardingComplete) {
      return OnBoardingScreen(onFinish: _completeOnboarding);
    }
    if (_showMainApp) {
      return MainNavScaffold();
    }
    return _showLogin
      ? LoginPage(
          onRegisterTap: () => setState(() => _showLogin = false),
          onGuestTap: _continueToHome,
        )
      : RegisterPage(
          onLoginTap: () => setState(() => _showLogin = true),
          onGuestTap: _continueToHome,
        );
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OptionsProvider()),
      ],
      child: GetMaterialApp(
        home: AppRoot(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}