class SubscriptionFeature {
  final String label;
  final bool isActive;

  SubscriptionFeature(this.label, this.isActive);

  factory SubscriptionFeature.fromJson(Map<String, dynamic> json) {
    return SubscriptionFeature(json['label'] as String, json['isActive'] as bool);
  }

  Map<String, dynamic> toJson() => {'label': label, 'isActive': isActive};
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

  bool get isTrial => id == 'sub_3_months';

 
  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      months: json['months'] as int,
      features:
          (json['features'] as List<dynamic>?)
              ?.map((e) => SubscriptionFeature.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'months': months,
    'features': features.map((e) => e.toJson()).toList(),
  };
}
