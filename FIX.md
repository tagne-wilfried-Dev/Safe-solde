# FIX.md — Erreurs, faiblesses et solutions

Analyse du projet **safe_solde** (application Flutter de suivi de solde) réalisée le 2026-06-19.
Les problèmes sont classés par gravité. Chaque entrée donne le **fichier concerné**, le **problème** et la **solution**.

Environnement détecté :
- Flutter installé : `3.24.3` (Dart `3.10.1`)
- SDK exigé par le projet : Dart `^3.11.3`

---

## 🔴 Bloquant (le projet ne compile pas en l'état)

### 1. Contrainte de SDK incompatible — `flutter pub get` échoue
**Fichier :** `pubspec.yaml` (ligne 22)

```yaml
environment:
  sdk: ^3.11.3
```

Le Dart SDK installé est **3.10.1**, qui ne satisfait pas `^3.11.3`. Résultat :

```
Because safe_solde requires SDK version ^3.11.3, version solving failed.
Failed to update packages.
```

Aucune commande (`pub get`, `analyze`, `run`, `build`, `test`) ne fonctionne tant que ce point n'est pas réglé.

**Solution — deux options :**

- **Option A (recommandée si on garde le Flutter actuel)** : abaisser la contrainte pour qu'elle corresponde au SDK installé :
  ```yaml
  environment:
    sdk: ">=3.5.0 <4.0.0"
  ```
- **Option B** : mettre à jour Flutter vers une version qui embarque Dart ≥ 3.11.3 :
  ```bash
  flutter upgrade
  ```
  (Flutter suggère lui-même la version `3.44.2`.)

Puis relancer :
```bash
flutter pub get
```

---

### 2. Fichier de test cassé (template par défaut jamais adapté)
**Fichier :** `test/widget_test.dart`

Le test référence des éléments qui **n'existent pas** dans l'application :
- `MyApp` → la classe réelle s'appelle `SafeSoldeApp`.
- un compteur (`find.text('0')`, incrémentation via `Icons.add`) → cette logique n'existe pas.

`flutter test` échouera à la **compilation**.

**Solution :** remplacer le contenu par un test réel, par exemple :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_solde/main.dart';

