class WalletModel {
  final int id;
  final double balance;
  final String? walletNumber;
  final DateTime? createdAt;
  final int totalTransactions;
  final int pendingTopups;

  WalletModel({
    required this.id,
    required this.balance,
    required this.walletNumber,
    required this.createdAt,
    required this.totalTransactions,
    required this.pendingTopups,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] ?? 0,
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      walletNumber: json['wallet_number'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      totalTransactions: json['total_transactions'] ?? 0,
      pendingTopups: json['pending_topups'] ?? 0,
    );
  }

  WalletModel copyWith({
    double? balance,
    int? totalTransactions,
    int? pendingTopups,
  }) {
    return WalletModel(
      id: id,
      balance: balance ?? this.balance,
      walletNumber: walletNumber,
      createdAt: createdAt,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      pendingTopups: pendingTopups ?? this.pendingTopups,
    );
  }
}
