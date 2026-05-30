import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// States for the location detection flow
sealed class LocationState {
  const LocationState();
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationSuccess extends LocationState {
  final String city;
  final String locality;
  final double latitude;
  final double longitude;

  const LocationSuccess({
    required this.city,
    required this.locality,
    required this.latitude,
    required this.longitude,
  });
}

class LocationFailed extends LocationState {
  final String error;
  const LocationFailed({this.error = 'Location unavailable'});
}

class LocationNotifier extends Notifier<LocationState> {
  @override
  LocationState build() => const LocationInitial();

  Future<void> detectCurrentLocation() async {
    if (state is LocationLoading) return;
    state = const LocationLoading();

    if (kIsWeb) {
      state = const LocationSuccess(
        city: 'Hyderabad',
        locality: 'Jubilee Hills',
        latitude: 17.4319,
        longitude: 78.4172,
      );
      return;
    }

    try {
      // 1. Check if location services are enabled
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = const LocationFailed(error: 'Location services are disabled');
        return;
      }

      // 2. Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = const LocationFailed(error: 'Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = const LocationFailed(error: 'Location permissions are permanently denied, we cannot request permissions.');
        return;
      }

      // 3. Get coordinates
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 6),
        ),
      );

      // 4. Reverse geocode
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        String locality = place.subLocality ?? place.locality ?? 'Jubilee Hills';
        if (locality.isEmpty) locality = place.name ?? 'Jubilee Hills';
        String city = place.subAdministrativeArea ?? place.administrativeArea ?? 'Hyderabad';
        if (city.isEmpty) city = place.locality ?? 'Hyderabad';
        if (locality.toLowerCase() == city.toLowerCase()) {
          locality = 'Central Hub';
        }

        state = LocationSuccess(
          city: city,
          locality: locality,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } else {
        state = const LocationFailed(error: 'Could not resolve location address');
      }
    } catch (e) {
      debugPrint('Location detection error: $e');
      state = LocationFailed(error: 'Location error: $e');
    }
  }
}

final locationNotifierProvider = NotifierProvider<LocationNotifier, LocationState>(
  LocationNotifier.new,
);
