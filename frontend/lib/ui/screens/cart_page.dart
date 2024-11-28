import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:intl/intl.dart';
import 'package:frontend/ui/screens/checkout_page.dart'; // Đảm bảo rằng bạn đã import CheckoutPage

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
      ),
      body: Consumer<CartProvider>(  // Dùng Consumer để lấy trạng thái giỏ hàng từ CartProvider
        builder: (context, cart, child) {
          // Nếu đang tải dữ liệu, hiển thị CircularProgressIndicator
          if (cart.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Nếu giỏ hàng trống, hiển thị thông báo
          if (cart.items.isEmpty) {
            return const Center(child: Text('Giỏ hàng trống'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final product = cart.items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Image.network(
                          product.photos.first,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(product.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(formatCurrency.format(product.price)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    if (product.quantity > 1) {
                                      cart.updateQuantity(
                                          product, product.quantity - 1);
                                    }
                                  },
                                ),
                                Text(
                                  '${product.quantity}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    cart.updateQuantity(
                                        product, product.quantity + 1);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => cart.removeFromCart(product),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Phần tổng tiền và nút thanh toán
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng tiền:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          formatCurrency.format(cart.totalAmount),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Nút thanh toán
                    ElevatedButton(
                      onPressed: () {
                        // Chuyển đến trang checkout khi người dùng nhấn nút thanh toán
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Thanh toán'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
