import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  const PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final structured = json['structured_formatting'] as Map<String, dynamic>? ?? {};
    return PlaceSuggestion(
      placeId: json['place_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      mainText: structured['main_text'] as String? ?? '',
      secondaryText: structured['secondary_text'] as String? ?? '',
    );
  }
}

class PlaceCoordinates {
  final double latitude;
  final double longitude;
  final String city;
  final String locality;

  const PlaceCoordinates({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.locality,
  });
}

class PlacesService {
  final String _apiKey;

  PlacesService(this._apiKey);

  static const _autocompleteUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const _geocodeUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

  /// Get autocomplete suggestions restricted to India ('in')
  Future<List<PlaceSuggestion>> getSuggestions(String input) async {
    if (input.trim().isEmpty) return const [];
    
    if (_apiKey.isEmpty || _apiKey == 'placeholder-key' || _apiKey.contains('AIzaSy')) {
      // If it's the default placeholder or matches the placeholder prefix but needs local fallbacks:
      if (_apiKey.isEmpty || _apiKey == 'placeholder-key') {
        return _getMetropolitanFallbacks(input);
      }
    }

    try {
      final uri = Uri.parse('$_autocompleteUrl?input=${Uri.encodeComponent(input)}&key=$_apiKey&components=country:in');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictions = data['predictions'] as List<dynamic>? ?? [];
        return predictions.map((p) => PlaceSuggestion.fromJson(p as Map<String, dynamic>)).toList();
      } else {
        debugPrint('Places autocomplete response error: ${response.statusCode}');
        return _getMetropolitanFallbacks(input);
      }
    } catch (e) {
      debugPrint('Places autocomplete network error: $e');
      return _getMetropolitanFallbacks(input);
    }
  }

  /// Get latitude/longitude coordinates and address names by Place ID
  Future<PlaceCoordinates?> getCoordinates(PlaceSuggestion suggestion) async {
    if (_apiKey.isEmpty || _apiKey == 'placeholder-key') {
      return _getMetropolitanCoordsFallback(suggestion);
    }

    try {
      final uri = Uri.parse('$_geocodeUrl?place_id=${suggestion.placeId}&key=$_apiKey');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];
        if (results.isNotEmpty) {
          final result = results.first as Map<String, dynamic>;
          final geometry = result['geometry'] as Map<String, dynamic>? ?? {};
          final location = geometry['location'] as Map<String, dynamic>? ?? {};
          final lat = double.tryParse(location['lat']?.toString() ?? '') ?? 17.4319;
          final lng = double.tryParse(location['lng']?.toString() ?? '') ?? 78.4172;

          // Extract city/locality from address components
          final components = result['address_components'] as List<dynamic>? ?? [];
          String city = 'Hyderabad';
          String locality = suggestion.mainText;

          for (final comp in components) {
            final types = comp['types'] as List<dynamic>? ?? [];
            if (types.contains('locality')) {
              city = comp['long_name']?.toString() ?? city;
            } else if (types.contains('sublocality') || types.contains('neighborhood')) {
              locality = comp['long_name']?.toString() ?? locality;
            }
          }

          return PlaceCoordinates(
            latitude: lat,
            longitude: lng,
            city: city,
            locality: locality,
          );
        }
      }
    } catch (e) {
      debugPrint('Places geocoding network error: $e');
    }
    return _getMetropolitanCoordsFallback(suggestion);
  }

  /// High-fidelity offline metropolitan fallbacks for clean testing
  List<PlaceSuggestion> _getMetropolitanFallbacks(String query) {
    final lower = query.toLowerCase().trim();
    final allFallbacks = [
      const PlaceSuggestion(placeId: 'f1', description: 'Jubilee Hills, Hyderabad, Telangana', mainText: 'Jubilee Hills', secondaryText: 'Hyderabad, Telangana'),
      const PlaceSuggestion(placeId: 'f2', description: 'Madhapur, Hyderabad, Telangana', mainText: 'Madhapur', secondaryText: 'Hyderabad, Telangana'),
      const PlaceSuggestion(placeId: 'f3', description: 'Banjara Hills, Hyderabad, Telangana', mainText: 'Banjara Hills', secondaryText: 'Hyderabad, Telangana'),
      const PlaceSuggestion(placeId: 'f4', description: 'Indiranagar, Bangalore, Karnataka', mainText: 'Indiranagar', secondaryText: 'Bangalore, Karnataka'),
      const PlaceSuggestion(placeId: 'f5', description: 'Koramangala, Bangalore, Karnataka', mainText: 'Koramangala', secondaryText: 'Bangalore, Karnataka'),
      const PlaceSuggestion(placeId: 'f6', description: 'Whitefield, Bangalore, Karnataka', mainText: 'Whitefield', secondaryText: 'Bangalore, Karnataka'),
      const PlaceSuggestion(placeId: 'f7', description: 'Bandra West, Mumbai, Maharashtra', mainText: 'Bandra West', secondaryText: 'Mumbai, Maharashtra'),
      const PlaceSuggestion(placeId: 'f8', description: 'Andheri West, Mumbai, Maharashtra', mainText: 'Andheri West', secondaryText: 'Mumbai, Maharashtra'),
      const PlaceSuggestion(placeId: 'f9', description: 'Connaught Place, New Delhi, Delhi', mainText: 'Connaught Place', secondaryText: 'New Delhi, Delhi'),
      const PlaceSuggestion(placeId: 'f10', description: 'T Nagar, Chennai, Tamil Nadu', mainText: 'T Nagar', secondaryText: 'Chennai, Tamil Nadu'),
    ];

    return allFallbacks.where((s) => s.description.toLowerCase().contains(lower)).toList();
  }

  PlaceCoordinates _getMetropolitanCoordsFallback(PlaceSuggestion suggestion) {
    switch (suggestion.placeId) {
      case 'f1': return const PlaceCoordinates(latitude: 17.4319, longitude: 78.4172, city: 'Hyderabad', locality: 'Jubilee Hills');
      case 'f2': return const PlaceCoordinates(latitude: 17.4483, longitude: 78.3915, city: 'Hyderabad', locality: 'Madhapur');
      case 'f3': return const PlaceCoordinates(latitude: 17.4139, longitude: 78.4326, city: 'Hyderabad', locality: 'Banjara Hills');
      case 'f4': return const PlaceCoordinates(latitude: 12.9719, longitude: 77.6412, city: 'Bangalore', locality: 'Indiranagar');
      case 'f5': return const PlaceCoordinates(latitude: 12.9352, longitude: 77.6245, city: 'Bangalore', locality: 'Koramangala');
      case 'f6': return const PlaceCoordinates(latitude: 12.9698, longitude: 77.7500, city: 'Bangalore', locality: 'Whitefield');
      case 'f7': return const PlaceCoordinates(latitude: 19.0596, longitude: 72.8295, city: 'Mumbai', locality: 'Bandra West');
      case 'f8': return const PlaceCoordinates(latitude: 19.1363, longitude: 72.8273, city: 'Mumbai', locality: 'Andheri West');
      case 'f9': return const PlaceCoordinates(latitude: 28.6304, longitude: 77.2177, city: 'New Delhi', locality: 'Connaught Place');
      case 'f10': return const PlaceCoordinates(latitude: 13.0405, longitude: 80.2337, city: 'Chennai', locality: 'T Nagar');
      default: return const PlaceCoordinates(latitude: 17.4319, longitude: 78.4172, city: 'Hyderabad', locality: 'Jubilee Hills');
    }
  }
}

// ─── Riverpod Provider ────────────────────────────────────────────────────────

final placesServiceProvider = Provider<PlacesService>((ref) {
  const key = String.fromEnvironment('GOOGLE_PLACES_API_KEY', defaultValue: '');
  return PlacesService(key);
});
