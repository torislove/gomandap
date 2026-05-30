// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VendorImpl _$$VendorImplFromJson(Map<String, dynamic> json) => _$VendorImpl(
      id: json['id'] as String,
      businessName: json['businessName'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      primaryImage: json['primaryImage'] as String?,
      portfolioImages: (json['portfolioImages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      pricingPackages:
          json['pricingPackages'] as Map<String, dynamic>? ?? const {},
      policies: json['policies'] as Map<String, dynamic>? ?? const {},
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$VendorImplToJson(_$VendorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessName': instance.businessName,
      'category': instance.category,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'primaryImage': instance.primaryImage,
      'portfolioImages': instance.portfolioImages,
      'pricingPackages': instance.pricingPackages,
      'policies': instance.policies,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
