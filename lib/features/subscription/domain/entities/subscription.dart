class SubscriptionFeature {
  final String label;
  final bool isActive;

  SubscriptionFeature(this.label, this.isActive);
}

class SubscriptionPlan {
  final String id;
  final String title;
  final double price;
  final int months;
  final List<SubscriptionFeature> features;

  SubscriptionPlan({
    required this.id,
    required this.title,
    required this.price,
    required this.months,
    required this.features,
  });

  bool get isTrial => title.contains("3 дні безплатно");
}
