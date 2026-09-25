import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart_page.dart';

final List<MenuItem> cartItems = [];

class MenuItem {
  final String name;
  final String description;
  final int price;
  String restaurantId;
  String restaurantName;
  int deliveryFee;
  int quantity;

  MenuItem({
    required this.name,
    required this.description,
    required this.price,
    this.restaurantId = '',
    this.restaurantName = '',
    this.deliveryFee = 120,
    this.quantity = 0,
  });
}

class MenuScreen extends StatefulWidget {
  final String restaurantName;
  final String? restaurantId;
  final int deliveryFee;
  final String description;
  final String imageUrl;

  const MenuScreen({
    super.key,
    this.restaurantName = "Baji's Kitchen",
    this.restaurantId,
    this.deliveryFee = 120,
    this.description = '',
    this.imageUrl = '',
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuItem> items = [];
  bool loading = true;
  String currentName = '';
  String currentDescription = '';
  int currentDeliveryFee = 120;
  String currentImageUrl = '';

  @override
  void initState() {
    super.initState();
    currentName = widget.restaurantName;
    currentDescription = widget.description;
    currentDeliveryFee = widget.deliveryFee;
    currentImageUrl = widget.imageUrl;

    if (widget.restaurantId != null && widget.restaurantId!.isNotEmpty) {
      loadDynamicMenu();
    } else {
      loadStaticMenu();
    }
  }

  void loadStaticMenu() {
    if (widget.restaurantName == "Amma's Handi") {
      items = [
        MenuItem(
          name: 'Chicken Karahi',
          description: 'Fresh desi chicken karahi',
          price: 750,
        ),
        MenuItem(
          name: 'Mutton Karahi',
          description: 'Traditional mutton karahi',
          price: 1100,
        ),
        MenuItem(
          name: 'Roti',
          description: 'Fresh tandoori roti',
          price: 30,
        ),
        MenuItem(
          name: 'Raita',
          description: 'Creamy homemade raita',
          price: 100,
        ),
      ];
    } else if (widget.restaurantName == 'Burger Point') {
      items = [
        MenuItem(
          name: 'Zinger Burger',
          description: 'Crispy chicken burger',
          price: 450,
        ),
        MenuItem(
          name: 'Beef Burger',
          description: 'Juicy beef patty burger',
          price: 550,
        ),
        MenuItem(
          name: 'Loaded Fries',
          description: 'Fries with cheese and sauce',
          price: 300,
        ),
        MenuItem(
          name: 'Cold Drink',
          description: 'Chilled soft drink',
          price: 100,
        ),
      ];
    } else if (widget.restaurantName == 'Pizza House') {
      items = [
        MenuItem(
          name: 'Chicken Pizza',
          description: 'Chicken tikka with cheese',
          price: 900,
        ),
        MenuItem(
          name: 'Cheese Pizza',
          description: 'Extra cheesy pizza',
          price: 850,
        ),
        MenuItem(
          name: 'Garlic Bread',
          description: 'Fresh garlic bread',
          price: 300,
        ),
        MenuItem(
          name: 'Cold Drink',
          description: 'Chilled soft drink',
          price: 100,
        ),
      ];
    } else {
      items = [
        MenuItem(
          name: 'Beef Nihari',
          description: 'Slow-cooked overnight, served with naan',
          price: 550,
        ),
        MenuItem(
          name: 'Nihari Special',
          description: 'Extra maghaz aur nalli ke sath',
          price: 700,
        ),
        MenuItem(
          name: 'Plain Naan',
          description: 'Tandoor se seedha, garma garam',
          price: 40,
        ),
        MenuItem(
          name: 'Kheer',
          description: 'Ghar ki bani meethi kheer',
          price: 150,
        ),
      ];
    }

    currentDeliveryFee = widget.deliveryFee;
    applyRestaurantMeta();
    loading = false;
    setState(() {});
  }

  Future<void> loadDynamicMenu() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .get();

      if (!doc.exists) {
        if (!mounted) return;
        setState(() => loading = false);
        return;
      }

      final data = doc.data()!;
      currentName = (data['name'] ?? widget.restaurantName).toString();
      currentDescription = (data['description'] ?? '').toString();
      currentImageUrl = (data['imageUrl'] ?? '').toString();
      currentDeliveryFee = (data['deliveryFee'] as num?)?.toInt() ?? 120;

      final rawMenu = data['menuItems'];
      final loadedItems = <MenuItem>[];

      if (rawMenu is List) {
        for (final raw in rawMenu) {
          if (raw is Map) {
            loadedItems.add(
              MenuItem(
                name: (raw['name'] ?? 'Item').toString(),
                description: (raw['description'] ?? '').toString(),
                price: (raw['price'] as num?)?.toInt() ?? 0,
              ),
            );
          }
        }
      }

      items = loadedItems;
      applyRestaurantMeta();
    } catch (_) {
      items = [];
    }

    if (!mounted) return;
    setState(() => loading = false);
  }

  void applyRestaurantMeta() {
    for (final item in items) {
      item.restaurantId = widget.restaurantId ?? currentName;
      item.restaurantName = currentName;
      item.deliveryFee = currentDeliveryFee;
    }
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice =>
      items.fold(0, (sum, item) => sum + item.quantity * item.price);

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF1E3B32);
    const cream = Color(0xFFF2ECE1);
    const orange = Color(0xFFE0A339);

    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentName,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: darkGreen,
                          ),
                        ),
                        if (currentDescription.isNotEmpty)
                          Text(
                            currentDescription,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        Text(
                          'Delivery charges: Rs $currentDeliveryFee',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE58B2A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _headerImage(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? Center(
                          child: Text(
                            'No menu items available',
                            style: GoogleFonts.poppins(color: Colors.black54),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.description,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Rs ${item.price}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: darkGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  item.quantity == 0
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              item.quantity = 1;
                                              if (!cartItems.contains(item)) {
                                                cartItems.add(item);
                                              }
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: darkGreen,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'Add',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: darkGreen,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    item.quantity--;
                                                    if (item.quantity == 0) {
                                                      cartItems.remove(item);
                                                    }
                                                  });
                                                },
                                                child: const Icon(
                                                  Icons.remove,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 24,
                                                child: Text(
                                                  '${item.quantity}',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(
                                                    () => item.quantity++,
                                                  );
                                                },
                                                child: const Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: totalItems == 0
          ? null
          : Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: darkGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$totalItems item${totalItems > 1 ? 's' : ''} | Rs $totalPrice',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CartScreen(items: items),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'View cart',
                          style: GoogleFonts.poppins(
                            color: orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          color: orange,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _headerImage() {
    if (currentImageUrl.isEmpty) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE8C8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.restaurant,
          color: Color(0xFFE58B2A),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        currentImageUrl,
        width: 42,
        height: 42,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 42,
          height: 42,
          color: const Color(0xFFFFE8C8),
          child: const Icon(
            Icons.restaurant,
            color: Color(0xFFE58B2A),
          ),
        ),
      ),
    );
  }
}
