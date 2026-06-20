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
            const SnackBar(
                content:Text("Veuillez remplir correctement les champs")),
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
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Titre:"),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: "Montant:"),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            SwitchListTile(
              title: Text(_isIncome ? "C'est une entree" : "c'est une depense"),
              value: _isIncome,
              onChanged: (val) => setState(() => _isIncome = val),
            ),
            ElevatedButton(onPressed: _submitData, child: Text("Enregistrer✅")),
          ],
        ),
      ),
    );
  }
}
