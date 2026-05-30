import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
class PincodeLocationData {
  final String village;
  final String state;
  final String district;

  PincodeLocationData({
    required this.village,
    required this.state,
    required this.district,
  });
}

class PincodeService {
  /// Fetches location details for a given 6-digit PIN code.
  /// Returns a list of available localities/villages under this PIN.
  static Future<List<PincodeLocationData>> fetchByPincode(String pincode) async {
    if (pincode.length != 6) return [];

    try {
      final baseUrl = EnvConfig.pincodeBaseUrl;
      final url = Uri.parse('$baseUrl/pincode/$pincode');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty && data[0]['Status'] == 'Success') {
          final List<dynamic> postOffices = data[0]['PostOffice'] ?? [];
          return postOffices.map((po) {
            return PincodeLocationData(
              village: po['Name']?.toString() ?? '',
              district: po['District']?.toString() ?? '',
              state: po['State']?.toString() ?? '',
            );
          }).toList();
        }
      }
      return [];
    } catch (e) {
      // In production, log this error
      return [];
    }
  }
}
