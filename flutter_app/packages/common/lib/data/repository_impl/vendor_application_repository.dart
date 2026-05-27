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

  // In-memory store for offline/dev mode
  static final List<VendorApplication> _mockStore = [];

  VendorApplicationRepository(this._client);

  static const _table = 'vendor_applications';

  // ─── Submit ─────────────────────────────────────────────────────────────────

  /// Creates a new vendor application. Returns the created record (with id).
  Future<VendorApplication> submitApplication(VendorApplication draft) async {
    if (_client == null) {
      // Offline: generate a mock id and store in-memory
      final mock = draft.copyWith(
        id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
        submittedAt: DateTime.now(),
        status: VendorAppStatus.pending,
      );
      _mockStore.removeWhere((a) => a.phone == mock.phone);
      _mockStore.add(mock);
      debugPrint('[VendorRepo] Mock submit: ${mock.businessName}');
      return mock;
    }

    try {
      final data = await _client!
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
    if (_client == null) {
      final idx = _mockStore.indexWhere((a) => a.id == applicationId);
      if (idx != -1) {
        _mockStore[idx] = _mockStore[idx].copyWith(
          status: status,
          correctionNotes: correctionNotes,
          reviewedAt: DateTime.now(),
        );
      }
      return;
    }

    try {
      await _client!.from(_table).update({
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
    if (_client == null) {
      final idx = _mockStore.indexWhere((a) => a.id == applicationId);
      if (idx != -1) {
        _mockStore[idx] = updated.copyWith(
          id: applicationId,
          status: VendorAppStatus.underReview,
          correctionNotes: [],
        );
      }
      return;
    }

    final payload = updated.toInsertJson()
      ..['status'] = VendorAppStatus.underReview.toDbString()
      ..['correction_notes'] = []
      ..['reviewed_at'] = null;

    try {
      await _client!.from(_table).update(payload).eq('id', applicationId);
    } catch (e) {
      debugPrint('[VendorRepo] resubmit error: $e');
      rethrow;
    }
  }

  // ─── Streams (Supabase Realtime) ────────────────────────────────────────────

  /// Stream of ALL vendor applications — used by Admin panel.
  Stream<List<VendorApplication>> watchAllApplications() {
    if (_client == null) {
      // Mock: emit current store every 2 seconds to simulate real-time
      return Stream.periodic(const Duration(seconds: 2), (_) => List<VendorApplication>.from(_mockStore))
          .startWith(List<VendorApplication>.from(_mockStore));
    }

    return _client!
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('submitted_at', ascending: false)
        .map((rows) => rows.map(VendorApplication.fromJson).toList())
        .handleError((e) {
          debugPrint('[VendorRepo] watchAllApplications stream error: $e');
          return <VendorApplication>[];
        });
  }

  /// Stream of a single vendor's application, filtered by phone number.
  Stream<VendorApplication?> watchMyApplication(String phone) {
    if (_client == null) {
      return Stream.periodic(const Duration(seconds: 2), (_) {
        try {
          return _mockStore.firstWhere((a) => a.phone == phone);
        } catch (_) {
          return null;
        }
      }).startWith(() {
        try {
          return _mockStore.firstWhere((a) => a.phone == phone);
        } catch (_) {
          return null;
        }
      }());
    }

    return _client!
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('phone', phone)
        .order('submitted_at', ascending: false)
        .map((rows) => rows.isEmpty ? null : VendorApplication.fromJson(rows.first))
        .handleError((e) {
          debugPrint('[VendorRepo] watchMyApplication stream error: $e');
          return null;
        });
  }

  /// One-shot fetch for admin dashboard pending count badge.
  Future<int> fetchPendingCount() async {
    if (_client == null) {
      return _mockStore
          .where((a) => a.status == VendorAppStatus.pending)
          .length;
    }
    try {
      final response = await _client!
          .from(_table)
          .select('id')
          .eq('status', 'pending');
      return (response as List).length;
    } catch (e) {
      debugPrint('[VendorRepo] fetchPendingCount error: $e');
      return 0;
    }
  }
}

// ─── Extension for Stream.startWith ──────────────────────────────────────────
extension _StartWith<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
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
final vendorPhoneProvider = StateProvider<String>((ref) => '');

final myVendorApplicationProvider =
    StreamProvider<VendorApplication?>((ref) {
  final phone = ref.watch(vendorPhoneProvider);
  if (phone.isEmpty) return Stream.value(null);
  return ref.watch(vendorApplicationRepositoryProvider).watchMyApplication(phone);
});

/// Pending count for admin tab badge.
final vendorPendingCountProvider = FutureProvider<int>((ref) {
  return ref.watch(vendorApplicationRepositoryProvider).fetchPendingCount();
});
