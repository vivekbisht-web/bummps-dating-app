import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/bummps_logo.dart';
import '../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';
import '../../../data/models/subscription_plan.dart';

class PlansView extends StatefulWidget {
  const PlansView({super.key});

  @override
  State<PlansView> createState() => _PlansViewState();
}

class _PlansViewState extends State<PlansView> {
  bool isMonthly = true;
  String? selectedPlanId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<HomeController>();
      controller.fetchSubscriptionPlans();
      controller.fetchUserSubscription();
      controller.fetchWalletBalance();
    });
  }

  Future<void> _handleRefresh() async {
    final controller = Get.find<HomeController>();
    await Future.wait([
      controller.fetchSubscriptionPlans(),
      controller.fetchUserSubscription(),
      controller.fetchWalletBalance(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const BummpsLogo(compact: true),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: const [
          SizedBox(width: 48),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // --- Ambient Golden Spotlight Glow Behind Header & Top Cards ---
            Positioned(
              top: -40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFD4AF37).withOpacity(0.18),
                        const Color(0xFF9E7830).withOpacity(0.07),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // --- Main Content ---
            RefreshIndicator(
              color: AppColors.gold,
              backgroundColor: AppColors.surface,
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    // --- Crown Icon ---
                    Center(
                      child: CustomPaint(
                        size: const Size(44, 32),
                        painter: _CrownPainter(color: AppColors.gold),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // --- Header Section: "Choose Your Plan" ---
                    Center(
                      child: Text(
                        'Choose Your Plan',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.gold,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Pick the plan that fits how you date',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF9E9A90),
                            fontSize: 14,
                            letterSpacing: 0.2,
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
                                      child: const Text(
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

                    // --- Dynamic Subscription Tier Cards from API ---
                    Obx(() {
                      final controller = Get.find<HomeController>();
                      if (controller.isLoadingPlans.value && controller.subscriptionPlans.isEmpty) {
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

                      // Default selection to first plan if none selected yet
                      final currentSelectedId = selectedPlanId ??
                          (controller.currentSubscription.value?.hasActiveSubscription == true &&
                                  controller.currentSubscription.value?.planId != null
                              ? controller.currentSubscription.value!.planId
                              : (controller.subscriptionPlans.isNotEmpty
                                  ? controller.subscriptionPlans.first.id
                                  : null));

                      return Column(
                        children: controller.subscriptionPlans.map((plan) {
                          final bool isCurrentPlan = controller.currentSubscription.value?.planId == plan.id &&
                              controller.currentSubscription.value?.isActive == true;
                          final bool isSelected = currentSelectedId == plan.id;
                          final double price = isMonthly ? plan.monthlyPrice : plan.annualPrice;

                          return _buildPlanCard(
                            context: context,
                            controller: controller,
                            plan: plan,
                            price: price,
                            isCurrentPlan: isCurrentPlan,
                            isSelected: isSelected,
                          );
                        }).toList(),
                      );
                    }),
                    const SizedBox(height: 12),

                    // --- Wallet Balance Card ---
                    _buildWalletCard(),
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
                            'Exclusively for Pro & Premium members: A dedicated lifestyle assistant to help you curate your profile and prepare for the perfect first encounter.',
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
                              'message': 'I was charged for subscription but it is not active.',
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
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Plan Card Widget (With Luminous Golden Glow from Reference)
  // ---------------------------------------------------------------------------

  Widget _buildPlanCard({
    required BuildContext context,
    required HomeController controller,
    required SubscriptionPlan plan,
    required double price,
    required bool isCurrentPlan,
    required bool isSelected,
  }) {
    final bool isPopular = plan.isPopular == true;
    final bool isGlowing = isSelected || isCurrentPlan;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlanId = plan.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 22),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Card Body with Glowing Golden Shadow
            Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              decoration: BoxDecoration(
                color: const Color(0xFF131315),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isGlowing
                      ? const Color(0xFFE8B84B)
                      : (isPopular
                          ? const Color(0xFFE8B84B).withOpacity(0.45)
                          : const Color(0xFF262420)),
                  width: isGlowing ? 1.8 : 1.2,
                ),
                boxShadow: isGlowing
                    ? [
                        // Soft outer gold bloom
                        BoxShadow(
                          color: const Color(0xFFE8B84B).withOpacity(0.32),
                          blurRadius: 28,
                          spreadRadius: 1.5,
                          offset: const Offset(0, 3),
                        ),
                        // Inner tight gold halo
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.18),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan Name, Tagline & Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: Title & Tagline (from API)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            Builder(
                              builder: (context) {
                                String displaySubtitle = plan.subtitle.trim();
                                if (displaySubtitle.isEmpty) {
                                  final nameLower = plan.name.toLowerCase();
                                  if (nameLower.contains('bummps.') || nameLower.contains('basic') || nameLower.contains('silver')) {
                                    displaySubtitle = 'Get started';
                                  } else if (nameLower.contains('pro') || nameLower.contains('platinum')) {
                                    displaySubtitle = 'Go all in';
                                  }
                                }

                                if (displaySubtitle.isEmpty || displaySubtitle.toUpperCase().contains('POPULAR')) {
                                  return const SizedBox.shrink();
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(top: 3.0, right: 8.0),
                                  child: Text(
                                    displaySubtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF8E8A82),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Right: Price & /month (from API)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$${price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isMonthly ? '/month' : '/mo',
                            style: const TextStyle(
                              color: Color(0xFF8E8A82),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!isMonthly && plan.annualPrice > 0) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '\$${(price * 12).toStringAsFixed(2)} billed annually',
                        style: const TextStyle(
                          color: Color(0xFF8E8A82),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),

                  // Features List (from API)
                  if (plan.features.isNotEmpty)
                    ...plan.features.map<Widget>((feature) => _buildFeatureItem(
                          feature.text,
                          isIncluded: feature.included,
                        ))
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'All standard membership benefits',
                        style: TextStyle(color: Color(0xFFDDD8D0), fontSize: 14),
                      ),
                    ),

                  const SizedBox(height: 18),

                  // Subscribe CTA Button
                  Obx(() {
                    final isSubmitting = controller.isSubmittingSubscription.value;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCurrentPlan
                            ? const Color(0xFF1E1E22)
                            : AppColors.gold,
                        foregroundColor: isCurrentPlan
                            ? AppColors.gold
                            : AppColors.onGold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: isCurrentPlan
                              ? BorderSide(color: AppColors.gold.withOpacity(0.4), width: 1)
                              : BorderSide.none,
                        ),
                        minimumSize: const Size.fromHeight(46),
                        elevation: 0,
                      ),
                      onPressed: (isCurrentPlan || isSubmitting)
                          ? null
                          : () {
                              _showPaymentMethodSheet(
                                context,
                                controller,
                                plan.id,
                                isMonthly ? 'monthly' : 'annual',
                                price,
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
                              style: TextStyle(
                                color: isCurrentPlan ? AppColors.gold : AppColors.onGold,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                    );
                  }),
                ],
              ),
            ),

            // "MOST POPULAR" Pill Badge on Top Right
            if (isPopular)
              Positioned(
                top: -12,
                right: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8B84B),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      color: Color(0xFF141416),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Feature Checkmark Item
  // ---------------------------------------------------------------------------

  Widget _buildFeatureItem(String text, {bool isIncluded = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isIncluded ? const Color(0xFF282216) : const Color(0xFF1E1E22),
            ),
            child: Icon(
              isIncluded ? Icons.check : Icons.close,
              color: isIncluded ? const Color(0xFFD4AF37) : Colors.white24,
              size: 13,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isIncluded ? const Color(0xFFDDD8D0) : Colors.white38,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                decoration: isIncluded ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Wallet Balance Card
  // ---------------------------------------------------------------------------

  Widget _buildWalletCard() {
    final controller = Get.find<HomeController>();
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1C18), Color(0xFF2A2520)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1.2),
        ),
        child: Row(
          children: [
            // Wallet icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet, color: AppColors.gold, size: 24),
            ),
            const SizedBox(width: 16),
            // Balance info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WALLET BALANCE',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  controller.isLoadingWallet.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                        )
                      : Text(
                          '₹${controller.walletBalance.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ],
              ),
            ),
            // Add Money button
            Obx(() {
              final isAdding = controller.isAddingMoney.value;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isAdding ? null : () => _showAddMoneySheet(context, controller),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isAdding ? AppColors.gold.withOpacity(0.5) : AppColors.gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAdding)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onGold),
                          )
                        else
                          const Icon(Icons.add, size: 16, color: AppColors.onGold),
                        const SizedBox(width: 6),
                        Text(
                          isAdding ? 'ADDING...' : 'ADD MONEY',
                          style: const TextStyle(
                            color: AppColors.onGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Add Money Bottom Sheet
  // ---------------------------------------------------------------------------

  void _showAddMoneySheet(BuildContext context, HomeController controller) {
    final TextEditingController amountController = TextEditingController();
    final List<int> quickAmounts = [100, 200, 500, 1000, 2000];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1C),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Add Money to Wallet',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose an amount or enter custom value',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),

                // Quick amount chips
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: quickAmounts.map((amt) {
                    return GestureDetector(
                      onTap: () {
                        amountController.text = amt.toString();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2520),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                        ),
                        child: Text(
                          '₹$amt',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Custom amount input
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: const TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold),
                    hintText: 'Enter amount',
                    hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.5)),
                    filled: true,
                    fillColor: const Color(0xFF141416),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.gold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Add Money CTA
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text.trim());
                    if (amount == null || amount <= 0) {
                      Get.snackbar(
                        'Invalid Amount',
                        'Please enter a valid amount.',
                        backgroundColor: Colors.red.withOpacity(0.8),
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                      );
                      return;
                    }
                    Navigator.of(ctx).pop();
                    controller.addMoneyToWallet(amount);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.onGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text(
                    'PROCEED TO PAY',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Payment Method Selection Sheet
  // ---------------------------------------------------------------------------

  void _showPaymentMethodSheet(
    BuildContext context,
    HomeController controller,
    String planId,
    String billingCycle,
    double price,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Choose Payment Method',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Amount: \$${price.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Wallet Option
              Obx(() {
                final balance = controller.walletBalance.value;
                final bool hasEnough = balance >= price;
                return _buildPaymentOption(
                  icon: Icons.account_balance_wallet,
                  title: 'Pay with Wallet',
                  subtitle: 'Balance: ₹${balance.toStringAsFixed(2)}${hasEnough ? '' : ' (Insufficient)'}',
                  enabled: hasEnough,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    controller.purchaseSubscription(planId, billingCycle);
                  },
                );
              }),

              const SizedBox(height: 16),

              // Stripe/Card Option
              _buildPaymentOption(
                icon: Icons.credit_card,
                title: 'Pay with Card',
                subtitle: 'Pay securely via Stripe',
                enabled: true,
                onTap: () {
                  Navigator.of(ctx).pop();
                  controller.purchaseSubscription(
                    planId,
                    billingCycle,
                    paymentMethod: 'stripe',
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF141416),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: enabled ? AppColors.gold.withOpacity(0.4) : AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.gold, size: 22),
              ),
              const SizedBox(width: 14),
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
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: enabled ? AppColors.gold : AppColors.divider,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Existing Helper Widgets
  // ---------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------
// Sleek Gold Crown Icon Painter
// -----------------------------------------------------------------------------

class _CrownPainter extends CustomPainter {
  final Color color;

  _CrownPainter({this.color = AppColors.gold});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Bottom horizontal bar
    canvas.drawLine(
      Offset(w * 0.12, h * 0.90),
      Offset(w * 0.88, h * 0.90),
      paint,
    );

    // Crown peaks contour
    final path = Path();
    path.moveTo(w * 0.14, h * 0.74);
    path.lineTo(w * 0.08, h * 0.26); // Left wing peak
    path.lineTo(w * 0.32, h * 0.48); // Left dip
    path.lineTo(w * 0.50, h * 0.10); // Center tall peak
    path.lineTo(w * 0.68, h * 0.48); // Right dip
    path.lineTo(w * 0.92, h * 0.26); // Right wing peak
    path.lineTo(w * 0.86, h * 0.74); // Right bottom corner
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
