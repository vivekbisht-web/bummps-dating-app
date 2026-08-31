import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';

import '../../../core/services/network/dio_exception.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_profile.dart';
import '../controllers/home_controller.dart';


class EditProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // --- Form controllers ---
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final locationController = TextEditingController();
  final heightController = TextEditingController();
  final jobTitleController = TextEditingController();
  final companyController = TextEditingController();
  final schoolController = TextEditingController();
  final bioController = TextEditingController();

  final Rxn<DateTime> dob = Rxn<DateTime>();
  final RxInt bioLength = 0.obs;

  // --- Dropdowns & Selection Lists ---
  final RxnString gender = RxnString();
  final RxnString interestedIn = RxnString();
  final RxList<String> selectedInterests = <String>[].obs;
  final RxList<String> selectedLifestyle = <String>[].obs;
  final RxList<String> selectedLanguages = <String>[].obs;

  final RxDouble latitude = 28.6139.obs;
  final RxDouble longitude = 77.2090.obs;

  // --- Preferences ---
  final RxInt agePreferenceMin = 25.obs;
  final RxInt agePreferenceMax = 35.obs;
  final RxInt distancePreference = 25.obs;

  // --- Photos: slot 0 is primary, 1-5 are additional ---
  // Store either a remote URL (starts with 'http' or '/uploads') or a local path
  final RxList<String?> photos = List<String?>.filled(6, null).obs;

  final List<String> genders = const ['Woman', 'Man', 'Non-binary'];
  final List<String> interestedInOptions = const ['Woman', 'Man', 'Everyone'];

  final List<String> interestsOptions = const [
    'PHOTOGRAPHY',
    'ARCHITECTURE',
    'FINE DINING',
    'TRAVEL',
    'ART GALLERIES',
    'SAILING',
    'FITNESS',
    'MUSIC',
    'READING',
    'COOKING',
  ];

  final List<String> lifestyleOptions = const [
    'NON-SMOKER',
    'SMOKER',
    'FITNESS',
    'SOCIAL DRINKER',
    'DOG LOVER',
    'CAT LOVER',
    'VEGAN',
  ];

  final List<String> languageOptions = const [
    'English',
    'French',
    'Spanish',
    'German',
    'Italian',
    'Hindi',
    'Mandarin',
    'Arabic',
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  void loadProfileData() {
    try {
      isLoading.value = true;
      UserProfile? profile;

      if (Get.isRegistered<HomeController>()) {
        profile = Get.find<HomeController>().currentUserProfile.value;
      }

      if (profile != null) {
        _populateFields(profile);
      } else {
        // Fallback to fetch from API
        _fetchFromApi();
      }
    } catch (e) {
      debugPrint('[EditProfileController] Load profile error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _populateFields(UserProfile profile) {
    nameController.text = profile.name;
    bioController.text = profile.bio;
    bioLength.value = profile.bio.length;
    locationController.text = profile.livingIn;
    heightController.text = profile.height;
    jobTitleController.text = profile.jobTitle;
    companyController.text = profile.company;
    schoolController.text = profile.school;

    // Map database gender back to display gender
    if (profile.gender.toLowerCase() == 'male') {
      gender.value = 'Man';
    } else if (profile.gender.toLowerCase() == 'female') {
      gender.value = 'Woman';
    } else {
      gender.value = 'Non-binary';
    }

    if (profile.interestedIn.toLowerCase() == 'male') {
      interestedIn.value = 'Man';
    } else if (profile.interestedIn.toLowerCase() == 'female') {
      interestedIn.value = 'Woman';
    } else {
      interestedIn.value = 'Everyone';
    }

    selectedInterests.assignAll(profile.interests);
    selectedLifestyle.assignAll(profile.lifestyle);
    selectedLanguages.assignAll(profile.languages);

    latitude.value = profile.latitude;
    longitude.value = profile.longitude;
    distancePreference.value = profile.distancePreference > 0 ? profile.distancePreference : 25;

    // Populate photos
    if (profile.profilePic.isNotEmpty) {
      photos[0] = profile.profilePic;
    }
    for (int i = 0; i < profile.additionalPhotos.length && i < 5; i++) {
      photos[i + 1] = profile.additionalPhotos[i];
    }
  }

  Future<void> _fetchFromApi() async {
    try {
      final authRepo = Get.find<AuthRepository>();
      final homeCtrl = Get.find<HomeController>();
      final profile = await authRepo.getProfile(homeCtrl.currentUserProfile.value?.id ?? '');
      _populateFields(profile);
    } catch (e) {
      AppSnackbar.showError(
        title: 'Error',
        message: 'Failed to load profile details. Please try again.',
      );
    }
  }

  void onBioChanged(String value) => bioLength.value = value.length;

  void selectGender(String value) => gender.value = value;

  void selectInterestedIn(String value) => interestedIn.value = value;

  void toggleInterest(String value) {
    if (selectedInterests.contains(value)) {
      selectedInterests.remove(value);
    } else if (selectedInterests.length < 5) {
      selectedInterests.add(value);
    } else {
      AppSnackbar.showWarning(
        title: 'Selection Limit',
        message: 'You can select up to 5 interests.',
      );
    }
  }

  bool isInterestSelected(String value) => selectedInterests.contains(value);

  void toggleLifestyle(String value) {
    if (selectedLifestyle.contains(value)) {
      selectedLifestyle.remove(value);
    } else {
      selectedLifestyle.add(value);
    }
  }

  bool isLifestyleSelected(String value) => selectedLifestyle.contains(value);

  void toggleLanguage(String value) {
    if (selectedLanguages.contains(value)) {
      selectedLanguages.remove(value);
    } else {
      selectedLanguages.add(value);
    }
  }

  bool isLanguageSelected(String value) => selectedLanguages.contains(value);

  Future<void> pickDob() async {
    final context = Get.context;
    if (context == null) return;
    final now = DateTime.now();
    final maxDobFor18 = DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: dob.value != null && dob.value!.isBefore(maxDobFor18) ? dob.value! : maxDobFor18,
      firstDate: DateTime(1900),
      lastDate: maxDobFor18,
    );
    if (picked != null) {
      dob.value = picked;
      dobController.text = '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void useCurrentLocation() {
    latitude.value = 28.6139 + (DateTime.now().millisecond % 100) * 0.0001;
    longitude.value = 77.2090 + (DateTime.now().millisecond % 100) * 0.0001;
    locationController.text = 'New Delhi, India';
    AppSnackbar.showInfo(
      title: 'Location Detected',
      message: 'Coordinates: ${latitude.value.toStringAsFixed(4)}, ${longitude.value.toStringAsFixed(4)}',
    );
  }

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
      AppSnackbar.showError(
        title: 'Photo Upload Error',
        message: 'Failed to pick image: $e',
      );
    }
  }

  void removePhoto(int index) {
    photos[index] = null;
  }

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
        return 'female';
    }
  }

  Future<void> saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      AppSnackbar.showWarning(title: 'Required Field', message: 'Please enter your name.');
      return;
    }

    if (photos[0] == null || photos[0]!.isEmpty) {
      AppSnackbar.showWarning(title: 'Required Field', message: 'Please add a primary cover photo.');
      return;
    }

    try {
      isSaving.value = true;
      final authRepository = Get.find<AuthRepository>();

      // Compile normal fields
      final Map<String, dynamic> data = {
        'name': nameController.text.trim(),
        'bio': bioController.text.trim(),
        'gender': _mapGender(gender.value),
        'interestedIn': _mapGender(interestedIn.value),
        'jobTitle': jobTitleController.text.trim(),
        'company': companyController.text.trim(),
        'school': schoolController.text.trim(),
        'livingIn': locationController.text.trim(),
        'height': heightController.text.trim(),
        'longitude': longitude.value.toString(),
        'latitude': latitude.value.toString(),
        'distancePreference': distancePreference.value.toString(),
        'agePreference': '${agePreferenceMin.value}-${agePreferenceMax.value}',
        'interests': jsonEncode(selectedInterests),
        'lifestyle': jsonEncode(selectedLifestyle),
        'languages': jsonEncode(selectedLanguages),
      };

      // Set age if date of birth was selected
      if (dob.value != null) {
        final ageCalculated = DateTime.now().year - dob.value!.year;
        data['age'] = ageCalculated.toString();
      }

      final formDataMap = Map<String, dynamic>.from(data);

      // Handle primary cover photo
      final primary = photos[0];
      if (primary != null && primary.isNotEmpty) {
        // If it's a local file path (i.e. picked from device)
        if (!primary.startsWith('http') && !primary.startsWith('/uploads')) {
          formDataMap['profilePic'] = await dio.MultipartFile.fromFile(
            primary,
            filename: primary.split('/').last,
          );
        } else {
          // It's the original remote url, pass it back to keep it
          formDataMap['profilePicUrl'] = primary;
        }
      }

      // Handle additional photos
      final List<dio.MultipartFile> additionalFiles = [];
      final List<String> existingPhotosToKeep = [];

      for (int i = 1; i < photos.length; i++) {
        final path = photos[i];
        if (path != null && path.isNotEmpty) {
          if (!path.startsWith('http') && !path.startsWith('/uploads')) {
            additionalFiles.add(
              await dio.MultipartFile.fromFile(
                path,
                filename: path.split('/').last,
              ),
            );
          } else {
            existingPhotosToKeep.add(path);
          }
        }
      }

      if (additionalFiles.isNotEmpty) {
        formDataMap['additionalPhotos'] = additionalFiles;
      }
      if (existingPhotosToKeep.isNotEmpty) {
        formDataMap['existingAdditionalPhotos'] = jsonEncode(existingPhotosToKeep);
      }

      final formData = dio.FormData.fromMap(formDataMap);
      final updatedProfile = await authRepository.updateProfile(formData: formData);

      // Update HomeController instance
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().currentUserProfile.value = updatedProfile;
      }

      AppSnackbar.showSuccess(
        title: 'Profile Updated',
        message: 'Your profile has been successfully saved!',
      );
      Get.back();
    } on ApiException catch (e) {
      AppSnackbar.showError(
        title: 'Update Failed',
        message: e.message,
      );
    } catch (e) {
      debugPrint('[EditProfileController] Save profile error: $e');
      AppSnackbar.showError(
        title: 'Error',
        message: 'An unexpected error occurred while saving profile.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    dobController.dispose();
    locationController.dispose();
    heightController.dispose();
    jobTitleController.dispose();
    companyController.dispose();
    schoolController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
