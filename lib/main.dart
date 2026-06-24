import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final profil = prefs.getString('profil');
  runApp(SafeSoldeApp(profilExistant: profil));
}

class SafeSoldeApp extends StatelessWidget {
  final String? profilExistant;
  const SafeSoldeApp({super.key, this.profilExistant});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '\$afe\$olde',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: profilExistant == null
          ? const SplashScreen()
          : DashboardScreen(profil: profilExistant!),
    );
  }
}