void main() {
  testWidgets('L\'écran d\'accueil affiche le solde', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeSoldeApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Solde'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget); // le FAB
  });
}
```

> ⚠️ `_loadTransactions()` utilise `SharedPreferences` ; pensez à
> `SharedPreferences.setMockInitialValues({})` en début de test pour éviter
> une exception de plugin manquant.

---

### 3. `.gitignore` corrompu (séquence de collage parasite + doublon)
**Fichier :** `.gitignore`

```
[200~android/app/src/main/res/mipmap-hdpi/ic_launcher2.png
android/app/src/main/res/mipmap-hdpi/ic_launcher2.png
```

Le `[200~` est une séquence d'échappement de *bracketed paste* collée par erreur ; la règle est donc inopérante, et la ligne suivante est un doublon.

**Solution :** nettoyer ces lignes (corriger les noms réels des icônes à ignorer si nécessaire) :

```
android/app/src/main/res/mipmap-hdpi/ic_launcher2.png
android/app/src/main/res/mipmap-mdpi/ic_launcher1.png
android/app/src/main/res/mipmap-xhdpi/ic_launcher3.png
android/app/src/main/res/mipmap-xxhdpi/ic_launcher2.png
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher1.png
```

---

## 🟠 Bugs / fuites (à corriger rapidement)

### 4. `TextEditingController` jamais libérés → fuite mémoire
**Fichier :** `lib/screens/add_transaction_screen.dart`

`_titleController` et `_amountController` sont créés mais aucun `dispose()` n'est défini. C'est une fuite mémoire (et une violation de la règle de lint sur les contrôleurs non disposés).

**Solution :** ajouter dans `_AddTransactionScreenState` :

```dart
@override
void dispose() {
  _titleController.dispose();
  _amountController.dispose();
  super.dispose();
}
```

---

### 5. Crash possible au démarrage si les données sauvegardées sont corrompues
**Fichier :** `lib/screens/home_screen.dart` (`_loadTransactions`, lignes 62-71)

`json.decode(savedData)` et `Transaction.fromMap(item)` ne sont protégés par aucun `try/catch`. Si le JSON stocké est invalide (version incompatible, écriture interrompue, champ manquant), l'application **plante au lancement** sans récupération possible.

**Solution :**

```dart
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
```

---

### 6. Identifiant de transaction non fiable (risque de collision)
**Fichiers :** `lib/screens/add_transaction_screen.dart` (ligne 32)

```dart
id: DateTime.now().toString(),
```

Deux transactions créées dans la même milliseconde auraient le même `id`. C'est aussi problématique le jour où l'on voudra supprimer/modifier par `id`.

**Solution :** utiliser un identifiant unique. Le plus simple sans dépendance :

```dart
id: '${DateTime.now().microsecondsSinceEpoch}',
```

Ou, plus robuste, ajouter le paquet `uuid` puis `id: const Uuid().v4()`.

---

### 7. Imports inutiles (warnings de lint)
**Fichier :** `lib/screens/home_screen.dart` (lignes 1, 4, 8)

```dart
import 'package:flutter/cupertino.dart';            // non utilisé
import 'package:safe_solde/screens/add_transaction_screen.dart'; // non utilisé (navigation par route nommée)
import '../main.dart';                               // non utilisé
```

`flutter_lints` signalera `unused_import`. L'import de `main.dart` depuis un écran crée en plus une dépendance circulaire inutile.

**Solution :** supprimer ces trois lignes.

---

## 🟡 Faiblesses fonctionnelles / UX

### 8. Impossible de supprimer ou modifier une transaction
**Fichier :** `lib/screens/home_screen.dart` (`ListView.builder`)

Une fois ajoutée, une opération ne peut plus être retirée — fonctionnalité de base manquante pour une app de budget.

**Solution :** envelopper le `ListTile` dans un `Dismissible` (glisser pour supprimer) :

```dart
return Dismissible(
  key: ValueKey(tx.id),
  direction: DismissDirection.endToStart,
  background: Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    child: const Icon(Icons.delete, color: Colors.white),
  ),
  onDismissed: (_) {
    setState(() => _transactions.removeAt(index));
    _saveTransactions();
  },
  child: ListTile(/* ... */),
);
```

---

### 9. Aucun état vide
**Fichier :** `lib/screens/home_screen.dart`

Quand la liste est vide, l'écran affiche une zone blanche sans explication.

**Solution :**

```dart
child: _transactions.isEmpty
    ? const Center(child: Text('Aucune opération pour le moment.\nAppuyez sur + pour commencer.', textAlign: TextAlign.center))
    : ListView.builder(/* ... */),
```

---

### 10. Formatage des montants incohérent
**Fichier :** `lib/screens/home_screen.dart` (ligne 100)

Le solde est formaté avec `toStringAsFixed(0)` (ligne 86) mais la liste affiche `${tx.amount}` brut → ex. `100.0 FCFA`. Affichage hétérogène, et aucun séparateur de milliers.

**Solution :** utiliser un format cohérent (idéalement le paquet `intl` avec `NumberFormat`), ou au minimum :

```dart
trailing: Text("${tx.amount.toStringAsFixed(0)} FCFA"),
```

Mieux, marquer le signe : `"${tx.isIncome ? '+' : '-'}${tx.amount.toStringAsFixed(0)} FCFA"`.

---

### 11. La date est stockée mais jamais affichée
**Fichiers :** `lib/models/transaction.dart`, `lib/screens/home_screen.dart`

Le champ `date` est sauvegardé mais l'utilisateur ne le voit nulle part.

**Solution :** l'afficher dans le `subtitle` du `ListTile` (avec `intl` : `DateFormat('dd/MM/yyyy').format(tx.date)`).

---

### 12. Pas de filtrage de saisie sur le montant
**Fichier :** `lib/screens/add_transaction_screen.dart` (TextField montant)

`keyboardType: TextInputType.number` n'empêche pas la saisie de caractères invalides (selon les claviers) ni de plusieurs points.

**Solution :** ajouter des `inputFormatters` :

```dart
import 'package:flutter/services.dart';
// ...
keyboardType: const TextInputType.numberWithOptions(decimal: true),
inputFormatters: [
  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
],
```

---

## 🟢 Qualité / cohérence (améliorations)

### 13. Thème incohérent : `primarySwatch` déprécié + AppBar surchargée
**Fichiers :** `lib/main.dart`, `lib/screens/home_screen.dart`

- `primarySwatch: Colors.green` (ligne 19) est largement remplacé par `ColorScheme.fromSeed` et redondant.
- L'`AppBarTheme` définit un vert foncé `Color.fromARGB(255, 28, 77, 30)`, mais `HomeScreen` force `backgroundColor: Colors.green` (ligne 78), annulant le thème. L'apparence diffère entre écrans.

**Solution :** supprimer `primarySwatch` et retirer le `backgroundColor` codé en dur de l'AppBar de `HomeScreen` pour laisser le thème s'appliquer uniformément.

---

### 14. `flutter_launcher_icons` dans `dependencies` au lieu de `dev_dependencies`
**Fichier :** `pubspec.yaml` (ligne 34)

C'est un outil de build, pas une dépendance d'exécution ; il alourdit l'app.

**Solution :** le déplacer sous `dev_dependencies`.

---

### 15. Assets non déclarés / inutilisés
**Fichiers :** `pubspec.yaml`, dossier `assets/`

`assets/` contient `budget.png`, `croissance.png`, `oconsafe2.png`, plusieurs icônes… mais aucune section `flutter: assets:` ne les déclare. Seul `logo.png` est utilisé (par `flutter_launcher_icons`). Les autres sont du poids mort dans le dépôt.

**Solution :** supprimer les images réellement inutilisées, ou, si elles doivent servir, les déclarer :

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/logo.png
```

---

### 16. README par défaut (non personnalisé)
**Fichier :** `README.md`

C'est encore le texte générique du template Flutter, sans description du projet, ni instructions d'installation.

**Solution :** documenter le but de l'app, le prérequis de SDK (cf. point 1) et les commandes `flutter pub get` / `flutter run`.

---

### 17. Modèle `Transaction` sans `==`/`hashCode`
**Fichier :** `lib/models/transaction.dart`

Sans surcharge d'égalité, comparer ou dédoublonner des transactions se fait par référence, ce qui complique tests et logique future.

**Solution :** implémenter `==`/`hashCode` (basés sur `id`) ou utiliser `freezed`/`equatable`.

---

## ✅ Ordre de correction recommandé

1. **Point 1** (contrainte SDK) — sans lui, rien ne tourne.
2. **Points 2 et 3** (test cassé, `.gitignore`).
3. **Points 4, 5, 6, 7** (fuite mémoire, crash au chargement, id, imports).
4. **Points 8–12** (fonctionnalités/UX).
5. **Points 13–17** (qualité et cohérence).

Après chaque lot, valider avec :
```bash
flutter pub get
flutter analyze
flutter test
```
