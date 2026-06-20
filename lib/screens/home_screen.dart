import 'package:flutter/material.dart';
import 'package:safe_solde/models/transaction.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState  extends State<HomeScreen>{
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions(); // charger les transactions sauvegardees au demarrage
  }



  double get _totalBalance {
    double total = 0;
    for (var tx in _transactions) {
      if(tx.isIncome == true) {
        total += tx.amount;
      } else {
        total -= tx.amount;
      }
    }
    return total;
  }

  void _navigateAdd() async {
    // on wait la transaction que AddTransactionScreen send

    final result = await Navigator.pushNamed(context,'/add');

    if (result != null && result is Transaction) {
      setState(() {
      _transactions.add(result);
    });
    _saveTransactions(); // sauvegarder les transactions apres l'ajout
    }
  }

  // logique de sauvegarde pour la persistance des donnees
    Future<void> _saveTransactions() async {
        final prefs = await SharedPreferences.getInstance();
        // On transforme la liste d'objets en liste de maps, puis en json
        final String encodedData = json.encode(_transactions.map((tx) => tx.toMap()).toList());
        await prefs.setString('user_transactions', encodedData);
    }

    // chargemen au demarrage
    Future<void> _loadTransactions() async {
      final prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString('user_transactions');
      if (savedData == null) return;
      try {
        final List<dynamic> decodedData = json.decode(savedData);
        final loaded = decodedData
            .map((item) => Transaction.fromMap(item as Map<String, dynamic>))
            .toList();
        if (!mounted) return;
        setState(() => _transactions = loaded);
      } catch (e) {
        debugPrint('Données corrompues, réinitialisation : $e');
        await prefs.remove('user_transactions'); // évite un crash en boucle
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('\$afe💰️olde'),
      ),
      body: Column(
        children: [
          // widget du solde
          Container(
            padding: EdgeInsets.all(20),
            child: Text(
              "Solde: ${_totalBalance.toStringAsFixed(0)}FCFA",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
          ),
          // Liste des transactions
          Expanded(
            child: _transactions.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune opération pour le moment.\nAppuyez sur + pour commencer.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (ctx, index) {
                      final tx = _transactions[index];
                      return Dismissible(
                        key: ValueKey(tx.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          setState(() => _transactions.removeAt(index));
                          _saveTransactions();
                        },
                        child: ListTile(
                          leading: Icon(
                            tx.isIncome ? Icons.add_circle : Icons.remove_circle,
                            color: tx.isIncome ? Colors.green : Colors.red,
                          ),
                          title: Text(tx.title),
                          subtitle: Text(DateFormat('dd/MM/yyyy').format(tx.date)),
                          trailing: Text(
                            "${tx.isIncome ? '+' : '-'}${tx.amount.toStringAsFixed(0)} FCFA",
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add,color:Colors.white),
        onPressed: () => _navigateAdd(),
        backgroundColor: const Color.fromARGB(255, 122, 61, 3),
      ),
    );
  }
}
