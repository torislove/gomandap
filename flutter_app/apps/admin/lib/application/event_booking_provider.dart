import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';

// The data model for Admin bookings
class AdminBooking {
  final String id;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final String vendorId;
  final String vendorName;
  final String vendorCategory;
  final String vendorCity;
  final String eventDate;
  final int totalAmount;
  final String escrowStatus;
  final int currentMilestone; // 1: Advance, 2: Mid-way, 3: Completed
  final bool isClubbed;

  const AdminBooking({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.vendorId,
    required this.vendorName,
    required this.vendorCategory,
    required this.vendorCity,
    required this.eventDate,
    required this.totalAmount,
    required this.escrowStatus,
    required this.currentMilestone,
    this.isClubbed = false,
  });

  factory AdminBooking.fromJson(Map<String, dynamic> json) {
    return AdminBooking(
      id: json['id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      clientName: json['client_name']?.toString() ?? 'Unknown Client',
      clientPhone: json['client_phone']?.toString() ?? '',
      vendorId: json['vendor_id']?.toString() ?? '',
      vendorName: json['vendor_name']?.toString() ?? 'Unknown Vendor',
      vendorCategory: json['vendor_category']?.toString() ?? 'Category',
      vendorCity: json['vendor_city']?.toString() ?? 'City',
      eventDate: json['event_date']?.toString() ?? 'TBD',
      totalAmount: int.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      escrowStatus: json['escrow_status']?.toString() ?? 'Pending',
      currentMilestone: int.tryParse(json['current_milestone']?.toString() ?? '1') ?? 1,
      isClubbed: json['is_clubbed'] == true,
    );
  }
}

// Fallback mock data if Supabase isn't providing any live records
final List<AdminBooking> _mockBookingsFallback = [
  const AdminBooking(
    id: 'bkg-1',
    clientId: 'cli-rahul',
    clientName: 'Rahul Sharma',
    clientPhone: '+91 91102 33412',
    vendorId: 'vnd-venue-royal',
    vendorName: 'The Royal Mandapam & Gardens',
    vendorCategory: 'Venue',
    vendorCity: 'Hyderabad',
    eventDate: '12 Oct 2026',
    totalAmount: 650000,
    escrowStatus: 'Milestone 2 (Mid-way Locked)',
    currentMilestone: 2,
    isClubbed: true,
  ),
  const AdminBooking(
    id: 'bkg-2',
    clientId: 'cli-priyanka',
    clientName: 'Priyanka Patel',
    clientPhone: '+91 98845 11023',
    vendorId: 'vnd-decor-marigold',
    vendorName: 'Elite Marigold Decorators',
    vendorCategory: 'Decorator',
    vendorCity: 'Hyderabad',
    eventDate: '24 Nov 2026',
    totalAmount: 250000,
    escrowStatus: 'Milestone 1 (Advance Released)',
    currentMilestone: 1,
    isClubbed: true,
  ),
  const AdminBooking(
    id: 'bkg-3',
    clientId: 'cli-anirudh',
    clientName: 'Anirudh Reddy',
    clientPhone: '+91 70192 44321',
    vendorId: 'vnd-photo-pixel',
    vendorName: 'Pixel Perfect Wedding Films',
    vendorCategory: 'Photography',
    vendorCity: 'Hyderabad',
    eventDate: '08 Sep 2026',
    totalAmount: 150000,
    escrowStatus: 'Milestone 3 (Completed)',
    currentMilestone: 3,
    isClubbed: false,
  ),
];

/// Provides a real-time stream of all bookings from the Supabase `event_bookings` table.
/// Falls back to mock data if the table is empty or Supabase is offline.
final liveEventBookingsProvider = StreamProvider.autoDispose<List<AdminBooking>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  
  if (client == null) {
    return Stream.value(_mockBookingsFallback);
  }

  try {
    return client
        .from('event_bookings')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          if (data.isEmpty) return _mockBookingsFallback;
          return data.map((json) => AdminBooking.fromJson(json)).toList();
        });
  } catch (e) {
    return Stream.value(_mockBookingsFallback);
  }
});

/// A notifier to handle optimistic UI updates when releasing escrow funds
class EscrowActionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> releaseMilestone(String bookingId, int currentMilestone) async {
    state = const AsyncValue.loading();
    final client = ref.read(supabaseClientProvider);
    
    // Simulate optimistic delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (client != null) {
      try {
        final newMilestone = currentMilestone < 3 ? currentMilestone + 1 : 3;
        final newStatus = newMilestone == 3 
            ? 'Milestone 3 (Completed)' 
            : 'Milestone $newMilestone (Released)';
            
        await client.from('event_bookings').update({
          'current_milestone': newMilestone,
          'escrow_status': newStatus,
        }).eq('id', bookingId);
      } catch (e) {
        state = AsyncValue.error(e, StackTrace.current);
        return;
      }
    }
    
    state = const AsyncValue.data(null);
  }

  Future<void> resolveDispute(String bookingId, String resolutionStatus) async {
    state = const AsyncValue.loading();
    final client = ref.read(supabaseClientProvider);
    
    await Future.delayed(const Duration(milliseconds: 600));

    if (client != null) {
      try {
        await client.from('event_bookings').update({
          'escrow_status': resolutionStatus,
          'current_milestone': 3, // Force complete the cycle
        }).eq('id', bookingId);
      } catch (e) {
        state = AsyncValue.error(e, StackTrace.current);
        return;
      }
    }
    
    state = const AsyncValue.data(null);
  }
}

final escrowActionProvider = NotifierProvider<EscrowActionNotifier, AsyncValue<void>>(
  EscrowActionNotifier.new,
);
