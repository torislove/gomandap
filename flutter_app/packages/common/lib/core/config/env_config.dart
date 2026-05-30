import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }

  // Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? 'https://default-url.supabase.co';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? 'default_anon_key';

  // APIs
  static String get mapboxAccessToken => dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  static String get razorpayKey => dotenv.env['RAZORPAY_KEY'] ?? '';
  static String get whatsappApiToken => dotenv.env['WHATSAPP_API_TOKEN'] ?? '';
  static String get resendApiKey => dotenv.env['RESEND_API_KEY'] ?? '';

  // API Base URLs (if needed to override)
  static String get pincodeBaseUrl => dotenv.env['PINCODE_API_URL'] ?? 'https://api.postalpincode.in';
  static String get ifscBaseUrl => dotenv.env['IFSC_API_URL'] ?? 'https://ifsc.razorpay.com';
}
