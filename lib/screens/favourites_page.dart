import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({Key? key}) : super(key: key);

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  List<Map<String, dynamic>> _favoriteRestaurants = [];
  bool _isLoading = true;
  String _error = '';
  final List<String> _priceOptions = ['Any', '\$', '\$\$', '\$\$\$', '\$\$\$\$'];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Future<void> _loadFavorites() async {
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //       _error = '';
  //     });
  //
  //     // Simulate network delay
  //     await Future.delayed(const Duration(seconds: 1));
  //
  //     // Dummy data instead of Firebase
  //     List<Map<String, dynamic>> favorites = [
  //       {
  //         'placeId': 'dummy_1',
  //         'name': 'The Golden Spoon',
  //         'cuisine': 'Italian',
  //         'rating': 4.5,
  //         'address': '123 Main Street, Downtown',
  //         'priceLevel': 3,
  //         'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=400&q=80',
  //         'addedAt': DateTime.now().subtract(const Duration(days: 2)),
  //       },
  //       {
  //         'placeId': 'dummy_2',
  //         'name': 'Sakura Sushi Bar',
  //         'cuisine': 'Japanese',
  //         'rating': 4.8,
  //         'address': '456 Oak Avenue, Midtown',
  //         'priceLevel': 4,
  //         'image': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?auto=format&fit=crop&w=400&q=80',
  //         'addedAt': DateTime.now().subtract(const Duration(days: 5)),
  //       },
  //       {
  //         'placeId': 'dummy_3',
  //         'name': 'Burger Paradise',
  //         'cuisine': 'American',
  //         'rating': 4.2,
  //         'address': '789 Pine Road, Uptown',
  //         'priceLevel': 2,
  //         'image': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=400&q=80',
  //         'addedAt': DateTime.now().subtract(const Duration(days: 1)),
  //       },
  //       {
  //         'placeId': 'dummy_4',
  //         'name': 'Spice Garden',
  //         'cuisine': 'Indian',
  //         'rating': 4.6,
  //         'address': '321 Elm Street, Old Town',
  //         'priceLevel': 2,
  //         'image': 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=400&q=80',
  //         'addedAt': DateTime.now().subtract(const Duration(days: 3)),
  //       },
  //       {
  //         'placeId': 'dummy_5',
  //         'name': 'Le Petit Café',
  //         'cuisine': 'French',
  //         'rating': 4.7,
  //         'address': '654 Maple Drive, French Quarter',
  //         'priceLevel': 3,
  //         'image': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=400&q=80',
  //         'addedAt': DateTime.now().subtract(const Duration(days: 4)),
  //       },
  //       {
  //         'placeId': 'dummy_6',
  //         'name': 'Taco Fiesta',
  //         'cuisine': 'Mexican',
  //         'rating': 4.3,
  //         'address': '987 Cedar Lane, South Side',
  //         'priceLevel': 1,
  //         'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?auto=format&fit=crop&w=400&q=80',
  //         'addedAt': DateTime.now().subtract(const Duration(days: 6)),
  //       },
  //     ];
  //
  //     setState(() {
  //       _favoriteRestaurants = favorites;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _error = 'Error loading favorites: $e';
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _loadFavorites() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _favoriteRestaurants = [];
          _isLoading = false;
        });
        return;
      }

      // Get user's favorites from Firestore
      final favoritesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .get();

      List<Map<String, dynamic>> favorites = [];

      for (var doc in favoritesSnapshot.docs) {
        final data = doc.data();
        favorites.add({
          'placeId': doc.id,
          'name': data['name'] ?? 'Unknown Restaurant',
          'cuisine': data['cuisine'] ?? 'Unknown',
          'rating': (data['rating'] ?? 0.0).toDouble(),
          'address': data['address'] ?? 'No address available',
          'priceLevel': data['priceLevel'] ?? 2,
          'image': data['image'] ?? 'https://via.placeholder.com/400x200',
          'addedAt': (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        });
      }

      setState(() {
        _favoriteRestaurants = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading favorites: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(String placeId, String restaurantName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Remove from Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(placeId)
          .delete();

      // Update local state
      setState(() {
        _favoriteRestaurants.removeWhere((restaurant) => restaurant['placeId'] == placeId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed $restaurantName from favorites'),
          backgroundColor: const Color(0xFFFF5FCF),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing from favorites: $e'),
          backgroundColor: const Color(0xFFFF5FCF),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.black, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(13),
            ),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(restaurant['image']),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Restaurant details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurant['name'],
                        style: GoogleFonts.fredoka(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5FCF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Colors.black,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'FAVORITE',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3DDCFF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Text(
                        restaurant['cuisine'],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFF4D),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.black,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            restaurant['rating'].toString(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF39FF6A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Text(
                        _priceOptions[restaurant['priceLevel'] ?? 2],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.black,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        restaurant['address'],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildNeoButton(
                        text: 'VIEW DETAILS',
                        color: const Color(0xFF3DDCFF),
                        onPressed: () {
                          _showRestaurantDetails(restaurant);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNeoButton(
                        text: 'REMOVE',
                        color: const Color(0xFFFF5FCF),
                        onPressed: () {
                          _showRemoveConfirmation(restaurant);
                        },
                        icon: Icons.favorite,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRestaurantDetails(Map<String, dynamic> restaurant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurant['name'],
                        style: GoogleFonts.fredoka(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5FCF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  'Cuisine: ${restaurant['cuisine']}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Rating: ${restaurant['rating']} ⭐',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Price: ${_priceOptions[restaurant['priceLevel'] ?? 2]}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Address: ${restaurant['address']}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: _buildNeoButton(
                    text: 'REMOVE FAVORITE',
                    color: const Color(0xFFFF5FCF),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showRemoveConfirmation(restaurant);
                    },
                    icon: Icons.favorite,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRemoveConfirmation(Map<String, dynamic> restaurant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
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
                  Icons.favorite,
                  color: Color(0xFFFF5FCF),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Remove from Favorites?',
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to remove "${restaurant['name']}" from your favorites?',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildNeoButton(
                        text: 'CANCEL',
                        color: const Color(0xFF3DDCFF),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNeoButton(
                        text: 'REMOVE',
                        color: const Color(0xFFFF5FCF),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _removeFavorite(restaurant['placeId'], restaurant['name']);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFF4D),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        backgroundColor: const Color(0xFFFFFF4D),
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFF5FCF),
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 4),
            ),
          ),
          child: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 48),
                Expanded(
                  child: Center(
                    child: Text(
                      'MY FAVORITES',
                      style: GoogleFonts.fredoka(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          strokeWidth: 3,
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5FCF),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.black,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildNeoButton(
                text: 'TRY AGAIN',
                color: const Color(0xFF39FF6A),
                onPressed: _loadFavorites,
              ),
            ],
          ),
        ),
      );
    }

    if (_favoriteRestaurants.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFF4D),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite_border,
                color: Colors.black,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'No favorites yet',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start exploring restaurants and add them to your favorites!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildNeoButton(
                text: 'EXPLORE RESTAURANTS',
                color: const Color(0xFF3DDCFF),
                onPressed: () {
                  // Navigate to restaurants page
                  Navigator.of(context).pushNamed('/restaurants');
                },
                icon: Icons.search,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // Increased bottom padding
      itemCount: _favoriteRestaurants.length,
      itemBuilder: (context, index) {
        return _buildRestaurantCard(_favoriteRestaurants[index]);
      },
    );
  }
}