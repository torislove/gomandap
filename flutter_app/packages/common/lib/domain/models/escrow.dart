// Booking & Escrow domain models for Gomandap platform
// These map directly to Supabase DB tables: bookings & escrow_milestones

class BookingStatus {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
}

class MilestoneStatus {
  static const String released = 'released';
  static const String held = 'held';
  static const String locked = 'locked';
}

class EscrowMilestoneRecord {
  final String id;
  final String bookingId;
  final String title;
  final double percentage;
  final double amount;
  final String trigger;
  final String status;

  const EscrowMilestoneRecord({
    required this.id,
    required this.bookingId,
    required this.title,
    required this.percentage,
    required this.amount,
    required this.trigger,
    required this.status,
  });

  factory EscrowMilestoneRecord.fromJson(Map<String, dynamic> json) {
    return EscrowMilestoneRecord(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      percentage: double.tryParse(json['percentage']?.toString() ?? '0') ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      trigger: json['trigger_event']?.toString() ?? '',
      status: json['status']?.toString() ?? MilestoneStatus.locked,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_id': bookingId,
    'title': title,
    'percentage': percentage,
    'amount': amount,
    'trigger_event': trigger,
    'status': status,
  };
}

class Booking {
  final String id;
  final String clientId;
  final String vendorId;
  final String vendorName;
  final String vendorCategory;
  final String? vendorImageUrl;
  final DateTime eventDate;
  final int guestCount;
  final double totalAmount;
  final String status;
  final List<EscrowMilestoneRecord> milestones;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.clientId,
    required this.vendorId,
    required this.vendorName,
    required this.vendorCategory,
    this.vendorImageUrl,
    required this.eventDate,
    required this.guestCount,
    required this.totalAmount,
    required this.status,
    this.milestones = const [],
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      vendorId: json['vendor_id']?.toString() ?? '',
      vendorName: json['vendor_name']?.toString() ?? 'Vendor',
      vendorCategory: json['vendor_category']?.toString() ?? 'Service',
      vendorImageUrl: json['vendor_image_url']?.toString(),
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'].toString())
          : DateTime.now().add(const Duration(days: 30)),
      guestCount: int.tryParse(json['guest_count']?.toString() ?? '0') ?? 0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? BookingStatus.pending,
      milestones: (json['milestones'] as List<dynamic>?)
              ?.map((m) => EscrowMilestoneRecord.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'client_id': clientId,
    'vendor_id': vendorId,
    'vendor_name': vendorName,
    'vendor_category': vendorCategory,
    'vendor_image_url': vendorImageUrl,
    'event_date': eventDate.toIso8601String(),
    'guest_count': guestCount,
    'total_amount': totalAmount,
    'status': status,
  };
}
