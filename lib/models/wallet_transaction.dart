
class WalletTransaction {
  final int id;
  final String type; // credit / debit
  final double amount;
  final String reference;
  final String status;
  final DateTime createdAt;
  final String walletNumber;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.reference,
    required this.status,
    required this.createdAt,
    required this.walletNumber,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
  return WalletTransaction(
    
    id: json['id'] ?? 0,
    type: json['type'] ?? '',
    amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
    reference: json['reference'] ?? '',
    status: json['status'] ?? '',
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(), // fallback آمن
    walletNumber: json['wallet_number'] ?? '',
  );
}

}
