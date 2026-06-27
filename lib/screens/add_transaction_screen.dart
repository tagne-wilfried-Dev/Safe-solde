import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isIncome = true;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitData() {
    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text) ?? 0;

    // cas de valeurs invalides on sort direct sans rien faire
    if (enteredTitle.isEmpty || enteredAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: const Text('Certains champs sont vides ou mal remplis'),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
            ),
        );
      return;
    }

    //sinon on cree la transaction et on la renvoie au dashboard
    Navigator.of(context).pop(
      Transaction(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        title: enteredTitle,
        amount: enteredAmount,
        isIncome: _isIncome,
        date: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajout d'une Operation")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Titre',
                hintText: 'Salaire; Loyer…',
                prefixIcon: Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Montant',
                suffixText: 'FCFA',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            const SizedBox(height: 16),
            // Sélecteur entrée/dépense explicite (Material 3)
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                    value: true,
                    label: Text('Entrée'),
                    icon: Icon(Icons.trending_up)),
                ButtonSegment(
                    value: false,
                    label: Text('Dépense'),
                    icon: Icon(Icons.trending_down)),
              ],
              selected: {_isIncome},
              onSelectionChanged: (s) => setState(() => _isIncome = s.first),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _submitData,
              icon: const Icon(Icons.check),
              label: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
