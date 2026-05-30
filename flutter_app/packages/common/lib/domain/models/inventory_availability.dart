class InventoryAvailability {
  final String id;
  final String inventoryId;
  final DateTime availableDate;
  final bool isBooked;
  final String? lockedByBookingId;
  final DateTime createdAt;

  InventoryAvailability({
    required this.id,
    required this.inventoryId,
    required this.availableDate,
    required this.isBooked,
    this.lockedByBookingId,
    required this.createdAt,
  });

  factory InventoryAvailability.fromJson(Map<String, dynamic> json) {
    return InventoryAvailability(
      id: json['id'] as String,
      inventoryId: json['inventory_id'] as String,
      availableDate: DateTime.parse(json['available_date'] as String),
      isBooked: json['is_booked'] as bool? ?? false,
      lockedByBookingId: json['locked_by_booking_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventory_id': inventoryId,
      'available_date': availableDate.toIso8601String().split('T').first,
      'is_booked': isBooked,
      'locked_by_booking_id': lockedByBookingId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
