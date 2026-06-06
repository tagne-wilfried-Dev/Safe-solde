import 'package:flutter/material.dart';

void main() {
  runApp(const SafeSoldeApp());
}

// --- MODÈLE DE DONNÉES ---
class Transaction {
  final String title;
  final double amount;
  final bool isIncome; // true = Entrée, false = Dépense
  final DateTime date;

  Transaction({required this.title, required this.amount, required this.isIncome, required this.date});
}

class SafeSoldeApp extends StatelessWidget {
  const SafeSoldeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '\$afe\$olde',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// --- ÉCRAN PRINCIPAL (TABLEAU DE BORD) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Liste temporaire pour stocker les transactions (en attendant la base de données)
  final List<Transaction> _transactions = [
    Transaction(title: "Salaire", amount: 50000, isIncome: true, date: DateTime.now()),
    Transaction(title: "Achat Pain", amount: 500, isIncome: false, date: DateTime.now()),
  ];

  // Fonction pour calculer le solde total
  double get _totalBalance {
    double total = 0;
    for (var tx in _transactions) {
      tx.isIncome ? total += tx.amount : total -= tx.amount;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('\$afe\$olde', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // SECTION SOLDE (Dashboard)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.green.shade100,
            child: Column(
              children: [
                const Text("Mon Solde Actuel", style: TextStyle(fontSize: 18)),
                Text("${_totalBalance.toStringAsFixed(0)} FCFA", 
                     style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(15),
            child: Text("Historique", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),

          // LISTE DES TRANSACTIONS
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (ctx, index) {
                final tx = _transactions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tx.isIncome ? Colors.green : Colors.red,
                    child: Icon(tx.isIncome ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white),
                  ),
                  title: Text(tx.title),
                  subtitle: Text("${tx.date.day}/${tx.date.month}/${tx.date.year}"),
                  trailing: Text(
                    "${tx.isIncome ? '+' : '-'} ${tx.amount} FCFA",
                    style: TextStyle(color: tx.isIncome ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // On ajoutera ici la navigation vers l'écran d'ajout
          print("Ajouter une transaction");
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}