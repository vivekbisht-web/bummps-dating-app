import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../controllers/profile_setup_controller.dart';

/// Step 4 — "The Final Glance" Profile Preview.
class PreviewStep extends StatelessWidget {
  const PreviewStep({super.key, required this.controller});

  final ProfileSetupController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'The Final Glance',
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This is how your essence will appear to others in the Bummps ecosystem. Exclusivity is in the details.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          // About You Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About You',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  controller.bioController.text.trim().isNotEmpty
                      ? '"${controller.bioController.text.trim()}"'
                      : '"Seeking a connection that transcends the ordinary. A connoisseur of late-night conversations, vintage horology, and architectural wonders."',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          
          // Core Interests Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Core Interests',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final interests = controller.selectedInterests;
                  final displayList = interests.isNotEmpty
                      ? interests
                      : ['Fine Dining', 'Art Galleries', 'Sailing', 'Travel'];
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: displayList.map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.textMuted.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          interest.toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 18),
          
          // Live Preview Card
          Container(
            height: 420,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.divider),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover Image
                  Obx(() {
                    final primaryPhoto = controller.photos[0];
                    if (primaryPhoto == null) {
                      return Image.asset(
                        'assets/images/onboarding_1.png',
                        fit: BoxFit.cover,
                      );
                    } else if (primaryPhoto.startsWith('assets/')) {
                      return Image.asset(
                        primaryPhoto,
                        fit: BoxFit.cover,
                      );
                    } else if (primaryPhoto.startsWith('http')) {
                      return Image.network(
                        primaryPhoto,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return Image.file(
                        File(primaryPhoto),
                        fit: BoxFit.cover,
                      );
                    }
                  }),
                  
                  // Black Scrim overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.85),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                  
                  // Top Right Badge (PREVIEW MODE)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'PREVIEW MODE',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  // Bottom Left Details
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${controller.firstNameController.text.trim().isEmpty ? 'Alexander' : controller.firstNameController.text.trim()}, ${controller.age}',
                              style: AppTextStyles.displayLarge.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.verified,
                              color: AppColors.gold,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.textMuted,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              controller.locationController.text.trim().isNotEmpty
                                  ? controller.locationController.text.trim()
                                  : 'Upper East Side, NY',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Match Score Widget
                        Row(
                          children: [
                            _ScoreBox(digit: '9'),
                            const SizedBox(width: 4),
                            _ScoreBox(digit: '8'),
                            const SizedBox(width: 8),
                            Text(
                              'MATCH\nSCORE',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                                letterSpacing: 0.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Action Buttons
          PrimaryButton(
            label: 'LOOKS PERFECT',
            onPressed: controller.next,
          ),
          const SizedBox(height: 12),
          
          // EDIT PROFILE custom outlined button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: controller.editProfile,
              child: Ink(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.gold.withOpacity(0.4), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    'EDIT PROFILE',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String digit;
  const _ScoreBox({required this.digit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        digit,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.gold,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
