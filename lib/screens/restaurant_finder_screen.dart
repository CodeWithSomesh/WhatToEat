import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'auto_wheel_screen.dart';

class RestaurantFinderScreen extends StatefulWidget {
  const RestaurantFinderScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantFinderScreen> createState() => _RestaurantFinderScreenState();
}

class _RestaurantFinderScreenState extends State<RestaurantFinderScreen> {
  final List<Map<String, dynamic>> _restaurants = [
    {
      'name': 'Sushi World',
      'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
      'cuisine': 'Japanese',
      'rating': 4.7,
      'address': '123 Tokyo Ave',
    },
    {
      'name': 'Pizza Palace',
      'image': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=400&q=80',
      'cuisine': 'Italian',
      'rating': 4.5,
      'address': '456 Rome St',
    },
    {
      'name': 'Burger Barn',
      'image': 'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=400&q=80',
      'cuisine': 'American',
      'rating': 4.3,
      'address': '789 New York Rd',
    },
    {
      'name': 'Curry House',
      'image': 'https://images.unsplash.com/photo-1502741338009-cac2772e18bc?auto=format&fit=crop&w=400&q=80',
      'cuisine': 'Indian',
      'rating': 4.6,
      'address': '321 Delhi Blvd',
    },
    {
      'name': 'Noodle House',
      'image': 'https://images.unsplash.com/photo-1464306076886-debca5e8a6b0?auto=format&fit=crop&w=400&q=80',
      'cuisine': 'Chinese',
      'rating': 4.4,
      'address': '654 Beijing Rd',
    },
    {
      'name': 'Taco Town',
      'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
      'cuisine': 'Mexican',
      'rating': 4.2,
      'address': '987 Mexico St',
    },
    {
      'name': 'Vegan Delight',
      'image': 'https://images.unsplash.com/photo-1502741338009-cac2772e18bc?auto=format&fit=crop&w=400&q=80',
      'cuisine': 'Vegan',
      'rating': 4.8,
      'address': '111 Greenway',
    },
    {
      'name': 'Steak House',
      'image': 'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=400&q=80',
      'cuisine': 'Steak',
      'rating': 4.7,
      'address': '222 Grill Ave',
    },
    {
      'name': 'Seafood Shack',
      'image': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=400&q=80',
      'cuisine': 'Seafood',
      'rating': 4.5,
      'address': '333 Ocean Dr',
    },
    {
      'name': 'Pasta Point',
      'image': 'https://images.unsplash.com/photo-1464306076886-debca5e8a6b0?auto=format&fit=crop&w=400&q=80',
      'cuisine': 'Italian',
      'rating': 4.6,
      'address': '444 Rome St',
    },
  ];

  int _currentIndex = 0;
  double _dragDx = 0;
  double _dragStartX = 0;
  final List<Map<String, dynamic>> _liked = [];

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
    setState(() {
      _currentIndex++;
      _dragDx = 0;
    });
  }

  void _startOver() {
    setState(() {
      _currentIndex = 0;
      _liked.clear();
      _dragDx = 0;
    });
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
    final isDone = _currentIndex >= 10;
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Finder', style: GoogleFonts.luckiestGuy(fontSize: 26)),
        backgroundColor: const Color(0xFF3DDCFF),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFFFF4D),
      body: isDone ? _buildEndScreen(context) : _buildSwipeScreen(context),
    );
  }

  Widget _buildSwipeScreen(BuildContext context) {
    final restaurant = _restaurants[_currentIndex];
    return Column(
      children: [
        const SizedBox(height: 16),
        // Progress bar and counter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Text('SWIPE TO CHOOSE!', style: GoogleFonts.luckiestGuy(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Container(
                          height: 12,
                          width: (( _currentIndex + 1 ) / 10) * MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5FCF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${_currentIndex + 1}/10', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_currentIndex < _restaurants.length - 1)
                  _RestaurantCard(
                    restaurant: _restaurants[_currentIndex + 1],
                    scale: 0.95,
                    opacity: 0.7,
                    offset: 20,
                  ),
                GestureDetector(
                  onHorizontalDragStart: _onDragStart,
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _onDragEnd,
                  child: Transform.translate(
                    offset: Offset(_dragDx, 0),
                    child: Transform.rotate(
                      angle: _dragDx * 0.002,
                      child: _RestaurantCard(
                        restaurant: restaurant,
                        scale: 1.0,
                        opacity: 1.0,
                        offset: 0,
                      ),
                    ),
                  ),
                ),
                if (_dragDx > 40)
                  Positioned(
                    top: 60,
                    left: 40,
                    child: Opacity(
                      opacity: min(_dragDx / 120, 1),
                      child: _SwipeIndicator(label: 'LIKE', color: Colors.green),
                    ),
                  ),
                if (_dragDx < -40)
                  Positioned(
                    top: 60,
                    right: 40,
                    child: Opacity(
                      opacity: min(-_dragDx / 120, 1),
                      child: _SwipeIndicator(label: 'NOPE', color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // X and Love buttons
        Padding(
          padding: const EdgeInsets.only(bottom: 32.0, top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _skipCurrent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                  elevation: 4,
                  side: const BorderSide(color: Colors.red, width: 2),
                ),
                child: const Icon(Icons.close, size: 36),
              ),
              const SizedBox(width: 40),
              ElevatedButton(
                onPressed: _likeCurrent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                  elevation: 4,
                  side: const BorderSide(color: Colors.green, width: 2),
                ),
                child: const Icon(Icons.favorite, size: 36),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEndScreen(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF39FF6A),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(8, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ALL DONE!', style: GoogleFonts.luckiestGuy(fontSize: 38, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('You liked ${_liked.length} restaurants', style: GoogleFonts.montserrat(fontSize: 20)),
              const SizedBox(height: 32),
              SizedBox(
                width: 320,
                child: ElevatedButton(
                  onPressed: _spinFromPicks,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5FCF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: const BorderSide(color: Colors.black, width: 2),
                  ),
                  child: const Text('SPIN FROM YOUR PICKS! →'),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 320,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3DDCFF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: const BorderSide(color: Colors.black, width: 2),
                  ),
                  child: const Text('START OVER'),
                ),
              ),
            ],
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  restaurant['image'],
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                restaurant['name'],
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.restaurant_menu, color: Colors.grey[700], size: 20),
                  const SizedBox(width: 6),
                  Text(
                    restaurant['cuisine'],
                    style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 2),
                  Text(
                    restaurant['rating'].toString(),
                    style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red[400], size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      restaurant['address'],
                      style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w400),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
  const _SwipeIndicator({required this.label, required this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
