import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          Obx(() => _PhotoTile(
                label: 'Primary Cover',
                height: 220,
                photoPath: controller.photos[0],
                onTap: () => controller.addPhoto(0),
                onRemove: () => controller.removePhoto(0),
              )),
          const SizedBox(height: 16),
          Obx(() => GridView.builder(
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
                  final actualIndex = index + 1;
                  return _PhotoTile(
                    photoPath: controller.photos[actualIndex],
                    onTap: () => controller.addPhoto(actualIndex),
                    onRemove: () => controller.removePhoto(actualIndex),
                  );
                },
              )),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Get.snackbar('Bummps', 'Quality guidelines coming soon');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.gold, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Quality Guidelines',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
  const _PhotoTile({
    this.label,
    this.height,
    required this.onTap,
    required this.onRemove,
    this.photoPath,
  });

  final String? label;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: photoPath != null ? null : onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          image: photoPath != null
              ? DecorationImage(
                  image: FileImage(File(photoPath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (photoPath == null)
              Column(
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
            if (photoPath != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
