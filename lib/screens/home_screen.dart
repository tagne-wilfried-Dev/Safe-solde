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
          title: const Text('Safe Solde'),
      ),
      body: Column(
        children: [
          // carte héro du solde : point focal, couleur selon positif/négatif
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
            child: _transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.account_balance_wallet_outlined,
                            size: 72, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('Aucune opération',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey.shade600)),
                        const SizedBox(height: 4),
                        Text(
                            'Appuyez sur + pour ajouter une entrée ou une dépense',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80), // évite que le FAB masque le dernier item
                    itemCount: _transactions.length,
                    itemBuilder: (ctx, index) {
                      final tx = _transactions[index];
                      final color = tx.isIncome
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828);
                      return Dismissible(
                        key: ValueKey(tx.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          setState(() => _transactions.removeAt(index));
                          _saveTransactions();
                        },
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            leading: CircleAvatar(
                              backgroundColor: color.withOpacity(0.12),
                              child: Icon(
                                tx.isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: color,
                              ),
                            ),
                            title: Text(tx.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              DateFormat('dd/MM/yyyy').format(tx.date),
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12),
                            ),
                            trailing: Text(
                              "${tx.isIncome ? '+' : '-'}${tx.amount.toStringAsFixed(0)} FCFA",
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                        ),
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
        label: const Text('Ajouter'),
      ),
    );
  }
}
