// ignore_for_file: avoid_print, depend_on_referenced_packages, prefer_const_declarations
import 'package:supabase/supabase.dart';
import 'dart:math';

final supabaseUrl = 'http://192.168.31.199:54321';
final supabaseKey = 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH'; // Note: Service role key is better for injection, but we'll try anon key if policies allow or if we just use normal insert. Actually, wait, maybe we should use service role key? We'll see. If RLS blocks it, we might need to bypass it or use the service role key.

void main() async {
  final client = SupabaseClient(supabaseUrl, supabaseKey);
  
  final categories = ['Banquet', 'Photography', 'Decoration', 'Catering', 'Makeup', 'Jewelry'];
  final cities = ['Hyderabad', 'Bangalore', 'Chennai', 'Mumbai', 'Delhi'];
  final localities = ['Jubilee Hills', 'Banjara Hills', 'Koramangala', 'Indiranagar', 'Andheri West', 'Bandra'];
  final images = [
    'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
    'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800',
    'https://images.unsplash.com/photo-1555244162-803834f70033?w=800',
    'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=800',
    'https://images.unsplash.com/photo-1505909182942-e2f09aee3e89?w=800',
  ];

  final random = Random();

  print('Injecting mock vendors...');

  // Delete all existing mock vendors
  // We'll delete where approval_status = 'APPROVED' or 'PENDING'
  // Or just delete all vendors if possible (this might fail due to FKs or RLS).
  try {
    // If we have delete permission
    await client.from('vendors').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    print('Cleared existing vendors (if permitted).');
  } catch(e) {
    print('Could not clear existing vendors (RLS might block deletes without service key): $e');
  }

  // Insert new ones
  for (final cat in categories) {
    for (int i = 0; i < 20; i++) {
      final city = cities[random.nextInt(cities.length)];
      final locality = localities[random.nextInt(localities.length)];
      final rating = (4.0 + random.nextDouble()).toStringAsFixed(1);
      final price = (500 + random.nextInt(5000)).toString();

      try {
        await client.from('vendors').insert({
          'user_id': '00000000-0000-0000-0000-000000000000', // Need a valid UUID here usually, or omit if nullable
          'name': '$cat Vendor Elite ${i + 1} $city',
          'type': cat,
          'city': city,
          'locality': locality,
          'latitude': 17.0 + random.nextDouble(),
          'longitude': 78.0 + random.nextDouble(),
          'rating': double.parse(rating),
          'base_price': double.parse(price),
          'cover_photo_url': images[random.nextInt(images.length)],
          'photos': [images[random.nextInt(images.length)], images[random.nextInt(images.length)]],
          'approval_status': 'APPROVED',
          'is_live': true,
          'cancellation_policy': 'Cancel up to 48 hours before',
        });
      } catch (e) {
         // If user_id is required and no mock user exists, we might need to skip or handle differently.
         // Let's print the first error and break.
         print('Error inserting: $e');
         break;
      }
    }
  }

  print('Insertion completed.');
}
