import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';
import 'package:gomandap_common/domain/models/category_model.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

class _CategoriesNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => {1, 21, 22, 2, 3, 4, 5, 6, 7, 8, 10, 12, 17, 13, 9, 14, 15, 11, 16, 18};

  void toggle(int id) {
    HapticFeedback.lightImpact();
    final next = Set<int>.from(state);
    if (next.contains(id)) { next.remove(id); } else { next.add(id); }
    state = next;
  }

  void selectAll() => state = weddingCategoriesList.map((c) => c.id).toSet();
  void deselectAll() => state = {};
}

final adminActiveCategoriesProvider = NotifierProvider<_CategoriesNotifier, Set<int>>(_CategoriesNotifier.new);

// ─── Screen ───────────────────────────────────────────────────────────────────

class AdminCategoriesScreen extends ConsumerWidget {
  const AdminCategoriesScreen({super.key});

  Future<void> _saveToSupabase(BuildContext context, WidgetRef ref, Set<int> active) async {
    HapticFeedback.heavyImpact();
    final client = ref.read(supabaseClientProvider);
    if (client == null) {
      if (context.mounted) _showSnack(context, 'Offline — changes saved locally only', isError: true);
      return;
    }
    try {
      await client.from('app_configurations').upsert({
        'id': 'global_config',
        'active_categories': active.toList(),
      });
      if (context.mounted) _showSnack(context, '✅ Category layout saved to database!');
    } catch (e) {
      if (context.mounted) _showSnack(context, 'Error: $e', isError: true);
    }
  }

  void _showSnack(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: isError ? GomandapTokens.error : GomandapTokens.emeraldGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIds = ref.watch(adminActiveCategoriesProvider);
    final total = weddingCategoriesList.length;
    final active = activeIds.length;

    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Category Manager',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
            Text('$active of $total active',
                style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: GomandapTokens.royalNavy),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'all', child: Text('Select All')),
              const PopupMenuItem(value: 'none', child: Text('Deselect All')),
            ],
            onSelected: (v) {
              if (v == 'all') {
                ref.read(adminActiveCategoriesProvider.notifier).selectAll();
              } else {
                ref.read(adminActiveCategoriesProvider.notifier).deselectAll();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.4,
              ),
              itemCount: weddingCategoriesList.length,
              itemBuilder: (context, idx) {
                final cat = weddingCategoriesList[idx];
                final isActive = activeIds.contains(cat.id);
                return _CategoryTile(
                  category: cat,
                  isActive: isActive,
                  onTap: () => ref.read(adminActiveCategoriesProvider.notifier).toggle(cat.id),
                );
              },
            ),
          ),
          // Save Button
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _saveToSupabase(context, ref, activeIds),
                  icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                  label: const Text('Save Category Layout',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GomandapTokens.royalNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

class _CategoryTile extends StatelessWidget {
  final dynamic category;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryTile({required this.category, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? GomandapTokens.royalNavy : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? Colors.transparent : GomandapTokens.lightSlate,
            width: 1.5,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: GomandapTokens.royalNavy.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(category.fallbackIcon, size: 20,
                  color: isActive ? GomandapTokens.champagneGoldStart : GomandapTokens.royalNavy),
              const SizedBox(width: 10),
              Expanded(
                child: Text(category.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isActive ? Colors.white : GomandapTokens.royalNavy,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
              Icon(
                isActive ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 16,
                color: isActive ? GomandapTokens.champagneGoldStart : GomandapTokens.lightSlate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
