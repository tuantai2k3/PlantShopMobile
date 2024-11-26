class Rating {
  final int id;
  final int userId;
  final int productId;
  final int rating;
  final String? review;
  final String status;
  final String createdAt;
  final Map<String, dynamic>? user; // thông tin user nếu có
  final Map<String, dynamic>? product; // thông tin product nếu có

  Rating({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    this.review,
    required this.status,
    required this.createdAt,
    this.user,
    this.product,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      rating: json['rating'],
      review: json['review'],
      status: json['status'],
      createdAt: json['created_at'],
      user: json['user'],
      product: json['product'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'rating': rating,
      'review': review,
      'status': status,
      'created_at': createdAt,
      'user': user,
      'product': product,
    };
  }
}