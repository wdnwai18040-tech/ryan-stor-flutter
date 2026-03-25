import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoyaltyTier {
  final String tier;
  final String displayName;
  final double discountPercent;
  final String iconUrl;
  final double totalSpent;
  final double progress;
  final double remaining;
  final String? nextTier;

  LoyaltyTier({
    required this.tier,
    required this.displayName,
    required this.discountPercent,
    required this.iconUrl,
    required this.totalSpent,
    required this.progress,
    required this.remaining,
    this.nextTier,
  });

  factory LoyaltyTier.fromJson(Map<String, dynamic> json) {
    String icon = json['icon_url'] ?? '';

    if (icon.isNotEmpty && !icon.startsWith("http")) {
      icon = "https://api.ryanstor.com$icon";
    }

    return LoyaltyTier(
      tier: json['tier'] ?? '',
      displayName: json['display_name'] ?? '',
      discountPercent:
          double.tryParse(json['discount_percent'].toString()) ?? 0,
      iconUrl: icon,
      totalSpent: double.tryParse(json['total_spent'].toString()) ?? 0,
      progress: double.tryParse(json['progress'].toString()) ?? 0,
      remaining: double.tryParse(json['remaining'].toString()) ?? 0,
      nextTier: json['next_tier'],
    );
  }
}

class LoyaltyService {
  static const String baseUrl = 'https://api.ryanstor.com';

  Future<LoyaltyTier?> fetchUserLoyalty() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token'); // أو 'token' حسب نظامك

      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/loyalty/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        final data = json.decode(response.body);
        return LoyaltyTier.fromJson(data);
      }
    } catch (e) {
      print('❌ Loyalty Error: $e');
    }
    return null;
  }
}
