import 'package:freezed_annotation/freezed_annotation.dart';

part 'vendor.freezed.dart';
part 'vendor.g.dart';

@freezed
class Vendor with _$Vendor {
  const factory Vendor({
    required String id,
    required String businessName,
    required String category,
    required double rating,
    required int reviewCount,
    String? primaryImage,
    @Default([]) List<String> portfolioImages,
    @Default({}) Map<String, dynamic> pricingPackages,
    @Default({}) Map<String, dynamic> policies,
    double? latitude,
    double? longitude,
  }) = _Vendor;

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);
}
