import 'package:flutter/material.dart';

class AmountInputDialog extends StatelessWidget {
  final String code;
  final ValueChanged<double> onSave;

  const AmountInputDialog({
    super.key,
    required this.code,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController amountController = TextEditingController();

    return AlertDialog(
      title: const Text('Voer bedrag in'),
      content: TextField(
        controller: amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Bedrag (e.g., 2.50)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
        ElevatedButton(
          onPressed: () {
            final amountText = amountController.text.trim();
            if (amountText.isNotEmpty) {
              try {
                final amount = double.parse(amountText);
                onSave(amount);
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ongeldig bedrag')),
                );
              }
            }
          },
          child: const Text('Opslaan'),
        ),
      ],
    );
  }
}
