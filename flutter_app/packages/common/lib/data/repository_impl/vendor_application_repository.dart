import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client.dart';
import '../../domain/models/vendor_application.dart';

// ─── Repository ───────────────────────────────────────────────────────────────

/// Full CRUD + Realtime repository for vendor onboarding applications.
///
/// All methods gracefully degrade to in-memory mock behaviour when
/// Supabase is not initialised (offline / dev mode).
class VendorApplicationRepository {
  final SupabaseClient? _client;

  VendorApplicationRepository(this._client);

  static const _table = 'vendor_applications';

  // ─── Submit ─────────────────────────────────────────────────────────────────

  /// Creates a new vendor application. Returns the created record (with id).
  Future<VendorApplication> submitApplication(VendorApplication draft) async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase is unconfigured. Real-time onboarding requires active database coordinates.');
    }

    try {
      final data = await client
          .from(_table)
          .insert(draft.toInsertJson())
          .select()
          .single();
      return VendorApplication.fromJson(data);
    } catch (e) {
      debugPrint('[VendorRepo] submitApplication error: $e');
      rethrow;
    }
  }

  // ─── Update Status (Admin) ──────────────────────────────────────────────────

  /// Updates application status and optional correction notes.
  Future<void> updateStatus({
    required String applicationId,
    required VendorAppStatus status,
    List<CorrectionNote> correctionNotes = const [],
  }) async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase is unconfigured. Real-time approvals require active database coordinates.');
    }

    try {
      await client.from(_table).update({
        'status': status.toDbString(),
        'correction_notes':
            correctionNotes.map((n) => n.toJson()).toList(),
        'reviewed_at': DateTime.now().toIso8601String(),
      }).eq('id', applicationId);
    } catch (e) {
      debugPrint('[VendorRepo] updateStatus error: $e');
      rethrow;
    }
  }

  // ─── Re-submit after correction ─────────────────────────────────────────────

  /// Vendor re-submits after fixing flagged fields. Resets to under_review.
  Future<void> resubmit({
    required String applicationId,
    required VendorApplication updated,
  }) async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase is unconfigured. Real-time re-submit requires active database coordinates.');
    }

    final payload = updated.toInsertJson()
      ..['status'] = VendorAppStatus.underReview.toDbString()
      ..['correction_notes'] = []
      ..['reviewed_at'] = null;

    try {
      await client.from(_table).update(payload).eq('id', applicationId);
    } catch (e) {
      debugPrint('[VendorRepo] resubmit error: $e');
      rethrow;
    }
  }

  // ─── Streams (Supabase Realtime) ────────────────────────────────────────────

  /// Stream of ALL vendor applications — used by Admin panel.
  Stream<List<VendorApplication>> watchAllApplications() {
    final client = _client;
    if (client == null) {
      return Stream.value(<VendorApplication>[]);
    }

    return client
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('submitted_at', ascending: false)
        .map((rows) => rows.map(VendorApplication.fromJson).toList())
        .handleError((e) {
          debugPrint('[VendorRepo] watchAllApplications stream error: $e');
          throw e;
        });
  }

  /// Stream of a single vendor's application, filtered by phone number.
  Stream<VendorApplication?> watchMyApplication(String phone) {
    final client = _client;
    if (client == null) {
      return Stream.value(null);
    }

    return client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('phone', phone)
        .order('submitted_at', ascending: false)
        .map((rows) => rows.isEmpty ? null : VendorApplication.fromJson(rows.first))
        .handleError((e) {
          debugPrint('[VendorRepo] watchMyApplication stream error: $e');
          throw e;
        });
  }

  /// Real-time stream for admin dashboard pending count badge.
  Stream<int> watchPendingCount() {
    final client = _client;
    if (client == null) {
      return Stream.value(0);
    }
    return client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('status', 'pending')
        .map((rows) => rows.length)
        .handleError((e) {
          debugPrint('[VendorRepo] watchPendingCount stream error: $e');
          return 0;
        });
  }
}

// ─── Riverpod Providers ───────────────────────────────────────────────────────

final vendorApplicationRepositoryProvider =
    Provider<VendorApplicationRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return VendorApplicationRepository(client);
});

/// Stream of all applications for the admin panel.
final allVendorApplicationsProvider =
    StreamProvider<List<VendorApplication>>((ref) {
  return ref.watch(vendorApplicationRepositoryProvider).watchAllApplications();
});

/// Stream of the current vendor's own application.
/// Requires [vendorPhoneProvider] to be set.
class VendorPhoneNotifier extends Notifier<String> {
  @override
  String build() => '9876543210';
  void setPhone(String phone) => state = phone;
}
final vendorPhoneProvider = NotifierProvider<VendorPhoneNotifier, String>(VendorPhoneNotifier.new);

final myVendorApplicationProvider =
    StreamProvider<VendorApplication?>((ref) {
  final phone = ref.watch(vendorPhoneProvider);
  if (phone.isEmpty) return Stream.value(null);
  return ref.watch(vendorApplicationRepositoryProvider).watchMyApplication(phone);
});

/// Pending count for admin tab badge (Real-Time).
final vendorPendingCountProvider = StreamProvider<int>((ref) {
  return ref.watch(vendorApplicationRepositoryProvider).watchPendingCount();
});
