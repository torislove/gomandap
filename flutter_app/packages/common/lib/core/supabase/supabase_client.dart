import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure helper to safely initialize Supabase client.
class SupabaseService {
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static Future<void> initializeSafe() async {
    if (_initialized) return;
    try {
      await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://placeholder-project.supabase.co'),
        anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'placeholder-key'),
      );
      _initialized = true;
    } catch (e) {
      debugPrint('Supabase Service safe-caught initialization exception (falling back to premium offline mocks): $e');
      _initialized = false;
    }
  }
}

/// Raw Supabase client provider. Returns null if uninitialized/offline.
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  if (!SupabaseService.isInitialized) return null;
  const url = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://placeholder-project.supabase.co');
  if (url.contains('placeholder-project')) {
    return null;
  }
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});

/// Live database connection status checker (performs quick health ping).
final supabaseConnectedProvider = FutureProvider<bool>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return false;
  try {
    // Perform a lightweight query to confirm active table connectivity
    await client.from('vendors').select('id').limit(1).maybeSingle();
    return true;
  } catch (e) {
    debugPrint('⚡ Supabase live database connection ping failed: $e');
    return false;
  }
});

/// Dynamic active categories stream. Falls back to premium default category indices.
final activeCategoriesStreamProvider = StreamProvider<List<int>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    return Stream.value([1, 2, 3, 4, 5, 9, 13, 17]);
  }

  return client
      .from('app_configurations')
      .stream(primaryKey: ['id'])
      .map((data) {
        if (data.isEmpty) return [1, 2, 3, 4, 5, 9, 13, 17];
        final list = data.first['active_categories'] as List<dynamic>?;
        return list?.map((e) => int.parse(e.toString())).toList() ?? [1, 2, 3, 4, 5, 9, 13, 17];
      })
      .handleError((err) {
        debugPrint('Supabase categories stream error (returning default mocks): $err');
        return [1, 2, 3, 4, 5, 9, 13, 17];
      });
});

/// Dynamic hero carousel banners stream with offline-first cache.
final heroCarouselsFutureProvider = StreamProvider<List<Map<String, String>>>((ref) async* {
  final prefs = await SharedPreferences.getInstance();
  final defaultBanners = [
    {
      'image_url': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
      'title': 'Grand Ballroom Reopenings',
      'subtitle': 'Flat 20% off on premium venues',
      'target_route': '/search?category=venue',
    },
    {
      'image_url': 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800',
      'title': 'Sangeet Choreography Special',
      'subtitle': 'Book elite performance packages',
      'target_route': '/search?category=choreographer',
    },
  ];

  // 1. Instantly yield cached banners if available
  final cachedStr = prefs.getString('cache_hero_banners');
  if (cachedStr != null) {
    try {
      final List<dynamic> decoded = jsonDecode(cachedStr);
      final List<Map<String, String>> cachedBanners = decoded.map((e) => Map<String, String>.from(e)).toList();
      yield cachedBanners;
    } catch (e) {
      debugPrint('Banner cache parsing error: $e');
    }
  } else {
    // If no cache, yield default while fetching
    yield defaultBanners;
  }

  final client = ref.watch(supabaseClientProvider);
  if (client == null) return;

  try {
    final response = await client
        .from('home_carousels')
        .select()
        .eq('is_active', true)
        .order('display_order', ascending: true);

    if (response.isNotEmpty) {
      final freshBanners = response.map<Map<String, String>>((row) => {
        'image_url': row['image_url']?.toString() ?? '',
        'title': row['title']?.toString() ?? '',
        'subtitle': row['subtitle']?.toString() ?? '',
        'target_route': row['target_route']?.toString() ?? '',
      }).toList();
      
      // Persist to cache
      await prefs.setString('cache_hero_banners', jsonEncode(freshBanners));
      
      // Yield fresh data
      yield freshBanners;
    }
  } catch (e) {
    debugPrint('Supabase carousels load error (returning premium mocks): $e');
  }
});

/// Dynamic sponsorship sangeet campaign config.
final activeCampaignFutureProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final defaultCampaign = {
    'title': 'GoMandap Elite Events',
    'description': 'Crafting grand memories, managing sangeet packages, sound setups & catering.',
    'action_label': 'Book Consult',
    'svg_animation_speed': 1.0,
    'glow_color': '#DFBA73',
  };

  if (client == null) return defaultCampaign;

  try {
    final response = await client
        .from('sponsorship_campaigns')
        .select()
        .eq('is_active', true)
        .limit(1)
        .maybeSingle();

    if (response == null) return defaultCampaign;

    return {
      'title': response['title']?.toString() ?? defaultCampaign['title'],
      'description': response['description']?.toString() ?? defaultCampaign['description'],
      'action_label': response['action_label']?.toString() ?? defaultCampaign['action_label'],
      'svg_animation_speed': double.tryParse(response['svg_animation_speed']?.toString() ?? '') ?? 1.0,
      'glow_color': response['glow_color']?.toString() ?? defaultCampaign['glow_color'],
    };
  } catch (e) {
    debugPrint('Supabase campaign load error (returning premium mocks): $e');
    return defaultCampaign;
  }
});
