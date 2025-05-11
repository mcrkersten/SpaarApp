import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TotalBalanceCard extends StatefulWidget {
  final VoidCallback onAddPressed;

  const TotalBalanceCard({
    super.key,
    required this.onAddPressed,
  });

  @override
  TotalBalanceCardState createState() => TotalBalanceCardState();
}

class TotalBalanceCardState extends State<TotalBalanceCard> {
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    calculateTotalAmount();
  }

  Future<void> calculateTotalAmount() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesData = prefs.getString('categories');
    double total = 0.0;

    if (categoriesData != null) {
      final categories = (jsonDecode(categoriesData) as List);
      
      for (var category in categories) {
        final categoryName = category['name'];
        final savedItems = prefs.getString(categoryName);

        if (savedItems != null) {
          final items = List<Map<String, dynamic>>.from(jsonDecode(savedItems));
          for (var item in items) {
            total += item['amount'] as double;
          }
        }
      }
    }

    setState(() {
      _totalAmount = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Totaal Statiegeld',
            style: TextStyle(
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
    );
  }
}
