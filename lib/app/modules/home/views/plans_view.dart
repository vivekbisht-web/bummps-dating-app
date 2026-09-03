  import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/bummps_logo.dart';
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
              // --- Wallet Balance Card ---
              _buildWalletCard(),
              const SizedBox(height: 24),

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

              // Stripe/Card Option 🆕
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
                      style: TextStyle(
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
