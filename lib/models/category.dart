class Category {
  final String id;
  final String name;
  final String? imageUrl;

  Category({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final rawImage =
        json['image'] ?? json['image_url'] ?? json['icon'] ?? json['photo'];

    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      imageUrl: _normalizeImageUrl(rawImage?.toString()),
    );
  }

  static String? _normalizeImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;

    final value = url.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    const base = 'https://api.ryanstor.com';
    if (value.startsWith('/')) return '$base$value';
    return '$base/$value';
  }
}
