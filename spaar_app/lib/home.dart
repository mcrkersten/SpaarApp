import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spaar_app/widgets/add_category_card.dart';
import 'package:spaar_app/widgets/custom_app_bar.dart';
import 'widgets/category_card.dart';
import 'widgets/total_balance_card.dart';
import 'category_items_page.dart';

class Category {
  final String name;
  final Color color;

  Category({required this.name, required this.color});

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color.value,
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        name: json['name'],
        color: Color(json['color']),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Category> _categories = [];
  final GlobalKey<TotalBalanceCardState> _totalBalanceKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('categories');
    if (savedData != null) {
      setState(() {
        _categories = (jsonDecode(savedData) as List)
            .map((item) => Category.fromJson(item))
            .toList();
      });
    }
  }

  void _updateTotalBalance() {
    _totalBalanceKey.currentState?.calculateTotalAmount();
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width - 32;

    return Scaffold(
      appBar: const CustomAppBar(username: 'Max'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          TotalBalanceCard(
            key: _totalBalanceKey,
            onAddPressed: _updateTotalBalance,
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _categories.length; i++)
            CategoryCard(
              width: cardWidth,
              label: _categories[i].name,
              color: _categories[i].color,
              onAddPressed: () {
                final oldName = _categories[i].name;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryItemsPage(
                      categoryName: _categories[i].name,
                      color: _categories[i].color,
                      onCategoryDeleted: _removeCategory,
                    ),
                  ),
                ).then((updatedCategory) async {
                  if (updatedCategory != null) {
                    final newName = updatedCategory['name'];
                    final newColor = Color(updatedCategory['color']);

                    // Update the category in memory
                    setState(() {
                      _categories[i] = Category(
                        name: newName,
                        color: newColor,
                      );
                    });

                    // Save the updated categories list
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString(
                      'categories',
                      jsonEncode(_categories.map((c) => c.toJson()).toList()),
                    );

                    // Move the items if the name changed
                    if (oldName != newName) {
                      final oldItems = prefs.getString(oldName);
                      if (oldItems != null) {
                        prefs.remove(oldName);
                        prefs.setString(newName, oldItems);
                      }
                    }
                  }
                });
              },
              onCategoryDeleted: _removeCategory,
            ),
          AddCategoryCard(
            width: cardWidth,
            onCategoryAdded: (category) {
              _addCategory(category);
              _updateTotalBalance();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addCategory(Category category) async {
    setState(() {
      _categories.add(category);
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'categories',
      jsonEncode(_categories.map((c) => c.toJson()).toList()),
    );
  }

  Future<void> _removeCategory(String categoryName) async {
    setState(() {
      _categories.removeWhere((c) => c.name == categoryName);
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'categories',
      jsonEncode(_categories.map((c) => c.toJson()).toList()),
    );
  }
}
