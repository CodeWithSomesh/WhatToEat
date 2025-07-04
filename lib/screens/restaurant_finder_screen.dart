import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'auto_wheel_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class RestaurantFinderScreen extends StatefulWidget {
  const RestaurantFinderScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantFinderScreen> createState() => _RestaurantFinderScreenState();
}

class _RestaurantFinderScreenState extends State<RestaurantFinderScreen> 
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _restaurants = [];
  int _currentIndex = 0;
  double _dragDx = 0;
  double _dragStartX = 0;
  final List<Map<String, dynamic>> _liked = [];
  bool _isLoading = true;
  String _error = '';
  late AnimationController _cardAnimationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _cardAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _cardAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.elasticOut),
    );
    _buttonAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _buttonAnimationController, curve: Curves.easeInOut),
    );
    _fetchNearbyRestaurants();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchNearbyRestaurants() async {
    try {
      if (!kIsWeb) {
        // Request location permissions
        final permission = await Permission.location.request();
        if (permission != PermissionStatus.granted) {
          setState(() {
            _error = 'Location permission is required to find nearby restaurants';
            _isLoading = false;
          });
          return;
        }
      } else {
        // On web, permissions are handled by the browser
      }

      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // Use Google Places API (you'll need to add your API key)
      final apiKey = 'AIzaSyDK1_xIKbNdprvMSiz22k5wiXL2C301bps'; // Replace with your actual API key
      final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
          '?location=${position.latitude},${position.longitude}'
          '&radius=5000'
          '&type=restaurant'
          '&key=$apiKey';

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        setState(() {
          _restaurants = results.take(15).map((restaurant) {
            final photos = restaurant['photos'] as List?;
            final photoReference = (photos != null && photos.isNotEmpty)
                ? photos[0]['photo_reference']
                : null;
            
            return {
              'name': restaurant['name'] ?? 'Unknown Restaurant',
              'image': photoReference != null 
                  ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey'
                  : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=400&q=80',
              'cuisine': _extractCuisineType(restaurant['types'] ?? []),
              'rating': (restaurant['rating'] ?? 4.0).toDouble(),
              'address': restaurant['vicinity'] ?? 'Address not available',
              'priceLevel': restaurant['price_level'] ?? 2,
              'placeId': restaurant['place_id'],
            };
          }).toList();
          _isLoading = false;
        });
        
        _cardAnimationController.forward();
      } else {
        throw Exception('Failed to load restaurants');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load restaurants: $e';
        _isLoading = false;
        // Fallback to dummy data
        _restaurants = _getDummyRestaurants();
      });
      _cardAnimationController.forward();
    }
  }

  String _extractCuisineType(List types) {
    const cuisineMap = {
      'bakery': 'Bakery',
      'bar': 'Bar',
      'cafe': 'Cafe',
      'meal_delivery': 'Delivery',
      'meal_takeaway': 'Takeaway',
      'restaurant': 'Restaurant',
    };
    
    for (String type in types) {
      if (cuisineMap.containsKey(type)) {
        return cuisineMap[type]!;
      }
    }
    return 'Restaurant';
  }

  List<Map<String, dynamic>> _getDummyRestaurants() {
    return [
      {
        'name': 'Sushi Zen',
        'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
        'cuisine': 'Japanese',
        'rating': 4.7,
        'address': '123 Tokyo Ave',
        'priceLevel': 3,
      },
      {
        'name': 'Pizza Paradiso',
        'image': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=400&q=80',
        'cuisine': 'Italian',
        'rating': 4.5,
        'address': '456 Rome St',
        'priceLevel': 2,
      },
      {
        'name': 'Burger Bliss',
        'image': 'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=400&q=80',
        'cuisine': 'American',
        'rating': 4.3,
        'address': '789 New York Rd',
        'priceLevel': 2,
      },
      {
        'name': 'Spice Garden',
        'image': 'https://images.unsplash.com/photo-1502741338009-cac2772e18bc?auto=format&fit=crop&w=400&q=80',
        'cuisine': 'Indian',
        'rating': 4.6,
        'address': '321 Delhi Blvd',
        'priceLevel': 2,
      },
      {
        'name': 'Dragon Wok',
        'image': 'https://images.unsplash.com/photo-1464306076886-debca5e8a6b0?auto=format&fit=crop&w=400&q=80',
        'cuisine': 'Chinese',
        'rating': 4.4,
        'address': '654 Beijing Rd',
        'priceLevel': 2,
      },
    ];
  }

  void _onDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragDx = details.globalPosition.dx - _dragStartX;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragDx.abs() > 100) {
      if (_dragDx > 0) {
        _likeCurrent();
      } else {
        _skipCurrent();
      }
    } else {
      setState(() {
        _dragDx = 0;
      });
    }
  }

  void _likeCurrent() {
    if (_currentIndex < _restaurants.length) {
      _liked.add(_restaurants[_currentIndex]);
    }
    _nextCard();
  }

  void _skipCurrent() {
    _nextCard();
  }

  void _nextCard() {
    _cardAnimationController.reset();
    setState(() {
      _currentIndex++;
      _dragDx = 0;
    });
    if (_currentIndex < _restaurants.length) {
      _cardAnimationController.forward();
    }
  }

  void _startOver() {
    setState(() {
      _currentIndex = 0;
      _liked.clear();
      _dragDx = 0;
      _isLoading = true;
    });
    _fetchNearbyRestaurants();
  }

  void _spinFromPicks() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AutoWheelScreen(
          options: _liked.map((r) => r['name'] as String).toList(),
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
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF3DDCFF),
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 4),
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Text(
                  'RESTAURANT FINDER',
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
      body: _isLoading ? _buildLoadingScreen() : 
            _error.isNotEmpty ? _buildErrorScreen() :
            _currentIndex >= _restaurants.length ? _buildEndScreen() : _buildSwipeScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5FCF)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'FINDING NEARBY\nRESTAURANTS...',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'OOPS!',
              style: GoogleFonts.fredoka(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            _buildNeoButton(
              text: 'TRY AGAIN',
              color: const Color(0xFFFF5FCF),
              onPressed: _startOver,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeScreen() {
    final restaurant = _restaurants[_currentIndex];
    return Column(
      children: [
        const SizedBox(height: 16),
        // Enhanced progress section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Text(
                'SWIPE TO CHOOSE!',
                style: GoogleFonts.fredoka(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: (_currentIndex + 1) / _restaurants.length,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF5FCF)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${_restaurants.length}',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Enhanced card stack
        Expanded(
          child: AnimatedBuilder(
            animation: _cardAnimation,
            builder: (context, child) {
              return Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background cards
                    if (_currentIndex < _restaurants.length - 1)
                      _RestaurantCard(
                        restaurant: _restaurants[_currentIndex + 1],
                        scale: 0.92,
                        opacity: 0.6,
                        offset: 20,
                      ),
                    if (_currentIndex < _restaurants.length - 2)
                      _RestaurantCard(
                        restaurant: _restaurants[_currentIndex + 2],
                        scale: 0.85,
                        opacity: 0.3,
                        offset: 40,
                      ),
                    // Main card
                    GestureDetector(
                      onHorizontalDragStart: _onDragStart,
                      onHorizontalDragUpdate: _onDragUpdate,
                      onHorizontalDragEnd: _onDragEnd,
                      child: Transform.translate(
                        offset: Offset(_dragDx, 0),
                        child: Transform.rotate(
                          angle: _dragDx * 0.001,
                          child: Transform.scale(
                            scale: _cardAnimation.value,
                            child: _RestaurantCard(
                              restaurant: restaurant,
                              scale: 1.0,
                              opacity: 1.0,
                              offset: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Swipe indicators
                    if (_dragDx > 50)
                      Positioned(
                        top: 80,
                        left: 40,
                        child: Transform.rotate(
                          angle: -0.3,
                          child: Opacity(
                            opacity: min(_dragDx / 150, 1),
                            child: _SwipeIndicator(
                              label: 'LOVE IT!',
                              color: const Color(0xFF39FF6A),
                              icon: Icons.favorite,
                            ),
                          ),
                        ),
                      ),
                    if (_dragDx < -50)
                      Positioned(
                        top: 80,
                        right: 40,
                        child: Transform.rotate(
                          angle: 0.3,
                          child: Opacity(
                            opacity: min(-_dragDx / 150, 1),
                            child: _SwipeIndicator(
                              label: 'NOPE!',
                              color: const Color(0xFFFF6B6B),
                              icon: Icons.close,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        // Enhanced action buttons
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0, top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _buttonAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _buttonAnimation.value,
                    child: _ActionButton(
                      icon: Icons.close,
                      color: const Color(0xFFFF6B6B),
                      onPressed: () {
                        _buttonAnimationController.forward().then((_) {
                          _buttonAnimationController.reverse();
                        });
                        _skipCurrent();
                      },
                    ),
                  );
                },
              ),
              const SizedBox(width: 60),
              AnimatedBuilder(
                animation: _buttonAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _buttonAnimation.value,
                    child: _ActionButton(
                      icon: Icons.favorite,
                      color: const Color(0xFF39FF6A),
                      onPressed: () {
                        _buttonAnimationController.forward().then((_) {
                          _buttonAnimationController.reverse();
                        });
                        _likeCurrent();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEndScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF39FF6A),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(12, 12),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration,
                size: 64,
                color: Color(0xFFFF5FCF),
              ),
              const SizedBox(height: 16),
              Text(
                'ALL DONE!',
                style: GoogleFonts.fredoka(
                  fontSize: 42,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You liked ${_liked.length} restaurants',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 32),
              _buildNeoButton(
                text: 'SPIN FROM YOUR PICKS! 🎲',
                color: const Color(0xFFFF5FCF),
                onPressed: _spinFromPicks,
              ),
              const SizedBox(height: 16),
              _buildNeoButton(
                text: 'START OVER',
                color: const Color(0xFF3DDCFF),
                onPressed: _startOver,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeoButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black, width: 3),
          ),
        ).copyWith(
          shadowColor: MaterialStateProperty.all(Colors.transparent),
          overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black.withOpacity(0.1);
            }
            return null;
          }),
        ),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final double scale;
  final double opacity;
  final double offset;

  const _RestaurantCard({
    required this.restaurant,
    this.scale = 1.0,
    this.opacity = 1.0,
    this.offset = 0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 340,
          margin: EdgeInsets.only(top: offset, bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(8, 8),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.network(
                  restaurant['image'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.restaurant,
                        size: 64,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant['name'],
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3DDCFF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Text(
                            restaurant['cuisine'],
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFFFD700), size: 20),
                            const SizedBox(width: 4),
                            Text(
                              restaurant['rating'].toString(),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFFF6B6B), size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            restaurant['address'],
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Price: ',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '\$' * (restaurant['priceLevel'] ?? 2),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF39FF6A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeIndicator extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _SwipeIndicator({
    required this.label,
    required this.color,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}