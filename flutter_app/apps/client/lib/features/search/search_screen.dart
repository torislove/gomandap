import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'search_notifier.dart';
import 'widgets/omni_filter_bar.dart';
import 'widgets/staggered_results_feed.dart';

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

    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
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
              hintText: 'Search Mandaps, Caterers, DJs...',
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
        children: [
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
                    '${searchState.activeFiltersCount} filters actively refining results',
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
                    child: const Text(
                      'Clear',
                      style: TextStyle(
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
}

