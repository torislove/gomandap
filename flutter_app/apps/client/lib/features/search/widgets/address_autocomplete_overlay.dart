import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/core/location/places_service.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

class AddressAutocompleteOverlay extends ConsumerStatefulWidget {
  final String hintText;
  final ValueChanged<PlaceCoordinates> onLocationSelected;

  const AddressAutocompleteOverlay({
    super.key,
    required this.hintText,
    required this.onLocationSelected,
  });

  @override
  ConsumerState<AddressAutocompleteOverlay> createState() => _AddressAutocompleteOverlayState();
}

class _AddressAutocompleteOverlayState extends ConsumerState<AddressAutocompleteOverlay> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = [];
  bool _isLoading = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onSearchChanged(String query, PlacesService service) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.trim().isEmpty) {
        if (mounted) {
          setState(() {
            _suggestions = const [];
            _isLoading = false;
          });
        }
        return;
      }
      if (mounted) {
        setState(() => _isLoading = true);
      }
      
      final list = await service.getSuggestions(query);
      
      if (mounted) {
        setState(() {
          _suggestions = list;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion, PlacesService service) async {
    HapticFeedback.selectionClick();
    _focusNode.unfocus();
    
    if (mounted) {
      setState(() {
        _searchController.text = suggestion.mainText;
        _suggestions = const [];
        _isLoading = true;
      });
    }

    final coords = await service.getCoordinates(suggestion);
    
    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (coords != null) {
      widget.onLocationSelected(coords);
    }
  }

  @override
  Widget build(BuildContext context) {
    final placesService = ref.watch(placesServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: (val) => _onSearchChanged(val, placesService),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(fontSize: 13, color: GomandapTokens.slateGray),
            prefixIcon: const Icon(Icons.search_rounded, color: GomandapTokens.slateGray, size: 18),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDFBA73)),
                      ),
                    ),
                  )
                : _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: GomandapTokens.slateGray, size: 16),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _searchController.clear();
                          _onSearchChanged('', placesService);
                        },
                      )
                    : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: GomandapTokens.softMist,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: GomandapTokens.lightSlate),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xFFDFBA73), width: 1.5),
            ),
          ),
        ),
        
        if (_suggestions.isNotEmpty && _isFocused)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GomandapTokens.lightSlate),
              boxShadow: [
                BoxShadow(
                  color: GomandapTokens.royalNavy.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: GomandapTokens.lightSlate),
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: GomandapTokens.softMist,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFDFBA73)),
                    ),
                    title: Text(
                      suggestion.mainText,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: GomandapTokens.royalNavy),
                    ),
                    subtitle: Text(
                      suggestion.secondaryText,
                      style: const TextStyle(fontSize: 10, color: GomandapTokens.slateGray),
                    ),
                    onTap: () => _selectSuggestion(suggestion, placesService),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
