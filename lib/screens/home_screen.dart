
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
    _saveTransactions(); // sauvegarder les transactions apres L'Amour
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
      try{
        final List<dynamic> decodedData = json.decode(savedData);
        final loaded = decodedData.map((item) => Transaction.fromMap(item as Map<String, dynamic>)).toList();
        if (!mounted) return;
        setState(() => _transactions = loaded);
      } catch(e) {
        debugPrint('Donnees corrompues,Reinitialisation : $e');
        await prefs.remove('user_transactions');// on supprime pour eviter un crash en boucle
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
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _totalBalance >= 0
                    ? [const Color(0xFF1C4D1E), const Color(0xFF2E7D32)]
                    : [const Color(0xFF8E2A2A), const Color(0xFFB71C1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Solde actuel',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  '${_totalBalance.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Liste des transactions
          Expanded(
            child: _transactions.isEmpty ? const Center(
              child: Text('Aucune operation pour le moment.\n Appuyez sur ➕ pour enregistrer votre premiere transaction.',
              textAlign: TextAlign.center))
            : ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (ctx, index) {
                final tx = _transactions[index];
                final color = tx.isIncome ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
                // on wrap listTile dans un Dismissible pour permettre la suppression au glisser
                return Dismissible(
                    key: ValueKey(tx.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete,color: Colors.white),
                    ),
                    onDismissed: (_) {
                      setState(() {
                        _transactions.removeAt(index);
                      });
                      _saveTransactions();
                    },
                    child: ListTile(
                      leading: Icon(tx.isIncome ? Icons.add_circle : Icons.remove_circle,
                      color: tx.isIncome ? Colors.green : Colors.red),
                      title: Text(tx.title),
                      trailing: Text("${tx.isIncome ? '+':'-'}${tx.amount.toStringAsFixed(0)} FCFA"),
                      subtitle:DateFormat('dd/MM/yyyy').format(tx.date),
                )
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateAdd,
        backgroundColor: const Color(0xFF1C4D1E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Transaction'),
      ),
    );
  }
}