import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../controllers/profile_setup_controller.dart';

class AgeGroupOption {
  final String label;
  final int minAge;
  final int maxAge;
  final String imageUrl;

  const AgeGroupOption({
    required this.label,
    required this.minAge,
    required this.maxAge,
    required this.imageUrl,
  });
}

/// Step 4 — "Preferences" (Age Group Selection & Search Radius Distance).
class PreferencesStep extends StatelessWidget {
  const PreferencesStep({super.key, required this.controller});

  final ProfileSetupController controller;

  static const List<AgeGroupOption> ageGroups = [
    AgeGroupOption(
      label: '18-25',
      minAge: 18,
      maxAge: 25,
      imageUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
    ),
    AgeGroupOption(
      label: '25-35',
      minAge: 25,
      maxAge: 35,
      imageUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',
    ),
    AgeGroupOption(
      label: '35-50',
      minAge: 35,
      maxAge: 50,
      imageUrl:
          'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=crop&w=300&q=80',
    ),
    AgeGroupOption(
      label: '50+',
      minAge: 50,
      maxAge: 100,
      imageUrl:
          'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?auto=format&fit=crop&w=300&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upper uppercase label
          Text(
            'Preferences',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          // Headline
          Text(
            'Who are you looking for?',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            'Pick an age group to start browsing',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // 2x2 Age Group Selection Grid
          Obx(() {
            final currentMin = controller.agePreferenceMin.value;
            final currentMax = controller.agePreferenceMax.value;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildAgeCard(ageGroups[0], currentMin, currentMax),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAgeCard(ageGroups[1], currentMin, currentMax),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildAgeCard(ageGroups[2], currentMin, currentMax),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAgeCard(ageGroups[3], currentMin, currentMax),
                    ),
                  ],
                ),
              ],
            );
          }),

          const SizedBox(height: 40),

          // Maximum Distance Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.gold,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'MAXIMUM DISTANCE',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Obx(() => Text(
                      '${controller.distancePreference.value} km',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Distance Slider and Ranges
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.gold,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.gold,
              overlayColor: AppColors.gold.withOpacity(0.2),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Obx(() => Slider(
                  value: controller.distancePreference.value.toDouble(),
                  min: 1.0,
                  max: 100.0,
                  onChanged: (val) {
                    controller.distancePreference.value = val.round();
                  },
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 km', style: AppTextStyles.caption),
                Text('100 km', style: AppTextStyles.caption),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // CTA Button
          PrimaryButton(
            label: 'SAVE PREFERENCES',
            onPressed: controller.next,
          ),

          const SizedBox(height: 16),

          // Centered helper/disclaimer text
          Center(
            child: Text(
              'You can change these preferences at any time in your profile settings.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeCard(AgeGroupOption option, int currentMin, int currentMax) {
    final isSelected = currentMin == option.minAge && currentMax == option.maxAge;

    return GestureDetector(
      onTap: () {
        controller.agePreferenceMin.value = option.minAge;
        controller.agePreferenceMax.value = option.maxAge;
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.gold : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // Circular image
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.gold : AppColors.divider,
                  width: 2,
                ),
                image: DecorationImage(
                  image: NetworkImage(option.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Custom pill selection label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.transparent : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.gold : AppColors.divider,
                  width: 1.5,
                ),
              ),
              child: Text(
                option.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.gold : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
