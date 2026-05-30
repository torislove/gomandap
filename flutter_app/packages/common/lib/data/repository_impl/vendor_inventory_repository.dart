import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase/supabase_client.dart';
import '../../domain/models/vendor_inventory.dart';
import '../../domain/models/inventory_availability.dart';

final inventoryRepositoryProvider = Provider((ref) {
  return VendorInventoryRepository(ref.watch(supabaseClientProvider));
});

class VendorInventoryRepository {
  final dynamic _client;

  VendorInventoryRepository(this._client);

  Future<List<VendorInventory>> getInventoryForVendor(String vendorId) async {
    if (_client == null) return [];
    
    final response = await _client
        .from('vendor_inventory')
        .select()
        .eq('vendor_id', vendorId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => VendorInventory.fromJson(e)).toList();
  }

  Future<VendorInventory> addInventory(VendorInventory inventory) async {
    if (_client == null) throw Exception("Supabase client not initialized");
    
    final data = inventory.toJson();
    data.remove('id'); // DB will generate UUID
    data.remove('created_at');

    final response = await _client
        .from('vendor_inventory')
        .insert(data)
        .select()
        .single();
        
    return VendorInventory.fromJson(response);
  }

  Future<List<InventoryAvailability>> getAvailabilityForInventory(String inventoryId) async {
    if (_client == null) return [];

    final response = await _client
        .from('inventory_availability')
        .select()
        .eq('inventory_id', inventoryId)
        .order('available_date', ascending: true);

    return (response as List).map((e) => InventoryAvailability.fromJson(e)).toList();
  }

  Future<void> setAvailability(String inventoryId, DateTime date, bool isBooked) async {
    if (_client == null) return;
    
    final dateStr = date.toIso8601String().split('T').first;

    // UPSERT
    await _client
        .from('inventory_availability')
        .upsert({
          'inventory_id': inventoryId,
          'available_date': dateStr,
          'is_booked': isBooked,
        }, onConflict: 'inventory_id,available_date');
  }
}
