import 'package:flutter/material.dart';
import '../../theme/gomandap_tokens.dart';

class GomandapScreen extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color backgroundColor;
  final bool useSafeAreaTop;
  final bool useSafeAreaBottom;
  final bool useHorizontalPadding;
  final EdgeInsetsGeometry? customPadding;
  final bool extendBodyBehindAppBar;
  final bool extendBody;
  final double maxWidth;

  const GomandapScreen({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.drawer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor = GomandapTokens.iceCreamGray,
    this.useSafeAreaTop = true,
    this.useSafeAreaBottom = true,
    this.useHorizontalPadding = true,
    this.customPadding,
    this.extendBodyBehindAppBar = false,
    this.extendBody = false,
    this.maxWidth = 600.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    // 1. Apply padding if requested
    if (useHorizontalPadding || customPadding != null) {
      content = Padding(
        padding: customPadding ?? const EdgeInsets.symmetric(horizontal: GomandapTokens.spacingLg),
        child: content,
      );
    }

    // 2. Wrap in maximum width constraint for web/tablets
    content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth), // Ensures layout doesn't stretch awkwardly
        child: content,
      ),
    );

    // 3. Apply Safe Area bounds around the constrained content
    if (useSafeAreaTop || useSafeAreaBottom) {
      content = SafeArea(
        top: useSafeAreaTop,
        bottom: useSafeAreaBottom,
        left: false,
        right: false,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: extendBody,
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
