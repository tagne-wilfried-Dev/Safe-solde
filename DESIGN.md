# DESIGN.md — Améliorations du rendu visuel

Guide d'amélioration de l'interface de **safe_solde**, écran par écran.
Pour chaque point : le **fichier + les lignes concernées**, le **problème visuel**, et le **code amélioré** à mettre en place.

> Objectif : passer d'un rendu « brut Material par défaut » à une interface soignée, cohérente et lisible.
> Plusieurs suggestions utilisent le paquet `intl` (formatage des montants/dates) — pratique mais optionnel.

---

## 1. Thème global — fondations visuelles

**Fichier :** `lib/main.dart` 

### Problème
- `primarySwatch` (déprécié) coexiste avec `ColorScheme.fromSeed` → couleurs imprévisibles.
- Aucune typographie, aucun style de carte ni de bouton définis globalement → chaque écran improvise.

### Amélioration
Centraliser le style dans le thème pour que tous les écrans en héritent :

```dart
theme: ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1C4D1E), // vert profond de la marque
    primary: const Color(0xFF1C4D1E),
    secondary: Colors.greenAccent.shade700,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: const Color(0xFFF5F7F5), // fond légèrement teinté, pas blanc pur
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1C4D1E),
    foregroundColor: Colors.white,
    centerTitle: false,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white,
    ),
  ),
  cardTheme: CardTheme(
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1C4D1E),
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
  ),
),
```

> Supprime `primarySwatch`. Tout le reste de l'app deviendra cohérent sans effort.

---

## 2. Écran d'accueil — la carte de solde

**Fichier :** `lib/screens/home_screen.dart`  (le `Container` du solde)

### Problème
Le solde est un simple `Text` dans un `Container` sans fond : visuellement plat, peu mis en valeur, pas de couleur selon positif/négatif, pas de séparateur de milliers.

### Amélioration
Remplacer le `Container` par une **carte héro** colorée :

```dart
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
```

> Effet : le solde devient le point focal de l'écran, et la couleur communique instantanément l'état (vert = positif, rouge = négatif).

---

## 3. Écran d'accueil — l'AppBar

**Fichier :** `lib/screens/home_screen.dart` 

### Problème
```dart
appBar: AppBar(
  title: Text('\$afe💰️olde'),
  backgroundColor: Colors.green,   // ← écrase le vert foncé du thème
),
```
Le `Colors.green` codé en dur casse la cohérence avec le thème (point 1).

### Amélioration
Laisser le thème gérer la couleur, et nettoyer le titre :

```dart
appBar: AppBar(
  title: const Text('Safe Solde'),
),
```

> Si tu tiens aux emojis, garde-les mais retire `backgroundColor` pour hériter du vert foncé du thème.

---

## 4. Écran d'accueil — les éléments de la liste

**Fichier :** `lib/screens/home_screen.dart`  (`itemBuilder`)

### Problème
- `ListTile` nu, sans carte ni séparation → la liste paraît tassée.
- `trailing: Text("${tx.amount} FCFA")` affiche `100.0 FCFA` (décimale parasite) et sans signe ni couleur.
- La date n'est pas montrée.

### Amélioration
Envelopper chaque ligne dans une `Card` avec icône colorée, montant signé et date :

```dart
itemBuilder: (ctx, index) {
  final tx = _transactions[index];
  final color = tx.isIncome ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
  return Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.12),
        child: Icon(
          tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
        ),
      ),
      title: Text(tx.title,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${tx.date.day.toString().padLeft(2, '0')}/'
        '${tx.date.month.toString().padLeft(2, '0')}/${tx.date.year}',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
      trailing: Text(
        '${tx.isIncome ? '+' : '-'}${tx.amount.toStringAsFixed(0)} FCFA',
        style: TextStyle(
          color: color, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    ),
  );
},
```

> Effet : chaque opération devient une carte lisible, le sens (entrée/dépense) saute aux yeux grâce à la couleur et au signe.

---

## 5. Écran d'accueil — état vide

**Fichier :** `lib/screens/home_screen.dart`  (le `Expanded`)

### Problème
Quand il n'y a aucune transaction, l'écran affiche un grand vide blanc.

### Amélioration
Afficher un message d'accueil illustré :

