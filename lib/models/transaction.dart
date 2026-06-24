class Transaction {
  final String libelle;
  final double montant;
  final bool estEntree;
  final DateTime date;
  final String categorie;

  Transaction({
    required this.libelle,
    required this.montant,
    required this.estEntree,
    required this.date,
    required this.categorie,
  });

  Map<String, dynamic> toJson() => {
    'libelle': libelle,
    'montant': montant,
    'estEntree': estEntree,
    'date': date.toIso8601String(),
    'categorie': categorie,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    libelle: json['libelle'],
    montant: json['montant'],
    estEntree: json['estEntree'],
    date: DateTime.parse(json['date']),
    categorie: json['categorie'] ?? 'Autre',
  );
}

