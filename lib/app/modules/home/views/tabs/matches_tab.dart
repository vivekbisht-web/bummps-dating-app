import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../controllers/home_controller.dart';

class MatchesTab extends GetView<HomeController> {
  const MatchesTab({super.key});

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Soul Resonance',
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Profiles that share alignment with your signature energy.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 28),

              // --- New Matches Section ---
              Text(
                'NEW MATCHES',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: Obx(() {
                  if (controller.matches.isEmpty) {
                    return Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.divider, width: 1.5),
                            ),
                            child: const Icon(Icons.favorite_border, color: AppColors.textMuted, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Matches will appear here as you discover matching frequencies.',
                              style: AppTextStyles.caption.copyWith(fontSize: 12),
                            ),
                          )
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.matches.length,
                    itemBuilder: (context, index) {
                      final match = controller.matches[index];
                      return GestureDetector(
                        onTap: () {
                          // Find corresponding chat thread and open it
                          final chatName = '${match.name}, ${match.age}';
                          final chat = controller.chatThreads.firstWhere(
                            (element) => element.name == chatName,
                            orElse: () => controller.chatThreads.first,
                          );
                          controller.openChatDetail(chat);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 18),
                          child: Column(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.gold, width: 2),
                                  image: DecorationImage(
                                    image: NetworkImage(match.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                match.name,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 36),

              // --- Likes You Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LIKES YOU',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppColors.gold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '2 SOULS',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.onGold,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Locked Premium Likes Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemCount: 2,
                itemBuilder: (context, index) {
                  final likedUser = index == 0
                      ? ProfileCardData(
                          name: 'Charlotte',
                          age: 28,
                          job: 'Fashion Designer',
                          distance: '1 mile away',
                          bio: '',
                          id: '',
                          matchScore: '97',
                          imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400&auto=format&fit=crop&q=80',
                        )
                      : ProfileCardData(
                          name: 'Aria',
                          age: 30,
                          job: 'Neurologist',
                          distance: '6 miles away',
                          bio: '',
                          id: '',
                          matchScore: '94',
                          imageUrl: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=400&auto=format&fit=crop&q=80',
                        );

                  return _LockedLikesGridItem(user: likedUser);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedLikesGridItem extends StatelessWidget {
  final ProfileCardData user;
  const _LockedLikesGridItem({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred background image
          Image.network(
            user.imageUrl,
            fit: BoxFit.cover,
          ),
          
          // Blur effect overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),

          // Lock badge and content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1.5),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: AppColors.gold,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${user.matchScore}% Match',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${user.name.replaceAll(RegExp(r'.'), '*')} • ${user.age}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Click overlay trigger
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _showUpgradeSheet();
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showUpgradeSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium, color: AppColors.gold, size: 28),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bummps Gold Premium',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock who liked you, unlimited rewinds, 5 Super Likes daily, and monthly profile boosts.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '12 Months Access',
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        '\$9.99 / month (Save 50%)',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  Text(
                    '\$119.99',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.gold, fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Purchase Success',
                  'Welcome to Bummps Gold ecosystem.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.gold,
                  colorText: AppColors.onGold,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.onGold,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'UPGRADE TO GOLD',
                style: AppTextStyles.button,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'MAYBE LATER',
                style: AppTextStyles.button.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
