import 'package:flutter/material.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final String profil;
  const AddTransactionScreen({super.key, required this.profil});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _libelleController = TextEditingController();
  final _montantController = TextEditingController();
  bool _estEntree = true;
  String _categorie = 'Salaire';

  Map<String, List<String>> get _categoriesParProfil => {
    'Étudiant': {
      'entree': ['Bourse', 'Job étudiant', 'Aide famille', 'Autre'],
      'sortie': ['Loyer', 'Transport', 'Alimentation', 'Cours', 'Tontine versée', 'Autre']
    }['entree']!,
    'Élève': {
      'entree': ['Argent de poche', 'Aide famille', 'Autre'],
      'sortie': ['Fournitures', 'Transport', 'Alimentation', 'Autre']
    }['entree']!,
    'Salarié': {
      'entree': ['Salaire', 'Tontine reçue', 'Prime', 'Autre'],
      'sortie': ['Loyer', 'Transport', 'Alimentation', 'Tontine versée', 'Facture', 'Autre']
    }['entree']!,
    'Freelance': {
      'entree': ['Mission', 'Facture client', 'Tontine reçue', 'Autre'],
      'sortie': ['Matériel', 'Transport', 'Alimentation', 'Tontine versée', 'Autre']
    }['entree']!,
    'Professionnel': {
      'entree': ['Salaire', 'Dividendes', 'Tontine reçue', 'Autre'],
      'sortie': ['Loyer', 'Transport', 'Alimentation', 'Tontine versée', 'Investissement', 'Autre']
    }['entree']!,
  };

  List<String> get _categoriesEntree {
    final Map<String, Map<String, List<String>>> all = {
      'Étudiant': {'entree': ['Bourse', 'Job étudiant', 'Aide famille', 'Autre'], 'sortie': ['Loyer', 'Transport', 'Alimentation', 'Cours', 'Tontine versée', 'Autre']},
      'Élève': {'entree': ['Argent de poche', 'Aide famille', 'Autre'], 'sortie': ['Fournitures', 'Transport', 'Alimentation', 'Autre']},
      'Salarié': {'entree': ['Salaire', 'Tontine reçue', 'Prime', 'Autre'], 'sortie': ['Loyer', 'Transport', 'Alimentation', 'Tontine versée', 'Facture', 'Autre']},
      'Freelance': {'entree': ['Mission', 'Facture client', 'Tontine reçue', 'Autre'], 'sortie': ['Matériel', 'Transport', 'Alimentation', 'Tontine versée', 'Autre']},
      'Professionnel': {'entree': ['Salaire', 'Dividendes', 'Tontine reçue', 'Autre'], 'sortie': ['Loyer', 'Transport', 'Alimentation', 'Tontine versée', 'Investissement', 'Autre']},
    };
    return all[widget.profil]?['entree'] ?? ['Salaire', 'Autre'];
  }

  List<String> get _categoriesSortie {
    final Map<String, Map<String, List<String>>> all = {
      'Étudiant': {'entree': ['Bourse', 'Job étudiant', 'Aide famille', 'Autre'], 'sortie': ['Loyer', 'Transport', 'Alimentation', 'Cours', 'Tontine versée', 'Autre']},
      'Élève': {'entree': ['Argent de poche', 'Aide famille', 'Autre'], 'sortie': ['Fournitures', 'Transport', 'Alimentation', 'Autre']},
      'Salarié': {'entree': ['Salaire', 'Tontine reçue', 'Prime', 'Autre'], 'sortie': ['Loyer', 'Transport', 'Alimentation', 'Tontine versée', 'Facture', 'Autre']},
      'Freelance': {'entree': ['Mission', 'Facture client', 'Tontine reçue', 'Autre'], 'sortie': ['Matériel', 'Transport', 'Alimentation', 'Tontine versée', 'Autre']},
      'Professionnel': {'entree': ['Salaire', 'Dividendes', 'Tontine reçue', 'Autre'], 'sortie': ['Loyer', 'Transport', 'Alimentation', 'Tontine versée', 'Investissement', 'Autre']},
    };
    return all[widget.profil]?['sortie'] ?? ['Loyer', 'Autre'];
  }

  void _sauvegarder() {
    if (_libelleController.text.isEmpty || _montantController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplis tous les champs !')),
      );
      return;
    }
    Navigator.pop(
      context,
      Transaction(
        libelle: _libelleController.text,
        montant: double.parse(_montantController.text),
        estEntree: _estEntree,
        date: DateTime.now(),
        categorie: _categorie,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _estEntree ? _categoriesEntree : _categoriesSortie;
    if (!categories.contains(_categorie)) _categorie = categories.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Nouvelle transaction',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Toggle
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
              child: Row(
                children: [
                  _toggleBtn('↓ Entrée', _estEntree, const Color(0xFF2E7D32),
                          () => setState(() { _estEntree = true; _categorie = _categoriesEntree.first; })),
                  _toggleBtn('↑ Sortie', !_estEntree, const Color(0xFFC62828),
                          () => setState(() { _estEntree = false; _categorie = _categoriesSortie.first; })),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _champ(_libelleController, 'Libellé', Icons.edit),
            const SizedBox(height: 12),
            _champ(_montantController, 'Montant (FCFA)', Icons.attach_money,
                clavier: TextInputType.number),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _categorie,
                  isExpanded: true,
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _categorie = val!),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _estEntree ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _sauvegarder,
                child: const Text('Enregistrer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(String label, bool actif, Color couleur, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: actif ? couleur : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: actif ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _champ(TextEditingController ctrl, String label, IconData icone,
      {TextInputType clavier = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: TextField(
        controller: ctrl,
        keyboardType: clavier,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icone, color: const Color(0xFF2E7D32)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}