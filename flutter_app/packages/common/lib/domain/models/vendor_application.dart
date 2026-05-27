import 'package:flutter/foundation.dart';

// ─── Status Enum ──────────────────────────────────────────────────────────────
enum VendorAppStatus {
  pending,
  underReview,
  needsCorrection,
  approved,
  rejected;

  static VendorAppStatus fromString(String s) {
    switch (s) {
      case 'under_review':  return VendorAppStatus.underReview;
      case 'needs_correction': return VendorAppStatus.needsCorrection;
      case 'approved':      return VendorAppStatus.approved;
      case 'rejected':      return VendorAppStatus.rejected;
      default:              return VendorAppStatus.pending;
    }
  }

  String toDbString() {
    switch (this) {
      case VendorAppStatus.underReview:       return 'under_review';
      case VendorAppStatus.needsCorrection:   return 'needs_correction';
      case VendorAppStatus.approved:          return 'approved';
      case VendorAppStatus.rejected:          return 'rejected';
      case VendorAppStatus.pending:           return 'pending';
    }
  }
}

// ─── Correction Note ──────────────────────────────────────────────────────────
@immutable
class CorrectionNote {
  final String field;
  final String message;

  const CorrectionNote({required this.field, required this.message});

  factory CorrectionNote.fromJson(Map<String, dynamic> j) =>
      CorrectionNote(field: j['field'] as String, message: j['message'] as String);

  Map<String, dynamic> toJson() => {'field': field, 'message': message};
}

// ─── Vendor Application Model ─────────────────────────────────────────────────
@immutable
class VendorApplication {
  final String id;
  final String businessName;
  final String ownerName;
  final String phone;
  final String city;
  final List<String> categories;
  final String? gstin;
  final String? description;
  final String? kycDocUrl;
  final List<String> portfolioUrls;
  final int priceMin;
  final int priceMax;
  final VendorAppStatus status;
  final List<CorrectionNote> correctionNotes;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  const VendorApplication({
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.phone,
    required this.city,
    required this.categories,
    this.gstin,
    this.description,
    this.kycDocUrl,
    this.portfolioUrls = const [],
    required this.priceMin,
    required this.priceMax,
    this.status = VendorAppStatus.pending,
    this.correctionNotes = const [],
    required this.submittedAt,
    this.reviewedAt,
  });

  // ─── JSON serialisation ────────────────────────────────────────────────────
  factory VendorApplication.fromJson(Map<String, dynamic> j) {
    return VendorApplication(
      id: j['id'] as String,
      businessName: j['business_name'] as String,
      ownerName: j['owner_name'] as String,
      phone: j['phone'] as String,
      city: j['city'] as String,
      categories: (j['category'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      gstin: j['gstin'] as String?,
      description: j['description'] as String?,
      kycDocUrl: j['kyc_doc_url'] as String?,
      portfolioUrls: (j['portfolio_urls'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      priceMin: (j['price_min'] as num?)?.toInt() ?? 0,
      priceMax: (j['price_max'] as num?)?.toInt() ?? 0,
      status: VendorAppStatus.fromString(j['status'] as String? ?? 'pending'),
      correctionNotes: (j['correction_notes'] as List<dynamic>? ?? [])
          .map((e) => CorrectionNote.fromJson(e as Map<String, dynamic>))
          .toList(),
      submittedAt: DateTime.parse(j['submitted_at'] as String),
      reviewedAt: j['reviewed_at'] != null
          ? DateTime.parse(j['reviewed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'business_name': businessName,
        'owner_name': ownerName,
        'phone': phone,
        'city': city,
        'category': categories,
        'gstin': gstin,
        'description': description,
        'kyc_doc_url': kycDocUrl,
        'portfolio_urls': portfolioUrls,
        'price_min': priceMin,
        'price_max': priceMax,
        'status': status.toDbString(),
        'correction_notes': correctionNotes.map((n) => n.toJson()).toList(),
      };

  VendorApplication copyWith({
    String? id,
    String? businessName,
    String? ownerName,
    String? phone,
    String? city,
    List<String>? categories,
    String? gstin,
    String? description,
    String? kycDocUrl,
    List<String>? portfolioUrls,
    int? priceMin,
    int? priceMax,
    VendorAppStatus? status,
    List<CorrectionNote>? correctionNotes,
    DateTime? submittedAt,
    DateTime? reviewedAt,
  }) {
    return VendorApplication(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      categories: categories ?? this.categories,
      gstin: gstin ?? this.gstin,
      description: description ?? this.description,
      kycDocUrl: kycDocUrl ?? this.kycDocUrl,
      portfolioUrls: portfolioUrls ?? this.portfolioUrls,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      status: status ?? this.status,
      correctionNotes: correctionNotes ?? this.correctionNotes,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
