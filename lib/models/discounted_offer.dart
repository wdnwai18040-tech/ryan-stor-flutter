class DiscountedOffer {
  final int variantId;
  final String variantName;
  final double originalPrice;
  final double discountPercentage;
  final double finalPrice;
  final int productId;
  final String productName;
  final String? imageUrl;

  static const String baseUrl = "https://api.ryanstor.com";

  DiscountedOffer({
    required this.variantId,
    required this.variantName,
    required this.originalPrice,
    required this.discountPercentage,
    required this.finalPrice,
    required this.productId,
    required this.productName,
    this.imageUrl,
  });

  factory DiscountedOffer.fromJson(Map<String, dynamic> json) {
    String? rawImage = json['image_url'];

    return DiscountedOffer(
      variantId: int.parse(json['variant_id'].toString()),
      variantName: json['variant_name']?.toString() ?? '',
      originalPrice:
          double.tryParse(json['original_price'].toString()) ?? 0.0,
      discountPercentage:
          double.tryParse(json['discount_percentage'].toString()) ?? 0.0,
      finalPrice:
          double.tryParse(json['final_price'].toString()) ?? 0.0,
      productId: int.parse(json['product_id'].toString()),
      productName: json['product_name']?.toString() ?? '',
      imageUrl: rawImage != null
          ? (rawImage.startsWith('http')
              ? rawImage
              : '$baseUrl$rawImage')
          : null,
    );
  }
}