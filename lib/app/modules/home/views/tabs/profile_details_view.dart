import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../controllers/home_controller.dart';

class ProfileDetailsView extends StatelessWidget {
  final ProfileCardData profile;
  final HomeController controller;

  const ProfileDetailsView({
    super.key,
    required this.profile,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Profile Description - Midnight Gilded',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Profile Photo Frame ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 520,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.divider, width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      profile.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surface,
                        child: const Icon(Icons.person, size: 80, color: AppColors.textMuted),
                      ),
                    ),

                    // Scrim overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.9),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),

                    // Overlay details (Name, Age, Location)
                    Positioned(
                      left: 20,
                      bottom: 24,
                      right: 120, // Leave space for buttons on bottom right
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${profile.name}, ${profile.age}',
                            style: AppTextStyles.displayLarge.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  profile.location,
                                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Floating buttons on bottom-right of photo
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Row(
                        children: [
                          // Pass button
                          GestureDetector(
                            onTap: () {
                              Get.back();
                              controller.forceSwipe('nope');
                            },
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1.5),
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 24),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Like button
                          GestureDetector(
                            onTap: () {
                              Get.back();
                              controller.forceSwipe('like');
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.favorite, color: Colors.black, size: 28),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- The Essence Header ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'THE ESSENCE',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
                ],
              ),
            ),

            // Bio quote container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  '"${profile.bio}"',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Interests chips list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: profile.interests.map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getInterestIcon(interest), color: AppColors.gold, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          interest,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            // --- Key Details 2x2 Grid ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
                ),
                children: [
                  _buildGridCard(Icons.straighten, 'HEIGHT', profile.height),
                  _buildGridCard(Icons.school_outlined, 'EDUCATION', profile.education),
                  _buildGridCard(Icons.business_center_outlined, 'PROFESSION', profile.job),
                  _buildGridCard(Icons.language, 'LANGUAGES', profile.languages),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // --- Lifestyle Panel ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LIFESTYLE',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...profile.lifestyle.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: Row(
                          children: [
                            Icon(_getLifestyleIcon(item), color: AppColors.gold, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item,
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(Icons.check, color: Colors.black, size: 10),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),

            // --- Bottom MESSAGE Button ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.back();
                    // Open/simulate messaging with this profile
                    final chatName = '${profile.name}, ${profile.age}';
                    
                    // Create thread if not exist
                    final exists = controller.chatThreads.any((element) => element.name == chatName);
                    if (!exists) {
                      controller.chatThreads.insert(
                        0,
                        ChatThread(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: chatName,
                          imageUrl: profile.imageUrl,
                          initialMessage: 'Say hello to ${profile.name}!',
                          initialTime: 'Just Now',
                        ),
                      );
                    }

                    // Open Messages tab
                    controller.activeTab.value = 2;
                    // Auto-open chat details
                    final chat = controller.chatThreads.firstWhere((element) => element.name == chatName);
                    controller.openChatDetail(chat);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.forum, color: Colors.black, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'MESSAGE ${profile.name.toUpperCase()}',
                          style: AppTextStyles.button.copyWith(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getInterestIcon(String interest) {
    switch (interest.toLowerCase()) {
      case 'photography':
        return Icons.camera_alt_outlined;
      case 'travel':
        return Icons.flight_takeoff_outlined;
      case 'architecture':
        return Icons.apartment_outlined;
      case 'oenology':
        return Icons.local_bar_outlined;
      case 'classical':
      case 'classical music':
        return Icons.music_note_outlined;
      case 'yachting':
        return Icons.directions_boat_outlined;
      default:
        return Icons.star_border_outlined;
    }
  }

  IconData _getLifestyleIcon(String item) {
    final lower = item.toLowerCase();
    if (lower.contains('smoker')) {
      return Icons.smoking_rooms_outlined;
    } else if (lower.contains('drink') || lower.contains('wine')) {
      return Icons.local_drink_outlined;
    } else if (lower.contains('cat')) {
      return Icons.pets_outlined;
    } else if (lower.contains('dog')) {
      return Icons.pets_outlined;
    }
    return Icons.info_outline;
  }
}
