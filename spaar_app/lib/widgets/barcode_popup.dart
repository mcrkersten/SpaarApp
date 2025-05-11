import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class BarcodePopup extends StatelessWidget {
  final Map<String, dynamic> item;

  const BarcodePopup({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final code = item['code'];
    final entryDate = DateTime.parse(item['entryDate']);
    final expirationDate = entryDate.add(const Duration(days: 365));

    return AlertDialog(
      title: const Text("EAN Barcode"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BarcodeWidget(
            barcode: Barcode.ean13(),
            data: code.padLeft(13, '0').substring(0, 13),
            width: 250,
            height: 100,
            drawText: true,
          ),
          const SizedBox(height: 16),
          Text("Code: $code"),
          const SizedBox(height: 8),
          Text("Entry Date: ${entryDate.toLocal().toIso8601String().split('T').first}"),
          Text("Expires: ${expirationDate.toLocal().toIso8601String().split('T').first}"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
