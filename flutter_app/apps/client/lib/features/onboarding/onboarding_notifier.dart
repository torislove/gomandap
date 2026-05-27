import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
  final double? latitude;
  final double? longitude;

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
    this.latitude,
    this.longitude,
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
    double? latitude,
    double? longitude,
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
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

  Future<void> detectCurrentLocation() async {
    state = state.copyWith(isLocationSearching: true, isLocationSuccess: false);
    
    try {
      // 1. Check if location services are enabled
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Fall back gracefully with simulated delay to show animated pulse
        await Future.delayed(const Duration(milliseconds: 2200));
        setLocation('Hyderabad', 'Jubilee Hills');
        return;
      }

      // 2. Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Denied, fallback
          await Future.delayed(const Duration(milliseconds: 2200));
          setLocation('Hyderabad', 'Jubilee Hills');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Denied forever, fallback
        await Future.delayed(const Duration(milliseconds: 2200));
        setLocation('Hyderabad', 'Jubilee Hills');
        return;
      }

      // 3. Get coordinates (with moderate accuracy and a strict time limit to prevent hangs)
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 6),
      );

      // 4. Reverse geocode coordinates using geocoding package
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        
        // Extract a premium locality & city label
        String locality = place.subLocality ?? place.locality ?? 'Jubilee Hills';
        if (locality.isEmpty) locality = place.name ?? 'Jubilee Hills';
        
        String city = place.subAdministrativeArea ?? place.administrativeArea ?? 'Hyderabad';
        if (city.isEmpty) city = place.locality ?? 'Hyderabad';

        // Clean up formatting
        if (locality.toLowerCase() == city.toLowerCase()) {
          locality = 'Central Hub';
        }

        state = state.copyWith(
          detectedCity: city,
          detectedLocality: locality,
          latitude: position.latitude,
          longitude: position.longitude,
          isLocationSuccess: true,
          isLocationSearching: false,
        );
      } else {
        // Empty placemarks fallback
        setLocation('Hyderabad', 'Jubilee Hills');
      }
    } catch (e) {
      debugPrint('Geolocator execution exception (engaging mock geofence): $e');
      // Simulated processing delay for seamless animation progression
      await Future.delayed(const Duration(milliseconds: 2200));
      setLocation('Hyderabad', 'Jubilee Hills');
    }
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
