import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding/onboarding_notifier.dart';
import 'translations.dart';
import 'language_info.dart';

// ─── I18n State ──────────────────────────────────────────────────────────────

class I18nState {
  final String currentCode;
  final Map<String, String> translations;

  const I18nState({
    this.currentCode = 'en',
    this.translations = const {},
  });

  I18nState copyWith({String? currentCode, Map<String, String>? translations}) {
    return I18nState(
      currentCode: currentCode ?? this.currentCode,
      translations: translations ?? this.translations,
    );
  }

  /// Translate a key with optional {{placeholder}} replacements.
  String t(String key, [Map<String, String>? placeholders]) {
    var text = translations[key] ?? key;
    if (placeholders != null) {
      for (final entry in placeholders.entries) {
        text = text.replaceAll('{{${entry.key}}}', entry.value);
      }
    }
    return text;
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class I18nNotifier extends Notifier<I18nState> {
  @override
  I18nState build() {
    final initialCode = LanguageInfo.nameToCode(ref.watch(onboardingNotifierProvider).selectedLanguage);
    final map = Translations.forLanguage(initialCode);
    return I18nState(currentCode: initialCode, translations: map);
  }

  void setLanguage(String code) {
    if (code == state.currentCode) return;
    final map = Translations.forLanguage(code);
    state = I18nState(currentCode: code, translations: map);
  }
}

final i18nProvider = NotifierProvider<I18nNotifier, I18nState>(I18nNotifier.new);

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Convenience extension so any ConsumerWidget/ConsumerStatefulWidget can call
/// `ref.t('nav.home')` or `ref.t('home.events_count', {'count': '142'})`.
extension I18nExtension on WidgetRef {
  String t(String key, [Map<String, String>? placeholders]) {
    return watch(i18nProvider).t(key, placeholders);
  }
}

/// Convenience extension for use in non-Consumer widgets (e.g. StatelessWidget
/// wrapped with a Consumer). Only use for one-off reads — prefer WidgetRef.t for
/// reactive rebuilds.
extension I18nContextExtension on BuildContext {
  String t(String key, [Map<String, String>? placeholders]) {
    return ProviderScope.containerOf(this, listen: false).read(i18nProvider).t(key, placeholders);
  }
}
