import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:ryaaans_store/core/network/network_service.dart';
import 'package:ryaaans_store/exceptions/no_internet_exception.dart';
import 'package:ryaaans_store/utils/api_error_handler.dart';
import 'package:ryaaans_store/models/discounted_offer.dart';

import '../exceptions/session_expired_exception.dart';

class ApiService {
  final NetworkService _networkService = NetworkService();
  static const String baseUrl = 'https://api.ryanstor.com';

  final String? token;

  ApiService({this.token});

  // =========================
  // HEADERS
  // =========================
  Map<String, String> _headers() {
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // =========================
  // 💰 Wallet
  // =========================
  Future<double> getWalletBalance() async {
    final data = await get('/wallet');

    if (data is Map && data.containsKey('balance')) {
      return double.parse(data['balance'].toString());
    }

    throw Exception('تعذر قراءة رصيد المحفظة');
  }

  // =========================
  // REQUESTS
  // =========================
 Future<dynamic> get(String endpoint) async {

  final hasInternet = await _networkService.hasInternet();
  if (!hasInternet) {
    throw NoInternetException();
  }

  final response = await http
      .get(Uri.parse('$baseUrl$endpoint'), headers: _headers())
      .timeout(const Duration(seconds: 10));

  return _handleResponse(response);
}

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {

  final hasInternet = await _networkService.hasInternet();
  if (!hasInternet) {
    throw Exception("NO_INTERNET");
  }

  final headers = {..._headers(), 'Content-Type': 'application/json'};

  final response = await http
      .post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      )
      .timeout(const Duration(seconds: 10));

  return _handleResponse(response);
}

  // =========================
  // 📤 Upload
  // =========================
  Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields,
    File imageFile,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );

    request.headers.addAll(_headers());
    request.fields.addAll(fields);

    final multipartFile = await http.MultipartFile.fromPath(
      'receipt',
      imageFile.path,
      contentType: MediaType.parse('image/jpeg'),
    );

    request.files.add(multipartFile);

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );

    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }
  
  // =========================
  // discounted offers
  // =========================
Future<List<DiscountedOffer>> getDiscountedOffers() async {
  final data = await get('/products/discounted');

  if (data is List) {
    return data
        .map((item) => DiscountedOffer.fromJson(item))
        .toList();
  }

  return [];
}

  // =========================
  // RESPONSE HANDLER (CORE)
  // =========================
  dynamic _handleResponse(http.Response response) {
    print("=== API DEBUG ===");
    print("URL STATUS: ${response.statusCode}");
    print("RAW BODY: ${response.body}");
    print("=================");

    String message = 'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا';

    try {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('message')) {
        message = data['message'].toString();
      }
    } catch (_) {}

    // SUCCESS
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final body = jsonDecode(response.body);

        if (body is Map && body.containsKey('success')) {
          if (body['success'] == true) {
            return body['data'];
          } else {
            throw Exception(body['message']?.toString() ?? message);
          }
        }

        return body;
      } catch (_) {
        return response.body;
      }
    }

    // SESSION EXPIRED
    if (response.statusCode == 401) {
      throw SessionExpiredException(message);
    }
    // OTHER ERRORS
    throw ApiErrorHandler.handle(response);
  }
}
