import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingUiState {
  final String selectedLanguage;
  final String userName;

  const OnboardingUiState({
    this.selectedLanguage = 'English',
    this.userName = '',
  });

  OnboardingUiState copyWith({
    String? selectedLanguage,
    String? userName,
  }) {
    return OnboardingUiState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      userName: userName ?? this.userName,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingUiState> {
  @override
  OnboardingUiState build() => const OnboardingUiState();

  void setLanguage(String lang) {
    state = state.copyWith(selectedLanguage: lang);
  }

  void setUserName(String name) {
    state = state.copyWith(userName: name);
  }
}

final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingUiState>(
  OnboardingNotifier.new,
);

