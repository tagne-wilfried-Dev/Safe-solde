// Test du widget principal de l'application.
//
// Pour interagir avec un widget dans un test, on utilise WidgetTester
// du paquet flutter_test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:safe_solde/main.dart';

void main() {
  testWidgets('L\'écran d\'accueil affiche le solde', (WidgetTester tester) async {
    // _loadTransactions() utilise SharedPreferences : on fournit des
    // valeurs initiales factices pour éviter une exception de plugin manquant.
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const SafeSoldeApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Solde'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget); // le FAB
  });
}
