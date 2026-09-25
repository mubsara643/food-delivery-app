import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final int subtotal;
  final int deliveryFee;
  final int total;

  const CheckoutScreen({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final instructionsController = TextEditingController();

  String paymentMethod = 'Cash on Delivery';
  bool placingOrder = false;

  @override
  void initState() {
    super.initState();
    loadSavedDetails();
  }

  Future<void> loadSavedDetails() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    nameController.text = prefs.getString('customer_name') ?? '';
    phoneController.text = prefs.getString('customer_phone') ?? '';
    addressController.text = prefs.getString('customer_address') ?? '';
    instructionsController.text =
        prefs.getString('customer_instructions') ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    instructionsController.dispose();
    super.dispose();
  }

  Future<void> placeOrder() async {
    if (placingOrder) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      placingOrder = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'customer_name',
        nameController.text.trim(),
      );
      await prefs.setString(
        'customer_phone',
        phoneController.text.trim(),
      );
      await prefs.setString(
        'customer_address',
        addressController.text.trim(),
      );
      await prefs.setString(
        'customer_instructions',
        instructionsController.text.trim(),
      );

      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user?.uid,
        'customerName': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'instructions': instructionsController.text.trim(),
        'paymentMethod': paymentMethod,
        'subtotal': widget.subtotal,
        'deliveryFee': widget.deliveryFee,
        'total': widget.total,
        'status': 'Order Placed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(
            total: widget.total,
            customerName: nameController.text.trim(),
            phone: phoneController.text.trim(),
            address: addressController.text.trim(),
            paymentMethod: paymentMethod,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        placingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order save nahi ho saka: $e'),
        ),
      );
    }
  }

  InputDecoration decoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2ECE1),
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF1E3B32),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Delivery Information',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: nameController,
              decoration: decoration(
                'Full Name',
                Icons.person_outline,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: decoration(
                'Phone Number',
                Icons.phone_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: addressController,
              maxLines: 2,
              decoration: decoration(
                'Delivery Address',
                Icons.location_on_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your delivery address';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: instructionsController,
              maxLines: 2,
              decoration: decoration(
                'Delivery Instructions (Optional)',
                Icons.note_alt_outlined,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: Radio<String>(
                  value: 'Cash on Delivery',
                  groupValue: paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      paymentMethod = value!;
                    });
                  },
                ),
                title: const Text(
                  'Cash on Delivery',
                  overflow: TextOverflow.ellipsis,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: Radio<String>(
                  value: 'Card',
                  groupValue: paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      paymentMethod = value!;
                    });
                  },
                ),
                title: const Text(
                  'Card',
                  overflow: TextOverflow.ellipsis,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    summaryRow(
                      'Subtotal',
                      'Rs. ${widget.subtotal}',
                    ),
                    const SizedBox(height: 12),
                    summaryRow(
                      'Delivery Fee',
                      'Rs. ${widget.deliveryFee}',
                    ),
                    const Divider(height: 24),
                    summaryRow(
                      'Total',
                      'Rs. ${widget.total}',
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.delivery_dining_rounded,
                      color: Color(0xFFE0A339),
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Delivery Fee: Rs. ${widget.deliveryFee}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: placingOrder ? null : placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3B32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: placingOrder
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget summaryRow(
    String label,
    String value, {
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}


