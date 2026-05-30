import 'package:flutter/painting.dart';

/// Supported language codes with display metadata.
class LanguageInfo {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final Color primaryColor;
  final Color accentColor;

  const LanguageInfo({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.primaryColor,
    required this.accentColor,
  });

  static const List<LanguageInfo> all = [
    LanguageInfo(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
      primaryColor: Color(0xFF6366F1),
      accentColor: Color(0xFF818CF8),
    ),
    LanguageInfo(
      code: 'te',
      name: 'Telugu',
      nativeName: 'తెలుగు',
      flag: '🇮🇳',
      primaryColor: Color(0xFFEC4899),
      accentColor: Color(0xFFF472B6),
    ),
    LanguageInfo(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '🇮🇳',
      primaryColor: Color(0xFFF97316),
      accentColor: Color(0xFFFB923C),
    ),
    LanguageInfo(
      code: 'ta',
      name: 'Tamil',
      nativeName: 'தமிழ்',
      flag: '🇮🇳',
      primaryColor: Color(0xFF10B981),
      accentColor: Color(0xFF34D399),
    ),
    LanguageInfo(
      code: 'kn',
      name: 'Kannada',
      nativeName: 'ಕನ್ನಡ',
      flag: '🇮🇳',
      primaryColor: Color(0xFF8B5CF6),
      accentColor: Color(0xFFA78BFA),
    ),
    LanguageInfo(
      code: 'ml',
      name: 'Malayalam',
      nativeName: 'മലയാളം',
      flag: '🇮🇳',
      primaryColor: Color(0xFF06B6D4),
      accentColor: Color(0xFF22D3EE),
    ),
    LanguageInfo(
      code: 'bn',
      name: 'Bengali',
      nativeName: 'বাংলা',
      flag: '🇮🇳',
      primaryColor: Color(0xFFE11D48),
      accentColor: Color(0xFFFB7185),
    ),
  ];

  /// Map language name (from onboarding) to language code.
  static String nameToCode(String languageName) {
    for (final lang in all) {
      if (lang.name == languageName) return lang.code;
    }
    return 'en';
  }
}
