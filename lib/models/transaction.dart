class Transaction {
  final String id;
  final String title;
  final double amount;
  final bool isIncome;
  final DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.date,
  });

  // methode pour convertir l'objet en Map pour la sauvegarde JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isIncome': isIncome,
      'date': date.toIso8601String(),
    };
  }

  // Methode pour recreer l'objet a partir d'un Map
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