class GiftIdea {
  final String id;
  String title;
  String? description;
  String? link;
  String? storeName;
  String? storeLocation;
  double? estimatedPrice;
  String? currency;
  bool isPurchased;
  String? category;
  DateTime createdAt;

  GiftIdea({
    required this.id,
    required this.title,
    this.description,
    this.link,
    this.storeName,
    this.storeLocation,
    this.estimatedPrice,
    this.currency = 'USD',
    this.isPurchased = false,
    this.category,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'link': link,
        'storeName': storeName,
        'storeLocation': storeLocation,
        'estimatedPrice': estimatedPrice,
        'currency': currency,
        'isPurchased': isPurchased,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GiftIdea.fromJson(Map<String, dynamic> json) => GiftIdea(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        link: json['link'],
        storeName: json['storeName'],
        storeLocation: json['storeLocation'],
        estimatedPrice: json['estimatedPrice']?.toDouble(),
        currency: json['currency'] ?? 'USD',
        isPurchased: json['isPurchased'] ?? false,
        category: json['category'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  GiftIdea copyWith({
    String? title,
    String? description,
    String? link,
    String? storeName,
    String? storeLocation,
    double? estimatedPrice,
    String? currency,
    bool? isPurchased,
    String? category,
  }) =>
      GiftIdea(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        link: link ?? this.link,
        storeName: storeName ?? this.storeName,
        storeLocation: storeLocation ?? this.storeLocation,
        estimatedPrice: estimatedPrice ?? this.estimatedPrice,
        currency: currency ?? this.currency,
        isPurchased: isPurchased ?? this.isPurchased,
        category: category ?? this.category,
        createdAt: createdAt,
      );
}

const List<String> giftCategories = [
  '🎮 Tech & Gaming',
  '👗 Fashion & Style',
  '📚 Books & Education',
  '🍫 Food & Treats',
  '🌿 Health & Wellness',
  '🎨 Arts & Crafts',
  '🏠 Home & Living',
  '⚽ Sports & Outdoor',
  '💎 Jewelry & Accessories',
  '🎭 Experiences',
  '🧸 Toys & Fun',
  '✈️ Travel',
  '🎵 Music & Entertainment',
  '💻 Software & Subscriptions',
  '🌸 Other',
];
