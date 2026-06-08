Voici un **guide pédagogique complet et structuré** sous forme de Markdown. Ce document est conçu pour être ton fil conducteur. Il ne se contente pas de te donner le code, il t'explique **le pourquoi du comment** pour que tu puisses justifier tes choix devant le jury.

---

# 📘 Guide de Réalisation : Application $afe$olde
**Objectif :** Créer un gestionnaire de finances personnelles (Entrées/Sorties) avec Flutter.
**Niveau :** Débutant $\rightarrow$ Intermédiaire.

---

## 📌 Sommaire
1. [Architecture et Structure](#1-architecture-et-structure)
2. [Phase 1 : Le Modèle de Données](#2-phase-1-le-modèle-de-données)
3. [Phase 2 : L'Interface Principale (Dashboard)](#3-phase-2-linterface-principale-dashboard)
4. [Phase 3 : Le Formulaire d'Ajout (Navigation et Saisie)](#4-phase-3-le-formulaire-dajout)
5. [Phase 4 : La Logique de Mise à Jour (State Management)](#5-phase-4-la-logique-de-mise-à-jour)
6. [Phase 5 : La Persistance des Données (Sauvegarde Locale)](#6-phase-5-la-persistance-des-données)
7. [Phase 6 : Finalisation et Icône](#7-phase-6-finalisation-et-icône)

---

## 1. Architecture et Structure <a name="1-architecture-et-structure"></a>

Dans Flutter, tout est **Widget**. Un Widget est un composant d'interface (un bouton, un texte, une page).
Pour **$afe$olde**, nous allons utiliser une structure simple :
*   `main.dart` : Point d'entrée de l'application.
*   `models/` : Dossier pour définir la structure de nos données.
*   `screens/` : Dossier pour nos différentes pages (Home, AddTransaction).

**L'organisation des dossiers conseillée :**
```text
lib/
  ├── models/
  │    └── transaction.dart
  ├── screens/
  │    ├── home_screen.dart
  │    └── add_transaction_screen.dart
  └── main.dart
```

---

## 2. Phase 1 : Le Modèle de Données <a name="2-phase-1-le-modèle-de-données"></a>

Avant de dessiner, on définit ce qu'est une "Transaction". On crée une **Classe**.

**Fichier : `lib/models/transaction.dart`**
```dart
class Transaction {
  final String id;
  final String title;
  final double amount;
  final bool isIncome; // true = entrée, false = dépense
  final DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.date,
  });

  // Méthode pour convertir l'objet en Map (utile pour la sauvegarde JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isIncome': isIncome,
      'date': date.toIso8601String(),
    };
  }

  // Méthode pour recréer l'objet à partir d'un Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      isIncome: map['isIncome'],
      date: DateTime.parse(map['date']),
    );
  }
}
```
**💡 Note Pédagogique :** On utilise `factory` pour créer un constructeur capable de transformer des données brutes (venant d'un fichier) en un objet Dart utilisable.

---

## 3. Phase 2 : L'Interface Principale (Dashboard) <a name="3-phase-2-linterface-principale-dashboard"></a>

Ici, on crée la vue qui affiche le solde et la liste.

**Concept clé :** `ListView.builder` pour afficher une liste dynamique.

**Fichier : `lib/screens/home_screen.dart`** (Extrait principal)
```dart
// ... imports ...
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Transaction> _transactions = []; // Notre liste de données

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
      appBar: AppBar(title: Text('\$afe\$olde'), backgroundColor: Colors.green),
      body: Column(
        children: [
          // Widget du Solde
          Container(
            padding: EdgeInsets.all(20),
            child: Text("Solde : ${_totalBalance.toStringAsFixed(0)} FCFA", 
                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
        onPressed: () => _navigateToAddScreen(), // Voir phase 3
      ),
    );
  }
}
```

---

## 4. Phase 3 : Le Formulaire d'Ajout <a name="4-phase-3-le-formulaire-dajout"></a>

On crée une page avec des `TextField` pour saisir les données.

**Fichier : `lib/screens/add_transaction_screen.dart`**
```dart
class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isIncome = true;

  void _submitData() {
    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text) ?? 0;

    if (enteredTitle.isEmpty || enteredAmount <= 0) return;

    // On crée la transaction et on la renvoie à la page précédente
    Navigator.of(context).pop(Transaction(
      id: DateTime.now().toString(),
      title: enteredTitle,
      amount: enteredAmount,
      isIncome: _isIncome,
      date: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter une opération")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: "Titre")),
            TextField(controller: _amountController, decoration: InputDecoration(labelText: "Montant"), keyboardType: TextInputType.number),
            SwitchListTile(
              title: Text(_isIncome ? "C'est une Entrée" : "C'est une Dépense"),
              value: _isIncome,
              onChanged: (val) => setState(() => _isIncome = val),
            ),
            ElevatedButton(onPressed: _submitData, child: Text("Enregistrer"))
          ],
        ),
      ),
    );
  }
}
```

---

## 5. Phase 4 : La Logique de Mise à Jour <a name="5-phase-4-la-logique-de-mise-à-jour"></a>

C'est l'étape où on connecte les deux pages. On utilise `Navigator.push` pour aller à la page d'ajout et on attend le résultat.

**Dans `home_screen.dart`, remplace la fonction `_navigateToAddScreen` :**
```dart
void _navigateToAddScreen() async {
  // On attend que la page AddTransactionScreen renvoie un objet Transaction
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (ctx) => AddTransactionScreen()),
  );

  if (result != null && result is Transaction) {
    setState(() {
      _transactions.add(result); // Ajout à la liste et rafraîchissement de l'écran
    });
  }
}
```
**💡 Note Pédagogique :** `async` et `await` sont utilisés car la navigation est une opération "asynchrone" (on ne sait pas quand l'utilisateur va cliquer sur enregistrer).

---

## 6. Phase 5 : La Persistance des Données <a name="6-phase-5-la-persistance-des-données"></a>

Pour que les données ne s'effacent pas au redémarrage, on utilise `shared_preferences`.

1.  **Ajout du package** dans `pubspec.yaml` : `shared_preferences: ^2.2.2`
2.  **Import** : `import 'dart:convert';` et `import 'package:shared_preferences/shared_preferences.dart';`

**Logique de sauvegarde :**
```dart
Future<void> _saveTransactions() async {
  final prefs = await SharedPreferences.getInstance();
  // On transforme la liste d'objets en liste de Maps, puis en chaîne JSON
  final String encodedData = json.encode(_transactions.map((tx) => tx.toMap()).toList());
  await prefs.setString('user_transactions', encodedData);
}
```

**Logique de chargement (au démarrage) :**
```dart
Future<void> _loadTransactions() async {
  final prefs = await SharedPreferences.getInstance();
  final String? savedData = prefs.getString('user_transactions');
  if (savedData != null) {
    final List<dynamic> decodedData = json.decode(savedData);
    setState(() {
      _transactions = decodedData.map((item) => Transaction.fromMap(item)).toList();
    });
  }
}
```
*Appelle `_loadTransactions()` dans la méthode `initState()` de ton `_HomeScreenState`.*

---

## 7. Phase 6 : Finalisation et Icône <a name="7-phase-6-finalisation-et-icône"></a>

1.  **Design :** Ajoute des couleurs (`Colors.green.shade800`), des arrondis (`BorderRadius.circular(15)`) et des ombres (`BoxShadow`).
2.  **Icône :**
    *   Mets ton `logo.png` dans `assets/`.
    *   Configure `flutter_launcher_icons` dans `pubspec.yaml`.
    *   Lance : `flutter pub run flutter_launcher_icons`.

---

## 🎓 Résumé pour ton rapport de soutenance :
Si le jury te demande comment tu as travaillé, réponds ceci :
> *"J'ai adopté une approche itérative. J'ai d'abord défini un **modèle de données** robuste pour les transactions, puis j'ai construit l'**interface utilisateur** en utilisant des widgets de base. J'ai géré l'état de l'application avec `setState` pour une réactivité immédiate et j'ai implémenté la **persistance locale** via `shared_preferences` et la sérialisation JSON pour garantir que les données de l'utilisateur soient conservées."*

**Bon courage ! Tu as maintenant tout le plan. À toi de coder ! 🚀**