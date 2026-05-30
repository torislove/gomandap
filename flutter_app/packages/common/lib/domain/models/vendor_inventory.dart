enum InventoryType {
  perPlate('per_plate'),
  perDay('per_day'),
  perEvent('per_event');

  final String value;
  const InventoryType(this.value);

  factory InventoryType.fromValue(String val) {
    return InventoryType.values.firstWhere((e) => e.value == val, orElse: () => InventoryType.perDay);
  }
}

class VendorInventory {
  final String id;
  final String vendorId;
  final String title;
  final String? description;
  final InventoryType type;
  final double price;
  final int? maxCapacity;
  final DateTime createdAt;

  VendorInventory({
    required this.id,
    required this.vendorId,
    required this.title,
    this.description,
    required this.type,
    required this.price,
    this.maxCapacity,
    required this.createdAt,
  });

  factory VendorInventory.fromJson(Map<String, dynamic> json) {
    return VendorInventory(
      id: json['id'] as String,
      vendorId: json['vendor_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: InventoryType.fromValue(json['inv_type'] as String),
      price: (json['price'] as num).toDouble(),
      maxCapacity: json['max_capacity'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'title': title,
      'description': description,
      'inv_type': type.value,
      'price': price,
      'max_capacity': maxCapacity,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
