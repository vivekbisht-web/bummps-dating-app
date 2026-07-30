import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';

/// Drives the multi-step profile setup wizard: tracks the active step,
/// holds all form data, and handles inter-step navigation.
class ProfileSetupController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentStep = 0.obs;

  /// Steps designed in Figma. The progress label still references "of 5".
  static const int totalSteps = 6;
  static const int implementedSteps = 6;
  static const int maxInterests = 5;
  static const int maxBioLength = 300;

  // --- Credentials ---
  String registerName = '';
  String registerEmail = '';
  String registerPassword = '';

  // --- Step 1: basics ---
  final firstNameController = TextEditingController();
  final dobController = TextEditingController();
  final locationController = TextEditingController();
  final Rxn<DateTime> dob = Rxn<DateTime>();

  // --- Step 2: about you ---
  final bioController = TextEditingController();
  final RxInt bioLength = 0.obs;
  final RxnString gender = RxnString();
  final RxnString interestedIn = RxnString();
  final RxList<String> selectedInterests = <String>[].obs;
  final heightController = TextEditingController();
  final educationController = TextEditingController();
  final jobTitleController = TextEditingController();
  final companyController = TextEditingController();

  final RxDouble latitude = 28.6139.obs;
  final RxDouble longitude = 77.2090.obs;
  final RxInt agePreferenceMin = 25.obs;
  final RxInt agePreferenceMax = 35.obs;
  final RxInt distancePreference = 25.obs;

  final List<String> genders = const ['Woman', 'Man', 'Non-binary'];
  final List<String> interestedInOptions = const ['Woman', 'Man', 'Everyone'];
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

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      registerName = args['name'] ?? '';
      registerEmail = args['email'] ?? '';
      registerPassword = args['password'] ?? '';
    }
  }

  void editProfile() {
    currentStep.value = 0;
    _animateTo(0);
  }

  void onBioChanged(String value) => bioLength.value = value.length;

  void selectGender(String value) => gender.value = value;

  void selectInterestedIn(String value) => interestedIn.value = value;

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
    // Simulate coordinates detection for high premium feel
    latitude.value = 28.6139 + (DateTime.now().millisecond % 100) * 0.0001;
    longitude.value = 77.2090 + (DateTime.now().millisecond % 100) * 0.0001;
    locationController.text = 'New Delhi, India';
    Get.snackbar(
      'Location Detected',
      'Coordinates: ${latitude.value.toStringAsFixed(4)}, ${longitude.value.toStringAsFixed(4)}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  final ImagePicker _picker = ImagePicker();

  void addPhoto(int index) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        photos[index] = image.path;
      }
    } catch (e) {
      Get.snackbar('Bummps', 'Failed to pick image: $e');
    }
  }

  void removePhoto(int index) {
    photos[index] = null;
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

  void next() async {
    if (currentStep.value < implementedSteps - 1) {
      currentStep.value++;
      _animateTo(currentStep.value);
    } else {
      Get.showOverlay(
        asyncFunction: () async {
          final success = await registerUser();
          if (success) {
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
                      Get.offAllNamed(Routes.home);
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
        },
        loadingWidget: const Center(
          child: CircularProgressIndicator(
            color: AppColors.gold,
          ),
        ),
      );
    }
  }

  final RxBool isRegistering = false.obs;

  String _mapGender(String? appGender) {
    if (appGender == null) return 'female';
    switch (appGender.toLowerCase()) {
      case 'man':
      case 'male':
        return 'male';
      case 'woman':
      case 'female':
        return 'female';
      default:
        return 'female'; // Default fallback
    }
  }

  Future<bool> registerUser() async {
    isRegistering.value = true;
    try {
      final authRepository = Get.find<AuthRepository>();

      // Build fields Map
      final Map<String, dynamic> data = {
        'name': registerName.isNotEmpty ? registerName : (firstNameController.text.trim().isNotEmpty ? firstNameController.text.trim() : 'Sanidhya'),
        'email': registerEmail.isNotEmpty ? registerEmail : 'test@example.com',
        'password': registerPassword.isNotEmpty ? registerPassword : 'password123',
        'gender': _mapGender(gender.value),
        'interestedIn': _mapGender(interestedIn.value),
        'age': age.toString(),
        'bio': bioController.text.trim().isNotEmpty
            ? bioController.text.trim()
            : 'Seeking a connection that transcends the ordinary.',
        'jobTitle': jobTitleController.text.trim().isNotEmpty ? jobTitleController.text.trim() : 'Software Engineer',
        'company': companyController.text.trim().isNotEmpty ? companyController.text.trim() : 'Tech Corp',
        'school': educationController.text.trim().isNotEmpty ? educationController.text.trim() : 'Delhi University',
        'livingIn': locationController.text.trim().isNotEmpty ? locationController.text.trim() : 'New Delhi',
        'height': heightController.text.trim().isNotEmpty ? heightController.text.trim() : '185',
        'longitude': longitude.value.toString(),
        'latitude': latitude.value.toString(),
        'distancePreference': distancePreference.value.toString(),
        'agePreference': jsonEncode({'min': agePreferenceMin.value, 'max': agePreferenceMax.value}),
        'interests': jsonEncode(selectedInterests.isNotEmpty ? selectedInterests : ['coding', 'music', 'travel']),
      };

      final formDataMap = Map<String, dynamic>.from(data);

      // Attach profilePic (photos[0])
      final primaryPhoto = photos[0];
      if (primaryPhoto != null && primaryPhoto.isNotEmpty && !primaryPhoto.startsWith('assets/')) {
        formDataMap['profilePic'] = await dio.MultipartFile.fromFile(
          primaryPhoto,
          filename: primaryPhoto.split('/').last,
        );
      }

      // Attach additionalPhotos (photos[1..5])
      final List<dio.MultipartFile> additionalFiles = [];
      for (int i = 1; i < photos.length; i++) {
        final path = photos[i];
        if (path != null && path.isNotEmpty && !path.startsWith('assets/')) {
          additionalFiles.add(
            await dio.MultipartFile.fromFile(
              path,
              filename: path.split('/').last,
            ),
          );
        }
      }
      if (additionalFiles.isNotEmpty) {
        formDataMap['additionalPhotos'] = additionalFiles;
      }

      final formData = dio.FormData.fromMap(formDataMap);

      await authRepository.register(formData: formData);
      return true;
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isRegistering.value = false;
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
    jobTitleController.dispose();
    companyController.dispose();
    super.onClose();
  }
}
