import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'checkout_notifier.dart';
import '../cart/cart_notifier.dart';
import 'widgets/availability_stage.dart';
import 'widgets/package_customizer_stage.dart';
import 'widgets/escrow_visualizer_stage.dart';
import 'widgets/payment_stage.dart';

class EscrowCheckoutScreen extends ConsumerStatefulWidget {
  const EscrowCheckoutScreen({super.key});

  @override
  ConsumerState<EscrowCheckoutScreen> createState() => _EscrowCheckoutScreenState();
}

class _EscrowCheckoutScreenState extends ConsumerState<EscrowCheckoutScreen> {
  bool _isCustomizerExpanded = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutNotifierProvider);
    final notifier = ref.read(checkoutNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.white,
        leading: state.isSuccess
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.close_rounded, color: GomandapTokens.royalNavy),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.pop();
                },
              ),
        title: const Row(
          children: [
            Icon(Icons.shield_rounded, color: GomandapTokens.emeraldGreen, size: 20),
            SizedBox(width: 8),
            Text(
              'Express Checkout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: GomandapTokens.royalNavy,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Scrollable Single Page Checkout Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: state.isLoading || state.isSuccess
                  ? _buildLoadingSpinner(state.isSuccess)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Date & Schedule (Always visible)
                        const Text('1. Schedule Event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
                        const SizedBox(height: 12),
                        const AvailabilityStage(),
                        const SizedBox(height: 24),

                        // 2. Package Customizer (Collapsible)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => _isCustomizerExpanded = !_isCustomizerExpanded);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: GomandapTokens.lightSlate),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.tune_rounded, color: GomandapTokens.royalNavy, size: 18),
                                    SizedBox(width: 12),
                                    Text('2. Customize Package', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
                                  ],
                                ),
                                Icon(
                                  _isCustomizerExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  color: GomandapTokens.slateGray,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isCustomizerExpanded) ...[
                          const SizedBox(height: 16),
                          const PackageCustomizerStage(),
                        ],
                        const SizedBox(height: 24),

                        // 3. Escrow Visualizer
                        const Text('3. Escrow Guarantee', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
                        const SizedBox(height: 12),
                        const EscrowVisualizerStage(),
                        const SizedBox(height: 24),

                        // 4. Payment Methods
                        const Text('4. Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
                        const SizedBox(height: 12),
                        const PaymentStage(),
                        
                        const SizedBox(height: 80), // Padding for bottom bar
                      ],
                    ),
            ),
          ),

          // Bottom Action Bar (1-Click Booking)
          if (!state.isSuccess && !state.isLoading) _buildBottomActionsRow(context, ref, state, notifier),
        ],
      ),
    );
  }

  Widget _buildLoadingSpinner(bool isSuccess) {
    if (isSuccess) {
      return const SizedBox(
        height: 350,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, color: GomandapTokens.emeraldGreen, size: 64),
              SizedBox(height: 24),
              Text(
                'Booking Secured!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
              ),
              SizedBox(height: 8),
              Text(
                'Your payment is held safely in escrow.',
                style: TextStyle(fontSize: 12, color: GomandapTokens.slateGray),
              ),
            ],
          ),
        ),
      );
    }
    
    return const SizedBox(
      height: 350,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(GomandapTokens.emeraldGreen),
              strokeWidth: 3.5,
            ),
            SizedBox(height: 24),
            Text(
              'Routing secure gateway transaction...',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: GomandapTokens.royalNavy),
            ),
            SizedBox(height: 4),
            Text(
              'Please do not press back or close the app.',
              style: TextStyle(fontSize: 11, color: GomandapTokens.slateGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionsRow(
    BuildContext context,
    WidgetRef ref,
    CheckoutUiState state,
    CheckoutNotifier notifier,
  ) {
    final isNextDisabled = state.selectedDate == null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: GomandapTokens.lightSlate, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trust Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user_rounded, size: 12, color: GomandapTokens.emeraldGreen),
                const SizedBox(width: 6),
                const Text('100% Refundable if Vendor cancels. Escrow Guaranteed.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray)),
              ],
            ),
            const SizedBox(height: 12),
            
            // 1-Click Express Pay
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.apple_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text('Pay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: GomandapTokens.lightSlate),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png', width: 16, height: 16),
                        const SizedBox(width: 6),
                        const Text('Pay', style: TextStyle(color: GomandapTokens.royalNavy, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            GestureDetector(
              onTap: isNextDisabled
                  ? null
                  : () {
                      HapticFeedback.heavyImpact();
                      final cartState = ref.read(cartNotifierProvider);
                      notifier.submitPayment(cartState.items);
                    },
              child: AnimatedOpacity(
                opacity: isNextDisabled ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [GomandapTokens.emeraldGreen, GomandapTokens.emeraldGreenDark],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isNextDisabled
                        ? []
                        : [
                            BoxShadow(
                              color: GomandapTokens.emeraldGreen.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.lock_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Verify & Secure Booking',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
