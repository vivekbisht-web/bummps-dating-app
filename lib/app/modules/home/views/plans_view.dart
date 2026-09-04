import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';
import '../../../data/models/subscription_plan.dart';

// -----------------------------------------------------------------------------
// Scoped Luxury Midnight & Champagne Gold Color Palette for Plans Screen Only
// -----------------------------------------------------------------------------
class _PlanColors {
  _PlanColors._();

  // Pure dark background matching luxury obsidian theme
  static const Color background = Color(0xFF000000);
  static const Color cardBg = Color(0xFF0D0C0A);
  static const Color cardBorder = Color(0xFF241F18);
  static const Color cardBorderHover = Color(0xFFE5B869);

  // Warm Champagne & Honey Gold
  static const Color gold = Color(0xFFE5B869);
  static const Color goldLight = Color(0xFFF3CD85);
  static const Color goldDark = Color(0xFFC99843);
  static const Color onGold = Color(0xFF14110C);

  // Typography & Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textHighlight = Color(0xFFDDD5C8);
  static const Color textMuted = Color(0xFF8A7F71);
  static const Color textDark = Color(0xFF5E5448);
  static const Color textLegal = Color(0xFF6B6256);

  // Checkmark circles & icons
  static const Color checkBgActive = Color(0xFF261F13);
  static const Color checkBorderActive = Color(0xFF524024);
  static const Color checkIconActive = Color(0xFFE5B869);

  static const Color checkBgInactive = Color(0xFF1B1711);
  static const Color checkBorderInactive = Color(0xFF2E261A);
  static const Color checkIconInactive = Color(0xFF8C734B);

  // Toggle & sheets
  static const Color toggleBg = Color(0xFF141210);
  static const Color sheetBg = Color(0xFF12100E);
  static const Color sheetOptionBg = Color(0xFF181512);
  static const Color divider = Color(0xFF262017);
  static const Color badgeDarkBg = Color(0xFF2A2012);
  static const Color badgeGoldBg = Color(0xFF1A140A);
}

class PlansView extends StatefulWidget {
  const PlansView({super.key});

  @override
  State<PlansView> createState() => _PlansViewState();
}

