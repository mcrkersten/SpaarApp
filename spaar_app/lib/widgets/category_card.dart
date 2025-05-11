import 'dart:convert';
import 'package:flutter/material.dart';
import '../category_items_page.dart';
import '../scan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryCard extends StatefulWidget {
  final String label;
  final Color color;
  final double width;
  final VoidCallback onAddPressed;
  final ValueChanged<String> onCategoryDeleted;

  const CategoryCard({
    super.key,
    required this.label,
    required this.color,
    required this.width,
    required this.onAddPressed,
    required this.onCategoryDeleted,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotalAmount();
  }

  Future<void> _calculateTotalAmount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(widget.label);
    double total = 0.0;

    if (savedData != null) {
      final items = List<Map<String, dynamic>>.from(jsonDecode(savedData));
      for (var item in items) {
        total += item['amount'] as double;
      }
    }

    setState(() {
      _totalAmount = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryItemsPage(
              categoryName: widget.label,
              color: widget.color,
              onCategoryDeleted: (deletedCategory) {
                widget.onCategoryDeleted(deletedCategory);
              },
            ),
          ),
        ).then((_) {
          _calculateTotalAmount();
        });
      },
      child: Container(
        width: widget.width,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '€${_totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScanPage(
                      categoryName: widget.label,
                      categoryColor: widget.color,
                      onScanComplete: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryItemsPage(
                              categoryName: widget.label,
                              color: widget.color,
                              onCategoryDeleted: (deletedCategory) {
                                widget.onCategoryDeleted(deletedCategory);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 28, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
