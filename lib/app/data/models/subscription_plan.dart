class SubscriptionPlan {
  final String id;
  final String name;
  final String subtitle;
  final double monthlyPrice;
  final double annualPrice;
  final List<PlanFeature> features;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.features,
    required this.isPopular,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final prices = json['prices'] as Map<String, dynamic>? ?? {};
    final rawFeatures = json['features'] as List<dynamic>? ?? [];

    final monthly = (prices['monthly'] as num? ??
            json['monthlyPrice'] as num? ??
            json['price'] as num? ??
            json['monthly_price'] as num? ??
            0.0)
        .toDouble();

    final annualRaw = (prices['annual'] as num? ??
            json['annualPrice'] as num? ??
            json['annual_price'] as num? ??
            json['yearlyPrice'] as num? ??
            json['yearly_price'] as num? ??
            0.0)
        .toDouble();

    final annual = annualRaw > 0 ? annualRaw : (monthly > 0 ? (monthly * 0.7) : 0.0);

    return SubscriptionPlan(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ??
          json['tagline'] as String? ??
          json['description'] as String? ??
          '',
      monthlyPrice: monthly,
      annualPrice: annual,
      features: rawFeatures.map((f) {
        if (f is String) {
          return PlanFeature(id: '', text: f, included: true);
        } else if (f is Map<String, dynamic>) {
          return PlanFeature.fromJson(f);
        }
        return PlanFeature(id: '', text: f.toString(), included: true);
      }).toList(),
      isPopular: json['isPopular'] as bool? ??
          json['popular'] as bool? ??
          json['is_popular'] as bool? ??
          false,
    );
  }
}

class PlanFeature {
  final String id;
  final String text;
  final bool included;

  PlanFeature({
    required this.id,
    required this.text,
    required this.included,
  });

  factory PlanFeature.fromJson(Map<String, dynamic> json) {
    return PlanFeature(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      text: json['text'] as String? ??
          json['name'] as String? ??
          json['title'] as String? ??
          json['feature'] as String? ??
          '',
      included: json['included'] as bool? ??
          json['isIncluded'] as bool? ??
          json['is_included'] as bool? ??
          true,
    );
  }
}

class UserSubscription {
  final bool hasActiveSubscription;
  final String? planId;
  final String? planName;
  final String? billingCycle;
  final DateTime? endDate;
  final bool isActive;
  final bool isTrial;
  final bool success;
  final bool requiresSubscription;
  final String? message;

  UserSubscription({
    required this.hasActiveSubscription,
    this.planId,
    this.planName,
    this.billingCycle,
    this.endDate,
    required this.isActive,
    this.isTrial = false,
    this.success = true,
    this.requiresSubscription = false,
    this.message,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    final hasActive = json['hasActiveSubscription'] as bool? ?? false;
    final success = json['success'] as bool? ?? true;
    final requiresSub = json['requiresSubscription'] as bool? ?? false;
    final msg = json['message'] as String?;

    final sub = json['subscription'] as Map<String, dynamic>?;

    if (sub == null) {
      return UserSubscription(
        hasActiveSubscription: hasActive,
        isActive: false,
        isTrial: false,
        success: success,
        requiresSubscription: requiresSub,
        message: msg,
      );
    }

    final plan = sub['plan'] as Map<String, dynamic>?;
    final endStr = sub['endDate'] as String?;
    final isTrialVal = sub['isTrial'] as bool? ?? false;

    return UserSubscription(
      hasActiveSubscription: hasActive,
      planId: plan != null ? (plan['_id'] as String? ?? plan['id'] as String? ?? '') : null,
      planName: plan != null ? (plan['name'] as String? ?? '') : null,
      billingCycle: sub['billingCycle'] as String?,
      endDate: endStr != null ? DateTime.tryParse(endStr) : null,
      isActive: sub['isActive'] as bool? ?? false,
      isTrial: isTrialVal,
      success: success,
      requiresSubscription: requiresSub,
      message: msg,
    );
  }
}
