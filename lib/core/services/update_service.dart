import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  final String latestVersion;
  final String minVersion;
  final bool forceUpdate;
  final String apkUrl;
  final String changelog;

  UpdateInfo({
    required this.latestVersion,
    required this.minVersion,
    required this.forceUpdate,
    required this.apkUrl,
    required this.changelog,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      latestVersion: json['latest_version'],
      minVersion: json['min_version'],
      forceUpdate: json['force_update'],
      apkUrl: json['apk_url'],
      changelog: json['changelog'],
    );
  }
}

class UpdateService {
  static const String _url =
      "https://api.ryanstor.com/api/app/version";

  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http.get(Uri.parse(_url));

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      return UpdateInfo.fromJson(data);
    } catch (e) {
      print("ERROR: $e");
      return null;
    }
  }

  static Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    print("CURRENT VERSION: ${packageInfo.version}");
    return packageInfo.version;
  }

  static bool isUpdateRequired(
    String currentVersion,
    String latestVersion,
  ) {
    return currentVersion != latestVersion;
  }
}