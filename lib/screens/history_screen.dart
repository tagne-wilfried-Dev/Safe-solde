import 'package:flutter/material.dart';
import '../models/transaction.dart';

class HistoryScreen extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(int) onSupprimer;

  const HistoryScreen({
    super.key,
    required this.transactions,
    required this.onSupprimer,
  });

  @override
  Widget build(BuildContext context) {
    final liste = transactions.reversed.toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Historique',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: liste.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucune transaction pour l\'instant.',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: liste.length,
        itemBuilder: (_, i) {
          final t = liste[i];
          final indexOriginal = transactions.length - 1 - i;
          return Dismissible(
            key: Key('$i-${t.libelle}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => onSupprimer(indexOriginal),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: t.estEntree
                          ? const Color(0xFF2E7D32).withOpacity(0.1)
                          : const Color(0xFFC62828).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      t.estEntree
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: t.estEntree
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.libelle,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(t.categorie,
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                                '${t.date.day}/${t.date.month}/${t.date.year}',
                                style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${t.estEntree ? '+' : '-'}${t.montant.toStringAsFixed(0)} F',
                    style: TextStyle(
                      color: t.estEntree
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}