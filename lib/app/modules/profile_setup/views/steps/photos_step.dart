import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../controllers/profile_setup_controller.dart';

/// Step 3 — "Curate Your Gallery".
class PhotosStep extends StatelessWidget {
  const PhotosStep({super.key, required this.controller});

  final ProfileSetupController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text('Curate Your Gallery',
                style: AppTextStyles.headlineMedium),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your most captivating moments. Quality photography is '
            'the hallmark of a Bummps profile.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 28),
          _PhotoTile(
            label: 'Primary Cover',
            height: 220,
            onTap: () => controller.addPhoto(0),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.photos.length - 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              return _PhotoTile(onTap: () => controller.addPhoto(index + 1));
            },
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Continue',
            trailingIcon: Icons.arrow_forward,
            onPressed: controller.next,
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({this.label, this.height, required this.onTap});

  final String? label;
  final double? height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 1.5),
              ),
              child: const Icon(Icons.add, color: AppColors.gold),
            ),
            if (label != null) ...[
              const SizedBox(height: 12),
              Text(
                label!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
