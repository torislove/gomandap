
import 'package:flutter/material.dart';
import 'package:gomandap_common/theme/gomandap_theme.dart';
import 'core/router/app_router.dart';
class GoMandapApp extends StatelessWidget {
  const GoMandapApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp.router(
    title: 'GoMandap',
    theme: GomandapTheme.lightTheme,
    routerConfig: AppRouter.router,
    debugShowCheckedModeBanner: false,
  );
}
