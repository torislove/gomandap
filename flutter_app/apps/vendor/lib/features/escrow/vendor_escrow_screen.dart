import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/presentation/widgets/gomandap_screen.dart';

class VendorEscrowScreen extends ConsumerWidget {
  const VendorEscrowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GomandapScreen(
      backgroundColor: GomandapTokens.pearlWhite,
      useHorizontalPadding: false,
      useSafeAreaTop: false,
      useSafeAreaBottom: false,
      appBar: AppBar(
        title: const Text('Escrow Tracker', style: TextStyle(color: GomandapTokens.royalNavy)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: GomandapTokens.royalNavy),
      ),
      body: Padding(
        padding: const EdgeInsets.all(GomandapTokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(GomandapTokens.spacingLg),
              decoration: BoxDecoration(
                color: GomandapTokens.royalNavy,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Pending Escrow', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: GomandapTokens.spacingXs),
                      Text('₹1,50,000', style: GomandapTokens.outfitHeader.copyWith(color: Colors.white, fontSize: 32)),
                    ],
                  ),
                  const Icon(Icons.lock, color: GomandapTokens.champagneGoldStart, size: 48),
                ],
              ),
            ),
            const SizedBox(height: GomandapTokens.spacingLg),
            Text('Recent Transactions', style: GomandapTokens.outfitTitle),
            const SizedBox(height: GomandapTokens.spacingMd),
            Expanded(
              child: ListView(
                children: const [
                  _TransactionCard(eventName: 'Ramesh & Suresh Wedding', amount: '₹30,000', status: 'Released', date: 'Oct 12'),
                  _TransactionCard(eventName: 'Priya Reception', amount: '₹50,000', status: 'Pending', date: 'Oct 15'),
                  _TransactionCard(eventName: 'Amit Sangeet', amount: '₹70,000', status: 'Pending', date: 'Nov 01'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final String eventName;
  final String amount;
  final String status;
  final String date;

  const _TransactionCard({required this.eventName, required this.amount, required this.status, required this.date});

  @override
  Widget build(BuildContext context) {
    final isReleased = status == 'Released';
    return Container(
      margin: const EdgeInsets.only(bottom: GomandapTokens.spacingMd),
      padding: const EdgeInsets.all(GomandapTokens.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: GomandapTokens.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eventName, style: GomandapTokens.interBody.copyWith(fontWeight: FontWeight.bold, color: GomandapTokens.royalNavy)),
              const SizedBox(height: GomandapTokens.spacingXs),
              Text(date, style: GomandapTokens.interCaption),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: GomandapTokens.outfitTitle),
              const SizedBox(height: GomandapTokens.spacingXs),
              Text(status, style: GomandapTokens.interCaption.copyWith(color: isReleased ? GomandapTokens.emeraldGreen : GomandapTokens.warning)),
            ],
          ),
        ],
      ),
    );
  }
}
