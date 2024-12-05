class Order {
  final String name;
  final String phone;
  final String shipping_address;
  final String paymentMethod;
  final double totalAmount;
  final List<CartItem> cart;

  Order({
    required this.name,
    required this.phone,
    required this.shipping_address,
    required this.paymentMethod,
    required this.totalAmount,
    required this.cart,
  });

  Map<String, dynamic> toJson() {
    return {
      'name':name,
      'phone': phone,
      'shipping_address': shipping_address,
      'payment_method': paymentMethod,
      'total_amount': totalAmount,
      'cart': cart.map((item) => item.toJson()).toList(),
    };
  }
}

class CartItem {
  final int id;
  final int quantity;
  final double price;
  final String title;

  CartItem({
    required this.id,
    required this.quantity,
    required this.price,
    required this.title,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'quantity': quantity,
      'price': price,
    };
  }
}
