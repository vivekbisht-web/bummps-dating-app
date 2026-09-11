import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bummps_logo.dart';
import '../../controllers/home_controller.dart';

class MessagesTab extends GetView<HomeController> {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const BummpsLogo(compact: true),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshMatchesAndChats,
          color: AppColors.gold,
          backgroundColor: AppColors.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conversations',
                      style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Connections vibrating in conversation.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    onChanged: controller.searchChats,
                    decoration: const InputDecoration(
                      hintText: 'Search connections...',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Active Chats List
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingChats.value && controller.chatThreads.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.gold,
                      ),
                    );
                  }

                  final list = controller.filteredChatThreads;

                  if (list.isEmpty) {
                    final isSearching = controller.chatSearchQuery.value.trim().isNotEmpty;
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isSearching ? Icons.search_off_rounded : Icons.forum_outlined,
                                color: AppColors.textMuted,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isSearching ? 'No results found' : 'No active chats yet.',
                                style: AppTextStyles.titleMedium.copyWith(color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isSearching
                                    ? 'No conversations found matching "${controller.chatSearchQuery.value}"'
                                    : 'Swipe right on profiles or wait for matches to initiate a resonance.',
                                style: AppTextStyles.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const Divider(color: AppColors.divider, height: 1),
                    itemBuilder: (context, index) {
                      final chat = list[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(chat.imageUrl),
                              radius: 28,
                            ),
                            Obx(() {
                              if (chat.isOnline.value) {
                                return Positioned(
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
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                          ],
                        ),
                        title: Text(
                          chat.name,
                          style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Obx(
                            () => Text(
                              chat.lastMessage.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: chat.isUnread.value ? Colors.white : AppColors.textMuted,
                                fontWeight: chat.isUnread.value ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Obx(
                              () => Text(
                                chat.time.value,
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 11,
                                  color: chat.isUnread.value ? AppColors.gold : AppColors.textMuted,
                                  fontWeight: chat.isUnread.value ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Obx(() {
                              if (chat.isUnread.value) {
                                return Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.gold,
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }
                              return const SizedBox(width: 8, height: 8);
                            }),
                          ],
                        ),
                        onTap: () {
                          chat.isUnread.value = false;
                          controller.openChatDetail(chat);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
