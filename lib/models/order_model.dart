class Order {
  final int id;
  final String status;
  final String productName;
  final String variantName;
  final double totalAmount;
  final DateTime createdAt;
  final String? licenseKey;

  Order({
    required this.id,
    required this.status,
    required this.productName,
    required this.variantName,
    required this.totalAmount,
    required this.createdAt,
    this.licenseKey,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      // id
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,

      // status
      status: json['status'] ?? 'processing',

      // product name (list + details)
      productName:
          json['product']?['name'] ??
          json['product_name'] ??
          json['name'] ??
          '',

      // variant name (list + details)
      variantName: json['variant']?['name'] ?? json['variant_name'] ?? '',

      // total amount
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,

      // created at
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),

      // license key (details only)
      licenseKey: json['license_key'],
    );
  }
}
