import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'i18n_notifier.dart';

/// A reactive translated text widget.
/// Watches [i18nProvider] and rebuilds with the translated string when
/// the language changes. No need to convert the parent to a ConsumerWidget.
class Tr extends ConsumerWidget {
  final String translationKey;
  final Map<String, String>? placeholders;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final StrutStyle? strutStyle;

  const Tr(
    this.translationKey, {
    super.key,
    this.placeholders,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.strutStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(i18nProvider).t(translationKey, placeholders);
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      strutStyle: strutStyle,
    );
  }
}