class _PlansViewState extends State<PlansView> {
  bool isMonthly = true;
  String? selectedPlanId;
  String? hoveredPlanId;

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
      backgroundColor: _PlanColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _PlanColors.gold, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Image.asset(
          'assets/images/bummps-icon.png',
          height: 34,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: _PlanColors.gold, size: 24),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 4),
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
                        _PlanColors.gold.withOpacity(0.18),
                        _PlanColors.goldDark.withOpacity(0.06),
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
              color: _PlanColors.gold,
              backgroundColor: _PlanColors.sheetBg,
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
                        painter: _CrownPainter(color: _PlanColors.gold),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // --- Header Section: "Choose Your Plan" ---
                    Center(
                      child: Text(
                        'Choose Your Plan',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: _PlanColors.gold,
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
                            color: _PlanColors.textMuted,
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
                        color: _PlanColors.toggleBg,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: _PlanColors.cardBorder),
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
                                  color: isMonthly ? _PlanColors.gold : Colors.transparent,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Center(
                                  child: Text(
                                    'MONTHLY',
                                    style: TextStyle(
                                      color: isMonthly ? _PlanColors.onGold : _PlanColors.textMuted,
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
                                  color: !isMonthly ? _PlanColors.gold : Colors.transparent,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'ANNUAL',
                                      style: TextStyle(
                                        color: !isMonthly ? _PlanColors.onGold : _PlanColors.textMuted,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isMonthly ? _PlanColors.badgeDarkBg : _PlanColors.badgeGoldBg,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: _PlanColors.gold, width: 0.5),
                                      ),
                                      child: const Text(
                                        'SAVE 40%',
                                        style: TextStyle(
                                          color: _PlanColors.gold,
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
                            child: CircularProgressIndicator(color: _PlanColors.gold),
                          ),
                        );
                      }

                      if (controller.subscriptionPlans.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No plans available at the moment.',
                              style: TextStyle(color: _PlanColors.textMuted),
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
                        color: _PlanColors.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _PlanColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Concierge Support',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: _PlanColors.gold,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Exclusively for Pro & Premium members: A dedicated lifestyle assistant to help you curate your profile and prepare for the perfect first encounter.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _PlanColors.textMuted,
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
                              border: Border.all(color: _PlanColors.gold, width: 2.0),
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
                          color: _PlanColors.textLegal,
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
  // Plan Card Widget (Golden on Hover / Selection, Otherwise Clean Dark)
  // ---------------------------------------------------------------------------

  String _formatPlanName(String rawName) {
    final lower = rawName.toLowerCase().trim();
    if (lower == 'bummps.' || lower == 'bummps' || lower.contains('basic') || lower.contains('silver') || lower.contains('starter')) {
      return 'bummps.';
    } else if (lower == 'bummps+' || lower == 'bummps plus' || lower.contains('plus') || lower.contains('gold')) {
      return 'bummps+';
    } else if (lower == 'bummps pro' || lower.contains('pro') || lower.contains('platinum') || lower.contains('premium')) {
      return 'bummps Pro';
    }
    return rawName;
  }

  String _formatPlanSubtitle(String rawName, String rawSubtitle) {
    final clean = rawSubtitle.trim();
    if (clean.isNotEmpty && !clean.toUpperCase().contains('POPULAR')) {
      return clean;
    }
    final lower = rawName.toLowerCase().trim();
    if (lower.contains('bummps.') || lower == 'bummps' || lower.contains('basic') || lower.contains('silver') || lower.contains('starter')) {
      return 'Get started';
    } else if (lower.contains('pro') || lower.contains('platinum') || lower.contains('premium')) {
      return 'Go all in';
    }
    return '';
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required HomeController controller,
    required SubscriptionPlan plan,
    required double price,
    required bool isCurrentPlan,
    required bool isSelected,
  }) {
    final bool isPopular = plan.isPopular == true ||
        plan.name.toLowerCase().contains('+') ||
        plan.name.toLowerCase().contains('plus');

    final bool isHovered = hoveredPlanId == plan.id;
    final bool isHighlighted = hoveredPlanId != null ? isHovered : (isSelected || isCurrentPlan);

    final String displayName = _formatPlanName(plan.name);
    final String displaySubtitle = _formatPlanSubtitle(plan.name, plan.subtitle);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hoveredPlanId = plan.id;
        });
      },
      onExit: (_) {
        setState(() {
          if (hoveredPlanId == plan.id) {
            hoveredPlanId = null;
          }
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPlanId = plan.id;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 22),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main Card Body with Intense Dynamic Golden Glow when Highlighted / Hovered
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  color: _PlanColors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isHighlighted
                        ? _PlanColors.cardBorderHover
                        : _PlanColors.cardBorder,
                    width: isHighlighted ? 1.8 : 1.0,
                  ),
                  boxShadow: isHighlighted
                      ? [
                          // Outer wide gold aura / diffusion
                          BoxShadow(
                            color: _PlanColors.gold.withOpacity(0.35),
                            blurRadius: 32,
                            spreadRadius: 2.0,
                            offset: Offset.zero,
                          ),
                          // Medium luminous gold glow
                          BoxShadow(
                            color: _PlanColors.gold.withOpacity(0.50),
                            blurRadius: 16,
                            spreadRadius: 1.0,
                            offset: Offset.zero,
                          ),
                          // Tight crisp gold edge halo
                          BoxShadow(
                            color: _PlanColors.goldLight.withOpacity(0.40),
                            blurRadius: 5,
                            spreadRadius: 0.5,
                            offset: Offset.zero,
                          ),
                          // Deep drop shadow
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
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
                        // Left: Title & Tagline
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  color: isHighlighted ? _PlanColors.gold : Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              if (displaySubtitle.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 3.0, right: 8.0),
                                  child: Text(
                                    displaySubtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: _PlanColors.textMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Right: Price & /month
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: _PlanColors.gold,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isMonthly ? '/month' : '/mo',
                              style: const TextStyle(
                                color: _PlanColors.textMuted,
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
                            color: _PlanColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),

                    // Features List
                    if (plan.features.isNotEmpty)
                      ...plan.features.map<Widget>((feature) => _buildFeatureItem(
                            feature.text,
                            isIncluded: feature.included,
                            isHighlighted: isHighlighted,
                          ))
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'All standard membership benefits',
                          style: TextStyle(color: _PlanColors.textHighlight, fontSize: 14),
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
                              : (isHighlighted ? _PlanColors.gold : const Color(0xFF1E1A14)),
                          foregroundColor: isCurrentPlan
                              ? _PlanColors.gold
                              : (isHighlighted ? _PlanColors.onGold : _PlanColors.gold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: isCurrentPlan
                                ? BorderSide(color: _PlanColors.gold.withOpacity(0.4), width: 1)
                                : (isHighlighted
                                    ? BorderSide.none
                                    : BorderSide(color: _PlanColors.gold.withOpacity(0.35), width: 1)),
                          ),
                          minimumSize: const Size.fromHeight(48),
                          elevation: isHighlighted ? 2 : 0,
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
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isHighlighted ? _PlanColors.onGold : _PlanColors.gold,
                                ),
                              )
                            : Text(
                                isCurrentPlan ? 'YOUR CURRENT PLAN' : 'SUBSCRIBE NOW',
                                style: TextStyle(
                                  color: isCurrentPlan
                                      ? _PlanColors.gold
                                      : (isHighlighted ? _PlanColors.onGold : _PlanColors.gold),
                                  fontSize: 14,
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
                      color: _PlanColors.gold,
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
                        color: _PlanColors.onGold,
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
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Feature Checkmark Item
  // ---------------------------------------------------------------------------

  Widget _buildFeatureItem(String text, {bool isIncluded = true, bool isHighlighted = false}) {
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
              color: isHighlighted
                  ? (isIncluded ? _PlanColors.checkBgActive : const Color(0xFF1E1E22))
                  : (isIncluded ? _PlanColors.checkBgInactive : const Color(0xFF161412)),
              border: isIncluded
                  ? Border.all(
                      color: isHighlighted
                          ? _PlanColors.checkBorderActive
                          : _PlanColors.checkBorderInactive,
                      width: 0.8,
                    )
                  : null,
            ),
            child: Icon(
              isIncluded ? Icons.check : Icons.close,
              color: isHighlighted
                  ? (isIncluded ? _PlanColors.checkIconActive : Colors.white24)
                  : (isIncluded ? _PlanColors.checkIconInactive : Colors.white24),
              size: 13,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isIncluded
                    ? (isHighlighted ? _PlanColors.textHighlight : _PlanColors.textMuted)
                    : Colors.white38,
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
            colors: [Color(0xFF1A1713), Color(0xFF241F18)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _PlanColors.gold.withOpacity(0.3), width: 1.2),
        ),
        child: Row(
          children: [
            // Wallet icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _PlanColors.gold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet, color: _PlanColors.gold, size: 24),
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
                      color: _PlanColors.textMuted,
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
                          child: CircularProgressIndicator(strokeWidth: 2, color: _PlanColors.gold),
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
                      color: isAdding ? _PlanColors.gold.withOpacity(0.5) : _PlanColors.gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAdding)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: _PlanColors.onGold),
                          )
                        else
                          const Icon(Icons.add, size: 16, color: _PlanColors.onGold),
                        const SizedBox(width: 6),
                        Text(
                          isAdding ? 'ADDING...' : 'ADD MONEY',
                          style: const TextStyle(
                            color: _PlanColors.onGold,
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
              color: _PlanColors.sheetBg,
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
                      color: _PlanColors.divider,
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
                    color: _PlanColors.textMuted,
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
                          color: _PlanColors.sheetOptionBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _PlanColors.gold.withOpacity(0.4)),
                        ),
                        child: Text(
                          '₹$amt',
                          style: const TextStyle(
                            color: _PlanColors.gold,
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
                    prefixStyle: const TextStyle(color: _PlanColors.gold, fontSize: 18, fontWeight: FontWeight.bold),
                    hintText: 'Enter amount',
                    hintStyle: TextStyle(color: _PlanColors.textMuted.withOpacity(0.5)),
                    filled: true,
                    fillColor: _PlanColors.toggleBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _PlanColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _PlanColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _PlanColors.gold),
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
                    backgroundColor: _PlanColors.gold,
                    foregroundColor: _PlanColors.onGold,
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
            color: _PlanColors.sheetBg,
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
                    color: _PlanColors.divider,
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
                  color: _PlanColors.textMuted,
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
            color: _PlanColors.sheetOptionBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: enabled ? _PlanColors.gold.withOpacity(0.4) : _PlanColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _PlanColors.gold.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: _PlanColors.gold, size: 22),
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
                        color: _PlanColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: enabled ? _PlanColors.gold : _PlanColors.divider,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Advantage Cards
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
        color: _PlanColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _PlanColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF1E1A14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: _PlanColors.gold,
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
                    color: _PlanColors.textMuted,
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
          color: _PlanColors.textMuted,
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
        style: TextStyle(color: _PlanColors.divider, fontSize: 9),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Sleek Gold Crown Icon Painter
// -----------------------------------------------------------------------------

class _CrownPainter extends CustomPainter {
  final Color color;

  _CrownPainter({this.color = _PlanColors.gold});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Bottom horizontal bar
    canvas.drawLine(
      Offset(w * 0.12, h * 0.88),
      Offset(w * 0.88, h * 0.88),
      paint,
    );

    // Crown peaks contour
    final path = Path();
    path.moveTo(w * 0.14, h * 0.74);
    path.lineTo(w * 0.08, h * 0.28); // Left wing peak
    path.lineTo(w * 0.30, h * 0.50); // Left inner dip
    path.lineTo(w * 0.50, h * 0.10); // Center tall peak
    path.lineTo(w * 0.70, h * 0.50); // Right inner dip
    path.lineTo(w * 0.92, h * 0.28); // Right wing peak
    path.lineTo(w * 0.86, h * 0.74); // Right bottom corner
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
