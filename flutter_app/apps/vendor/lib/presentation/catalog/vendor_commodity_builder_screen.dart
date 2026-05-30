import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/domain/models/vendor_inventory.dart';
import 'package:gomandap_common/data/repository_impl/vendor_inventory_repository.dart';

class VendorCommodityBuilderScreen extends ConsumerStatefulWidget {
  final String vendorId;
  const VendorCommodityBuilderScreen({super.key, required this.vendorId});

  @override
  ConsumerState<VendorCommodityBuilderScreen> createState() => _VendorCommodityBuilderScreenState();
}

class _VendorCommodityBuilderScreenState extends ConsumerState<VendorCommodityBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  InventoryType _selectedType = InventoryType.perEvent;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _savePackage() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      await repo.addInventory(
        VendorInventory(
          id: '',
          vendorId: widget.vendorId,
          title: _titleCtrl.text,
          description: _descCtrl.text,
          type: _selectedType,
          price: double.parse(_priceCtrl.text),
          maxCapacity: _capacityCtrl.text.isNotEmpty ? int.parse(_capacityCtrl.text) : null,
          createdAt: DateTime.now(),
        ),
      );
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commodity Package Published!'), backgroundColor: GomandapTokens.emeraldGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: GomandapTokens.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Commodity Package', style: TextStyle(color: GomandapTokens.royalNavy, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: GomandapTokens.royalNavy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Package Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GomandapTokens.royalNavy)),
              const SizedBox(height: 8),
              const Text('Define a strict package that clients can instantly book and pay for via Escrow.', style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray)),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Package Title (e.g. Platinum Banquet 500 Pax)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description / Inclusions',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<InventoryType>(
                // ignore: deprecated_member_use
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Pricing Model',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: InventoryType.values.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t.value.toUpperCase()),
                )).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedType = v);
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Base Price (₹)',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _capacityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Max Capacity (Optional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePackage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GomandapTokens.royalNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Publish Commodity for Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
