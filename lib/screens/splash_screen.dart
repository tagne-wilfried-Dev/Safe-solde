import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _profilSelectionne;
  final _nomController = TextEditingController();

  final List<Map<String, dynamic>> profils = [
    {'label': 'Étudiant', 'icone': Icons.school, 'couleur': Color(0xFF1565C0)},
    {'label': 'Élève', 'icone': Icons.menu_book, 'couleur': Color(0xFF6A1B9A)},
    {'label': 'Salarié', 'icone': Icons.work, 'couleur': Color(0xFF2E7D32)},
    {'label': 'Freelance', 'icone': Icons.laptop, 'couleur': Color(0xFFE65100)},
    {'label': 'Professionnel', 'icone': Icons.business_center, 'couleur': Color(0xFF00838F)},
  ];

  Future<void> _continuer() async {
    if (_profilSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis ton profil !')),
      );
      return;
    }
    if (_nomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entre ton prénom !')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('transactions');
    await prefs.remove('creances');
    await prefs.setString('profil', _profilSelectionne!);
    await prefs.setString('nom', _nomController.text.trim());

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardScreen(profil: _profilSelectionne!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond décoratif
          _fondDecoratif(),
          // Contenu
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Logo et titre
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: const Text('💰',
                              style: TextStyle(fontSize: 48)),
                        ),
                        const SizedBox(height: 16),
                        const Text('\$afe\$olde',
                            style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32))),
                        const Text('Gérez vos finances simplement',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Prénom
                  const Text('Ton prénom',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10)
                      ],
                    ),
                    child: TextField(
                      controller: _nomController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Jean, Marie...',
                        prefixIcon: const Icon(Icons.person,
                            color: Color(0xFF2E7D32)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Profil
                  const Text('Ton profil',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: profils.map((p) {
                      final selectionne = _profilSelectionne == p['label'];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _profilSelectionne = p['label']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: selectionne
                                ? (p['couleur'] as Color)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selectionne
                                  ? (p['couleur'] as Color)
                                  : Colors.grey.shade200,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8)
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(p['icone'] as IconData,
                                  color: selectionne
                                      ? Colors.white
                                      : p['couleur'] as Color,
                                  size: 32),
                              const SizedBox(height: 8),
                              Text(p['label'] as String,
                                  style: TextStyle(
                                      color: selectionne
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  // Bouton continuer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      onPressed: _continuer,
                      child: const Text('Commencer',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fondDecoratif() {
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

    // Cercles verts en haut
    paint.color = const Color(0xFF2E7D32).withOpacity(0.06);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.05), 120, paint);
    paint.color = const Color(0xFF2E7D32).withOpacity(0.04);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.12), 80, paint);

    // Pétales de fleurs
    paint.color = const Color(0xFFFFD700).withOpacity(0.07);
    for (int i = 0; i < 6; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.15 + i * 40, size.height * 0.85),
        20,
        paint,
      );
    }

    // Symboles argent stylisés (cercles dorés)
    paint.color = const Color(0xFFFFD700).withOpacity(0.05);
    canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.7), 60, paint);
    canvas.drawCircle(
        Offset(size.width * 0.05, size.height * 0.6), 40, paint);

    // Fleurs bas droite
    paint.color = const Color(0xFF2E7D32).withOpacity(0.05);
    canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.9), 80, paint);
    canvas.drawCircle(
        Offset(size.width * 0.75, size.height * 0.95), 50, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}