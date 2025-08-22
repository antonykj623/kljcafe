class Ledger {
  final int? id;
  final String type; // "income" or "expense"
  final double amount;
  final String description;
  final String date;
  final String paymentmode;

  Ledger({
    this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.paymentmode
  });

  // Convert DB row → Model
  factory Ledger.fromMap(Map<String, dynamic> map) {
    return Ledger(
      id: map['id'] as int?,
      type: map['type'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      paymentmode: map['payment_mode'] ?? ''
    );
  }

  // Convert Model → DB row
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'date': date,
      'payment_mode':paymentmode
    };
  }
}
