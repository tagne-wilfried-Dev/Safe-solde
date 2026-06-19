import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget{
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState {
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions(); // charger les transactions sauvegardees au demarrage
  }

  void _addTransaction(Transaction tx) {
    setState(() {
      _transactions.add(tx);
    });
    _saveTransactions(); // sauvegarder les transactions apres l'ajout
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

  void _navigateToAddScreen() async {
    // on wait la transaction que AddTransactionScreen send

    final result = await Navigator.push(context, MaterialPageRoute(builder: (ctx) => AddTransactionScreen()),
    );

    if (result != null && result is Transaction) {
      _addTransaction(result);
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
      if (savedData != null) {
        final List<dynamic> decodedData = json.decode(savedData);
        setState(() {
          _transactions = decodedData.map((item) => Transaction.fromMap(item)).tiList();
        });
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('\$afe💰️olde'),
          backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // widget du solde
          container(
            padding: EdgeInsets.all(20),
            child: Text(
              "Solde: ${_totalBalance.toStringAsFixed(0)}FCFA",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
          ),
          // Liste des transactions
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (ctx, index) {
                final tx = _transactions[index];
                return ListTile(
                  leading: Icon(tx.isIncome ? Icons.add_circle : Icons.remove_circle,
                  color: tx.isIncome ? Colors.green : Colors.red),
                  title: Text(tx.title),
                  trailing: Text("${tx.amount} FCFA"),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _navigateToAddScreen(),
      ),
    );
  }
}