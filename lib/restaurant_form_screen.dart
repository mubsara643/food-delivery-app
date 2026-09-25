import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RestaurantFormScreen extends StatefulWidget {
  final String? restaurantId;
  final Map<String, dynamic>? initialData;

  const RestaurantFormScreen({
    super.key,
    this.restaurantId,
    this.initialData,
  });

  bool get isEditing => restaurantId != null;

  @override
  State<RestaurantFormScreen> createState() => _RestaurantFormScreenState();
}

class _RestaurantFormScreenState extends State<RestaurantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageUrlController = TextEditingController();
  final addressController = TextEditingController();
  final deliveryFeeController = TextEditingController(text: '120');

  String type = 'Restaurant';
  String category = 'Ghar ka khana';
  bool saving = false;
  final List<_MenuEditor> menuEditors = [];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;

    if (data != null) {
      nameController.text = (data['name'] ?? '').toString();
      descriptionController.text = (data['description'] ?? '').toString();
      imageUrlController.text = (data['imageUrl'] ?? '').toString();
      addressController.text = (data['address'] ?? '').toString();
      deliveryFeeController.text =
          ((data['deliveryFee'] as num?)?.toInt() ?? 120).toString();
      type = (data['type'] ?? 'Restaurant').toString();
      category = (data['category'] ?? 'Ghar ka khana').toString();

      final menu = data['menuItems'];
      if (menu is List) {
        for (final raw in menu) {
          if (raw is Map) {
            menuEditors.add(
              _MenuEditor(
                name: (raw['name'] ?? '').toString(),
                description: (raw['description'] ?? '').toString(),
                price: ((raw['price'] as num?)?.toInt() ?? 0).toString(),
              ),
            );
          }
        }
      }
    }

    if (menuEditors.isEmpty) {
      menuEditors.add(_MenuEditor());
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    addressController.dispose();
    deliveryFeeController.dispose();
    for (final editor in menuEditors) {
      editor.dispose();
    }
    super.dispose();
  }

  Future<void> saveRestaurant() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first.')),
      );
      return;
    }

    for (final editor in menuEditors) {
      if (editor.name.text.trim().isEmpty ||
          int.tryParse(editor.price.text.trim()) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Har menu item ka name aur valid price enter karein.'),
          ),
        );
        return;
      }
    }

    setState(() => saving = true);

    try {
      final menuItems = menuEditors.map((editor) {
        return {
          'name': editor.name.text.trim(),
          'description': editor.description.text.trim(),
          'price': int.parse(editor.price.text.trim()),
        };
      }).toList();

      final payload = <String, dynamic>{
        'ownerId': user.uid,
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'imageUrl': imageUrlController.text.trim(),
        'type': type,
        'category': category,
        'address': addressController.text.trim(),
        'deliveryFee': int.parse(deliveryFeeController.text.trim()),
        'menuItems': menuItems,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final collection = FirebaseFirestore.instance.collection('restaurants');

      if (widget.isEditing) {
        await collection.doc(widget.restaurantId).update(payload);
      } else {
        payload['createdAt'] = FieldValue.serverTimestamp();
        await collection.add(payload);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Restaurant updated successfully.'
                : 'Restaurant created successfully.',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save restaurant: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF1E3B32);
    const cream = Color(0xFFF2ECE1);
    const orange = Color(0xFFE58B2A);

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Restaurant' : 'Create Restaurant',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        backgroundColor: cream,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            _label('Business type'),
            DropdownButtonFormField<String>(
              value: type,
              decoration: _inputDecoration(),
              items: const [
                DropdownMenuItem(
                  value: 'Restaurant',
                  child: Text('Restaurant'),
                ),
                DropdownMenuItem(
                  value: 'Home Kitchen',
                  child: Text('Home Kitchen'),
                ),
              ],
              onChanged: saving ? null : (value) => setState(() => type = value!),
            ),
            const SizedBox(height: 14),
            _label('Name'),
            TextFormField(
              controller: nameController,
              enabled: !saving,
              decoration: _inputDecoration(hint: 'Baji Kitchen'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Name required hai'
                  : null,
            ),
            const SizedBox(height: 14),
            _label('Description'),
            TextFormField(
              controller: descriptionController,
              enabled: !saving,
              maxLines: 3,
              decoration: _inputDecoration(
                hint: 'Apne business ke bare mein short description',
              ),
            ),
            const SizedBox(height: 14),
            _label('Image URL'),
            TextFormField(
              controller: imageUrlController,
              enabled: !saving,
              keyboardType: TextInputType.url,
              decoration: _inputDecoration(
                hint: 'https://example.com/food.jpg',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Public image link paste karein. Agar blank ho to default restaurant icon show hoga.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 14),
            _label('Category'),
            DropdownButtonFormField<String>(
              value: category,
              decoration: _inputDecoration(),
              items: const [
                DropdownMenuItem(
                  value: 'Ghar ka khana',
                  child: Text('Ghar ka khana'),
                ),
                DropdownMenuItem(
                  value: 'Fast food',
                  child: Text('Fast food'),
                ),
                DropdownMenuItem(
                  value: 'BBQ',
                  child: Text('BBQ'),
                ),
                DropdownMenuItem(
                  value: 'Bakery',
                  child: Text('Bakery'),
                ),
                DropdownMenuItem(
                  value: 'Desserts',
                  child: Text('Desserts'),
                ),
              ],
              onChanged: saving ? null : (value) => setState(() => category = value!),
            ),
            const SizedBox(height: 14),
            _label('Address / Location'),
            TextFormField(
              controller: addressController,
              enabled: !saving,
              maxLines: 2,
              decoration: _inputDecoration(
                hint: 'Gulshan-e-Iqbal, Karachi',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Address required hai'
                  : null,
            ),
            const SizedBox(height: 14),
            _label('Delivery fee'),
            TextFormField(
              controller: deliveryFeeController,
              enabled: !saving,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                hint: '120',
                prefixText: 'Rs ',
              ),
              validator: (value) {
                final fee = int.tryParse(value?.trim() ?? '');
                if (fee == null || fee < 0) {
                  return 'Valid delivery fee enter karein';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Menu items',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: darkGreen,
                  ),
                ),
                TextButton.icon(
                  onPressed: saving
                      ? null
                      : () {
                          setState(() {
                            menuEditors.add(_MenuEditor());
                          });
                        },
                  icon: const Icon(Icons.add),
                  label: const Text('Add item'),
                  style: TextButton.styleFrom(foregroundColor: darkGreen),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...List.generate(menuEditors.length, (index) {
              final editor = menuEditors[index];
              return _menuEditorCard(editor, index, orange, saving);
            }),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: saving ? null : saveRestaurant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.isEditing
                            ? 'Update Restaurant'
                            : 'Create Restaurant',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuEditorCard(
    _MenuEditor editor,
    int index,
    Color orange,
    bool disabled,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Item ${index + 1}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
              ),
              if (menuEditors.length > 1)
                IconButton(
                  onPressed: disabled
                      ? null
                      : () {
                          setState(() {
                            final removed = menuEditors.removeAt(index);
                            removed.dispose();
                          });
                        },
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.redAccent,
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: editor.name,
            enabled: !disabled,
            decoration: _inputDecoration(hint: 'Beef Nihari'),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: editor.description,
            enabled: !disabled,
            decoration: _inputDecoration(hint: 'Short item description'),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: editor.price,
            enabled: !disabled,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(
              hint: '550',
              prefixText: 'Rs ',
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E3B32),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1E3B32)),
      ),
    );
  }
}

class _MenuEditor {
  final TextEditingController name;
  final TextEditingController description;
  final TextEditingController price;

  _MenuEditor({
    String name = '',
    String description = '',
    String price = '',
  })  : name = TextEditingController(text: name),
        description = TextEditingController(text: description),
        price = TextEditingController(text: price);

  void dispose() {
    name.dispose();
    description.dispose();
    price.dispose();
  }
}
