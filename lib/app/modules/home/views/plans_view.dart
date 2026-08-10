import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class PlansView extends StatefulWidget {
  const PlansView({super.key});

  @override
  State<PlansView> createState() => _PlansViewState();
}

class _PlansViewState extends State<PlansView> {
  bool isMonthly = true;

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
        title: Image.asset(
          'assets/images/bummps..png',
          height: 18,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header Section ---
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Elevate Your Journey',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.gold,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Unlock the full potential of meaningful connections with our elite membership tiers.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Custom Segmented Toggle Control ---
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF141416),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.divider),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    // Monthly option
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isMonthly = true;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isMonthly ? AppColors.gold : Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Center(
                            child: Text(
                              'MONTHLY',
                              style: TextStyle(
                                color: isMonthly ? AppColors.onGold : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Annual option
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isMonthly = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: !isMonthly ? AppColors.gold : Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ANNUAL',
                                style: TextStyle(
                                  color: !isMonthly ? AppColors.onGold : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isMonthly ? const Color(0xFF2C2414) : const Color(0xFF1A1400),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.gold, width: 0.5),
                                ),
                                child: Text(
                                  'SAVE 40%',
                                  style: TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Subscription Tier Card ---
              Obx(() {
                final controller = Get.find<HomeController>();
                if (controller.isLoadingPlans.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: AppColors.gold),
                    ),
                  );
                }

                if (controller.subscriptionPlans.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'No plans available at the moment.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }

                return Column(
                  children: controller.subscriptionPlans.map((plan) {
                    final bool isCurrentPlan = controller.currentSubscription.value?.planId == plan.id &&
                        controller.currentSubscription.value?.isActive == true;
                    final double price = isMonthly ? plan.monthlyPrice : plan.annualPrice;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isCurrentPlan 
                              ? AppColors.gold 
                              : (plan.isPopular ? AppColors.gold.withOpacity(0.5) : AppColors.divider), 
                          width: isCurrentPlan ? 2.0 : 1.2
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                plan.subtitle.toUpperCase(),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              if (plan.isPopular)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C2414),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.gold, width: 0.8),
                                  ),
                                  child: const Text(
                                    'POPULAR',
                                    style: TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                plan.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isCurrentPlan)
                                const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '\$${price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '/mo',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (!isMonthly) ...[
                            const SizedBox(height: 4),
                            Text(
                              '\$${(price * 12).toStringAsFixed(2)} billed annually',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),

                          // Dynamic Features bullet points
                          ...plan.features.map((feature) => _buildFeaturePoint(
                                feature.text,
                                isIncluded: feature.included,
                              )),

                          const SizedBox(height: 24),

                          // Subscribe CTA
                          Obx(() {
                            final isSubmitting = controller.isSubmittingSubscription.value;
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCurrentPlan ? Colors.grey[900] : AppColors.gold,
                                foregroundColor: isCurrentPlan ? Colors.white60 : AppColors.onGold,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size.fromHeight(48),
                              ),
                              onPressed: (isCurrentPlan || isSubmitting) 
                                  ? null 
                                  : () async {
                                      await controller.purchaseSubscription(
                                        plan.id,
                                        isMonthly ? 'monthly' : 'annual',
                                      );
                                    },
                              child: isSubmitting 
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.onGold,
                                      ),
                                    )
                                  : Text(
                                      isCurrentPlan ? 'YOUR CURRENT PLAN' : 'SUBSCRIBE NOW',
                                      style: AppTextStyles.button.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                            );
                          }),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 32),

              // --- The Bummps Advantage Section ---
              const Center(
                child: Text(
                  'The Bummps Advantage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _buildAdvantageCard(
                icon: Icons.flash_on,
                title: 'Profile Boosts',
                description: 'Get up to 10x more visibility by jumping to the front of the queue during peak activity hours.',
              ),
              _buildAdvantageCard(
                icon: Icons.favorite,
                title: 'See Who Liked You',
                description: 'No more guessing. View everyone who has already shown interest in your profile.',
              ),
              _buildAdvantageCard(
                icon: Icons.public,
                title: 'Travel Mode',
                description: 'Change your location to any city globally and match before you land.',
              ),

              // Concierge Support Showcase Card
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    Text(
                      'Concierge Support',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.gold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Exclusively for Platinum members: A dedicated lifestyle assistant to help you curate your profile and prepare for the perfect first encounter.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 2.0),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(70),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&auto=format&fit=crop&q=80',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // --- Footer Links ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFooterLink('RESTORE PURCHASE'),
                  _buildFooterSpacer(),
                  _buildFooterLink(
                    'BILLING SUPPORT',
                    onTap: () => Get.toNamed(
                      Routes.helpSupport,
                      arguments: {
                        'subject': 'Payment Issue',
                        'category': 'Billing',
                        'message': 'I was charged for Gold subscription but it is not active.',
                      },
                    ),
                  ),
                  _buildFooterSpacer(),
                  _buildFooterLink('PRIVACY POLICY'),
                ],
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Subscription will automatically renew at the end of the selected period. You can cancel at any time in your account settings.\n© 2026 SoulSync International. All rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePoint(String text, {bool isIncluded = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            isIncluded ? Icons.check_circle : Icons.cancel,
            color: isIncluded ? AppColors.gold : Colors.white24,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isIncluded ? Colors.white : Colors.white38,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              decoration: isIncluded ? null : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvantageCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF1E1C18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.gold,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFooterSpacer() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        '|',
        style: TextStyle(color: AppColors.divider, fontSize: 9),
      ),
    );
  }
}
