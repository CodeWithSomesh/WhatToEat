import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RestaurantSearchScreen extends StatefulWidget {
  const RestaurantSearchScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantSearchScreen> createState() => _RestaurantSearchScreenState();
}

class _RestaurantSearchScreenState extends State<RestaurantSearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();

  List<Map<String, dynamic>> _searchResults = [];
  List<String> _searchHistory = [];
  List<String> _cuisineFilters = [];
  List<Map<String, dynamic>> _favoriteRestaurants = [];
  String _selectedPriceRange = 'Any';
  double _selectedRadius = 5.0; // km
  bool _isLoading = false;
  bool _hasSearched = false;
  String _error = '';
  String _currentLocation = '';
  Position? _userPosition;

  Timer? _debounceTimer;
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;
  bool _showFilters = false;

  final List<String> _cuisineOptions = [
    'Italian', 'Chinese', 'Japanese', 'Indian', 'Mexican', 'Thai', 'American',
    'French', 'Greek', 'Korean', 'Vietnamese', 'Turkish', 'Lebanese', 'Spanish'
  ];

  final List<String> _priceOptions = ['Any', '\$', '\$\$', '\$\$\$', '\$\$\$\$'];

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _filterAnimationController, curve: Curves.easeInOut),
    );
    _getCurrentLocation();
    _loadSearchHistory();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _searchFocusNode.dispose();
    _locationFocusNode.dispose();
    _debounceTimer?.cancel();
    _filterAnimationController.dispose();
    super.dispose();
  }

//   Future<void> _loadFavorites() async {
//     try {
//         final user = FirebaseAuth.instance.currentUser;
//         if (user != null) {
//         final doc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .collection('favorites')
//             .get();

//         setState(() {
//             _favoriteRestaurants = doc.docs.map((doc) => doc.id).toList();
//         });
//         }
//     } catch (e) {
//         print('Error loading favorites: $e');
//     }
//   }

