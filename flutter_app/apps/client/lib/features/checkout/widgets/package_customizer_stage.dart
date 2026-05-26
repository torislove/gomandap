import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import '../checkout_notifier.dart';

class PackageCustomizerStage extends ConsumerWidget {
  const PackageCustomizerStage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutNotifierProvider);
    final notifier = ref.read(checkoutNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 2: Customize Package 🍽',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: GomandapTokens.royalNavy,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Fine-tune your guest capacity count and select premium premium add-ons to build your perfect custom booking.',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: GomandapTokens.slateGray,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),

        // Guest Counter Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: GomandapTokens.lightSlate),
            boxShadow: GomandapTokens.softShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guest Capacity (Pax)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Min capacity: 50 Pax',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildCountButton(
                    icon: Icons.remove_rounded,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      notifier.updateGuestCount(state.guestCount - 50);
                    },
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${state.guestCount}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: GomandapTokens.royalNavy,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildCountButton(
                    icon: Icons.add_rounded,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      notifier.updateGuestCount(state.guestCount + 50);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Premium Add-ons Section
        const Text(
          'Select Premium Add-ons',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
        ),
        const SizedBox(height: 12),

        ...state.customOptions.entries.map((opt) {
          final optionId = opt.key;
          final isSelected = opt.value;
          final String priceLabel = optionId == 'Premium Decor'
              ? '+₹60,000'
              : optionId == 'Pre-wedding Shoot'
                  ? '+₹25,000'
                  : optionId == 'Sound & Laser DJ'
                      ? '+₹35,000'
                      : 'Included';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? GomandapTokens.emeraldGreen.withValues(alpha: 0.04)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? GomandapTokens.emeraldGreen : GomandapTokens.lightSlate,
              ),
            ),
            child: ListTile(
              onTap: () => notifier.toggleOption(optionId),
              leading: Checkbox(
                activeColor: GomandapTokens.emeraldGreen,
                value: isSelected,
                onChanged: (_) => notifier.toggleOption(optionId),
              ),
              title: Text(
                optionId,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: GomandapTokens.royalNavy,
                ),
              ),
              trailing: Text(
                priceLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? GomandapTokens.emeraldGreen : GomandapTokens.royalNavy,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCountButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: GomandapTokens.softMist,
          shape: BoxShape.circle,
          border: Border.all(color: GomandapTokens.lightSlate),
        ),
        child: Icon(icon, size: 18, color: GomandapTokens.royalNavy),
      ),
    );
  }
}

