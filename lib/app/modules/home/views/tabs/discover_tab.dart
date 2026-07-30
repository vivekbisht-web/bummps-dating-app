import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../controllers/home_controller.dart';

class DiscoverTab extends GetView<HomeController> {
  const DiscoverTab({super.key});

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
                GestureDetector(
                  onTap: () {
                    // Navigate to profile tab
                    controller.activeTab.value = 3;
                  },
                  child: Image.asset(
                    'assets/images/bummps-icon.png',
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ),
                Image.asset(
                  'assets/images/bummps..png',
                  height: 18,
                  fit: BoxFit.contain,
                ),
                IconButton(
                  icon: const Icon(Icons.tune_outlined, color: AppColors.gold),
                  onPressed: () {
                    // Quick filters feedback
                    Get.snackbar(
                      'Preferences',
                      'Filter preferences menu coming soon in Premium.',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: AppColors.surface,
                      colorText: AppColors.textPrimary,
                    );
                  },
                ),
              ],
            ),
          ),

          // Main Card Area
          Expanded(
            child: Obx(() {
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
                  const SizedBox(height: 16),

                  // ID label
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'ID: ${profile.id}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
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
