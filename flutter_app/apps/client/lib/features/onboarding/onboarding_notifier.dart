import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingUiState {
  final String selectedLanguage;
  final String eventType;
  final String userName;
  final String detectedCity;
  final String detectedLocality;
  final double guestCount;
  final double estimatedBudget;
  final bool isLocationSearching;
  final bool isLocationSuccess;

  const OnboardingUiState({
    this.selectedLanguage = 'English',
    this.eventType = 'Wedding',
    this.userName = '',
    this.detectedCity = 'Hyderabad',
    this.detectedLocality = 'Jubilee Hills',
    this.guestCount = 300,
    this.estimatedBudget = 500000,
    this.isLocationSearching = false,
    this.isLocationSuccess = false,
  });

  OnboardingUiState copyWith({
    String? selectedLanguage,
    String? eventType,
    String? userName,
    String? detectedCity,
    String? detectedLocality,
    double? guestCount,
    double? estimatedBudget,
    bool? isLocationSearching,
    bool? isLocationSuccess,
  }) {
    return OnboardingUiState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      eventType: eventType ?? this.eventType,
      userName: userName ?? this.userName,
      detectedCity: detectedCity ?? this.detectedCity,
      detectedLocality: detectedLocality ?? this.detectedLocality,
      guestCount: guestCount ?? this.guestCount,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      isLocationSearching: isLocationSearching ?? this.isLocationSearching,
      isLocationSuccess: isLocationSuccess ?? this.isLocationSuccess,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingUiState> {
  OnboardingNotifier() : super(const OnboardingUiState());

  void setLanguage(String lang) {
    state = state.copyWith(selectedLanguage: lang);
  }

  void setEventType(String type) {
    state = state.copyWith(eventType: type);
  }

  void setUserName(String name) {
    state = state.copyWith(userName: name);
  }

  void setLocation(String city, String locality) {
    state = state.copyWith(
      detectedCity: city,
      detectedLocality: locality,
      isLocationSuccess: true,
      isLocationSearching: false,
    );
  }

  void startLocationSearch() {
    state = state.copyWith(isLocationSearching: true, isLocationSuccess: false);
  }

  void setGuestCount(double count) {
    state = state.copyWith(guestCount: count);
  }

  void setBudget(double budget) {
    state = state.copyWith(estimatedBudget: budget);
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingUiState>(
  (ref) => OnboardingNotifier(),
);
