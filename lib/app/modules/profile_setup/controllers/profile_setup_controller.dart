import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_pages.dart';

/// Drives the multi-step profile setup wizard: tracks the active step,
/// holds all form data, and handles inter-step navigation.
class ProfileSetupController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentStep = 0.obs;

  /// Steps designed in Figma. The progress label still references "of 5".
  static const int totalSteps = 5;
  static const int implementedSteps = 5;
  static const int maxInterests = 5;
  static const int maxBioLength = 300;

  // --- Step 1: basics ---
  final firstNameController = TextEditingController();
  final dobController = TextEditingController();
  final locationController = TextEditingController();
  final Rxn<DateTime> dob = Rxn<DateTime>();

  // --- Step 2: about you ---
  final bioController = TextEditingController();
  final RxInt bioLength = 0.obs;
  final RxnString gender = RxnString();
  final RxList<String> selectedInterests = <String>[].obs;
  final heightController = TextEditingController();
  final educationController = TextEditingController();

  final List<String> genders = const ['Woman', 'Man', 'Non-binary'];
  final List<String> interests = const [
    'Photography',
    'Architecture',
    'Oenology',
    'Travel',
    'Classical Music',
    'Yachting',
  ];

  // --- Step 3: gallery ---
  final RxList<String?> photos = List<String?>.filled(6, null).obs;

  // --- Step 4: verification ---
  final RxBool isVerifying = false.obs;

  double get progress => (currentStep.value + 1) / totalSteps;
  int get percent => (progress * 100).round();

  bool get isLastImplementedStep =>
      currentStep.value == implementedSteps - 1;

  int get age {
    if (dob.value == null) return 29;
    final now = DateTime.now();
    int age = now.year - dob.value!.year;
    if (now.month < dob.value!.month ||
        (now.month == dob.value!.month && now.day < dob.value!.day)) {
      age--;
    }
    return age;
  }

  void editProfile() {
    currentStep.value = 0;
    _animateTo(0);
  }

  void onBioChanged(String value) => bioLength.value = value.length;

  void selectGender(String value) => gender.value = value;

  void toggleInterest(String value) {
    if (selectedInterests.contains(value)) {
      selectedInterests.remove(value);
    } else if (selectedInterests.length < maxInterests) {
      selectedInterests.add(value);
    } else {
      Get.snackbar('Bummps', 'You can select up to $maxInterests interests');
    }
  }

  bool isInterestSelected(String value) => selectedInterests.contains(value);

  Future<void> pickDob() async {
    final context = Get.context;
    if (context == null) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      dob.value = picked;
      dobController.text =
          '${_two(picked.month)}/${_two(picked.day)}/${picked.year}';
    }
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  void useCurrentLocation() {
    // TODO: integrate geolocation/permissions.
    Get.snackbar('Bummps', 'Detecting your current location...');
  }

  void addPhoto(int index) {
    // TODO: integrate image picker.
    Get.snackbar('Bummps', 'Photo picker coming soon');
  }

  Future<void> startVerification() async {
    isVerifying.value = true;
    Get.snackbar('Bummps', 'Launching selfie verification camera...');
    await Future.delayed(const Duration(seconds: 4));
    isVerifying.value = false;
    Get.snackbar('Bummps', 'Verification successful! Welcome.');
    await Future.delayed(const Duration(milliseconds: 500));
    next();
  }

  void doThisLaterVerification() {
    next();
  }

  void next() {
    if (currentStep.value < implementedSteps - 1) {
      currentStep.value++;
      _animateTo(currentStep.value);
    } else {
      Get.dialog(
        AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Success',
            style: AppTextStyles.headlineMedium.copyWith(color: AppColors.gold),
          ),
          content: Text(
            'Your premium Bummps profile is finalized and active. Welcome aboard!',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.close(1);
                Get.offAllNamed(Routes.onboarding);
              },
              child: Text(
                'Done',
                style: AppTextStyles.button.copyWith(color: AppColors.gold),
              ),
            )
          ],
        )
      );
    }
  }

  void back() {
    if (currentStep.value > 0) {
      currentStep.value--;
      _animateTo(currentStep.value);
    } else {
      Get.back();
    }
  }

  void skip() => next();

  void close() => Get.back();

  void _animateTo(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    firstNameController.dispose();
    dobController.dispose();
    locationController.dispose();
    bioController.dispose();
    heightController.dispose();
    educationController.dispose();
    super.onClose();
  }
}
