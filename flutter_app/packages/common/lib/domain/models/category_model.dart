import 'package:flutter/material.dart';

class CategoryDetails {
  final int id;
  final String name;
  final String imageUrl;
  final IconData fallbackIcon;
  final List<String> subServices;
  final List<String> deepFilterKeys;
  final Color accent;

  const CategoryDetails({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.fallbackIcon,
    required this.subServices,
    required this.deepFilterKeys,
    this.accent = const Color(0xFF0F172A), // default royalNavy
  });
}

/// The complete list of 20 Overarching Industry-Standard Wedding Categories modeled after WedMeGood & WeddingBazaar
const List<CategoryDetails> weddingCategoriesList = [
  CategoryDetails(
    id: 1,
    name: 'Banquet Halls',
    imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=400',
    fallbackIcon: Icons.account_balance_rounded,
    subServices: ['Luxury Banquets', 'AC Banquet Halls', 'Small Function Halls', 'Destination Ballroom'],
    deepFilterKeys: ['Capacity', 'AC Status', 'Parking Bays', 'Rooms Available'],
  ),
  CategoryDetails(
    id: 21,
    name: 'Kalyana Mandapams',
    imageUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=400',
    fallbackIcon: Icons.temple_hindu_rounded,
    subServices: ['Traditional Marriage Halls', 'Vedic Kalyana Mandapams', 'Heritage Mandapams'],
    deepFilterKeys: ['Capacity', 'Vedic Priest Support', 'Dining Capacity', 'Rooms Available'],
  ),
  CategoryDetails(
    id: 22,
    name: 'Open Lawns',
    imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400',
    fallbackIcon: Icons.nature_people_rounded,
    subServices: ['Fairy-Light Lawns', 'Marriage Gardens', 'Farmhouses', 'Lakeside Lawns'],
    deepFilterKeys: ['Guest Capacity', 'Catering External Allowed', 'Decor Setup Speed', 'Parking Bays'],
  ),
  CategoryDetails(
    id: 2,
    name: 'Photographers',
    imageUrl: 'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=400',
    fallbackIcon: Icons.camera_alt_rounded,
    subServices: ['Candid Photography', 'Traditional Shoots', 'Pre-Wedding Shoot', 'Cinematography', 'Drone Coverage'],
    deepFilterKeys: ['Raw Footage Policy', 'Delivery Speed', 'Team Size', 'Camera Brand'],
  ),
  CategoryDetails(
    id: 3,
    name: 'Bridal Makeup',
    imageUrl: 'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=400',
    fallbackIcon: Icons.brush_rounded,
    subServices: ['Bridal Makeup Artist', 'Airbrush Specialists', 'HD Makeup', 'Family Makeup', 'Pre-Bridal Grooming'],
    deepFilterKeys: ['MAC/Huda Premium Brands', 'Trial Session Fee', 'Hair Styling Included', 'Draping Support'],
  ),
  CategoryDetails(
    id: 4,
    name: 'Decorators',
    imageUrl: 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=400',
    fallbackIcon: Icons.auto_awesome_rounded,
    subServices: ['Floral Mandap Decor', 'Acrylic Glass Mandaps', 'Royal Carved Pillars', 'Boho Chic Backdrops', 'Fairy Lights Setup'],
    deepFilterKeys: ['Setup Hours Needed', 'Floral Grade (Fresh/Silk)', 'Sound Laser AV', 'Seating Layouts'],
  ),
  CategoryDetails(
    id: 5,
    name: 'Catering',
    imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',
    fallbackIcon: Icons.restaurant_rounded,
    subServices: ['Pure Veg Buffets', 'Multi-Cuisine Catering', 'Live Chaat Counters', 'Dessert Bars', 'Regional Specialties', 'Welcome Cocktails'],
    deepFilterKeys: ['Min Plates Booking', 'Live Counter Charge', 'Sweets Include Ratio', 'Taxes status'],
  ),
  CategoryDetails(
    id: 6,
    name: 'Mehndi Art',
    imageUrl: 'https://images.unsplash.com/photo-1542382257-201b72a27679?w=400',
    fallbackIcon: Icons.edit_rounded,
    subServices: ['Traditional Indian Bridal', 'Arabic Intricate Designs', 'Minimalist Mehndi', 'Baraat Portrait Mehndi'],
    deepFilterKeys: ['Mehndi Material Grade', 'Mehndi Team Size', 'Charges Per Arm', 'Travel Surcharge'],
  ),
  CategoryDetails(
    id: 7,
    name: 'Invitations',
    imageUrl: 'https://images.unsplash.com/photo-1512909006721-3d6018887383?w=400',
    fallbackIcon: Icons.mail_rounded,
    subServices: ['Physical Cards & Scrolls', 'Luxury Boxed Invites', 'Digital E-cards', 'Video Invitation Reels'],
    deepFilterKeys: ['Min Order Count', 'Alteration Loops', 'Foil/Letterpress Finish', 'Shipping Days'],
  ),
  CategoryDetails(
    id: 8,
    name: 'Bridal Wear',
    imageUrl: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400',
    fallbackIcon: Icons.checkroom_rounded,
    subServices: ['Bridal Lehengas', 'Kanjeevaram Sarees', 'Reception Gowns', 'Custom Designer Wear'],
    deepFilterKeys: ['Alteration Loops', 'Customization Weeks', 'Fitting Session Trials', 'Accessories Box'],
  ),
  CategoryDetails(
    id: 10,
    name: 'Groom Wear',
    imageUrl: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=400',
    fallbackIcon: Icons.checkroom_outlined,
    subServices: ['Designer Sherwanis', 'Suits & Tuxedos', 'Indo-Western Sets', 'Traditional Safas & Mojris'],
    deepFilterKeys: ['Alteration Loops', 'Fitting Session Trials', 'Customization Weeks', 'Styling Consultation'],
  ),
  CategoryDetails(
    id: 12,
    name: 'Jewellery',
    imageUrl: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=400',
    fallbackIcon: Icons.diamond_rounded,
    subServices: ['Antique Temple Gold', 'Kundan & Polki Sets', 'Precious Diamond Bridal', 'Pre-Wedding Rentals'],
    deepFilterKeys: ['Hallmarked Certified', 'Security Deposit Rent', 'Alteration Support', 'Return Grace Days'],
  ),
  CategoryDetails(
    id: 17,
    name: 'Planners',
    imageUrl: 'https://images.unsplash.com/photo-1507504038482-7621f3b723f3?w=400',
    fallbackIcon: Icons.assignment_rounded,
    subServices: ['Full Event Execution', 'Partial Coordination', 'Logistics & Travel Planners', 'Day-of Coordinators'],
    deepFilterKeys: ['Logistics Apps Used', 'Vendor Contracts Direct', 'Coordination Staff Ratio', 'Consultation Fee'],
  ),
  CategoryDetails(
    id: 13,
    name: 'Choreography',
    imageUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=400',
    fallbackIcon: Icons.accessibility_rounded,
    subServices: ['Sangeet Group Dance', 'Couple Entry Routines', 'Flash Mob Styling', 'Backup Dance Troupe'],
    deepFilterKeys: ['Session Practice Count', 'Track Editing Support', 'Practice Studio Included', 'Travel Outstation'],
  ),
  CategoryDetails(
    id: 9,
    name: 'DJ & Sound',
    imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400',
    fallbackIcon: Icons.headphones_rounded,
    subServices: ['Elite Sangeet DJs', 'Baraat Mobil Sound', 'Visual Laser Lighting', 'Truss & Smoke Setup'],
    deepFilterKeys: ['Decibel Compliance Cert', 'Baraat Mobil Setup', 'Visual Laser Lighting', 'Audio Backup Systems'],
  ),
  CategoryDetails(
    id: 14,
    name: 'Entertainment',
    imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=400',
    fallbackIcon: Icons.star_rounded,
    subServices: ['Celebrity Musicians', 'Folk Dancers', 'Astrologer Officiants', 'Live Instrumentalists', 'Themed Photobooths'],
    deepFilterKeys: ['AV Sound Setup Needs', 'Stage Dimensions Minimum', 'Astrologer Matchmaking', 'Photobooth Props'],
  ),
  CategoryDetails(
    id: 15,
    name: 'Pandits & Priests',
    imageUrl: 'https://images.unsplash.com/photo-1609137144813-2d256860d5b0?w=400',
    fallbackIcon: Icons.wb_sunny_rounded,
    subServices: ['Vedic Marriage Priests', 'Homam Specialists', 'Multi-Lingual Pandits'],
    deepFilterKeys: ['Samagri Materials Include', 'Assistant Priests Count', 'Travel Cost Outstation', 'Vedic Astrology Match'],
  ),
  CategoryDetails(
    id: 11,
    name: 'Luxury Cars',
    imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400',
    fallbackIcon: Icons.directions_car_rounded,
    subServices: ['Vintage Wedding Cars', 'Convertible Baraat Cars', 'Luxury Guest Coaches'],
    deepFilterKeys: ['Chauffeur Uniformed', 'Baraat Car Decor', 'Mileage Limit Hours', 'Fuel Included Status'],
  ),
  CategoryDetails(
    id: 16,
    name: 'Gifts & Hampers',
    imageUrl: 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=400',
    fallbackIcon: Icons.card_giftcard_rounded,
    subServices: ['Trousseau Packaging', 'Personalized Hampers', 'Sweets & Delicacies Boxes', 'Mehndi Return Favors'],
    deepFilterKeys: ['Logo Printing Support', 'Batch Shipping Charge', 'Min Order Quantity', 'Hampers Hand-Made'],
  ),
  CategoryDetails(
    id: 18,
    name: 'Honeymoon Travel',
    imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
    fallbackIcon: Icons.flight_rounded,
    subServices: ['Romantic Getaways', 'International Packages', 'Domestic Retreats', 'Heritage Hotel Booking'],
    deepFilterKeys: ['Flight Inclusions', 'Transfers Chauffeur', 'Sightseeing Custom', 'Stay Rating Stars'],
  ),
];
