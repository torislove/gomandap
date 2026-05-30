import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/domain/models/vendor_inventory.dart';

class PackageCalculator extends StatefulWidget {
  final List<VendorInventory> packages;
  final void Function(double newPrice, VendorInventory selectedPackage)? onSelectionChanged;
  final VoidCallback onAddToCart;

  const PackageCalculator({
    super.key,
    required this.packages,
    this.onSelectionChanged,
    required this.onAddToCart,
  });

  @override
  State<PackageCalculator> createState() => _PackageCalculatorState();
}

class _PackageCalculatorState extends State<PackageCalculator> {
  VendorInventory? _selectedPackage;
  double _guestCount = 100;

  @override
  void initState() {
    super.initState();
    if (widget.packages.isNotEmpty) {
      _selectedPackage = widget.packages.first;
    }
  }

  double _calculatePrice() {
    if (_selectedPackage == null) return 0;
    if (_selectedPackage!.type == InventoryType.perPlate) {
      return _selectedPackage!.price * _guestCount;
    }
    return _selectedPackage!.price; // per_event or per_day
  }

  void _update() {
    setState(() {});
    if (widget.onSelectionChanged != null && _selectedPackage != null) {
      widget.onSelectionChanged!(_calculatePrice(), _selectedPackage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.packages.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No bookable commodities available yet.', style: TextStyle(color: GomandapTokens.slateGray)),
      );
    }

    final total = _calculatePrice();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GomandapTokens.glassBackground.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: GomandapTokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Booking Package',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: GomandapTokens.royalNavy,
            ),
          ),
          const SizedBox(height: 12),

          ...widget.packages.map((pkg) => ListTile(
            title: Text(pkg.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('₹${pkg.price} (${pkg.type.value.replaceAll('_', ' ')})\n${pkg.description ?? ''}', style: const TextStyle(fontSize: 12)),
            // ignore: deprecated_member_use
            leading: Radio<VendorInventory>(
              value: pkg,
              // ignore: deprecated_member_use
              groupValue: _selectedPackage,
              activeColor: GomandapTokens.emeraldGreen,
              // ignore: deprecated_member_use
              onChanged: (v) {
                _selectedPackage = v;
                _update();
              },
            ),
            onTap: () {
              _selectedPackage = pkg;
              _update();
            },
          )),

          if (_selectedPackage?.type == InventoryType.perPlate) ...[
            const Divider(height: 24, thickness: 1, color: GomandapTokens.lightSlate),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Guests', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(_guestCount.toInt().toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
            Slider(
              min: 50,
              max: (_selectedPackage!.maxCapacity ?? 1000).toDouble(),
              divisions: 20,
              activeColor: GomandapTokens.emeraldGreen,
              value: _guestCount,
              onChanged: (v) {
                _guestCount = v;
                _update();
              },
            ),
          ],

          const Divider(height: 24, thickness: 1, color: GomandapTokens.lightSlate),

          // Total price display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Estimated Escrow', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              Text(
                '₹${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: GomandapTokens.emeraldGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Add to cart button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GomandapTokens.emeraldGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: widget.onAddToCart,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Lock Dates via Escrow',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
