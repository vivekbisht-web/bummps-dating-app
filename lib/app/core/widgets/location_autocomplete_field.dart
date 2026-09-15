import 'dart:async';
import 'package:flutter/material.dart';

import '../services/location_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LocationAutocompleteField extends StatefulWidget {
  const LocationAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.onLocationSelected,
    this.onDetectLocation,
    this.isDetecting = false,
    this.detectButtonText = 'USE CURRENT LOCATION',
    this.textInputAction = TextInputAction.done,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final void Function(LocationSuggestion suggestion)? onLocationSelected;
  final VoidCallback? onDetectLocation;
  final bool isDetecting;
  final String detectButtonText;
  final TextInputAction textInputAction;

  @override
  State<LocationAutocompleteField> createState() => _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<LocationAutocompleteField> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  List<LocationSuggestion> _suggestions = [];
  bool _isLoadingSuggestions = false;
  Timer? _debounceTimer;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    } else if (widget.controller.text.trim().length >= 2 && _suggestions.isNotEmpty) {
      _showOverlay();
    }
  }

  void _onTextChanged() {
    final query = widget.controller.text.trim();
    _debounceTimer?.cancel();

    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _isLoadingSuggestions = false;
      });
      _removeOverlay();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() {
        _isLoadingSuggestions = true;
      });

      final results = await LocationService.instance.getSuggestions(query);

      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _isLoadingSuggestions = false;
      });

      if (_focusNode.hasFocus && results.isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    _overlayEntry = _createOverlayEntry();
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? const Size(300, 50);

    return OverlayEntry(
      builder: (ctx) {
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0.0, 75.0),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFF181512),
              shadowColor: Colors.black.withOpacity(0.6),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  color: const Color(0xFF181512),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 0.6,
                    color: Colors.white.withOpacity(0.06),
                  ),
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return InkWell(
                      onTap: () {
                        widget.controller.text = suggestion.displayName;
                        widget.onLocationSelected?.call(suggestion);
                        _removeOverlay();
                        _focusNode.unfocus();
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppColors.gold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    suggestion.primaryText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (suggestion.secondaryText.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      suggestion.secondaryText,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.55),
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            textInputAction: widget.textInputAction,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              filled: false,
              hintText: widget.hint,
              hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
              suffixIcon: _isLoadingSuggestions
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                      ),
                    )
                  : (widget.controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                          onPressed: () {
                            widget.controller.clear();
                            setState(() {
                              _suggestions = [];
                            });
                            _removeOverlay();
                          },
                        )
                      : const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textMuted)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.gold, width: 1.5),
              ),
            ),
          ),
          if (widget.onDetectLocation != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: widget.isDetecting ? null : widget.onDetectLocation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isDetecting)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                    )
                  else
                    const Icon(Icons.my_location, size: 15, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Text(
                    widget.isDetecting ? 'DETECTING LOCATION...' : widget.detectButtonText,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
