import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/location_autocomplete_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/underline_field.dart';
import '../../controllers/profile_setup_controller.dart';

/// Step 1 — "Tell us who you are".
class BasicInfoStep extends StatelessWidget {
  const BasicInfoStep({super.key, required this.controller});

  final ProfileSetupController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us who you are', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            "Your journey begins with the basics. Let's start with your "
            'name and birth date.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 32),
          UnderlineField(
            label: 'First Name',
            hint: 'Enter your name',
            controller: controller.firstNameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 24),
          UnderlineField(
            label: 'Date of Birth',
            hint: 'mm/dd/yyyy',
            controller: controller.dobController,
            readOnly: true,
            onTap: controller.pickDob,
            suffixIcon: const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          GetBuilder<ProfileSetupController>(
            builder: (_) {
              return Obx(() {
                return LocationAutocompleteField(
                  label: 'Current Location',
                  hint: 'Search city or address',
                  controller: controller.locationController,
                  isDetecting: controller.isDetectingLocation.value,
                  onDetectLocation: controller.useCurrentLocation,
                  onLocationSelected: controller.onLocationSelected,
                  textInputAction: TextInputAction.done,
                );
              });
            },
          ),
          const SizedBox(height: 40),
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
