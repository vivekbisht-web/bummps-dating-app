import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/underline_field.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'EDIT PROFILE',
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Curate Gallery Header ---
              _buildSectionHeader('CURATE YOUR GALLERY'),
              const SizedBox(height: 12),
              
              // Cover Photo (Slot 0)
              _buildCoverPhotoSlot(),
              const SizedBox(height: 16),

              // Additional Photos Grid (Slots 1-5)
              _buildAdditionalPhotosGrid(),
              const SizedBox(height: 32),

              // --- Basic Info Section ---
              _buildSectionHeader('BASIC DETAILS'),
              const SizedBox(height: 16),

              UnderlineField(
                label: 'Name',
                hint: 'Enter your name',
                controller: controller.nameController,
              ),
              const SizedBox(height: 20),

              UnderlineField(
                label: 'Date of Birth',
                hint: 'Select Date of Birth',
                controller: controller.dobController,
                readOnly: true,
                onTap: controller.pickDob,
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),

              UnderlineField(
                label: 'Living In',
                hint: 'Enter your city',
                controller: controller.locationController,
              ),
              const SizedBox(height: 10),

              GestureDetector(
                onTap: controller.useCurrentLocation,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.my_location, size: 14, color: AppColors.gold),
                    const SizedBox(width: 6),
                    Text(
                      'DETECT LOCATION',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              UnderlineField(
                label: 'Height (cm)',
                hint: 'e.g. 175',
                controller: controller.heightController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),

              // --- Professional Info ---
              _buildSectionHeader('WORK & EDUCATION'),
              const SizedBox(height: 16),

              UnderlineField(
                label: 'Job Title',
                hint: 'e.g. Designer',
                controller: controller.jobTitleController,
              ),
              const SizedBox(height: 20),

              UnderlineField(
                label: 'Company',
                hint: 'e.g. Acme Corp',
                controller: controller.companyController,
              ),
              const SizedBox(height: 20),

              UnderlineField(
                label: 'School / University',
                hint: 'e.g. Harvard University',
                controller: controller.schoolController,
              ),
              const SizedBox(height: 32),

              // --- Bio Section ---
              _buildSectionHeader('ABOUT ME'),
              const SizedBox(height: 12),
              
              _buildBioTextField(),
              const SizedBox(height: 32),

              // --- Gender & Preferences ---
              _buildSectionHeader('GENDER DETAILS'),
              const SizedBox(height: 16),

              _buildGenderSelection(),
              const SizedBox(height: 20),

              _buildInterestedInSelection(),
              const SizedBox(height: 32),

              // --- Matching Preferences Sliders ---
              _buildSectionHeader('MATCHING PREFERENCES'),
              const SizedBox(height: 16),

              _buildDistanceSlider(),
              const SizedBox(height: 24),

              _buildAgeRangeSlider(),
              const SizedBox(height: 32),

              // --- Interests Chips Section ---
              _buildSectionHeader('INTERESTS (MAX 5)'),
              const SizedBox(height: 12),

              _buildInterestsChips(),
              const SizedBox(height: 32),

              // --- Lifestyle Chips Section ---
              _buildSectionHeader('LIFESTYLE'),
              const SizedBox(height: 12),

              _buildLifestyleChips(),
              const SizedBox(height: 32),

              // --- Languages Chips Section ---
              _buildSectionHeader('LANGUAGES'),
              const SizedBox(height: 12),

              _buildLanguagesChips(),
              const SizedBox(height: 48),

              // --- Save Changes Button ---
              _buildSaveButton(),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
      ],
    );
  }

  Widget _buildCoverPhotoSlot() {
    final photo = controller.photos[0];
    return GestureDetector(
      onTap: () => controller.addPhoto(0),
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (photo != null) ...[
              _buildImageWidget(photo),
              Positioned(
                top: 12,
                right: 12,
                child: _buildRemoveButton(() => controller.removePhoto(0)),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                  ),
                  child: Text(
                    'PRIMARY COVER',
                    style: AppTextStyles.caption.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ),
            ] else
              _buildAddPhotoPlaceholder('Primary Cover'),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalPhotosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final actualIndex = index + 1;
        final photo = controller.photos[actualIndex];
        return GestureDetector(
          onTap: () => controller.addPhoto(actualIndex),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (photo != null) ...[
                  _buildImageWidget(photo),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildRemoveButton(() => controller.removePhoto(actualIndex)),
                  ),
                ] else
                  _buildAddPhotoPlaceholder('Add Slot ${actualIndex + 1}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageWidget(String path) {
    if (path.startsWith('http') || path.startsWith('/uploads') || path.startsWith('/')) {
      final fullUrl = path.startsWith('http')
          ? path
          : 'http://148.66.153.121:5000${path.startsWith('/') ? '' : '/'}$path';
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 36),
        ),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildRemoveButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
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
    );
  }

  Widget _buildAddPhotoPlaceholder(String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold.withOpacity(0.8), width: 1.5),
          ),
          child: const Icon(Icons.add, color: AppColors.gold, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gold.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBioTextField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller.bioController,
            maxLines: 4,
            maxLength: 300,
            onChanged: controller.onBioChanged,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Share a little about yourself...',
              hintStyle: TextStyle(color: AppColors.textMuted),
              border: InputBorder.none,
              counterText: '',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Obx(() => Text(
                  '${controller.bioLength.value}/300',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR GENDER',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(() => Row(
              children: controller.genders.map((g) {
                final isSelected = controller.gender.value == g;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          g,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => controller.selectGender(g),
                      selectedColor: AppColors.gold,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(color: isSelected ? AppColors.gold : AppColors.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildInterestedInSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INTERESTED IN',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(() => Row(
              children: controller.interestedInOptions.map((g) {
                final isSelected = controller.interestedIn.value == g;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          g,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => controller.selectInterestedIn(g),
                      selectedColor: AppColors.gold,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(color: isSelected ? AppColors.gold : AppColors.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildDistanceSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MAXIMUM DISTANCE',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ),
            Obx(() => Text(
                  '${controller.distancePreference.value} miles',
                  style: AppTextStyles.caption.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
                )),
          ],
        ),
        Obx(() => Slider(
              value: controller.distancePreference.value.toDouble(),
              min: 5,
              max: 100,
              divisions: 19,
              activeColor: AppColors.gold,
              inactiveColor: AppColors.divider,
              onChanged: (val) {
                controller.distancePreference.value = val.round();
              },
            )),
      ],
    );
  }

  Widget _buildAgeRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AGE PREFERENCE',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ),
            Obx(() => Text(
                  '${controller.agePreferenceMin.value}-${controller.agePreferenceMax.value}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
                )),
          ],
        ),
        Obx(() => RangeSlider(
              values: RangeValues(
                controller.agePreferenceMin.value.toDouble(),
                controller.agePreferenceMax.value.toDouble(),
              ),
              min: 18,
              max: 80,
              activeColor: AppColors.gold,
              inactiveColor: AppColors.divider,
              labels: RangeLabels(
                '${controller.agePreferenceMin.value}',
                '${controller.agePreferenceMax.value}',
              ),
              onChanged: (values) {
                controller.agePreferenceMin.value = values.start.round();
                controller.agePreferenceMax.value = values.end.round();
              },
            )),
      ],
    );
  }

  Widget _buildInterestsChips() {
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.interestsOptions.map((interest) {
            final isSelected = controller.isInterestSelected(interest);
            return FilterChip(
              label: Text(
                interest,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => controller.toggleInterest(interest),
              selectedColor: AppColors.gold,
              checkmarkColor: Colors.black,
              backgroundColor: AppColors.surface,
              side: BorderSide(color: isSelected ? AppColors.gold : AppColors.divider),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          }).toList(),
        ));
  }

  Widget _buildLifestyleChips() {
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.lifestyleOptions.map((item) {
            final isSelected = controller.isLifestyleSelected(item);
            return FilterChip(
              label: Text(
                item,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => controller.toggleLifestyle(item),
              selectedColor: AppColors.gold,
              checkmarkColor: Colors.black,
              backgroundColor: AppColors.surface,
              side: BorderSide(color: isSelected ? AppColors.gold : AppColors.divider),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          }).toList(),
        ));
  }

  Widget _buildLanguagesChips() {
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.languageOptions.map((lang) {
            final isSelected = controller.isLanguageSelected(lang);
            return FilterChip(
              label: Text(
                lang,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => controller.toggleLanguage(lang),
              selectedColor: AppColors.gold,
              checkmarkColor: Colors.black,
              backgroundColor: AppColors.surface,
              side: BorderSide(color: isSelected ? AppColors.gold : AppColors.divider),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          }).toList(),
        ));
  }

  Widget _buildSaveButton() {
    return Obx(() {
      final isSaving = controller.isSaving.value;
      return Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isSaving ? null : controller.saveProfile,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.black)
                  : Text(
                      'SAVE CHANGES',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ),
        ),
      );
    });
  }
}
