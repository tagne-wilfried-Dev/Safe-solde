import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget{
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState {
  List<Transaction> _transactions = [];

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
      setState(() {
        _transactions.add(result); // on add a la liste et on refresh
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('\$afe\$olde'),
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