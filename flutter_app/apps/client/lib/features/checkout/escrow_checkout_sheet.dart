import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'checkout_notifier.dart';
import 'widgets/availability_stage.dart';
import 'widgets/package_customizer_stage.dart';
import 'widgets/escrow_visualizer_stage.dart';
import 'widgets/payment_stage.dart';

class EscrowCheckoutScreen extends ConsumerWidget {
  const EscrowCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutNotifierProvider);
    final notifier = ref.read(checkoutNotifierProvider.notifier);

    // Dynamic stage layout loading
    Widget stageWidget;
    switch (state.currentStage) {
      case 0:
        stageWidget = const AvailabilityStage();
        break;
      case 1:
        stageWidget = const PackageCustomizerStage();
        break;
      case 2:
        stageWidget = const EscrowVisualizerStage();
        break;
      case 3:
        stageWidget = const PaymentStage();
        break;
      default:
        stageWidget = const AvailabilityStage();
    }

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
              'GoMandap Escrow Checkout',
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
          // Visual Stepper (Hidden on successful transaction)
          if (!state.isSuccess) _buildVisualStepper(state.currentStage),

          // Scrollable Stage Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: state.isLoading
                  ? _buildLoadingSpinner()
                  : stageWidget,
            ),
          ),

          // Bottom Navigation Actions Row (Hidden on successful transaction)
          if (!state.isSuccess && !state.isLoading) _buildBottomActionsRow(context, ref, state, notifier),
        ],
      ),
    );
  }

  Widget _buildVisualStepper(int activeStage) {
    final stages = ['Schedule', 'Customize', 'Escrow', 'Pay'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(stages.length, (idx) {
          final isCompleted = idx < activeStage;
          final isActive = idx == activeStage;

          return Expanded(
            child: Row(
              children: [
                // Step Badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? GomandapTokens.emeraldGreen
                        : isActive
                            ? GomandapTokens.royalNavy
                            : GomandapTokens.softMist,
                    shape: BoxShape.circle,
                    border: isActive
                        ? Border.all(color: GomandapTokens.champagneGoldStart, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.done_rounded, size: 12, color: Colors.white)
                        : Text(
                            '${idx + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isActive ? Colors.white : GomandapTokens.slateGray,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),

                // Step Name label
                Text(
                  stages[idx],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive || isCompleted ? FontWeight.w800 : FontWeight.w600,
                    color: isActive
                        ? GomandapTokens.royalNavy
                        : isCompleted
                            ? GomandapTokens.emeraldGreen
                            : GomandapTokens.slateGray,
                  ),
                ),

                // Connecting Line between steps (except the last one)
                if (idx < stages.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: isCompleted ? GomandapTokens.emeraldGreen : GomandapTokens.lightSlate,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoadingSpinner() {
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
    final isFirst = state.currentStage == 0;
    final isLast = state.currentStage == 3;

    final nextButtonText = isLast ? 'Verify & Secure booking' : 'Continue';
    final isNextDisabled = state.currentStage == 0 && state.selectedDate == null;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: GomandapTokens.lightSlate, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Left action (Back/Exit)
          if (!isFirst)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                notifier.prevStage();
              },
              child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: GomandapTokens.softMist,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GomandapTokens.lightSlate),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: GomandapTokens.royalNavy,
                  size: 16,
                ),
              ),
            ),

          if (!isFirst) const SizedBox(width: 12),

          // Primary right CTA (Continue / Submit)
          Expanded(
            child: GestureDetector(
              onTap: isNextDisabled
                  ? null
                  : () {
                      if (isLast) {
                        HapticFeedback.heavyImpact();
                        notifier.submitPayment();
                      } else {
                        HapticFeedback.mediumImpact();
                        notifier.nextStage();
                      }
                    },
              child: AnimatedOpacity(
                opacity: isNextDisabled ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [GomandapTokens.emeraldGreen, GomandapTokens.emeraldGreenDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isNextDisabled
                        ? []
                        : [
                            BoxShadow(
                              color: GomandapTokens.emeraldGreen.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLast) ...[
                          const Icon(Icons.shield_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          nextButtonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

