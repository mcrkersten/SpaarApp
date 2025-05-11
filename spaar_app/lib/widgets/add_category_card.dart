import 'package:flutter/material.dart';
import 'package:spaar_app/home.dart';

class AddCategoryCard extends StatefulWidget {
  final double width;
  final Function(Category) onCategoryAdded;

  const AddCategoryCard({
    super.key,
    required this.width,
    required this.onCategoryAdded,
  });

  @override
  State<AddCategoryCard> createState() => _AddCategoryCardState();
}

class _AddCategoryCardState extends State<AddCategoryCard> {
  Future<void> _showAddCategoryDialog() async {
    final nameController = TextEditingController();
    Color? selectedColor;

    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nieuwe Categorie"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Categorie Naam',
                    ),
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
                        Colors.red
                      ])
                        GestureDetector(
                          onTap: () {
                            setState(() => selectedColor = color);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color
                                    ? Colors.black
                                    : Colors.transparent,
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
                final name = nameController.text.trim();
                if (name.isNotEmpty && selectedColor != null) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text("Opslaan"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final name = nameController.text.trim();
      if (name.isNotEmpty && selectedColor != null) {
        widget.onCategoryAdded(Category(name: name, color: selectedColor!));
      }
    }
  }

 @override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: _showAddCategoryDialog,
    child: Container(
      width: widget.width,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Text Section
          const Text(
            "Nieuwe Categorie",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Add Button (Matching Category Style)
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, size: 28, color: Colors.black),
          ),
        ],
      ),
    ),
  );
}

}
