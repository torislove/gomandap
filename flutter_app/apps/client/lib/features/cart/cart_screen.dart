import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import '../../core/i18n/i18n_notifier.dart';
import '../checkout/escrow_checkout_sheet.dart';
import 'cart_notifier.dart';
import 'package:gomandap_common/presentation/widgets/gomandap_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);
    final notifier = ref.read(cartNotifierProvider.notifier);

    return GomandapScreen(
      backgroundColor: GomandapTokens.pearlWhite,
      useHorizontalPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: GomandapTokens.royalNavy, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
        title: Consumer(
          builder: (context, r, _) => Text(
            r.watch(i18nProvider).t('cart.title'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: GomandapTokens.royalNavy,
            ),
          ),
        ),
      ),
      body: cartState.items.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                // Scrollable cart items list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartState.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return _buildCartCard(context, ref, item, notifier);
                    },
                  ),
                ),

                // Bottom payment summary card
                _buildPaymentSummary(context, cartState),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                color: GomandapTokens.softMist,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined, size: 36, color: GomandapTokens.slateGray),
            ),
            const SizedBox(height: 20),
            Consumer(
              builder: (context, r, _) => Column(
                children: [
                  Text(
                    r.watch(i18nProvider).t('cart.empty_title'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    r.watch(i18nProvider).t('cart.empty_subtitle'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: GomandapTokens.slateGray, height: 1.45),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.go('/home');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: GomandapTokens.emeraldGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        r.watch(i18nProvider).t('cart.explore_vendors'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartCard(
    BuildContext context,
    WidgetRef ref,
    CartItem item,
    CartNotifier notifier,
  ) {
    final isVenue = item.vendor.category == 'Venue' || item.vendor.category == 'Catering';
    final price = isVenue
        ? item.guestCount * item.vendor.basePlatePrice
        : item.vendor.packagePrice;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GomandapTokens.lightSlate),
        boxShadow: GomandapTokens.softShadow,
      ),
      child: Column(
        children: [
          // Item Details Row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item.vendor.imageUrls.isNotEmpty ? item.vendor.imageUrls[0] : '',
                    width: 72, height: 72, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72, height: 72,
                      color: GomandapTokens.softMist,
                      child: const Icon(Icons.image, color: GomandapTokens.slateGray),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: GomandapTokens.softMist,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.vendor.category,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: GomandapTokens.slateGray),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.vendor.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.vendor.locality,
                        style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    notifier.removeItem(item.vendor.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ref.watch(i18nProvider).t('cart.removed', {'name': item.vendor.name})),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'UNDO',
                          textColor: GomandapTokens.champagneGoldStart,
                          onPressed: () => notifier.addItem(item.vendor),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(color: GomandapTokens.lightSlate, height: 1),

          // Stepper modifiers if applicable
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isVenue)
                  Row(
                    children: [
                      _buildCountButton(
                        icon: Icons.remove_rounded,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          notifier.updateGuestCount(item.vendor.id, item.guestCount - 25);
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${item.guestCount} guests',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GomandapTokens.royalNavy),
                      ),
                      const SizedBox(width: 12),
                      _buildCountButton(
                        icon: Icons.add_rounded,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          notifier.updateGuestCount(item.vendor.id, item.guestCount + 25);
                        },
                      ),
                    ],
                  )
                else
                  Expanded(
                    child: Consumer(
                      builder: (context, r, _) => Text(
                        r.watch(i18nProvider).t('cart.standard_package'),
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: GomandapTokens.slateGray),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '₹${price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: GomandapTokens.softMist,
          shape: BoxShape.circle,
          border: Border.all(color: GomandapTokens.lightSlate),
        ),
        child: Icon(icon, size: 14, color: GomandapTokens.royalNavy),
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context, CartUiState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: GomandapTokens.lightSlate)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer(builder: (context, r, _) => Text(r.watch(i18nProvider).t('cart.subtotal'), style: const TextStyle(fontSize: 12, color: GomandapTokens.slateGray))),
              Text(
                '₹${state.subtotal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GomandapTokens.royalNavy),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer(builder: (context, r, _) => Text(r.watch(i18nProvider).t('cart.escrow_fee'), style: const TextStyle(fontSize: 12, color: GomandapTokens.slateGray))),
              Text(
                '₹${state.platformFee.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GomandapTokens.royalNavy),
              ),
            ],
          ),
          const Divider(color: GomandapTokens.lightSlate, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer(builder: (context, r, _) => Text(r.watch(i18nProvider).t('cart.total_estimate'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy))),
              Text(
                '₹${state.grandTotal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GomandapTokens.emeraldGreen),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action button
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EscrowCheckoutScreen()),
              );
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [GomandapTokens.emeraldGreen, GomandapTokens.emeraldGreenDark],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: GomandapTokens.emeraldGreen.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Secure Booking with Escrow',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

