
class AddTransactionScreen extends StatefulWidget {
    @override
    _AddTransactionScreenState createState() = _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
    final _titleController = TextEditingController();
    final _amountController = TextEditingController();
    bool _isIncome = true;

    void _submitData() {
        final enteredTitle = _titleController.text;
        final enteredAmount = double.tryParse(_amountController.text) ?? 0;

        // cas de valeurs invalides on sort direct sans rien faire
        if (enteredTitle.isEmpty || enteredAmount <= 0) return;

        //sinon on cree la transaction et on la renvoie au dashboard
        Navigator.of(context).pop(Transaction(
            id: DateTime.now().toString(),
            title: enteredTitle,
            amount: enteredAmount,
            isIncome: isIncome,
            date: DateTime.now(),
        ));
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text("Ajout d'une Operation")
            ),
            body: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                    children: [
                        TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                            labelText: "Titre:"
                            )   
                        ),
                        TextField(
                            controller: _amountController,
                            decoration: InputDecoration(labelText: "Montant:"),
                            keyboardType: TextInputType.number
                        ),
                        SwitchListTile(
                            title: Text(_isIncome ? "C'est une entree" : "c'est une depense"),
                            value: _isIncome,
                            onChanged: (val) => setState(() => _isIncome = val),
                        ),
                        ElevatedButton(
                            onPressed: _submitData,
                            child: Text("Enregistrer✅"))
                    ],
                ),
            ),
        );
    }
}