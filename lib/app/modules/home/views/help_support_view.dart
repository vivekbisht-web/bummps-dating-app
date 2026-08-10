import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/help_support_controller.dart';

class HelpSupportView extends GetView<HelpSupportController> {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold, size: 22),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Help & Support',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Header Description ---
                Text(
                  'How can we help you?',
                  style: AppTextStyles.displayLarge.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Submit a support ticket regarding any billing issues, account questions, or feedback. Our concierge team will address it promptly.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 32),

                // --- Category field ---
                Text(
                  'CATEGORY',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => DropdownButtonFormField<String>(
                      initialValue: controller.selectedCategory.value,
                      dropdownColor: AppColors.surface,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                      decoration: InputDecoration(
                        hintText: 'Select category',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                        ),
                      ),
                      items: controller.categories.map((String cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectedCategory.value = val;
                        }
                      },
                    )),
                const SizedBox(height: 24),

                // --- Subject field ---
                Text(
                  'SUBJECT',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.subjectController,
                  validator: controller.validateSubject,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Subscription issue',
                  ),
                ),
                const SizedBox(height: 24),

                // --- Message field ---
                Text(
                  'YOUR MESSAGE',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.messageController,
                  validator: controller.validateMessage,
                  maxLines: 6,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Please describe the issue in detail...',
                  ),
                ),
                const SizedBox(height: 40),

                // --- Submit Button ---
                Obx(() {
                  final loading = controller.isLoading.value;
                  return Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: loading ? null : AppColors.goldGradient,
                      color: loading ? AppColors.surfaceElevated : null,
                      borderRadius: BorderRadius.circular(16),
                      border: loading ? Border.all(color: AppColors.divider) : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: loading ? null : controller.submitSupportTicket,
                        child: Center(
                          child: loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.gold,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'SUBMIT TICKET',
                                      style: AppTextStyles.button.copyWith(
                                        color: AppColors.onGold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.send_rounded, color: AppColors.onGold, size: 18),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
