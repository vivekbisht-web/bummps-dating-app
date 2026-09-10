import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bummps_logo.dart';
import '../../../../routes/app_pages.dart';
import '../../controllers/home_controller.dart';

class MatchesTab extends GetView<HomeController> {
  const MatchesTab({super.key});

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
        child: RefreshIndicator(
          onRefresh: controller.refreshMatchesAndChats,
          color: AppColors.gold,
          backgroundColor: AppColors.card,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // --- New Matches Section Header ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Matches',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.likedHistory),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite, color: AppColors.gold, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Likes You',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // --- Matches & Likes Carousel ---
                SizedBox(
                  height: 110,
                  child: Obx(() {
                    if (controller.isLoadingMatches.value && controller.matches.isEmpty) {
                      return const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      // First item is always "Likes", followed by real matches
                      itemCount: 1 + controller.matches.length,
                      itemBuilder: (context, index) {
                        // Item 0: Who Liked Me shortcut
                        if (index == 0) {
                          return GestureDetector(
                            onTap: () => Get.toNamed(Routes.likedHistory),
                            child: Container(
                              margin: const EdgeInsets.only(right: 14),
                              child: Column(
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF382912),
                                          Color(0xFF1A140A),
                                        ],
                                      ),
                                      border: Border.all(color: AppColors.gold, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.gold.withOpacity(0.25),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.favorite_rounded,
                                            color: AppColors.gold,
                                            size: 26,
                                          ),
                                          const SizedBox(height: 2),
                                          Obx(() => Text(
                                            controller.likedProfilesList.isNotEmpty
                                                ? '${controller.likedProfilesList.length}+'
                                                : 'Likes',
                                            style: const TextStyle(
                                              color: AppColors.gold,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Likes',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Real matches
                        final match = controller.matches[index - 1];
                        return GestureDetector(
                          onTap: () {
                            final chat = controller.getOrCreateChatThread(match);
                            controller.openChatDetail(chat);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 14),
                            child: Column(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.gold.withOpacity(0.8), width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.gold.withOpacity(0.12),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: NetworkImage(match.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    match.name.split(' ').first,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // --- Messages Section Header ---
                Text(
                  'Messages',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),

                // --- Chat Threads List ---
                Obx(() {
                  if (controller.chatThreads.isEmpty) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: AppColors.gold,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Messages Yet',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Matches you connect with will appear here. Swipe on Discover to start matching!',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: () => controller.activeTab.value = 0,
                            icon: const Icon(Icons.explore_rounded, size: 18, color: Colors.black),
                            label: const Text(
                              'EXPLORE PROFILES',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.chatThreads.length,
                    itemBuilder: (context, index) {
                      final chat = controller.chatThreads[index];
                      final bool unread = chat.isUnread.value;
                      final bool online = chat.isOnline.value;

                      return GestureDetector(
                        onTap: () {
                          // Mark as read when clicking
                          chat.isUnread.value = false;
                          controller.openChatDetail(chat);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: unread ? AppColors.gold.withOpacity(0.4) : AppColors.divider,
                              width: unread ? 1.2 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Avatar section (with online indicator)
                              Stack(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(chat.imageUrl),
                                    radius: 28,
                                  ),
                                  if (online)
                                    Positioned(
                                      bottom: 0,
                                      right: 2,
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.card, width: 2),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),

                              // Details text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          chat.name.split(',').first,
                                          style: AppTextStyles.titleMedium.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          chat.time.value,
                                          style: AppTextStyles.caption.copyWith(
                                            color: unread ? AppColors.gold : AppColors.textMuted,
                                            fontSize: 12,
                                            fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            chat.lastMessage.value,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              color: unread ? Colors.white : AppColors.textMuted,
                                              fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                                              fontSize: 13.5,
                                            ),
                                          ),
                                        ),
                                        if (unread)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            margin: const EdgeInsets.only(left: 8),
                                            decoration: const BoxDecoration(
                                              color: AppColors.gold,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
