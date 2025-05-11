import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/scanned_item_list.dart';
import 'widgets/barcode_popup.dart';

class CategoryItemsPage extends StatefulWidget {
  final String categoryName;
  final Color color;
  final ValueChanged<String> onCategoryDeleted;

  const CategoryItemsPage({
    super.key,
    required this.categoryName,
    required this.color,
    required this.onCategoryDeleted,
  });

  @override
  State<CategoryItemsPage> createState() => _CategoryItemsPageState();
}

class _CategoryItemsPageState extends State<CategoryItemsPage> {
  List<Map<String, dynamic>> _items = [];
  String _categoryName = '';
  Color _categoryColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _categoryName = widget.categoryName;
    _categoryColor = widget.color;
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_categoryName);
    if (savedData != null) {
      setState(() {
        _items = List<Map<String, dynamic>>.from(jsonDecode(savedData));
      });
    }
  }

  Future<void> _saveCategory(String oldName) async {
    final prefs = await SharedPreferences.getInstance();

    // Update the main categories list
    final categoriesData = prefs.getString('categories');
    if (categoriesData != null) {
      final categories = (jsonDecode(categoriesData) as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final index = categories.indexWhere((c) => c['name'] == oldName);
      if (index != -1) {
        categories[index]['name'] = _categoryName;
        categories[index]['color'] = _categoryColor.value;
        prefs.setString('categories', jsonEncode(categories));
      }
    }

    // Move the items if the name changed
    if (oldName != _categoryName) {
      final oldItems = prefs.getString(oldName);
      if (oldItems != null) {
        prefs.remove(oldName);
        prefs.setString(_categoryName, oldItems);
      }
    }
  }

  Future<void> _showEditDialog() async {
  final nameController = TextEditingController(text: _categoryName);
  Color selectedColor = _categoryColor;
  final oldName = _categoryName;

  final result = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Bewerk Categorie"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Categorie Naam'),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var color in [
                      Colors.blue,
                      Colors.purple,
                      Colors.orange,
                      Colors.green,
                      Colors.red,
                      Colors.grey,
                    ])
                      GestureDetector(
                        onTap: () {
                          // Update the local dialog state
                          setState(() {});
                          // Update the parent state
                          this.setState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColor == color ? Colors.black : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuleren"),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                // Update the main state
                setState(() {
                  _categoryName = newName;
                  _categoryColor = selectedColor;
                });

                // Save the changes
                _saveCategory(oldName);

                // Close the dialog
                Navigator.pop(context, true);
              }
            },
            child: const Text("Opslaan"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            child: const Text(
              "Verwijderen",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );

  if (result == 'delete') {
    _deleteCategory();
  }
}


  Future<void> _deleteCategory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(widget.categoryName);

    final categoriesData = prefs.getString('categories');
    if (categoriesData != null) {
      final categories = (jsonDecode(categoriesData) as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      categories.removeWhere((c) => c['name'] == widget.categoryName);
      prefs.setString('categories', jsonEncode(categories));
    }

    // Notify HomePage about the deletion
    widget.onCategoryDeleted(widget.categoryName);

    Navigator.pop(context); // Go back to HomePage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _categoryColor,
        title: Text(_categoryName),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, {
              'name': _categoryName,
              'color': _categoryColor.value,
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
          ),
        ],
      ),
      body: ScannedItemList(
        items: _items,
        onItemTap: (item) {
          showDialog(
            context: context,
            builder: (context) => BarcodePopup(item: item),
          );
        },
        onDelete: (index) async {
          setState(() {
            _items.removeAt(index);
          });
          final prefs = await SharedPreferences.getInstance();
          prefs.setString(_categoryName, jsonEncode(_items));
        },
      ),
    );
  }
}
