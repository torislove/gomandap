import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import '../../core/i18n/i18n_notifier.dart';
import 'search_notifier.dart';
import 'widgets/omni_filter_bar.dart';
import 'widgets/staggered_results_feed.dart';
import 'package:gomandap_common/presentation/widgets/gomandap_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto focus search field on load for instant interactive feel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);
    final notifier = ref.read(searchNotifierProvider.notifier);

    return GomandapScreen(
      backgroundColor: GomandapTokens.pearlWhite,
      useHorizontalPadding: false,
      useSafeAreaTop: true,
      useSafeAreaBottom: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: GomandapTokens.royalNavy, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: GomandapTokens.softMist,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: GomandapTokens.lightSlate),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: (val) => notifier.updateQuery(val),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: GomandapTokens.royalNavy,
            ),
            decoration: InputDecoration(
              hintText: ref.t('search.hint'),
              hintStyle: TextStyle(
                color: GomandapTokens.slateGray.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: GomandapTokens.slateGray, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: GomandapTokens.slateGray, size: 18),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _searchController.clear();
                        notifier.updateQuery('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
          ),
        ),
        actions: const [
          SizedBox(width: 16),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: OmniFilterBar(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Prompts
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildQuickPrompt('Top Rated Photographers', Icons.star_rounded, notifier),
                const SizedBox(width: 8),
                _buildQuickPrompt('Budget Venues < 5L', Icons.monetization_on_rounded, notifier),
                const SizedBox(width: 8),
                _buildQuickPrompt('Escrow Protected', Icons.shield_rounded, notifier),
                const SizedBox(width: 8),
                _buildQuickPrompt('Trending Makeup Artists', Icons.face_retouching_natural_rounded, notifier),
              ],
            ),
          ),
          
          // Active filters chip info row (only shows when filters are active)
          if (searchState.activeFiltersCount > 0)
            Container(
              color: GomandapTokens.softMist.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.tune_rounded, size: 12, color: GomandapTokens.champagneGoldEnd),
                  const SizedBox(width: 6),
                  Text(
                    ref.t('search.filters_active', {'count': '${searchState.activeFiltersCount}'}),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: GomandapTokens.royalNavy,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      notifier.clearAllFilters();
                    },
                    child: Text(
                      ref.t('search.clear'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Search Results Grid Feed
          Expanded(
            child: StaggeredResultsFeed(
              vendors: searchState.results,
              isLoading: searchState.isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompt(String label, IconData icon, SearchNotifier notifier) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _searchController.text = label;
        // Trigger instant search
        notifier.updateQuery(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: GomandapTokens.lightSlate),
          boxShadow: [
            BoxShadow(
              color: GomandapTokens.royalNavy.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: GomandapTokens.champagneGoldStart),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GomandapTokens.royalNavy)),
          ],
        ),
      ),
    );
  }
}

