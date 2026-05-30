import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

class IfscData {
  final String bank;
  final String branch;
  final String city;

  IfscData({
    required this.bank,
    required this.branch,
    required this.city,
  });
}

class IfscService {
  /// Fetches bank details for a given 11-character IFSC code.
  static Future<IfscData?> fetchByIfsc(String ifsc) async {
    if (ifsc.length != 11) return null;

    try {
      final baseUrl = EnvConfig.ifscBaseUrl;
      final url = Uri.parse('$baseUrl/$ifsc');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return IfscData(
          bank: data['BANK']?.toString() ?? '',
          branch: data['BRANCH']?.toString() ?? '',
          city: data['CITY']?.toString() ?? '',
        );
      }
      return null;
    } catch (e) {
      // Log error in production
      return null;
    }
  }
}
