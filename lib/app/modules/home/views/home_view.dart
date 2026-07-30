import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/home_controller.dart';
import 'tabs/discover_tab.dart';
import 'tabs/matches_tab.dart';
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
        color: Colors.black,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(
              index: 0,
              icon: Icons.style_outlined,
              selectedIcon: Icons.style,
              label: 'Discovery',
              controller: controller,
            ),
            _NavBarItem(
              index: 1,
              icon: Icons.forum_outlined,
              selectedIcon: Icons.forum,
              label: 'Matches',
              controller: controller,
            ),
            _NavBarItem(
              index: 2,
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
        child: SizedBox(
          width: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? AppColors.gold : AppColors.textMuted,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.gold : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 3),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 7), // Maintain alignment spacer
              ]
            ],
          ),
        ),
      );
    });
  }
}
