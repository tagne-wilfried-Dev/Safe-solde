enum DebtType { owedMe, iOwe }
enum DebtStatus { pending, settled }

class Debt {
  final String id;
  final String contactName;
  final double amount;
  final DebtType type;
  final DateTime dueDate;
  final DebtStatus status;

  Debt({
    required this.id,
    required this.contactName,
    required this.amount,
    required this.type,
    required this.dueDate,
    required this.status,
  });

  // Convertion en Map pour SharedPreferenc
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactName': contactName,
      'amount': amount,
      'type': type.name, //ic"owedMe" soi "iOwe"
      'dueDate': dueDate.toIso8601String(),
      'status': status.name, //ici "pending" ou "settled"
    };
  }

  // reconversion en objet
  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'] as String,
      contactName: map['contactName'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: DebtType.values.byName(map['type'] as String),
      dueDate: DateTime.parse(map['dueDate'] as String),
      status: DebtStatus.values.byName(map['status'] as String),
    );
  }

  
  Debt copyWith({
    String? id,
    String? contactName,
    double? amount,
    DebtType? type,
    DateTime? dueDate,
    DebtStatus? status,
  }) {
    return Debt(
      id: id ?? this.id,
      contactName: contactName ?? this.contactName,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Debt && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
