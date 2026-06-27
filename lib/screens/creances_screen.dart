import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Creance {
  final String nom;
  final double montant;
  final bool estDette; // true = je dois, false = on me doit
  final DateTime date;
  final String? echeance;
  bool estRegle;

  Creance({
    required this.nom,
    required this.montant,
    required this.estDette,
    required this.date,
    this.echeance,
    this.estRegle = false,
  });

  Map<String, dynamic> toJson() => {
    'nom': nom,
    'montant': montant,
    'estDette': estDette,
    'date': date.toIso8601String(),
    'echeance': echeance,
    'estRegle': estRegle,
  };

  factory Creance.fromJson(Map<String, dynamic> json) => Creance(
    nom: json['nom'],
    montant: json['montant'],
    estDette: json['estDette'],
    date: DateTime.parse(json['date']),
    echeance: json['echeance'],
    estRegle: json['estRegle'] ?? false,
  );
}

class CreancesScreen extends StatefulWidget {
  const CreancesScreen({super.key});

  @override
  State<CreancesScreen> createState() => _CreancesScreenState();
}

class _CreancesScreenState extends State<CreancesScreen>
    with SingleTickerProviderStateMixin {
  List<Creance> creances = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _charger();
  }

  Future<void> _charger() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('creances');
    if (data != null) {
      final List liste = jsonDecode(data);
      setState(() {
        creances = liste.map((e) => Creance.fromJson(e)).toList();
      });
    }
  }

  Future<void> _sauvegarder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'creances', jsonEncode(creances.map((c) => c.toJson()).toList()));
  }

  List<Creance> get dettes => creances.where((c) => c.estDette).toList();
  List<Creance> get prets => creances.where((c) => !c.estDette).toList();

  double get totalDettes => dettes
      .where((c) => !c.estRegle)
      .fold(0, (s, c) => s + c.montant);
  double get totalPrets => prets
      .where((c) => !c.estRegle)
      .fold(0, (s, c) => s + c.montant);

  void _ajouterCreance() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _FormulaireCreance(
        onAjouter: (c) {
          setState(() => creances.add(c));
          _sauvegarder();
        },
      ),
    );
  }

  void _toggleRegle(int index) {
    setState(() => creances[index].estRegle = !creances[index].estRegle);
    _sauvegarder();
  }

  void _supprimer(int index) {
    setState(() => creances.removeAt(index));
    _sauvegarder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Créances',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '💸 Mes dettes'),
            Tab(text: '💰 Mes prêts'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Résumé
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _carteResume(
                    'Je dois',
                    totalDettes,
                    const Color(0xFFC62828),
                    Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _carteResume(
                    'On me doit',
                    totalPrets,
                    const Color(0xFF2E7D32),
                    Icons.arrow_downward,
                  ),
                ),
              ],
            ),
          ),
          // Liste
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _liste(dettes, estDette: true),
                _liste(prets, estDette: false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2E7D32),
        onPressed: _ajouterCreance,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _liste(List<Creance> liste, {required bool estDette}) {
    if (liste.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(estDette ? Icons.money_off : Icons.attach_money,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              estDette ? 'Aucune dette enregistrée' : 'Aucun prêt enregistré',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: liste.length,
      itemBuilder: (_, i) {
        final c = liste[i];
        final indexOriginal = creances.indexOf(c);
        return Dismissible(
          key: Key('${c.nom}$i'),
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
          onDismissed: (_) => _supprimer(indexOriginal),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.estRegle ? Colors.grey[100] : Colors.white,
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
                GestureDetector(
                  onTap: () => _toggleRegle(indexOriginal),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.estRegle
                          ? const Color(0xFF2E7D32)
                          : Colors.transparent,
                      border: Border.all(
                        color: c.estRegle
                            ? const Color(0xFF2E7D32)
                            : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: c.estRegle
                        ? const Icon(Icons.check,
                        color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.nom,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          decoration: c.estRegle
                              ? TextDecoration.lineThrough
                              : null,
                          color: c.estRegle ? Colors.grey : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${c.date.day}/${c.date.month}/${c.date.year}',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12),
                          ),
                          if (c.echeance != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('Échéance: ${c.echeance}',
                                  style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 11)),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${c.montant.toStringAsFixed(0)} F',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: c.estRegle
                        ? Colors.grey
                        : (estDette
                        ? const Color(0xFFC62828)
                        : const Color(0xFF2E7D32)),
                    decoration:
                    c.estRegle ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _carteResume(
      String titre, double montant, Color couleur, IconData icone) {
    return Container(
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: couleur.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icone, color: couleur, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre,
                    style:
                    TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text('${montant.toStringAsFixed(0)} F',
                    style: TextStyle(
                        color: couleur,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormulaireCreance extends StatefulWidget {
  final Function(Creance) onAjouter;
  const _FormulaireCreance({required this.onAjouter});

  @override
  State<_FormulaireCreance> createState() => _FormulaireCreanceState();
}

class _FormulaireCreanceState extends State<_FormulaireCreance> {
  final _nomController = TextEditingController();
  final _montantController = TextEditingController();
  final _echeanceController = TextEditingController();
  bool _estDette = true;

  void _sauvegarder() {
    if (_nomController.text.isEmpty || _montantController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplis tous les champs !')),
      );
      return;
    }
    widget.onAjouter(Creance(
      nom: _nomController.text,
      montant: double.parse(_montantController.text),
      estDette: _estDette,
      date: DateTime.now(),
      echeance: _echeanceController.text.isEmpty
          ? null
          : _echeanceController.text,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Nouvelle créance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _estDette = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _estDette
                            ? const Color(0xFFC62828)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('💸 Je dois',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: _estDette ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _estDette = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_estDette
                            ? const Color(0xFF2E7D32)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('💰 On me doit',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: !_estDette ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nomController,
            decoration: InputDecoration(
              labelText: 'Nom (ex: Jean, Loyer mars...)',
              prefixIcon: const Icon(Icons.person, color: Color(0xFF2E7D32)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _montantController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Montant (FCFA)',
              prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF2E7D32)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _echeanceController,
            decoration: InputDecoration(
              labelText: 'Échéance (optionnel, ex: 30/07/2026)',
              prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _estDette
                    ? const Color(0xFFC62828)
                    : const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _sauvegarder,
              child: const Text('Enregistrer',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}