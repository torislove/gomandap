import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';

/// Screen for managing wedding budget allocations across escrow milestones.
class BudgetPlannerScreen extends ConsumerStatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  ConsumerState<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends ConsumerState<BudgetPlannerScreen> {
  final TextEditingController _budgetController = TextEditingController();

  // Default distribution percentages for milestones.
  final Map<String, double> _percentages = {
    'Advance (20%)': 0.20,
    'Setup (40%)': 0.40,
    'Completion (40%)': 0.40,
  };

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  double _totalBudget() => double.tryParse(_budgetController.text) ?? 0.0;

  Map<String, double> _allocatedAmounts() {
    final total = _totalBudget();
    return _percentages.map((k, v) => MapEntry(k, total * v));
  }

  Future<void> _saveAllocations() async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    final allocations = _allocatedAmounts().entries.map((e) => {
          'milestone': e.key,
          'amount': e.value,
        }).toList();
    await client.from('escrow_milestones').insert(allocations);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budget allocations saved'), backgroundColor: GomandapTokens.emeraldGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allocations = _allocatedAmounts();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GomandapTokens.royalNavy,
        title: Text('Budget Planner', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      backgroundColor: GomandapTokens.pearlWhite,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Wedding Budget', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter amount in ₹',
                filled: true,
                fillColor: GomandapTokens.softMist,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            Text('Milestone Allocations', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...allocations.entries.map((e) => ListTile(
                  title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Text('₹${e.value.toStringAsFixed(0)}'),
                )),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: GomandapTokens.emeraldGreen, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _saveAllocations,
                child: const Text('Save Allocations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
