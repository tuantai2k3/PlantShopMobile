class Product {
  final int id;
  final String code;
  final String? barcode;
  final int? userId;
  final String title;
  final String slug;
  final String? summary;
  final String? description;
  final int stock;
  final int sold;
  final double priceIn;
  final double priceAvg;
  final double priceOut;
  final double price;
  final int hit;
  final int? brandId;
  final int? catId;
  final int? parentCatId;
  final List<String> photos;
  final String? size;
  final String? weight;
  final String? expired;
  final int isSold;
  final String type;
  final String status;
  final int feature;
  final DateTime createdAt;
  final DateTime updatedAt;

  // `isFavorite` field with getter and setter
  bool _isFavorite;

  // `quantity` field for cart management
  final int quantity;

  Product({
    required this.id,
    required this.code,
    this.barcode,
    this.userId,
    required this.title,
    required this.slug,
    this.summary,
    this.description,
    required this.stock,
    required this.sold,
    required this.priceIn,
    required this.priceAvg,
    required this.priceOut,
    required this.price,
    required this.hit,
    this.brandId,
    this.catId,
    this.parentCatId,
    required this.photos,
    this.size,
    this.weight,
    this.expired,
    required this.isSold,
    required this.type,
    required this.status,
    required this.feature,
    required this.createdAt,
    required this.updatedAt,
    bool? isFavorite, // Optional parameter for isFavorite
    this.quantity = 1, // Default quantity is 1
  }) : _isFavorite = isFavorite ?? false; // Default isFavorite to false if not provided

  // Getter and setter for `isFavorite`
  bool get isFavorite => _isFavorite;
  set isFavorite(bool value) {
    _isFavorite = value;
  }

  // Factory method to create a `Product` from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      barcode: json['barcode'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      summary: json['summary'],
      description: json['description'],
      stock: json['stock'] ?? 0,
      sold: json['sold'] ?? 0,
      priceIn: (json['price_in'] ?? 0).toDouble(),
      priceAvg: (json['price_avg'] ?? 0).toDouble(),
      priceOut: (json['price_out'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      hit: json['hit'] ?? 0,
      brandId: json['brand_id'],
      catId: json['cat_id'],
      parentCatId: json['parent_cat_id'],
      photos: json['photo'] != null && json['photo'] is List
          ? (json['photo'] as List).map((e) => e.toString()).toList()
          : [],
      size: json['size'],
      weight: json['weight'],
      expired: json['expired'],
      isSold: json['is_sold'] ?? 0,
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      feature: json['feature'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      isFavorite: json['is_favorite'] ?? false,
      quantity: json['quantity'] ?? 1, // Default quantity from JSON is 1
    );
  }

  // Method to convert the `Product` to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'barcode': barcode,
      'user_id': userId,
      'title': title,
      'slug': slug,
      'summary': summary,
      'description': description,
      'stock': stock,
      'sold': sold,
      'price_in': priceIn,
      'price_avg': priceAvg,
      'price_out': priceOut,
      'price': price,
      'hit': hit,
      'brand_id': brandId,
      'cat_id': catId,
      'parent_cat_id': parentCatId,
      'photo': photos,
      'size': size,
      'weight': weight,
      'expired': expired,
      'is_sold': isSold,
      'type': type,
      'status': status,
      'feature': feature,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_favorite': _isFavorite,
      'quantity': quantity,
    };
  }

  // `copyWith` method for immutability
  Product copyWith({
    int? id,
    String? code,
    String? barcode,
    int? userId,
    String? title,
    String? slug,
    String? summary,
    String? description,
    int? stock,
    int? sold,
    double? priceIn,
    double? priceAvg,
    double? priceOut,
    double? price,
    int? hit,
    int? brandId,
    int? catId,
    int? parentCatId,
    List<String>? photos,
    String? size,
    String? weight,
    String? expired,
    int? isSold,
    String? type,
    String? status,
    int? feature,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    int? quantity,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      barcode: barcode ?? this.barcode,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      summary: summary ?? this.summary,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      sold: sold ?? this.sold,
      priceIn: priceIn ?? this.priceIn,
      priceAvg: priceAvg ?? this.priceAvg,
      priceOut: priceOut ?? this.priceOut,
      price: price ?? this.price,
      hit: hit ?? this.hit,
      brandId: brandId ?? this.brandId,
      catId: catId ?? this.catId,
      parentCatId: parentCatId ?? this.parentCatId,
      photos: photos ?? this.photos,
      size: size ?? this.size,
      weight: weight ?? this.weight,
      expired: expired ?? this.expired,
      isSold: isSold ?? this.isSold,
      type: type ?? this.type,
      status: status ?? this.status,
      feature: feature ?? this.feature,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? _isFavorite,
      quantity: quantity ?? this.quantity,
    );
  }
}
