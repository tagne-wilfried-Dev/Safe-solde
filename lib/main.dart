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
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
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

      // redirections et pages
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/add': (context) => const AddTransactionScreen(),
      },
    );
  }
}