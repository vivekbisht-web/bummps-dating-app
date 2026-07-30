import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/home_controller.dart';
import 'tabs/discover_tab.dart';
import 'tabs/matches_tab.dart';
import 'tabs/messages_tab.dart';
import 'tabs/profile_tab.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        switch (controller.activeTab.value) {
          case 0:
            return const DiscoverTab();
          case 1:
            return const MatchesTab();
          case 2:
            return const MessagesTab();
          case 3:
            return const ProfileTab();
          default:
            return const DiscoverTab();
        }
      }),
      bottomNavigationBar: _PremiumBottomNavBar(controller: controller),
    );
  }
}

class _PremiumBottomNavBar extends StatelessWidget {
  final HomeController controller;
  const _PremiumBottomNavBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(
              index: 0,
              icon: Icons.explore_outlined,
              selectedIcon: Icons.explore,
              label: 'Discover',
              controller: controller,
            ),
            _NavBarItem(
              index: 1,
              icon: Icons.favorite_border,
              selectedIcon: Icons.favorite,
              label: 'Matches',
              controller: controller,
            ),
            _NavBarItem(
              index: 2,
              icon: Icons.forum_outlined,
              selectedIcon: Icons.forum,
              label: 'Messages',
              controller: controller,
            ),
            _NavBarItem(
              index: 3,
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: 'Profile',
              controller: controller,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final HomeController controller;

  const _NavBarItem({
    required this.index,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isSelected = controller.activeTab.value == index;

      return GestureDetector(
        onTap: () => controller.activeTab.value = index,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? Border.all(color: AppColors.gold.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? AppColors.gold : AppColors.textSecondary,
                size: 22,
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ]
            ],
          ),
        ),
      );
    });
  }
}
