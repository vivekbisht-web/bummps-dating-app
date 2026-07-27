import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Drives the multi-step profile setup wizard: tracks the active step,
/// holds all form data, and handles inter-step navigation.
class ProfileSetupController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentStep = 0.obs;

  /// Steps designed in Figma. The progress label still references "of 5".
  static const int totalSteps = 5;
  static const int implementedSteps = 3;
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
  final RxList<String?> photos = List<String?>.filled(5, null).obs;

  double get progress => (currentStep.value + 1) / totalSteps;
  int get percent => (progress * 100).round();

  bool get isLastImplementedStep =>
      currentStep.value == implementedSteps - 1;

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

  void next() {
    if (currentStep.value < implementedSteps - 1) {
      currentStep.value++;
      _animateTo(currentStep.value);
    } else {
      // TODO: navigate to the next steps (4-5) once designed / to home.
      Get.snackbar('Bummps', 'Profile basics saved. More steps coming soon.');
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
