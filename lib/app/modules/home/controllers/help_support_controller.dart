import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_snackbar.dart';
import '../../../data/repositories/auth_repository.dart';

class HelpSupportController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  final RxString selectedCategory = 'Billing'.obs;
  final RxBool isLoading = false.obs;

  final List<String> categories = [
    'Billing',
    'Account',
    'Technical',
    'Safety',
    'Feedback',
    'Other'
  ];

  @override
  void onInit() {
    super.onInit();
    _handleArguments();
  }

  /// Handle any navigation arguments passed to pre-fill the form (e.g. from payment issues)
  void _handleArguments() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      if (args.containsKey('category') && args['category'] is String) {
        final cat = args['category'] as String;
        // Make sure it matches one of the defined categories (case-sensitive check)
        final match = categories.firstWhere(
          (c) => c.toLowerCase() == cat.toLowerCase(),
          orElse: () => '',
        );
        if (match.isNotEmpty) {
          selectedCategory.value = match;
        }
      }
      if (args.containsKey('subject') && args['subject'] is String) {
        subjectController.text = args['subject'] as String;
      }
      if (args.containsKey('message') && args['message'] is String) {
        messageController.text = args['message'] as String;
      }
    }
  }

  /// Validation logic
  String? validateSubject(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a subject';
    }
    if (value.trim().length < 3) {
      return 'Subject must be at least 3 characters';
    }
    return null;
  }

  String? validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your message';
    }
    if (value.trim().length < 10) {
      return 'Message must be at least 10 characters';
    }
    return null;
  }

  /// Submits the ticket to the backend server
  Future<void> submitSupportTicket() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    try {
      final repository = Get.find<AuthRepository>();
      await repository.submitHelpSupport(
        subject: subjectController.text.trim(),
        category: selectedCategory.value,
        message: messageController.text.trim(),
      );

      // Return to previous screen
      Get.back();

      AppSnackbar.showSuccess(
        title: 'Ticket Submitted',
        message: 'Your ticket has been sent. Our team will get back to you shortly.',
      );

      // Clear inputs
      subjectController.clear();
      messageController.clear();
    } catch (e) {
      String errorMessage = 'Something went wrong. Please try again.';
      if (e is DioException) {
        final response = e.response;
        if (response != null && response.data != null) {
          if (response.data is Map<String, dynamic> &&
              response.data.containsKey('message')) {
            errorMessage = response.data['message'] as String;
          } else if (response.data is String) {
            errorMessage = response.data as String;
          }
        }
      }
      AppSnackbar.showError(
        title: 'Submission Failed',
        message: errorMessage,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
