import 'package:flutter/material.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SafeSoldeApp());
}


class SafeSoldeApp extends StatelessWidget {
  const SafeSoldeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '💰️afe💲olde',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green.shade700,
          secondary: Colors.greenAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 28, 77, 30),
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 2,
        ),
      ),

      // redirections et pages
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/add': (context) => const AddTransactionScreen(),
      },
    );
  }
}