import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bummps_logo.dart';
import '../../controllers/home_controller.dart';
import 'profile_details_view.dart';

class DiscoverTab extends GetView<HomeController> {
  const DiscoverTab({super.key});

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48), // Balances the filter button width for perfect centering
                const BummpsLogo(compact: true),
                IconButton(
                  icon: Obx(() => Icon(
                    Icons.tune_outlined,
                    color: controller.isFilterActive.value
                        ? AppColors.gold
                        : AppColors.textSecondary,
                  )),
                  onPressed: () => _showFilterSheet(context),
                ),
              ],
            ),
          ),

          // Main Card Area
          Expanded(
            child: Obx(() {
              if (controller.isLoadingFeed.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                  ),
                );
              }
              if (controller.profiles.isEmpty) {
                return _NoMoreProfilesView(controller: controller);
              }

              // Build stack of cards (bottom first, top last)
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Next card (underneath top card)
                  if (controller.profiles.length > 1)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        child: Transform.scale(
                          scale: 0.95,
                          child: _ProfileCard(
                            profile: controller.profiles[1],
                            isTopCard: false,
                          ),
                        ),
                      ),
                    ),

                  // Top Card
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      child: _TopDraggableCard(controller: controller),
                    ),
                  ),
                ],
              );
            }),
          ),

          // Action Buttons Bar
          _ActionButtonsBar(controller: controller),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TopDraggableCard extends StatelessWidget {
  final HomeController controller;
  const _TopDraggableCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final ProfileCardData topProfile = controller.profiles.first;

    return GestureDetector(
      onTap: () {
        Get.to(
          () => ProfileDetailsView(profile: topProfile, controller: controller),
          transition: Transition.downToUp,
        );
      },
      onPanUpdate: (details) {
        controller.updateCardPosition(
          controller.cardX.value + details.delta.dx,
          controller.cardY.value + details.delta.dy,
        );
      },
      onPanEnd: (details) {
        controller.handlePanEnd(
          details.velocity.pixelsPerSecond.dx,
          details.velocity.pixelsPerSecond.dy,
        );
      },
      child: Obx(() {
        // Compute animation transformation values based on drag
        final double x = controller.cardX.value;
        final double y = controller.cardY.value;
        final double angle = (x / 300) * 0.2; // slight rotation in radians

        return Transform.translate(
          offset: Offset(x, y),
          child: Transform.rotate(
            angle: angle,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _ProfileCard(
                  profile: topProfile,
                  isTopCard: true,
                ),

                // Swipe overlay action stamps (LIKE, NOPE, SUPER)
                if (controller.swipeDirection.value.isNotEmpty)
                  Positioned.fill(
                    child: Opacity(
                      opacity: controller.swipeOverlayOpacity.value,
                      child: _SwipeLabelOverlay(direction: controller.swipeDirection.value),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final ProfileCardData profile;
  final bool isTopCard;

  const _ProfileCard({
    required this.profile,
    required this.isTopCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.divider, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Profile photo
            Image.network(
              profile.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.surface,
                child: const Center(
                  child: Icon(Icons.person, size: 80, color: AppColors.textMuted),
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.surface,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  ),
                );
              },
            ),

            // Soft dark overlay scrim at bottom for text contrast
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black87,
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),

            // Top Badges
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // VERIFIED BADGE
                  if (profile.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.gold.withOpacity(0.6), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, color: AppColors.gold, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'VERIFIED',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // MATCH SCORE BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                    ),
                    child: Text(
                      '${profile.matchScore}% MATCH',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Profile info content at bottom
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Age
                  Row(
                    children: [
                      Text(
                        '${profile.name}, ${profile.age}',
                        style: AppTextStyles.displayLarge.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: AppColors.gold, size: 22),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Job details
                  Row(
                    children: [
                      const Icon(Icons.business_center_outlined, color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        profile.job,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Distance
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        profile.distance,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Bio description snippet
                  Text(
                    profile.bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.85),
                      fontSize: 12.5,
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeLabelOverlay extends StatelessWidget {
  final String direction;
  const _SwipeLabelOverlay({required this.direction});

  @override
  Widget build(BuildContext context) {
    Color labelColor = Colors.green;
    String labelText = 'LIKE';
    double rotateAngle = -0.15;

    if (direction == 'nope') {
      labelColor = AppColors.error;
      labelText = 'NOPE';
      rotateAngle = 0.15;
    } else if (direction == 'super') {
      labelColor = Colors.blue;
      labelText = 'SUPER';
      rotateAngle = 0.0;
    }

    return Center(
      child: Transform.rotate(
        angle: rotateAngle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: labelColor, width: 4),
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withOpacity(0.2),
          ),
          child: Text(
            labelText,
            style: AppTextStyles.displayLarge.copyWith(
              color: labelColor,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButtonsBar extends StatelessWidget {
  final HomeController controller;
  const _ActionButtonsBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // UNDO / REWIND
        _CircularActionButton(
          icon: Icons.replay,
          iconColor: Colors.white,
          backgroundColor: AppColors.surfaceElevated,
          size: 48,
          onTap: controller.undoSwipe,
        ),
        const SizedBox(width: 14),

        // PASS (X)
        _CircularActionButton(
          icon: Icons.close,
          iconColor: Colors.white,
          backgroundColor: AppColors.surfaceElevated,
          size: 52,
          onTap: () => controller.forceSwipe('nope'),
        ),
        const SizedBox(width: 14),

        // SUPER LIKE (STAR)
        _CircularActionButton(
          icon: Icons.star,
          iconColor: Colors.black,
          backgroundColor: AppColors.gold,
          size: 64,
          onTap: () => controller.forceSwipe('super'),
        ),
        const SizedBox(width: 14),

        // LIKE (HEART)
        _CircularActionButton(
          icon: Icons.favorite,
          iconColor: Colors.white,
          backgroundColor: AppColors.surfaceElevated,
          size: 52,
          onTap: () => controller.forceSwipe('like'),
        ),
        const SizedBox(width: 14),

        // BOOST (LIGHTNING)
        Obx(() {
          final bool isBoosted = controller.isBoostActive.value;
          return _CircularActionButton(
            icon: Icons.flash_on,
            iconColor: AppColors.gold,
            backgroundColor: isBoosted ? AppColors.gold.withOpacity(0.15) : AppColors.surfaceElevated,
            border: isBoosted ? Border.all(color: AppColors.gold, width: 1.5) : null,
            size: 48,
            onTap: controller.triggerBoost,
          );
        }),
      ],
    );
  }
}

class _CircularActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final BoxBorder? border;
  final double size;
  final VoidCallback onTap;

  const _CircularActionButton({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.border,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: border ?? Border.all(color: AppColors.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: iconColor, size: size * 0.45),
        ),
      ),
    );
  }
}

class _NoMoreProfilesView extends StatelessWidget {


  final HomeController controller;
  const _NoMoreProfilesView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Radar pulse effect simulation
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withOpacity(0.15), width: 3),
              ),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 2),
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.explore,
                        color: AppColors.onGold,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Looking for matches...',
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.gold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You have reviewed all souls nearby. Toggle preferences or undo to reconsider past swipes.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: controller.undoSwipe,
              icon: const Icon(Icons.replay, color: AppColors.gold),
              label: Text(
                'UNDO LAST SWIPE',
                style: AppTextStyles.button.copyWith(color: AppColors.gold, letterSpacing: 0.5),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter Bottom Sheet
// ---------------------------------------------------------------------------
class _FilterSheet extends StatefulWidget {
  final HomeController controller;
  const _FilterSheet({required this.controller});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  // Local draft state — committed only when user taps Apply
  String? _ageGroup;
  double _maxDistance = 25;
  final Set<String> _interests = {};
  final Set<String> _lifestyle  = {};
  final Set<String> _languages  = {};
  double _minHeight = 150;
  double _maxHeight = 200;
  bool _isVerified = false;

  static const List<String> _ageGroups = ['18-25', '25-35', '35-50', '50+'];
  static const List<String> _allInterests = [
    'PHOTOGRAPHY', 'ARCHITECTURE', 'FINE DINING', 'TRAVEL',
    'ART GALLERIES', 'SAILING', 'FITNESS', 'MUSIC', 'READING', 'COOKING',
  ];
  static const List<String> _allLifestyle = [
    'NON-SMOKER', 'SMOKER', 'FITNESS', 'SOCIAL DRINKER',
    'DOG LOVER', 'CAT LOVER', 'VEGAN',
  ];
  static const List<String> _allLanguages = [
    'English', 'French', 'Spanish', 'German',
    'Italian', 'Hindi', 'Mandarin', 'Arabic',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill from currently active filters
    final c = widget.controller;
    _ageGroup    = c.activeAgeGroup;
    _maxDistance = (c.activeMaxDistance ?? 25).toDouble();
    _interests.addAll(c.activeInterests);
    _lifestyle.addAll(c.activeLifestyle);
    _languages.addAll(c.activeLanguages);
    _minHeight   = (c.activeMinHeight ?? 150).toDouble();
    _maxHeight   = (c.activeMaxHeight ?? 200).toDouble();
    _isVerified  = c.activeIsVerified ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filters',
                        style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.controller.clearFilter();
                      },
                      child: Text('Clear All',
                          style: AppTextStyles.button.copyWith(
                              color: AppColors.gold, letterSpacing: 0)),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.divider),
              // Scrollable filter body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    // Age Group
                    _sectionLabel('Age Group'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10, runSpacing: 10,
                      children: _ageGroups.map((ag) {
                        final selected = _ageGroup == ag;
                        return GestureDetector(
                          onTap: () => setState(() =>
                              _ageGroup = selected ? null : ag),
                          child: _pill(ag, selected),
                        );
                      }).toList(),
                    ),

                    // Max Distance
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionLabel('Max Distance'),
                        Text('${_maxDistance.round()} km',
                            style: AppTextStyles.button.copyWith(
                                color: AppColors.gold, fontSize: 14)),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.gold,
                        inactiveTrackColor: AppColors.divider,
                        thumbColor: AppColors.gold,
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: _maxDistance,
                        min: 1, max: 100,
                        onChanged: (v) => setState(() => _maxDistance = v),
                      ),
                    ),

                    // Height Range
                    const SizedBox(height: 16),
                    _sectionLabel('Height Range'),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Min: ${_minHeight.round()} cm',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary)),
                        Text('Max: ${_maxHeight.round()} cm',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.gold,
                        inactiveTrackColor: AppColors.divider,
                        thumbColor: AppColors.gold,
                        trackHeight: 3,
                      ),
                      child: RangeSlider(
                        values: RangeValues(_minHeight, _maxHeight),
                        min: 140, max: 220,
                        activeColor: AppColors.gold,
                        inactiveColor: AppColors.divider,
                        onChanged: (v) => setState(() {
                          _minHeight = v.start;
                          _maxHeight = v.end;
                        }),
                      ),
                    ),

                    // Interests
                    const SizedBox(height: 16),
                    _sectionLabel('Interests'),
                    const SizedBox(height: 10),
                    _chipWrap(_allInterests, _interests),

                    // Lifestyle
                    const SizedBox(height: 24),
                    _sectionLabel('Lifestyle'),
                    const SizedBox(height: 10),
                    _chipWrap(_allLifestyle, _lifestyle),

                    // Languages
                    const SizedBox(height: 24),
                    _sectionLabel('Languages'),
                    const SizedBox(height: 10),
                    _chipWrap(_allLanguages, _languages),

                    // Verified Only
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionLabel('Verified Only'),
                        Switch(
                          value: _isVerified,
                          activeColor: AppColors.gold,
                          onChanged: (v) => setState(() => _isVerified = v),
                        ),
                      ],
                    ),

                    // Apply button
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        widget.controller.applyFilter(
                          ageGroup:    _ageGroup,
                          maxDistance: _maxDistance.round(),
                          interests:   _interests.toList(),
                          lifestyle:   _lifestyle.toList(),
                          languages:   _languages.toList(),
                          minHeight:   _minHeight.round(),
                          maxHeight:   _maxHeight.round(),
                          isVerified:  _isVerified,
                        );
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text('APPLY FILTERS',
                              style: AppTextStyles.button),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8),
      );

  Widget _pill(String label, bool selected) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold.withValues(alpha: 0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Text(label,
            style: AppTextStyles.bodyMedium.copyWith(
                color: selected ? AppColors.gold : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
      );

  Widget _chipWrap(List<String> options, Set<String> selected) {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: options.map((opt) {
        final sel = selected.contains(opt);
        return GestureDetector(
          onTap: () => setState(() => sel ? selected.remove(opt) : selected.add(opt)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? AppColors.gold.withValues(alpha: 0.15) : AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: sel ? AppColors.gold : AppColors.divider, width: 1.5),
            ),
            child: Text(opt,
                style: AppTextStyles.caption.copyWith(
                    color: sel ? AppColors.gold : AppColors.textSecondary,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }
}
