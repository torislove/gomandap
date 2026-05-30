import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/domain/models/vendor_inventory.dart';
import 'package:gomandap_common/domain/models/inventory_availability.dart';
import 'package:gomandap_common/data/repository_impl/vendor_inventory_repository.dart';

class VendorAvailabilityCalendarScreen extends ConsumerStatefulWidget {
  final String vendorId;
  const VendorAvailabilityCalendarScreen({super.key, required this.vendorId});

  @override
  ConsumerState<VendorAvailabilityCalendarScreen> createState() => _VendorAvailabilityCalendarScreenState();
}

class _VendorAvailabilityCalendarScreenState extends ConsumerState<VendorAvailabilityCalendarScreen> {
  List<VendorInventory> _inventories = [];
  VendorInventory? _selectedInventory;
  List<InventoryAvailability> _blockedDates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInventories();
  }

  Future<void> _loadInventories() async {
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final inv = await repo.getInventoryForVendor(widget.vendorId);
      if (mounted) {
        setState(() {
          _inventories = inv;
          if (inv.isNotEmpty) {
            _selectedInventory = inv.first;
            _loadAvailability(_selectedInventory!.id);
          } else {
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAvailability(String invId) async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final blocked = await repo.getAvailabilityForInventory(invId);
      if (mounted) {
        setState(() {
          _blockedDates = blocked;
        });
      }
    } catch (e) {
      // Ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleDate(DateTime date) async {
    if (_selectedInventory == null) return;
    
    // Check if already blocked
    final isCurrentlyBlocked = _blockedDates.any((e) => e.availableDate.year == date.year && e.availableDate.month == date.month && e.availableDate.day == date.day && e.isBooked);
    
    // Optimistic UI update
    setState(() {
      if (isCurrentlyBlocked) {
        _blockedDates.removeWhere((e) => e.availableDate.year == date.year && e.availableDate.month == date.month && e.availableDate.day == date.day);
      } else {
        _blockedDates.add(InventoryAvailability(id: '', inventoryId: _selectedInventory!.id, availableDate: date, isBooked: true, createdAt: DateTime.now()));
      }
    });

    try {
      final repo = ref.read(inventoryRepositoryProvider);
      await repo.setAvailability(_selectedInventory!.id, date, !isCurrentlyBlocked);
    } catch (e) {
      // Revert on error
      _loadAvailability(_selectedInventory!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Availability', style: TextStyle(color: GomandapTokens.royalNavy, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading && _inventories.isEmpty 
        ? const Center(child: CircularProgressIndicator())
        : _inventories.isEmpty
          ? const Center(child: Text("You need to create a commodity package first."))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: GomandapTokens.softMist,
                  child: DropdownButtonFormField<VendorInventory>(
                    // ignore: deprecated_member_use
                    value: _selectedInventory,
                    decoration: InputDecoration(
                      labelText: 'Select Package to Manage',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    items: _inventories.map((i) => DropdownMenuItem(
                      value: i,
                      child: Text('${i.title} (₹${i.price})'),
                    )).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedInventory = v);
                        _loadAvailability(v.id);
                      }
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Tap on dates to block/unblock them. Clients cannot book blocked dates.', style: TextStyle(color: GomandapTokens.slateGray, fontSize: 13)),
                ),
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7, 
                          mainAxisSpacing: 8, 
                          crossAxisSpacing: 8
                        ),
                        itemCount: 30, // Just mock next 30 days
                        itemBuilder: (context, index) {
                          final date = DateTime.now().add(Duration(days: index));
                          final isBlocked = _blockedDates.any((e) => e.availableDate.year == date.year && e.availableDate.month == date.month && e.availableDate.day == date.day && e.isBooked);
                          
                          return GestureDetector(
                            onTap: () => _toggleDate(date),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isBlocked ? GomandapTokens.error.withValues(alpha: 0.1) : GomandapTokens.emeraldGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isBlocked ? GomandapTokens.error : GomandapTokens.emeraldGreen),
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}\n${_getMonth(date.month)}', 
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12, 
                                    fontWeight: FontWeight.bold, 
                                    color: isBlocked ? GomandapTokens.error : GomandapTokens.emeraldGreenDark
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
    );
  }

  String _getMonth(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m-1];
  }
}
