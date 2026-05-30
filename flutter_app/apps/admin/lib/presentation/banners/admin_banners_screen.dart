import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

class _BannersNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() => [
    {
      'title': 'Grand Ballroom Reopenings',
      'subtitle': 'Flat 20% off on premium venues',
      'target_route': '/search?category=venue',
      'image_url': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
    },
    {
      'title': 'Sangeet Choreography Special',
      'subtitle': 'Book elite performance packages',
      'target_route': '/search?category=choreographer',
      'image_url': 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800',
    },
  ];

  void add(Map<String, dynamic> banner) => state = [...state, banner];
  void remove(int index) {
    final updated = [...state];
    updated.removeAt(index);
    state = updated;
  }
  void update(int index, Map<String, dynamic> data) {
    final updated = [...state];
    updated[index] = data;
    state = updated;
  }
}

final adminBannersProvider = NotifierProvider<_BannersNotifier, List<Map<String, dynamic>>>(_BannersNotifier.new);

// ─── Screen ───────────────────────────────────────────────────────────────────

class AdminBannersScreen extends ConsumerWidget {
  const AdminBannersScreen({super.key});

  Future<void> _saveToSupabase(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> banners) async {
    HapticFeedback.heavyImpact();
    final client = ref.read(supabaseClientProvider);
    if (client == null) {
      _showSnack(context, 'Offline — changes saved locally only', isError: true);
      return;
    }
    try {
      await client.from('home_carousels').upsert({'id': 1, 'banners': banners});
      if (context.mounted) _showSnack(context, '✅ Banners saved to live database!');
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
    final banners = ref.watch(adminBannersProvider);

    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Banner Sliders',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => _saveToSupabase(context, ref, banners),
              icon: const Icon(Icons.cloud_upload_rounded, size: 16),
              label: const Text('Save', style: TextStyle(fontWeight: FontWeight.w800)),
              style: TextButton.styleFrom(foregroundColor: GomandapTokens.royalNavy),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBannerForm(context, ref, null, -1),
        backgroundColor: GomandapTokens.royalNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Banner', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: banners.isEmpty
          ? const _EmptyBanners()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: banners.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, idx) {
                final banner = banners[idx];
                return _BannerCard(
                  banner: banner,
                  onEdit: () => _showBannerForm(context, ref, banner, idx),
                  onDelete: () {
                    HapticFeedback.mediumImpact();
                    ref.read(adminBannersProvider.notifier).remove(idx);
                  },
                );
              },
            ),
    );
  }

  void _showBannerForm(BuildContext context, WidgetRef ref, Map<String, dynamic>? existing, int editIndex) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final subtitleCtrl = TextEditingController(text: existing?['subtitle'] ?? '');
    final routeCtrl = TextEditingController(text: existing?['target_route'] ?? '/search');
    final imageCtrl = TextEditingController(text: existing?['image_url'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                editIndex == -1 ? 'Add New Banner' : 'Edit Banner',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
              ),
              const SizedBox(height: 20),
              _FormField(controller: titleCtrl, label: 'Banner Title', icon: Icons.title_rounded),
              const SizedBox(height: 12),
              _FormField(controller: subtitleCtrl, label: 'Subtitle / Description', icon: Icons.subtitles_rounded),
              const SizedBox(height: 12),
              _FormField(controller: routeCtrl, label: 'Target Route (e.g. /search?category=venue)', icon: Icons.link_rounded),
              const SizedBox(height: 12),
              _FormField(controller: imageCtrl, label: 'Image URL', icon: Icons.image_rounded),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  final data = {
                    'title': titleCtrl.text,
                    'subtitle': subtitleCtrl.text,
                    'target_route': routeCtrl.text,
                    'image_url': imageCtrl.text,
                  };
                  final notifier = ref.read(adminBannersProvider.notifier);
                  if (editIndex == -1) {
                    notifier.add(data);
                  } else {
                    notifier.update(editIndex, data);
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GomandapTokens.royalNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  editIndex == -1 ? 'Add Banner' : 'Update Banner',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Map<String, dynamic> banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BannerCard({required this.banner, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final imageUrl = banner['image_url']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GomandapTokens.lightSlate),
        boxShadow: GomandapTokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder())
                : _imagePlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(banner['title']?.toString() ?? '',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
                const SizedBox(height: 4),
                Text(banner['subtitle']?.toString() ?? '',
                    style: const TextStyle(fontSize: 12, color: GomandapTokens.slateGray)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.link_rounded, size: 12, color: GomandapTokens.champagneGoldEnd),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(banner['target_route']?.toString() ?? '',
                          style: const TextStyle(fontSize: 11, color: GomandapTokens.champagneGoldEnd, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_rounded, size: 14),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: GomandapTokens.royalNavy,
                          side: const BorderSide(color: GomandapTokens.royalNavy),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 14),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: GomandapTokens.error,
                        side: const BorderSide(color: GomandapTokens.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 150, color: GomandapTokens.softMist,
      child: const Center(child: Icon(Icons.image_rounded, size: 48, color: GomandapTokens.slateGray)),
    );
  }
}

class _EmptyBanners extends StatelessWidget {
  const _EmptyBanners();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.view_carousel_outlined, size: 64, color: GomandapTokens.slateGray),
          SizedBox(height: 16),
          Text('No banners yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
          SizedBox(height: 8),
          Text('Tap + Add Banner to create your first slider', style: TextStyle(color: GomandapTokens.slateGray)),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _FormField({required this.controller, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: GomandapTokens.slateGray),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GomandapTokens.royalNavy, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }
}
