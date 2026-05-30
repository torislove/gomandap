import '../models/vendor.dart';

abstract class VendorRepository {
  Future<List<Vendor>> getVendorsByCategory(String category);
  Stream<List<Vendor>> watchVendorsByCategory(String category);
  Future<List<Vendor>> getVendorsByCategoryAndProximity({
    required String category,
    required double latitude,
    required double longitude,
    double? maxDistanceKm,
  });
  Future<Vendor?> getVendorById(String id);
  Future<void> saveVendor(Vendor vendor);
}
