class GomandapIdGenerator {
  static String formatVendorId(String rawId, [String category = '']) {
    if (rawId.isEmpty) return 'GM-VND-GP-2026-0000';
    final hash = rawId.hashCode.abs() % 10000;
    
    String code = 'GP';
    final c = category.toLowerCase();
    if (c.contains('venue') || c.contains('banquet') || c.contains('mandap')) {
      code = 'VN';
    } else if (c.contains('photo')) {
      code = 'PH';
    } else if (c.contains('decor')) {
      code = 'DC';
    } else if (c.contains('cater')) {
      code = 'CT';
    } else if (c.contains('makeup')) {
      code = 'MK';
    }
    
    return 'GM-VND-$code-2026-${hash.toString().padLeft(4, '0')}';
  }

  static String formatClientId(String rawId) {
    if (rawId.isEmpty) return 'GM-CLI-2026-0000';
    final hash = rawId.hashCode.abs() % 10000;
    return 'GM-CLI-2026-${hash.toString().padLeft(4, '0')}';
  }

  static String formatBookingId(String rawId) {
    if (rawId.isEmpty) return 'GM-BKG-2026-0000';
    final hash = rawId.hashCode.abs() % 10000;
    return 'GM-BKG-2026-${hash.toString().padLeft(4, '0')}';
  }
}
