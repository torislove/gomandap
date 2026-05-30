import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';
import 'package:gomandap_common/domain/models/escrow.dart';

// ─── Repository ───────────────────────────────────────────────────────────────

class BookingRepository {
  final dynamic _client;

  BookingRepository(this._client);

  static const _bookingsTable = 'bookings';
  static const _milestonesTable = 'escrow_milestones';

  // ─── Create Booking with Escrow Milestones ─────────────────────────────────

  Future<Booking> createBooking(Booking draft) async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase client is offline. Real-time booking requires internet.');
    }

    try {
      // 1. Insert booking row
      final bookingData = await client
          .from(_bookingsTable)
          .insert(draft.toInsertJson())
          .select()
          .single();

      final createdBooking = Booking.fromJson(bookingData);
      final total = createdBooking.totalAmount;

      // 2. Create the 3 escrow milestones automatically
      final milestones = [
        {
          'booking_id': createdBooking.id,
          'title': 'Milestone 1: Advance Secure Deposit',
          'percentage': 25.0,
          'amount': total * 0.25,
          'trigger_event': 'Released immediately upon booking confirmation',
          'status': MilestoneStatus.released,
        },
        {
          'booking_id': createdBooking.id,
          'title': 'Milestone 2: Pre-Event Verification',
          'percentage': 50.0,
          'amount': total * 0.50,
          'trigger_event': 'Locked in Escrow. Released on event morning',
          'status': MilestoneStatus.held,
        },
        {
          'booking_id': createdBooking.id,
          'title': 'Milestone 3: Post-Event Completion',
          'percentage': 25.0,
          'amount': total * 0.25,
          'trigger_event': 'Locked in Escrow. Released after client verification',
          'status': MilestoneStatus.locked,
        },
      ];

      await client.from(_milestonesTable).insert(milestones);
      return createdBooking;
    } catch (e) {
      debugPrint('[BookingRepo] createBooking error: $e');
      rethrow;
    }
  }

  // ─── Watch Bookings (Real-Time Stream) ────────────────────────────────────

  Stream<List<Booking>> watchBookingsForClient(String clientId) {
    final client = _client;
    if (client == null) return Stream.value([]);

    return client
        .from(_bookingsTable)
        .stream(primaryKey: ['id'])
        .eq('client_id', clientId)
        .order('event_date', ascending: true)
        .map((rows) => rows.map((row) => Booking.fromJson(row)).toList())
        .handleError((e) {
          debugPrint('[BookingRepo] watchBookingsForClient stream error: $e');
          throw e;
        });
  }

  /// Stream of bookings for a vendor's Dashboard
  Stream<List<Booking>> watchBookingsForVendor(String vendorId) {
    final client = _client;
    if (client == null) return Stream.value([]);

    return client
        .from(_bookingsTable)
        .stream(primaryKey: ['id'])
        .eq('vendor_id', vendorId)
        .map((rows) => rows.map((row) => Booking.fromJson(row)).toList())
        .handleError((e) {
          debugPrint('[BookingRepo] watchBookingsForVendor stream error: $e');
          throw e;
        });
  }

  /// Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    final client = _client;
    if (client == null) throw StateError('Supabase offline');
    await client.from(_bookingsTable).update({
      'status': BookingStatus.cancelled,
    }).eq('id', bookingId);
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return BookingRepository(client);
});

/// Stream of bookings for the currently logged-in client
final clientBookingsProvider = StreamProvider.autoDispose<List<Booking>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null || client.auth.currentUser == null) {
    return Stream.value([]);
  }
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.watchBookingsForClient(client.auth.currentUser!.id);
});

/// Filtered by status - used by the tabs in BookingsScreen
final upcomingBookingsProvider = Provider.autoDispose<List<Booking>>((ref) {
  final allAsync = ref.watch(clientBookingsProvider);
  final all = allAsync.value ?? [];
  return all.where((b) => b.status == BookingStatus.confirmed || b.status == BookingStatus.pending).toList();
});

final completedBookingsProvider = Provider.autoDispose<List<Booking>>((ref) {
  final allAsync = ref.watch(clientBookingsProvider);
  final all = allAsync.value ?? [];
  return all.where((b) => b.status == BookingStatus.completed).toList();
});

final cancelledBookingsProvider = Provider.autoDispose<List<Booking>>((ref) {
  final allAsync = ref.watch(clientBookingsProvider);
  final all = allAsync.value ?? [];
  return all.where((b) => b.status == BookingStatus.cancelled).toList();
});
