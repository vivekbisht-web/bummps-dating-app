import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../controllers/home_controller.dart';
import '../../../profile_setup/controllers/profile_setup_controller.dart';

class ProfileTab extends GetView<HomeController> {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Safely retrieve setup info if registered
    String name = 'Alexander';
    int age = 29;
    String location = 'New Delhi, India';
    String job = 'Software Architect';
    String? photoPath;

    if (Get.isRegistered<ProfileSetupController>()) {
      final setupCtrl = Get.find<ProfileSetupController>();
      if (setupCtrl.firstNameController.text.trim().isNotEmpty) {
        name = setupCtrl.firstNameController.text.trim();
      }
      age = setupCtrl.age;
      if (setupCtrl.locationController.text.trim().isNotEmpty) {
        location = setupCtrl.locationController.text.trim();
      }
      if (setupCtrl.jobTitleController.text.trim().isNotEmpty) {
        job = setupCtrl.jobTitleController.text.trim();
      }
      if (setupCtrl.photos[0] != null) {
        photoPath = setupCtrl.photos[0];
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Image.asset(
          'assets/images/bummps..png',
          height: 18,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textPrimary),
            onPressed: () {
              Get.snackbar(
                'Settings',
                'Advanced settings menu coming soon.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.surface,
                colorText: AppColors.textPrimary,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Profile Avatar Stack ---
              Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    children: [
                      // Golden glowing border ring
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withOpacity(0.12),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(70),
                          child: _buildProfilePhoto(photoPath),
                        ),
                      ),
                      
                      // Edit badge
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: controller.editProfile,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.black,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Name, Age and Verified badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$name, $age',
                    style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.verified, color: AppColors.gold, size: 22),
                ],
              ),
              const SizedBox(height: 6),

              // Occupation and Location details
              Text(
                job,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // --- Premium Status Card ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E1C15),
                      Color(0xFF141310),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withOpacity(0.55), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.04),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.workspace_premium, color: AppColors.gold, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'BUMMPS GOLD',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.gold, width: 1),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Premium feature ecosystem is fully active. You have priority matching priority, infinite rewinds, and weekly profile spotlight boosts.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // --- Action Options List ---
              _ProfileOptionItem(
                icon: Icons.shield_outlined,
                title: 'Verification Status',
                subtitle: 'Verified Badge Active',
                trailing: const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                onTap: () {},
              ),
              _ProfileOptionItem(
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                subtitle: 'Push notifications configured',
                onTap: () {},
              ),
              _ProfileOptionItem(
                icon: Icons.lock_outline,
                title: 'Privacy & Security',
                subtitle: 'Manage encryption keys',
                onTap: () {},
              ),
              _ProfileOptionItem(
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'Securely clear auth token',
                titleColor: AppColors.error,
                onTap: controller.logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhoto(String? photoPath) {
    if (photoPath == null) {
      // Default fallback Network Avatar
      return Image.network(
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=80',
        fit: BoxFit.cover,
      );
    } else if (photoPath.startsWith('assets/')) {
      return Image.asset(
        photoPath,
        fit: BoxFit.cover,
      );
    } else if (photoPath.startsWith('http')) {
      return Image.network(
        photoPath,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        File(photoPath),
        fit: BoxFit.cover,
      );
    }
  }
}

class _ProfileOptionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const _ProfileOptionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: titleColor ?? AppColors.gold, size: 20),
        ),
        title: Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontSize: 15,
            color: titleColor ?? AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(fontSize: 12),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