// Future<void> _loadFavorites() async {
//     try {
//         setState(() {
//         _isLoading = true;
//         _error = '';
//         });
//
//         // Simulate network delay
//         await Future.delayed(const Duration(seconds: 1));
//
//         // Dummy data instead of Firebase
//         List<Map<String, dynamic>> favorites = [
//         {
//             'placeId': 'dummy_1',
//             'name': 'The Golden Spoon',
//             'cuisine': 'Italian',
//             'rating': 4.5,
//             'address': '123 Main Street, Downtown',
//             'priceLevel': 3,
//             'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=400&q=80',
//             'addedAt': DateTime.now().subtract(const Duration(days: 2)),
//         },
//         {
//             'placeId': 'dummy_2',
//             'name': 'Sakura Sushi Bar',
//             'cuisine': 'Japanese',
//             'rating': 4.8,
//             'address': '456 Oak Avenue, Midtown',
//             'priceLevel': 4,
//             'image': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?auto=format&fit=crop&w=400&q=80',
//             'addedAt': DateTime.now().subtract(const Duration(days: 5)),
//         },
//         {
//             'placeId': 'dummy_3',
//             'name': 'Burger Paradise',
//             'cuisine': 'American',
//             'rating': 4.2,
//             'address': '789 Pine Road, Uptown',
//             'priceLevel': 2,
//             'image': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=400&q=80',
//             'addedAt': DateTime.now().subtract(const Duration(days: 1)),
//         },
//         {
//             'placeId': 'dummy_4',
//             'name': 'Spice Garden',
//             'cuisine': 'Indian',
//             'rating': 4.6,
//             'address': '321 Elm Street, Old Town',
//             'priceLevel': 2,
//             'image': 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=400&q=80',
//             'addedAt': DateTime.now().subtract(const Duration(days: 3)),
//         },
//         {
//             'placeId': 'dummy_5',
//             'name': 'Le Petit Café',
//             'cuisine': 'French',
//             'rating': 4.7,
//             'address': '654 Maple Drive, French Quarter',
//             'priceLevel': 3,
//             'image': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=400&q=80',
//             'addedAt': DateTime.now().subtract(const Duration(days: 4)),
//         },
//         {
//             'placeId': 'dummy_6',
//             'name': 'Taco Fiesta',
//             'cuisine': 'Mexican',
//             'rating': 4.3,
//             'address': '987 Cedar Lane, South Side',
//             'priceLevel': 1,
//             'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?auto=format&fit=crop&w=400&q=80',
//             'addedAt': DateTime.now().subtract(const Duration(days: 6)),
//         },
//         ];
//
//         setState(() {
//         _favoriteRestaurants = favorites;
//         _isLoading = false;
//         });
//     } catch (e) {
//         setState(() {
//         _error = 'Error loading favorites: $e';
//         _isLoading = false;
//         });
//     }
//     }

  // Future<void> _toggleFavorite(Map<String, dynamic> restaurant) async {
  //     try {
  //         final user = FirebaseAuth.instance.currentUser;
  //         if (user == null) return;

  //         final placeId = restaurant['placeId'];
  //         final isFavorite = _favoriteRestaurants.contains(placeId);

  //         if (isFavorite) {
  //         // Remove from favorites
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(user.uid)
  //             .collection('favorites')
  //             .doc(placeId)
  //             .delete();

  //         setState(() {
  //             _favoriteRestaurants.remove(placeId);
  //         });

  //         ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //             content: Text('Removed ${restaurant['name']} from favorites'),
  //             backgroundColor: const Color(0xFFFF5FCF),
  //             ),
  //         );
  //         } else {
  //         // Add to favorites
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(user.uid)
  //             .collection('favorites')
  //             .doc(placeId)
  //             .set({
  //                 'name': restaurant['name'],
  //                 'cuisine': restaurant['cuisine'],
  //                 'rating': restaurant['rating'],
  //                 'address': restaurant['address'],
  //                 'priceLevel': restaurant['priceLevel'],
  //                 'image': restaurant['image'],
  //                 'addedAt': FieldValue.serverTimestamp(),
  //             });

  //         setState(() {
  //             _favoriteRestaurants.add(placeId);
  //         });

  //         ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //             content: Text('Added ${restaurant['name']} to favorites'),
  //             backgroundColor: const Color(0xFF39FF6A),
  //             ),
  //         );
  //         }
  //     } catch (e) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //             content: Text('Error updating favorites: $e'),
  //             backgroundColor: const Color(0xFFFF5FCF),
  //         ),
  //         );
  //     }
  // }

  // Future<void> _toggleFavorite(String placeId, String restaurantName) async {
  //     try {
  //         // Simulate network delay
  //         await Future.delayed(const Duration(milliseconds: 500));

  //         setState(() {
  //         _favoriteRestaurants.removeWhere((restaurant) => restaurant['placeId'] == placeId);
  //         });

  //         ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //             content: Text('Removed $restaurantName from favorites'),
  //             backgroundColor: const Color(0xFFFF5FCF),
  //         ),
  //         );
  //     } catch (e) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //             content: Text('Error removing from favorites: $e'),
  //             backgroundColor: const Color(0xFFFF5FCF),
  //         ),
  //         );
  //     }
  //    }

  // Future<void> _toggleFavorite(Map<String, dynamic> restaurant) async {
  //     try {
  //         String placeId = restaurant['placeId'].toString();
  //
  //         // Check if restaurant is already in favorites
  //         bool isCurrentlyFavorite = _favoriteRestaurants.any((fav) => fav['placeId'].toString() == placeId);
  //
  //         if (isCurrentlyFavorite) {
  //         // Remove from favorites
  //         setState(() {
  //             _favoriteRestaurants.removeWhere((fav) => fav['placeId'].toString() == placeId);
  //         });
  //
  //         ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //             content: Text('Removed ${restaurant['name']} from favorites'),
  //             backgroundColor: const Color(0xFFFF5FCF),
  //             ),
  //         );
  //         } else {
  //         // Add to favorites
  //         setState(() {
  //             _favoriteRestaurants.add({
  //             'placeId': restaurant['placeId'],
  //             'name': restaurant['name'],
  //             'cuisine': restaurant['cuisine'] ?? 'Unknown',
  //             'rating': restaurant['rating'] ?? 0.0,
  //             'address': restaurant['address'] ?? 'No address available',
  //             'priceLevel': restaurant['priceLevel'] ?? 2,
  //             'image': restaurant['image'] ?? 'https://via.placeholder.com/400x200',
  //             'addedAt': DateTime.now(),
  //             });
  //         });
  //
  //         ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //             content: Text('Added ${restaurant['name']} to favorites'),
  //             backgroundColor: const Color(0xFF39FF6A),
  //             ),
  //         );
  //         }
  //     } catch (e) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //             content: Text('Error updating favorites: $e'),
  //             backgroundColor: const Color(0xFFFF5FCF),
  //         ),
  //         );
  //     }
  // }

  // Load favorites from Firebase
  Future<void> _loadFavorites() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .get();

        setState(() {
          _favoriteRestaurants = doc.docs.map((doc) {
            final data = doc.data();
            return {
              'placeId': doc.id,
              'name': data['name'] ?? 'Unknown Restaurant',
              'cuisine': data['cuisine'] ?? 'Unknown',
              'rating': (data['rating'] ?? 0.0).toDouble(),
              'address': data['address'] ?? 'No address available',
              'priceLevel': data['priceLevel'] ?? 2,
              'image': data['image'] ?? 'https://via.placeholder.com/400x200',
              'addedAt': (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            };
          }).toList();
        });
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

// Toggle favorite status in Firebase
  Future<void> _toggleFavorite(Map<String, dynamic> restaurant) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please sign in to add favorites',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Color(0xFFFF5FCF),
          ),
        );
        return;
      }

      final placeId = restaurant['placeId'].toString();
      final isFavorite = _favoriteRestaurants.any((fav) => fav['placeId'].toString() == placeId);

      if (isFavorite) {
        // Remove from favorites
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(placeId)
            .delete();

        setState(() {
          _favoriteRestaurants.removeWhere((fav) => fav['placeId'].toString() == placeId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Removed ${restaurant['name']} from favorites',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFFFF5FCF),
          ),
        );
      } else {
        // Add to favorites
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(placeId)
            .set({
          'name': restaurant['name'],
          'cuisine': restaurant['cuisine'] ?? 'Unknown',
          'rating': restaurant['rating'] ?? 0.0,
          'address': restaurant['address'] ?? 'No address available',
          'priceLevel': restaurant['priceLevel'] ?? 2,
          'image': restaurant['image'] ?? 'https://via.placeholder.com/400x200',
          'addedAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _favoriteRestaurants.add({
            'placeId': restaurant['placeId'],
            'name': restaurant['name'],
            'cuisine': restaurant['cuisine'] ?? 'Unknown',
            'rating': restaurant['rating'] ?? 0.0,
            'address': restaurant['address'] ?? 'No address available',
            'priceLevel': restaurant['priceLevel'] ?? 2,
            'image': restaurant['image'] ?? 'https://via.placeholder.com/400x200',
            'addedAt': DateTime.now(),
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Added ${restaurant['name']} to favorites',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF39FF6A),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error updating favorites: $e',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFFF5FCF),
        ),
      );
    }
  }

  // Helper function to check if a restaurant is favorited
  bool _isRestaurantFavorited(String placeId) {
    return _favoriteRestaurants.any((fav) => fav['placeId'].toString() == placeId);
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (!kIsWeb) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          setState(() {
            _currentLocation = 'George Town, Penang, Malaysia'; // Default location
            _locationController.text = _currentLocation;
          });
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            setState(() {
              _currentLocation = 'George Town, Penang, Malaysia'; // Default location
              _locationController.text = _currentLocation;
            });
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          setState(() {
            _currentLocation = 'George Town, Penang, Malaysia'; // Default location
            _locationController.text = _currentLocation;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      _userPosition = position;
      await _reverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      // Set default location if GPS fails
      if (mounted) {
        setState(() {
          _currentLocation = 'George Town, Penang, Malaysia';
          _locationController.text = _currentLocation;
        });
      }
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final apiKey = 'AIzaSyDK1_xIKbNdprvMSiz22k5wiXL2C301bps'; //API Key from Google Cloud
      final url = 'https://maps.googleapis.com/maps/api/geocode/json'
          '?latlng=$lat,$lng&key=$apiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          final address = data['results'][0]['formatted_address'];
          setState(() {
            _currentLocation = address;
            _locationController.text = address;
          });
        }
      }
    } catch (e) {
      setState(() {
        _currentLocation = 'Current location';
      });
    }
  }

  void _loadSearchHistory() {
    // In a real app, you'd load this from SharedPreferences or a database
    setState(() {
      _searchHistory = ['Pizza', 'Sushi', 'Burger', 'Thai food', 'Coffee'];
    });
  }

  void _saveSearchHistory(String query) {
    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = '';
      _hasSearched = true;
    });

    _saveSearchHistory(query);

    try {
      String location = _locationController.text.trim();
      String locationParam = '';

      // Priority: User entered location > Current GPS location > Default fallback
      if (location.isNotEmpty && location != _currentLocation) {
        // Use user-entered location
        final geocodeResult = await _geocodeLocation(location);
        if (geocodeResult != null) {
          locationParam = '${geocodeResult['lat']},${geocodeResult['lng']}';
        }
      } else if (_userPosition != null) {
        // Use GPS location
        locationParam = '${_userPosition!.latitude},${_userPosition!.longitude}';
      } else if (location.isNotEmpty) {
        // Try to geocode the current location text
        final geocodeResult = await _geocodeLocation(location);
        if (geocodeResult != null) {
          locationParam = '${geocodeResult['lat']},${geocodeResult['lng']}';
        }
      }

      // Fallback to a default location if all else fails
      if (locationParam.isEmpty) {
        // Using a default location (you can change this to your preferred default)
        locationParam = '5.4164,100.3327'; // George Town, Penang coordinates
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Using default location for search',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Color(0xFFFFFF4D),
            ),
          );
        }
      }

      final apiKey = 'AIzaSyDK1_xIKbNdprvMSiz22k5wiXL2C301bps';
      final radius = (_selectedRadius * 1000).round();

      String url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
          '?location=$locationParam'
          '&radius=$radius'
          '&type=restaurant'
          '&keyword=${Uri.encodeComponent(query)}'
          '&key=$apiKey';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - please try again');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check for API errors
        if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
          throw Exception('API Error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
        }

        final results = data['results'] as List? ?? [];

        List<Map<String, dynamic>> filteredResults = results.map((restaurant) {
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
            'placeId': restaurant['place_id'] ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}',
            'types': restaurant['types'] ?? [],
            'isOpen': restaurant['opening_hours']?['open_now'],
          };
        }).toList();

        filteredResults = _applyFilters(filteredResults);

        if (mounted) {
          setState(() {
            _searchResults = filteredResults;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to search restaurants');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
          _searchResults = []; // Clear results on error
        });
      }
    }
  }

  Future<Map<String, double>?> _geocodeLocation(String location) async {
    if (location.isEmpty) return null;

    try {
      final apiKey = 'AIzaSyDK1_xIKbNdprvMSiz22k5wiXL2C301bps';
      final url = 'https://maps.googleapis.com/maps/api/geocode/json'
          '?address=${Uri.encodeComponent(location)}&key=$apiKey';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 8),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final geometry = data['results'][0]['geometry']['location'];
          return {
            'lat': geometry['lat'].toDouble(),
            'lng': geometry['lng'].toDouble(),
          };
        }
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    return null;
  }

  bool _matchesCuisineType(String filter, List<String> types, String cuisine) {
    // Map common cuisine filters to Google Places types
    final cuisineMapping = {
      'italian': ['italian', 'pizza'],
      'chinese': ['chinese', 'asian'],
      'japanese': ['japanese', 'sushi', 'asian'],
      'indian': ['indian', 'asian'],
      'mexican': ['mexican', 'latin'],
      'thai': ['thai', 'asian'],
      'american': ['american', 'burger', 'fast_food'],
      'french': ['french', 'european'],
      'greek': ['greek', 'mediterranean'],
      'korean': ['korean', 'asian'],
      'vietnamese': ['vietnamese', 'asian'],
      'turkish': ['turkish', 'mediterranean'],
      'lebanese': ['lebanese', 'middle_eastern', 'mediterranean'],
      'spanish': ['spanish', 'european'],
    };

    final mappedTypes = cuisineMapping[filter] ?? [filter];

    for (String mappedType in mappedTypes) {
      if (types.any((type) => type.contains(mappedType)) ||
          cuisine.contains(mappedType)) {
        return true;
      }
    }

    return false;
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> results) {
    return results.where((restaurant) {
      // Price filter
      if (_selectedPriceRange != 'Any') {
        final priceLevel = restaurant['priceLevel'] ?? 2;
        final selectedPrice = _priceOptions.indexOf(_selectedPriceRange);
        if (selectedPrice > 0 && priceLevel != selectedPrice) {
          return false;
        }
      }

      // Cuisine filter
      if (_cuisineFilters.isNotEmpty) {
        final restaurantCuisine = restaurant['cuisine'].toLowerCase();
        final restaurantTypes = (restaurant['types'] as List).map((t) => t.toString().toLowerCase()).toList();

        bool matchesCuisine = false;
        for (String filter in _cuisineFilters) {
          final filterLower = filter.toLowerCase();

          // Check if the filter matches the extracted cuisine
          if (restaurantCuisine.contains(filterLower)) {
            matchesCuisine = true;
            break;
          }

          // Check if the filter matches any of the Google Places types
          if (restaurantTypes.any((type) => type.contains(filterLower))) {
            matchesCuisine = true;
            break;
          }

          // Additional cuisine matching for common terms
          if (_matchesCuisineType(filterLower, restaurantTypes, restaurantCuisine)) {
            matchesCuisine = true;
            break;
          }
        }

        if (!matchesCuisine) return false;
      }

      return true;
    }).toList();
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

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  void _clearFilters() {
    setState(() {
      _cuisineFilters.clear();
      _selectedPriceRange = 'Any';
      _selectedRadius = 5.0;
    });
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
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
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                    if (restaurant['isOpen'] != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: restaurant['isOpen']
                              ? const Color(0xFF39FF6A)
                              : const Color(0xFFFF5FCF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Text(
                          restaurant['isOpen'] ? 'OPEN' : 'CLOSED',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
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
                    Flexible(
                      child: _buildNeoButton(
                        text: 'VIEW DETAILS',
                        color: const Color(0xFF3DDCFF),
                        onPressed: () {
                          _showRestaurantDetails(restaurant);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: _buildNeoButton(
                        text: _isRestaurantFavorited(restaurant['placeId']) ? 'REMOVE' : 'ADD',
                        color: _isRestaurantFavorited(restaurant['placeId'])
                            ? const Color(0xFFFF5FCF)
                            : const Color(0xFF39FF6A),
                        onPressed: () {
                          _toggleFavorite(restaurant);
                        },
                        icon: _isRestaurantFavorited(restaurant['placeId']) ? Icons.favorite : Icons.favorite_border,
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
                    text: _isRestaurantFavorited(restaurant['placeId']) ? 'REMOVE FAVORITE' : 'ADD TO FAVORITE',
                    color: _isRestaurantFavorited(restaurant['placeId'])
                        ? const Color(0xFFFF5FCF)
                        : const Color(0xFF39FF6A),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _toggleFavorite(restaurant);
                    },
                    icon: _isRestaurantFavorited(restaurant['placeId']) ? Icons.favorite : Icons.favorite_border,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

//   void _openDirections(Map<String, dynamic> restaurant) {
//     // This would typically open the maps app with directions
//     // For now, we'll just show a snackbar
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Opening directions to ${restaurant['name']}'),
//         backgroundColor: const Color(0xFF3DDCFF),
//       ),
//     );
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFF4D),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchSection(),
            if (_showFilters) _buildFiltersSection(),
            _buildResultsSection(),
          ],
        ),
      ),
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
            color: Color(0xFF3DDCFF),
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 4),
            ),
          ),
          child: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'SEARCH RESTAURANTS',
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

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search input
          Container(
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
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              onSubmitted: _performSearch,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search for restaurants, cuisine, food...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.black, size: 24),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchResults.clear();
                      _hasSearched = false;
                    });
                  },
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Location input
          Container(
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
            child: TextField(
              controller: _locationController,
              focusNode: _locationFocusNode,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Enter location or use current location',
                hintStyle: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                prefixIcon: const Icon(Icons.location_on, color: Colors.black, size: 24),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location, color: Color(0xFFFF5FCF)),
                  onPressed: () {
                    if (_currentLocation.isNotEmpty) {
                      _locationController.text = _currentLocation;
                    } else {
                      _getCurrentLocation();
                    }
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter and search buttons
          Row(
            children: [
              Expanded(
                child: _buildNeoButton(
                  text: 'FILTERS',
                  color: _showFilters ? const Color(0xFFFF5FCF) : const Color(0xFF39FF6A),
                  onPressed: _toggleFilters,
                  icon: Icons.filter_list,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNeoButton(
                  text: 'SEARCH',
                  color: const Color(0xFF3DDCFF),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      _performSearch(_searchController.text);
                    }
                  },
                  icon: Icons.search,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return AnimatedBuilder(
      animation: _filterAnimation,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _filterAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'FILTERS',
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _clearFilters,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5FCF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Text(
                            'CLEAR',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price Range Filter
                  Text(
                    'Price Range',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _priceOptions.map((price) {
                      final isSelected = _selectedPriceRange == price;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPriceRange = price;
                          });
                          // Remove the condition and always perform search
                          _performSearch(_searchController.text.isEmpty ? 'restaurant' : _searchController.text);
                          // if (_searchController.text.isNotEmpty) {
                          //   _performSearch(_searchController.text);
                          // }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF39FF6A) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Text(
                            price,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Search Radius
                  Text(
                    'Search Radius: ${_selectedRadius.toStringAsFixed(1)} km',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF3DDCFF),
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: const Color(0xFFFF5FCF),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      overlayColor: const Color(0xFFFF5FCF).withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _selectedRadius,
                      min: 1.0,
                      max: 20.0,
                      divisions: 19,
                      onChanged: (value) {
                        setState(() {
                          _selectedRadius = value;
                        });
                      },
                      onChangeEnd: (value) {
                        // if (_searchController.text.isNotEmpty) {
                        //   _performSearch(_searchController.text);
                        // }
                        // Remove the condition and always perform search
                        _performSearch(_searchController.text.isEmpty ? 'restaurant' : _searchController.text);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cuisine Filter
                  Text(
                    'Cuisine Types',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _cuisineOptions.map((cuisine) {
                      final isSelected = _cuisineFilters.contains(cuisine);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _cuisineFilters.remove(cuisine);
                            } else {
                              _cuisineFilters.add(cuisine);
                            }
                          });
                          // Remove the condition and always perform search
                          _performSearch(_searchController.text.isEmpty ? 'restaurant' : _searchController.text);
                          // if (_searchController.text.isNotEmpty) {
                          //   _performSearch(_searchController.text);
                          // }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF3DDCFF) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Text(
                            cuisine,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// 2. Complete the _buildResultsSection() method
  Widget _buildResultsSection() {
    if (_isLoading) {
      return Container(
        height: 200,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Container(
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
              onPressed: () {
                setState(() {
                  _error = '';
                });
                if (_searchController.text.isNotEmpty) {
                  _performSearch(_searchController.text);
                }
              },
            ),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return _buildSearchSuggestions();
    }

    if (_searchResults.isEmpty) {
      return Container(
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
              Icons.search_off,
              color: Colors.black,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'No restaurants found',
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search terms or filters',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildNeoButton(
              text: 'CLEAR SEARCH',
              color: const Color(0xFF3DDCFF),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchResults.clear();
                  _hasSearched = false;
                  _error = '';
                });
              },
            ),
          ],
        ),
      );
    }

    // Calculate available height dynamically
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = 80.0; // Your app bar height
    final searchSectionHeight = _showFilters ? 400.0 : 200.0; // Approximate heights
    final availableHeight = screenHeight - appBarHeight - searchSectionHeight - 60; // 60 for padding

    return Container(
      height: availableHeight > 300 ? availableHeight : 300, // Minimum height of 300
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          return _buildRestaurantCard(_searchResults[index]);
        },
      ),
    );
  }

// 3. Add the search suggestions widget
  Widget _buildSearchSuggestions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SEARCH SUGGESTIONS',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          if (_searchHistory.isNotEmpty) ...[
            Text(
              'Recent Searches',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory.map((term) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = term;
                    _performSearch(term);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3DDCFF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Text(
                      term,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          Text(
            'Popular Cuisines',
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Pizza', 'Sushi', 'Burger', 'Thai', 'Italian', 'Chinese'].map((cuisine) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = cuisine;
                  _performSearch(cuisine);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF39FF6A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Text(
                    cuisine,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}