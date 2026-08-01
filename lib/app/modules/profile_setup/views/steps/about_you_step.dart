import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/selectable_chip.dart';
import '../../controllers/profile_setup_controller.dart';

/// Step 2 — "Tell us about you".
class AboutYouStep extends StatelessWidget {
  const AboutYouStep({super.key, required this.controller});

  final ProfileSetupController controller;

  static const Map<String, IconData> _interestIcons = {
    'PHOTOGRAPHY': Icons.camera_alt_outlined,
    'ARCHITECTURE': Icons.apartment_outlined,
    'FINE DINING': Icons.restaurant_outlined,
    'TRAVEL': Icons.flight_takeoff_outlined,
    'ART GALLERIES': Icons.palette_outlined,
    'SAILING': Icons.sailing_outlined,
    'FITNESS': Icons.fitness_center_outlined,
    'MUSIC': Icons.music_note_outlined,
    'READING': Icons.menu_book_outlined,
    'COOKING': Icons.outdoor_grill_outlined,
  };

  static const Map<String, IconData> _lifestyleIcons = {
    'NON-SMOKER': Icons.smoke_free_outlined,
    'SMOKER': Icons.smoking_rooms_outlined,
    'FITNESS': Icons.fitness_center_outlined,
    'SOCIAL DRINKER': Icons.local_bar_outlined,
    'DOG LOVER': Icons.pets_outlined,
    'CAT LOVER': Icons.pets_outlined,
    'VEGAN': Icons.eco_outlined,
  };

  static const Map<String, IconData> _languageIcons = {
    'English': Icons.language,
    'French': Icons.language,
    'Spanish': Icons.language,
    'German': Icons.language,
    'Italian': Icons.language,
    'Hindi': Icons.language,
    'Mandarin': Icons.language,
    'Arabic': Icons.language,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about you', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Help your sparks get to know the person behind the profile. '
            'Your profile is your digital concierge.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 24),
          _sectionLabel('Bio'),
          const SizedBox(height: 8),
          _BioField(controller: controller),
          const SizedBox(height: 24),
          _sectionLabel('Gender'),
          const SizedBox(height: 10),
          Obx(
            () => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.genders
                  .map((g) => SelectableChip(
                        label: g,
                        selected: controller.gender.value == g,
                        onTap: () => controller.selectGender(g),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel('Interested In'),
          const SizedBox(height: 10),
          Obx(
            () => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.interestedInOptions
                  .map((g) => SelectableChip(
                        label: g,
                        selected: controller.interestedIn.value == g,
                        onTap: () => controller.selectInterestedIn(g),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionLabel('Interests'),
              Text('Select up to ${ProfileSetupController.maxInterests}',
                  style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 10),
          Obx(
            () => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.interests
                  .map((i) => SelectableChip(
                        label: i,
                        icon: _interestIcons[i],
                        selected: controller.isInterestSelected(i),
                        onTap: () => controller.toggleInterest(i),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _FilledField(
                  label: 'Height',
                  hint: '185 cm',
                  controller: controller.heightController,
                  icon: Icons.straighten,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _FilledField(
                  label: 'Education',
                  hint: 'Degree',
                  controller: controller.educationController,
                  icon: Icons.school_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _FilledField(
                  label: 'Job Title',
                  hint: 'Software Engineer',
                  controller: controller.jobTitleController,
                  icon: Icons.work_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _FilledField(
                  label: 'Company',
                  hint: 'Tech Corp',
                  controller: controller.companyController,
                  icon: Icons.business,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionLabel('Lifestyle'),
              Text('Select all that apply', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 10),
          Obx(
            () => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.lifestyleOptions
                  .map((l) => SelectableChip(
                        label: l,
                        icon: _lifestyleIcons[l],
                        selected: controller.isLifestyleSelected(l),
                        onTap: () => controller.toggleLifestyle(l),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel('Languages'),
          const SizedBox(height: 10),
          Obx(
            () => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.languageOptions
                  .map((lang) => SelectableChip(
                        label: lang,
                        icon: _languageIcons[lang],
                        selected: controller.isLanguageSelected(lang),
                        onTap: () => controller.toggleLanguage(lang),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Continue',
            trailingIcon: Icons.arrow_forward,
            onPressed: controller.next,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'MEMBER DISCRETION GUARANTEED',
              style: AppTextStyles.caption.copyWith(letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.gold,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      );
}

class _BioField extends StatelessWidget {
  const _BioField({required this.controller});

  final ProfileSetupController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: controller.bioController,
            onChanged: controller.onBioChanged,
            maxLength: ProfileSetupController.maxBioLength,
            maxLines: 3,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'Write a short bio that captures your essence...',
              hintStyle: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textMuted),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Obx(
            () => Text(
              '${controller.bioLength.value}/${ProfileSetupController.maxBioLength}',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilledField extends StatelessWidget {
  const _FilledField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
