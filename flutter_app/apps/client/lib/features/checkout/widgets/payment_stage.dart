import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import '../checkout_notifier.dart';

class PaymentStage extends ConsumerWidget {
  const PaymentStage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutNotifierProvider);

    if (state.isSuccess) {
      return _buildSuccessScreen(context, ref);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 4: Secure Payment 💳',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: GomandapTokens.royalNavy,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Complete your payment securely. Only the Milestone 1 deposit will be released immediately to lock the vendor.',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: GomandapTokens.slateGray,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),

        // Payment Gateway Selector List
        _buildPaymentMethodOption(
          icon: Icons.qr_code_2_rounded,
          title: 'UPI Payment (GPay, PhonePe, Paytm)',
          subtitle: 'Direct bank transfer with instant confirmation',
          isSelected: true,
        ),
        const SizedBox(height: 12),
        _buildPaymentMethodOption(
          icon: Icons.credit_card_rounded,
          title: 'Credit / Debit Card (Razorpay Secures)',
          subtitle: 'Visa, MasterCard, RuPay, Amex accepted',
          isSelected: false,
        ),
        const SizedBox(height: 12),
        _buildPaymentMethodOption(
          icon: Icons.account_balance_rounded,
          title: 'Netbanking / Corporate Transfer',
          subtitle: 'All major Indian banks supported',
          isSelected: false,
        ),
        const SizedBox(height: 28),

        // Total Summary Breakdowns
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: GomandapTokens.softMist,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: GomandapTokens.lightSlate),
          ),
          child: Column(
            children: [
              _buildPriceRow('Event base subtotal', state.subtotal),
              const SizedBox(height: 8),
              _buildPriceRow('Platform Escrow Fee (2%)', state.platformFee),
              const Divider(color: GomandapTokens.lightSlate, height: 24),
              _buildPriceRow('Total Booking Estimate', state.grandTotal, isGrandTotal: true),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Milestone 1 Advance due now',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GomandapTokens.emeraldGreen),
                  ),
                  Text(
                    '₹${(state.grandTotal * 0.25).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: GomandapTokens.emeraldGreen),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Secure Lock visual
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_rounded, size: 12, color: GomandapTokens.slateGray),
            const SizedBox(width: 4),
            Text(
              'Escrow connection secured with AES-256 SSL encryption',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? GomandapTokens.emeraldGreen.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? GomandapTokens.emeraldGreen : GomandapTokens.lightSlate,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? GomandapTokens.emeraldGreen : GomandapTokens.royalNavy),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray)),
        trailing: Radio<bool>(
          activeColor: GomandapTokens.emeraldGreen,
          value: isSelected,
          groupValue: true,
          onChanged: (_) {},
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isGrandTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isGrandTotal ? 14 : 12,
            fontWeight: isGrandTotal ? FontWeight.w800 : FontWeight.w600,
            color: isGrandTotal ? GomandapTokens.royalNavy : GomandapTokens.slateGray,
          ),
        ),
        Text(
          '₹${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
          style: TextStyle(
            fontSize: isGrandTotal ? 16 : 12,
            fontWeight: isGrandTotal ? FontWeight.w900 : FontWeight.w700,
            color: GomandapTokens.royalNavy,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        // Success Animated Checkmark
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(
            color: GomandapTokens.emeraldGreen,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.done_all_rounded, size: 40, color: Colors.white),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Booking Securely Locked! 🎉',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
        ),
        const SizedBox(height: 8),
        const Text(
          'Milestone 1 payment received. Vendor has locked your dates. Remaining milestones are safely held in GoMandap Escrow vaults.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray, height: 1.45),
        ),
        const SizedBox(height: 32),

        // Transaction details card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: GomandapTokens.softMist,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GomandapTokens.lightSlate),
          ),
          child: const Column(
            children: [
              _SuccessDetailRow(label: 'Booking ID', val: 'GMD-7829-2026'),
              SizedBox(height: 8),
              _SuccessDetailRow(label: 'Payment Gateway Ref', val: 'pay_UPI_9821820X'),
              SizedBox(height: 8),
              _SuccessDetailRow(label: 'Escrow Milestone locked', val: 'GMD_ESC_MILE_1_2'),
            ],
          ),
        ),
        const SizedBox(height: 48),

        // Primary Action
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            // Reset checkout state and navigate to escrow tracker screen
            ref.read(checkoutNotifierProvider.notifier).reset();
            context.go('/escrow/GMD-7829-2026');
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
                    'Track Escrow Milestones',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessDetailRow extends StatelessWidget {
  final String label;
  final String val;

  const _SuccessDetailRow({required this.label, required this.val});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray)),
        Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
      ],
    );
  }
}

