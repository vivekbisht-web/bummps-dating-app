import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bummps_logo.dart';
import '../../../../routes/app_pages.dart';
import '../../controllers/home_controller.dart';
import '../../../profile_setup/controllers/profile_setup_controller.dart';

class ProfileTab extends GetView<HomeController> {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const BummpsLogo(compact: true),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Main User Card ---
              Obx(() {
                final profile = controller.currentUserProfile.value;

                String name = 'Julianne Carter';
                int age = 28;
                String location = 'San Francisco';
                String job = 'Visual Designer';
                String? photoPath;

                if (profile != null) {
                  name = profile.name;
                  age = profile.age;
                  if (profile.livingIn.isNotEmpty) {
                    location = profile.livingIn;
                  }
                  if (profile.jobTitle.isNotEmpty) {
                    job = profile.jobTitle;
                  }
                  if (profile.profilePic.isNotEmpty) {
                    photoPath = profile.profilePic;
                  }
                } else if (Get.isRegistered<ProfileSetupController>()) {
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

                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.gold.withOpacity(0.35), width: 1.0),
                  ),
                  child: Column(
                    children: [
                      // Avatar stack
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.gold, width: 2.0),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: _buildProfilePhoto(photoPath),
                            ),
                          ),
                          // Floating edit pencil badge
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: controller.editProfile,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: AppColors.gold,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Name, Age
                      Text(
                        '$name, $age',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Job in Location
                      Text(
                        '$job in $location',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // EDIT PROFILE button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.onGold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: controller.editProfile,
                        child: Text(
                          'EDIT PROFILE',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),

              // --- Grouped Settings Menu ---
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    _buildSettingsRow(
                      icon: Icons.person_outline,
                      title: 'Account',
                      onTap: () {},
                      showDivider: true,
                    ),
                    _buildSettingsRow(
                      icon: Icons.notifications_none_outlined,
                      title: 'Notifications',
                      onTap: () {},
                      showDivider: true,
                    ),
                    _buildSettingsRow(
                      icon: Icons.favorite_border,
                      title: 'Liked History',
                      onTap: () => Get.toNamed(Routes.likedHistory),
                      showDivider: true,
                    ),
                    _buildSettingsRow(
                      icon: Icons.lock_outline,
                      title: 'Privacy',
                      onTap: () {},
                      showDivider: true,
                    ),
                    _buildSettingsRow(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () => Get.toNamed(Routes.helpSupport),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- BUMMPS Gold Upgrade Card ---
              Obx(() {
                final sub = controller.currentSubscription.value;
                final bool hasSub = sub != null && sub.isActive;
                final bool isTrial = sub != null && sub.isTrial;
                
                String title = 'BUMMPS Gold';
                String desc = 'See who liked you & more';
                String actionText = 'UPGRADE';
                IconData badgeIcon = Icons.workspace_premium;
                
                if (hasSub) {
                  actionText = 'MANAGE';
                  if (isTrial) {
                    title = 'Free Trial Active';
                    desc = 'Unlimited likes & superboost active';
                    badgeIcon = Icons.card_giftcard;
                  } else {
                    title = 'BUMMPS ${sub.planName ?? 'Premium'} Active';
                    desc = 'Active subscription premium features';
                    badgeIcon = Icons.verified;
                  }
                }
                
                return GestureDetector(
                  onTap: () => Get.toNamed(Routes.plans),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2A2211),
                          Color(0xFF16130C),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1.0),
                    ),
                    child: Row(
                      children: [
                        // Gold badge icon in a rounded square
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                          ),
                          child: Icon(
                            badgeIcon,
                            color: AppColors.gold,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Title & Description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.gold,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                desc,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // UPGRADE action
                        TextButton(
                          onPressed: () => Get.toNamed(Routes.plans),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            actionText,
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // --- Logout Button ---
              OutlinedButton(
                onPressed: controller.logout,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.gold, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: AppColors.gold, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.gold,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Version String ---
              Center(
                child: Text(
                  'SoulSync v2.4.1 (Build 890)',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Icon(icon, color: AppColors.gold, size: 22),
          title: Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          onTap: onTap,
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: AppColors.divider, height: 1),
          ),
      ],
    );
  }

  Widget _buildProfilePhoto(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) {
      // Default fallback female portrait (Julianne Carter)
      return Image.network(
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
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
        errorBuilder: (context, error, stackTrace) => Image.network(
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
          fit: BoxFit.cover,
        ),
      );
    } else if (photoPath.startsWith('/') || photoPath.contains('/')) {
      // Relative server image path
      final fullUrl = photoPath.startsWith('/')
          ? 'https://datingapp-oz22.onrender.com$photoPath'
          : 'https://datingapp-oz22.onrender.com/$photoPath';
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.network(
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Image.file(
        File(photoPath),
        fit: BoxFit.cover,
      );
    }
  }
}
