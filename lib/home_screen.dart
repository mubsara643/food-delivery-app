import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'menu_screen.dart';
import 'orders_screen.dart';
import 'auth_screen.dart';
import 'owner_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  String _searchQuery = '';

  final categories = [
    'Sab kuch',
    'Ghar ka khana',
    'Fast food',
  ];

  final List<Map<String, dynamic>> prefilledRestaurants = [
    {
      'name': "Baji's Kitchen",
      'description': 'Nihari - Ghar ka khana',
      'category': 'Ghar ka khana',
      'type': 'Home Kitchen',
      'time': '25-35 min',
      'price': 'Rs 400+',
      'rating': '4.9',
      'deliveryFee': 120,
      'imageUrl': '',
    },
    {
      'name': "Amma's Handi",
      'description': 'Karahi - Ghar ka khana',
      'category': 'Ghar ka khana',
      'type': 'Home Kitchen',
      'time': '30-40 min',
      'price': 'Rs 600+',
      'rating': '4.8',
      'deliveryFee': 120,
      'imageUrl': '',
    },
    {
      'name': 'Burger Point',
      'description': 'Burgers - Fast food',
      'category': 'Fast food',
      'type': 'Restaurant',
      'time': '20-30 min',
      'price': 'Rs 450+',
      'rating': '4.7',
      'deliveryFee': 120,
      'imageUrl': '',
    },
    {
      'name': 'Pizza House',
      'description': 'Pizza - Fast food',
      'category': 'Fast food',
      'type': 'Restaurant',
      'time': '25-35 min',
      'price': 'Rs 700+',
      'rating': '4.8',
      'deliveryFee': 120,
      'imageUrl': '',
    },
  ];

  Future<void> openOwnerPanel() async {
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => user == null
            ? const AuthScreen()
            : const OwnerDashboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF1E3B32);
    const cream = Color(0xFFF2ECE1);

    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Gulshan-e-Iqbal - Karachi',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _topIcon(
                    icon: Icons.receipt_long_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OrdersScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, authSnapshot) {
                      final user = authSnapshot.data;

                      if (user == null) {
                        return const SizedBox.shrink();
                      }

                      return StreamBuilder<
                          DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .snapshots(),
                        builder: (context, userSnapshot) {
                          final isOwner =
                              userSnapshot.data?.data()?['role'] == 'owner';

                          if (!isOwner) {
                            return const SizedBox.shrink();
                          }

                          return _topIcon(
                            icon: Icons.storefront_outlined,
                            onTap: openOwnerPanel,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  _topIcon(
                    icon: Icons.person_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AuthScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text(
                'Aaj kya\nkhaayen, Ahmed?',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  decoration: InputDecoration(
                    icon: const Icon(Icons.search),
                    hintText: 'Biryani, karahi, ya koi vendor...',
                    border: InputBorder.none,
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.black38,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, index) {
                    final selected = index == _selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = index);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? darkGreen : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: selected ? darkGreen : Colors.black12,
                          ),
                        ),
                        child: Text(
                          categories[index],
                          style: GoogleFonts.poppins(
                            color: selected ? Colors.white : Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _selectedCategory == 2
                    ? 'Fast food near you'
                    : 'Ghar ka Khana near you',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 14),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('restaurants')
                    .snapshots(),
                builder: (context, snapshot) {
                  final dynamicRestaurants = <Map<String, dynamic>>[];

                  if (snapshot.hasData) {
                    for (final doc in snapshot.data!.docs) {
                      final data = doc.data();
                      dynamicRestaurants.add({
                        ...data,
                        'id': doc.id,
                        'isDynamic': true,
                      });
                    }
                  }

                  final allRestaurants = [
                    ...prefilledRestaurants,
                    ...dynamicRestaurants,
                  ];

                  final filteredRestaurants = allRestaurants.where((r) {
                    final categoryMatch = _selectedCategory == 0 ||
                        (r['category'] ?? '') == categories[_selectedCategory];
                    final searchText = r.values.join(' ').toLowerCase();
                    final searchMatch = searchText.contains(
                      _searchQuery.trim().toLowerCase(),
                    );
                    return categoryMatch && searchMatch;
                  }).toList();

                  if (filteredRestaurants.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No restaurant found',
                          style: GoogleFonts.poppins(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: filteredRestaurants.map((r) {
                      final isDynamic = r['isDynamic'] == true;
                      final restaurantName = (r['name'] ?? 'Restaurant').toString();
                      final description =
                          (r['description'] ?? r['category'] ?? '').toString();
                      final category = (r['category'] ?? 'Other').toString();
                      final time = (r['time'] ?? '25-40 min').toString();
                      final price = (r['price'] ?? 'Menu available').toString();
                      final rating = (r['rating'] ?? '4.8').toString();
                      final fee = (r['deliveryFee'] as num?)?.toInt() ?? 120;
                      final imageUrl = (r['imageUrl'] ?? '').toString();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MenuScreen(
                                  restaurantName: restaurantName,
                                  restaurantId: isDynamic
                                      ? (r['id'] ?? '').toString()
                                      : null,
                                  deliveryFee: fee,
                                  description: description,
                                  imageUrl: imageUrl,
                                ),
                              ),
                            );
                          },
                          child: vendorCard(
                            name: restaurantName,
                            tag: '$category | ${r['type'] ?? 'Restaurant'}',
                            time: time,
                            price: price,
                            rating: rating,
                            deliveryFee: fee,
                            imageUrl: imageUrl,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3B32),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget vendorCard({
    required String name,
    required String tag,
    required String time,
    required String price,
    required String rating,
    required int deliveryFee,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          _vendorImage(imageUrl),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          rating,
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tag,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        time,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      price,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Delivery charges: Rs $deliveryFee',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE58B2A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vendorImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFC96A45),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.restaurant, color: Colors.white),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 50,
          height: 50,
          color: const Color(0xFFC96A45),
          child: const Icon(Icons.restaurant, color: Colors.white),
        ),
      ),
    );
  }
}
