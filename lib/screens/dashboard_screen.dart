import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';
import 'history_screen.dart';
import 'splash_screen.dart';
import 'conseils_screen.dart';
import 'creances_screen.dart';
class DashboardScreen extends StatefulWidget {
  final String profil;
  const DashboardScreen({super.key, required this.profil});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Transaction> transactions = [];
  String nom = '';

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('transactions');
    final n = prefs.getString('nom') ?? '';
    if (data != null) {
      final List liste = jsonDecode(data);
      setState(() {
        transactions = liste.map((e) => Transaction.fromJson(e)).toList();
        nom = n;
      });
    } else {
      setState(() => nom = n);
    }
  }

  Future<void> _sauvegarderTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transactions',
        jsonEncode(transactions.map((t) => t.toJson()).toList()));
  }

  double get solde => transactions.fold(
      0, (sum, t) => t.estEntree ? sum + t.montant : sum - t.montant);
  double get totalEntrees => transactions
      .where((t) => t.estEntree)
      .fold(0, (sum, t) => sum + t.montant);
  double get totalSorties => transactions
      .where((t) => !t.estEntree)
      .fold(0, (sum, t) => sum + t.montant);

  void ajouterTransaction(Transaction t) {
    setState(() => transactions.add(t));
    _sauvegarderTransactions();
  }

  void supprimerTransaction(int index) {
    setState(() => transactions.removeAt(index));
    _sauvegarderTransactions();
  }

  String _salutation() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          _fondDecoratif(context),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${_salutation()}, $nom 👋',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(widget.profil,
                              style: const TextStyle(
                                  color: Color(0xFF2E7D32), fontSize: 13)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('profil');
                          await prefs.remove('nom');
                          await prefs.remove('transactions');
                          await prefs.remove('creances');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const SplashScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8)
                            ],
                          ),
                          child: const Icon(Icons.settings, color: Color(0xFF2E7D32)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Carte solde
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: solde >= 0
                            ? [const Color(0xFF2E7D32), const Color(0xFF66BB6A)]
                            : [const Color(0xFFC62828), const Color(0xFFEF5350)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color: (solde >= 0
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFC62828))
                                .withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Solde disponible',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 8),
                        Text('${solde.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _miniCarte('↓ Entrées',
                                '${totalEntrees.toStringAsFixed(0)} F',
                                Colors.white.withOpacity(0.2)),
                            const SizedBox(width: 12),
                            _miniCarte('↑ Sorties',
                                '${totalSorties.toStringAsFixed(0)} F',
                                Colors.white.withOpacity(0.2)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Graphique
                  if (totalEntrees > 0 || totalSorties > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Répartition du mois',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 160,
                            child: PieChart(PieChartData(
                              sections: [
                                if (totalEntrees > 0)
                                  PieChartSectionData(
                                    value: totalEntrees,
                                    color: const Color(0xFF2E7D32),
                                    title:
                                    '${(totalEntrees / (totalEntrees + totalSorties) * 100).toStringAsFixed(0)}%',
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                if (totalSorties > 0)
                                  PieChartSectionData(
                                    value: totalSorties,
                                    color: const Color(0xFFC62828),
                                    title:
                                    '${(totalSorties / (totalEntrees + totalSorties) * 100).toStringAsFixed(0)}%',
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                              ],
                              sectionsSpace: 4,
                              centerSpaceRadius: 35,
                            )),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _legende(const Color(0xFF2E7D32), 'Entrées'),
                              const SizedBox(width: 20),
                              _legende(const Color(0xFFC62828), 'Sorties'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ConseilsScreen()),
                      ),
                      icon: const Icon(Icons.lightbulb, color: Color(0xFF2E7D32)),
                      label: const Text('Conseils & Astuces',
                          style: TextStyle(color: Color(0xFF2E7D32))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreancesScreen()),
                      ),
                      icon: const Icon(Icons.account_balance_wallet, color: Color(0xFF2E7D32)),
                      label: const Text('Dettes & Prêts',
                          style: TextStyle(color: Color(0xFF2E7D32))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Bouton historique
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoryScreen(
                            transactions: transactions,
                            onSupprimer: supprimerTransaction,
                          ),
                        ),
                      ).then((_) => _chargerDonnees()),
                      icon: const Icon(Icons.history,
                          color: Color(0xFF2E7D32)),
                      label: const Text('Voir l\'historique',
                          style: TextStyle(color: Color(0xFF2E7D32))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2E7D32),
        onPressed: () async {
          final t = await Navigator.push<Transaction>(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    AddTransactionScreen(profil: widget.profil)),
          );
          if (t != null) ajouterTransaction(t);
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label:
        const Text('Ajouter', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _miniCarte(String titre, String valeur, Color couleur) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: couleur,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titre,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Text(valeur,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _legende(Color couleur, String label) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration:
            BoxDecoration(color: couleur, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _fondDecoratif(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height),
      painter: _FondPainter(),
    );
  }
}

class _FondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color(0xFF2E7D32).withOpacity(0.04);
    canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.1), 100, paint);
    paint.color = const Color(0xFFFFD700).withOpacity(0.05);
    canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.8), 80, paint);
    paint.color = const Color(0xFF2E7D32).withOpacity(0.03);
    canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.9), 60, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}