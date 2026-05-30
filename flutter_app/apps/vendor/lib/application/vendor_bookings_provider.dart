import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';

// The data model for Vendor bookings
class VendorBooking {
  final String id;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final String vendorId;
  final String eventDate;
  final int totalAmount;
  final String escrowStatus;
  final int currentMilestone; // 1: Advance, 2: Mid-way, 3: Completed
  final bool isClubbed;

  const VendorBooking({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.vendorId,
    required this.eventDate,
    required this.totalAmount,
    required this.escrowStatus,
    required this.currentMilestone,
    this.isClubbed = false,
  });

  factory VendorBooking.fromJson(Map<String, dynamic> json) {
    return VendorBooking(
      id: json['id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      clientName: json['client_name']?.toString() ?? 'Unknown Client',
      clientPhone: json['client_phone']?.toString() ?? '',
      vendorId: json['vendor_id']?.toString() ?? '',
      eventDate: json['event_date']?.toString() ?? 'TBD',
      totalAmount: int.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      escrowStatus: json['escrow_status']?.toString() ?? 'Pending',
      currentMilestone: int.tryParse(json['current_milestone']?.toString() ?? '1') ?? 1,
      isClubbed: json['is_clubbed'] == true,
    );
  }
}

// Fallback mock data if Supabase isn't providing any live records
final List<VendorBooking> _mockBookingsFallback = [
  const VendorBooking(
    id: 'bkg-1',
    clientId: 'cli-rahul',
    clientName: 'Manoj Kumar & Kavya',
    clientPhone: '+91 91102 33412',
    vendorId: 'vnd-current',
    eventDate: '12 Oct 2026',
    totalAmount: 350000,
    escrowStatus: 'Pending',
    currentMilestone: 1,
    isClubbed: false,
  ),
  const VendorBooking(
    id: 'bkg-2',
    clientId: 'cli-priyanka',
    clientName: 'Nikhil & Priya',
    clientPhone: '+91 98845 11023',
    vendorId: 'vnd-current',
    eventDate: '18 Oct 2026',
    totalAmount: 120000,
    escrowStatus: 'Milestone 1 (Advance Released)',
    currentMilestone: 1,
    isClubbed: true,
  ),
];

/// Provides a real-time stream of all bookings from the Supabase `bookings` table for the current vendor.
final vendorBookingsProvider = StreamProvider.autoDispose<List<VendorBooking>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  
  if (client == null) {
    return Stream.value(_mockBookingsFallback);
  }

  // Assuming vendor is authenticated via phone or ID. 
  // We filter by vendor_id = client.auth.currentUser!.id
  try {
    final user = client.auth.currentUser;
    if (user == null) return Stream.value(_mockBookingsFallback);
    
    return client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('vendor_id', user.id)
        .order('created_at', ascending: false)
        .map((data) {
          if (data.isEmpty) return _mockBookingsFallback;
          return data.map((json) => VendorBooking.fromJson(json)).toList();
        });
  } catch (e) {
    return Stream.value(_mockBookingsFallback);
  }
});

/// A notifier to handle vendor actions on a proposal (Accept, Decline, File Dispute)
class VendorActionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> updateBookingStatus(String bookingId, String status) async {
    state = const AsyncValue.loading();
    final client = ref.read(supabaseClientProvider);
    
    // Simulate optimistic delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (client != null) {
      try {
        await client.from('bookings').update({
          'escrow_status': status,
        }).eq('id', bookingId);
      } catch (e) {
        state = AsyncValue.error(e, StackTrace.current);
        return;
      }
    }
    
    state = const AsyncValue.data(null);
  }
}

final vendorActionProvider = NotifierProvider<VendorActionNotifier, AsyncValue<void>>(
  VendorActionNotifier.new,
);
