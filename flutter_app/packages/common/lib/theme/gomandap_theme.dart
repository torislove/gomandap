
import 'package:flutter/material.dart';
import 'gomandap_tokens.dart';
class GomandapTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: GomandapTokens.pearlWhite,
    colorScheme: const ColorScheme.light(primary: GomandapTokens.royalNavy, secondary: GomandapTokens.emeraldGreen),
  );
}