```dart
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
              Text('Appuyez sur + pour ajouter une entrée ou une dépense',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500)),
            ],
          ),
        )
      : ListView.builder(
          padding: const EdgeInsets.only(bottom: 80), // évite que le FAB masque le dernier item
          itemCount: _transactions.length,
          itemBuilder: (ctx, index) { /* voir point 4 */ },
        ),
),
```

---

## 6. Écran d'accueil — le bouton flottant (FAB)

**Fichier :** `lib/screens/home_screen.dart`

### Problème
```dart
backgroundColor: const Color.fromARGB(255, 122, 61, 3), // marron
```
Le marron jure avec la palette verte de l'app.

### Amélioration
Aligner sur la couleur de marque et étoffer le bouton avec un libellé :

```dart
floatingActionButton: FloatingActionButton.extended(
  onPressed: _navigateAdd,
  backgroundColor: const Color(0xFF1C4D1E),
  foregroundColor: Colors.white,
  icon: const Icon(Icons.add),
  label: const Text('Ajouter'),
),
```

---

## 7. Écran d'ajout — espacement et structure du formulaire

**Fichier :** `lib/screens/add_transaction_screen.dart` 

### Problème
Les trois champs (`TextField`, `TextField`, `SwitchListTile`) et le bouton sont collés les uns aux autres dans une `Column` sans espacement → formulaire serré et peu aéré. Le bouton n'est pas en pleine largeur.

### Amélioration
Aérer avec des `SizedBox`, élargir le bouton et améliorer les libellés :

```dart
body: Padding(
  padding: const EdgeInsets.all(20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        controller: _titleController,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Titre',
          hintText: 'Ex. Courses, Salaire…',
          prefixIcon: Icon(Icons.edit_note),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Montant',
          suffixText: 'FCFA',
          prefixIcon: Icon(Icons.payments_outlined),
        ),
      ),
      const SizedBox(height: 8),
      // Sélecteur entrée/dépense plus visuel (voir point 8)
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(_isIncome ? "C'est une entrée" : "C'est une dépense"),
        secondary: Icon(
          _isIncome ? Icons.trending_up : Icons.trending_down,
          color: _isIncome ? Colors.green : Colors.red,
        ),
        value: _isIncome,
        onChanged: (val) => setState(() => _isIncome = val),
      ),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: _submitData,
        icon: const Icon(Icons.check),
        label: const Text('Enregistrer'),
      ),
    ],
  ),
),
```

> `crossAxisAlignment: stretch` + le thème du point 1 donnent un bouton pleine largeur et des champs uniformes.

---

## 8. Écran d'ajout — sélecteur Entrée / Dépense plus parlant (optionnel)

**Fichier :** `lib/screens/add_transaction_screen.dart` 

### Problème
Un `Switch` est ambigu pour choisir entre « entrée » et « dépense » (on ne sait pas quel état = quoi).

### Amélioration
Remplacer par un `SegmentedButton` explicite (Material 3) :

```dart
SegmentedButton<bool>(
  segments: const [
    ButtonSegment(value: true,  label: Text('Entrée'),  icon: Icon(Icons.trending_up)),
    ButtonSegment(value: false, label: Text('Dépense'), icon: Icon(Icons.trending_down)),
  ],
  selected: {_isIncome},
  onSelectionChanged: (s) => setState(() => _isIncome = s.first),
),
```

---

## 9. Détail — le `SnackBar` de validation

**Fichier :** `lib/screens/add_transaction_screen.dart` 

### Problème
Le `SnackBar` d'erreur est neutre, ne ressort pas comme un avertissement.

### Amélioration
Le colorer et l'arrondir :

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Veuillez remplir correctement les champs'),
    backgroundColor: Colors.red.shade700,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
);
```

---

## Récapitulatif des priorités visuelles

| Priorité | Point | Impact visuel |
|---|---|---|
| ⭐⭐⭐ | 1. Thème global | Cohérence sur toute l'app, base de tout le reste |
| ⭐⭐⭐ | 2. Carte de solde | Point focal de l'écran d'accueil |
| ⭐⭐⭐ | 4. Cartes de la liste | Lisibilité des opérations |
| ⭐⭐ | 6. FAB + 7. Formulaire | Cohérence des couleurs et de la saisie |
| ⭐⭐ | 5. État vide | Première impression à l'ouverture |
| ⭐ | 3, 8, 9 | Finitions |

Conseil : appliquer le **point 1 d'abord** (le thème), car les points suivants en héritent automatiquement (formes, couleurs, boutons).
