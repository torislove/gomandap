import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'presentation/dashboard/admin_dashboard_screen.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoMandap Administration Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: GomandapTokens.pearlWhite,
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: GomandapTokens.royalNavy,
          primary: GomandapTokens.royalNavy,
          secondary: GomandapTokens.champagneGoldStart,
        ),
      ),
      home: const AdminDashboardScreen(),
    );
  }
}
