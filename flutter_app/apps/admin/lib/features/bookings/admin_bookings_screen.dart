import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';
import 'package:gomandap_common/domain/models/escrow.dart';

final allBookingsProvider = StreamProvider.autoDispose<List<Booking>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return Stream.value([]);
  
  return client
      .from('bookings')
      .stream(primaryKey: ['id'])
      .order('event_date', ascending: false)
      .map((rows) => rows.map((r) => Booking.fromJson(r)).toList());
});

class AdminBookingsScreen extends ConsumerWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(allBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Bookings', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, idx) {
              final b = bookings[idx];
              return Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: GomandapTokens.lightSlate),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(b.vendorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Status: ${b.status}\nAmount: ₹${b.totalAmount}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
