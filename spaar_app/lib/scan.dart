import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/amount_input_dialog.dart';

class ScanPage extends StatefulWidget {
  final String categoryName;
  final Color categoryColor;
  final VoidCallback onScanComplete;

  const ScanPage({
    super.key,
    required this.categoryName,
    required this.categoryColor,
    required this.onScanComplete,
  });

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();

    // Properly initialize the camera
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _scannerController.start();
      setState(() {
        _isCameraInitialized = true;
      });
    });
  }

  Future<void> _saveScannedItem(String code, double amount) async {
    final now = DateTime.now();
    final item = {
      'code': code,
      'amount': amount,
      'entryDate': now.toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(widget.categoryName);
    List<Map<String, dynamic>> items = [];

    if (savedData != null) {
      items = List<Map<String, dynamic>>.from(jsonDecode(savedData));
    }

    items.add(item);
    prefs.setString(widget.categoryName, jsonEncode(items));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item saved successfully!')),
    );

    if (mounted) {
      widget.onScanComplete();
      Navigator.pop(context);
    }
  }

  Future<void> _showAmountDialog(String code) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AmountInputDialog(
          code: code,
          onSave: (amount) {
            _saveScannedItem(code, amount);
            Navigator.of(context).pop(); // Close the dialog
          },
        );
      },
    );

    _scannerController.start();
  }

  Future<void> _showManualEntryDialog() async {
    final codeController = TextEditingController();
    final amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Handmatige Invoer"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Code',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Bedrag (€)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuleren"),
            ),
            ElevatedButton(
              onPressed: () {
                final code = codeController.text.trim();
                final amountText = amountController.text.trim();
                final amount = double.tryParse(amountText) ?? 0.0;

                if (code.isNotEmpty && amount > 0) {
                  _saveScannedItem(code, amount);
                  Navigator.pop(context);
                }
              },
              child: const Text("Opslaan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.categoryColor,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.barcode_reader),
            const SizedBox(width: 8),
            Text('Scan in ${widget.categoryName}'),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Barcode Scanner
          if (_isCameraInitialized)
            MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    final code = barcode.rawValue!;
                    _scannerController.stop();
                    _showAmountDialog(code);
                    break;
                  }
                }
              },
            )
          else
            const Center(child: CircularProgressIndicator()),
          // Manual Entry Button
          Positioned(
            bottom: 32,
            right: 32,
            child: GestureDetector(
              onTap: _showManualEntryDialog,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: widget.categoryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.categoryColor.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}
