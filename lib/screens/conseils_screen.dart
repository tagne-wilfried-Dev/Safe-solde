import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ConseilsScreen extends StatelessWidget {
  const ConseilsScreen({super.key});

  final List<Map<String, dynamic>> conseils = const [
    {
      'titre': 'La règle des 50/30/20',
      'description': '50% de tes revenus pour les besoins essentiels, 30% pour les loisirs, 20% pour l\'épargne.',
      'icone': Icons.pie_chart,
      'couleur': Color(0xFF2E7D32),
    },
    {
      'titre': 'Constitue un fonds d\'urgence',
      'description': 'Mets de côté l\'équivalent de 3 mois de dépenses en cas d\'imprévu.',
      'icone': Icons.savings,
      'couleur': Color(0xFF1565C0),
    },
    {
      'titre': 'Note chaque dépense',
      'description': 'Enregistre chaque transaction dès qu\'elle se produit pour ne rien oublier.',
      'icone': Icons.edit_note,
      'couleur': Color(0xFFE65100),
    },
    {
      'titre': 'Méfie-toi des petites dépenses',
      'description': 'Les petits achats quotidiens (café, données, crédits) s\'accumulent vite.',
      'icone': Icons.warning_amber,
      'couleur': Color(0xFFC62828),
    },
    {
      'titre': 'Anticipe tes tontines',
      'description': 'Note les dates de cotisation à l\'avance pour ne jamais être pris au dépourvu.',
      'icone': Icons.group,
      'couleur': Color(0xFF6A1B9A),
    },
    {
      'titre': 'Fixe-toi des objectifs',
      'description': 'Un objectif précis (ex: économiser 50 000 FCFA en 3 mois) te motive à mieux gérer.',
      'icone': Icons.flag,
      'couleur': Color(0xFF00838F),
    },
  ];

  final List<Map<String, dynamic>> ressources = const [
    {
      'titre': 'Comment gérer son budget au Cameroun',
      'type': 'Article',
      'icone': Icons.article,
      'url': 'https://www.google.com/search?q=gestion+budget+cameroun',
      'couleur': Color(0xFF2E7D32),
    },
    {
      'titre': 'La tontine : avantages et risques',
      'type': 'Article',
      'icone': Icons.article,
      'url': 'https://www.google.com/search?q=tontine+cameroun+avantages+risques',
      'couleur': Color(0xFF1565C0),
    },
    {
      'titre': 'Finances personnelles pour débutants',
      'type': 'Vidéo YouTube',
      'icone': Icons.play_circle,
      'url': 'https://www.youtube.com/results?search_query=finances+personnelles+afrique+francophone',
      'couleur': Color(0xFFC62828),
    },
    {
      'titre': 'Investir en Afrique : par où commencer',
      'type': 'Vidéo YouTube',
      'icone': Icons.play_circle,
      'url': 'https://www.youtube.com/results?search_query=investir+afrique+debutant',
      'couleur': Color(0xFFE65100),
    },
    {
      'titre': 'Épargne et patrimoine en Afrique',
      'type': 'Vidéo YouTube',
      'icone': Icons.play_circle,
      'url': 'https://www.youtube.com/results?search_query=epargne+patrimoine+afrique',
      'couleur': Color(0xFF6A1B9A),
    },
  ];

  Future<void> _ouvrir(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Conseils & Astuces',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section conseils
            const Text('💡 Astuces financières',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...conseils.map((c) => _carteConseil(c)),
            const SizedBox(height: 24),
            // Section ressources
            const Text('📚 Ressources utiles',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...ressources.map((r) => _carteRessource(r)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _carteConseil(Map<String, dynamic> c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (c['couleur'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(c['icone'] as IconData,
                color: c['couleur'] as Color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c['titre'] as String,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(c['description'] as String,
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteRessource(Map<String, dynamic> r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => _ouvrir(r['url'] as String),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (r['couleur'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(r['icone'] as IconData,
              color: r['couleur'] as Color, size: 22),
        ),
        title: Text(r['titre'] as String,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(r['type'] as String,
            style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        trailing: const Icon(Icons.open_in_new,
            color: Color(0xFF2E7D32), size: 18),
      ),
    );
  }
}