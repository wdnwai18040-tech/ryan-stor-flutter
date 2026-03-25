class Product {
  final String id;
  final String name;
  final String? imageUrl;
  final String categoryId;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.categoryId,
    this.isAvailable = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImage =
        json['imageUrl'] ??
        json['image_url'] ??
        json['image'] ??
        json['photo'] ??
        json['thumbnail'] ??
        json['image_path'] ??
        json['images'] ??
        json['media'] ??
        json['variations'];

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      imageUrl: _normalizeImageUrl(_extractImageValue(rawImage)),
      categoryId: (json['categoryId'] ?? json['category_id'])?.toString() ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  static String? _extractImageValue(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw;

    if (raw is List && raw.isNotEmpty) {
      return _extractImageValue(raw.first);
    }

    if (raw is Map) {
      const keys = [
        'url',
        'path',
        'image',
        'image_url',
        'imageUrl',
        'src',
        'full_url',
        'thumbnail',
      ];

      for (final key in keys) {
        if (raw.containsKey(key)) {
          final value = _extractImageValue(raw[key]);
          if (value != null && value.trim().isNotEmpty) return value;
        }
      }
    }
    return null;
  }

  static String? _normalizeImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;

    final value = url.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    // ✅ تم الإصلاح: إزالة المسافات الزائدة تماماً
    const base = 'https://api.ryanstor.com';

    if (value.startsWith('/')) return '$base$value';
    return '$base/$value';
  }
}

class ProductVariant {
  final int id;
  final String name;
  final String? description;

  // السعر الأصلي
  final double price;

  // السعر بعد الخصم
  final double finalPrice;

  // نسبة الخصم
  final double? discountPercentage;

  // هل الخصم مفعل
  final bool isDiscountActive;

  final String? imageUrl;
  final String variantType;
  final int availableCodes;
  final String availability;

  final bool requirePlayerId;
  final bool requirePlayerName;
  final bool requirePlayerEmail;
  final bool requirePlayerPassword;

  ProductVariant({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.finalPrice,
    required this.isDiscountActive,
    this.discountPercentage,
    this.imageUrl,
    required this.variantType,
    required this.availableCodes,
    required this.availability,
    this.requirePlayerId = false,
    this.requirePlayerName = false,
    this.requirePlayerEmail = false,
    this.requirePlayerPassword = false,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    final originalPrice =
        double.tryParse(json['price']?.toString() ?? '0') ?? 0.0;

    final calculatedFinalPrice =
        double.tryParse(json['final_price']?.toString() ?? '0') ??
        originalPrice;

    final discountPercent = double.tryParse(
      json['discount_percentage']?.toString() ?? '',
    );

    final discountActive = _toBool(json['is_discount_active']);

    return ProductVariant(
      id: int.parse(json['id']?.toString() ?? '0'),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),

      price: originalPrice,
      finalPrice: calculatedFinalPrice,
      discountPercentage: discountPercent,
      isDiscountActive: discountActive,

      imageUrl: Product._normalizeImageUrl(
        Product._extractImageValue(json['image_url'] ?? json['imageUrl']),
      ),

      variantType: json['variant_type']?.toString() ?? 'service',

      availableCodes:
          int.tryParse(json['available_quantity']?.toString() ?? '0') ?? 0,

      availability: json['availability']?.toString() ?? 'unavailable',

      requirePlayerId: _toBool(json['require_player_id']),
      requirePlayerName: _toBool(json['require_player_name']),
      requirePlayerEmail: _toBool(json['require_player_email']),
      requirePlayerPassword: _toBool(json['require_player_password']),
    );
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  }
}
