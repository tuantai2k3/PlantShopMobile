import 'package:flutter/material.dart';
import 'package:frontend/models/order.dart'; // Import mô hình Order
import 'package:frontend/models/product.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/Services/order_service.dart'; // Import dịch vụ gửi đơn hàng
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'bank_payment_page.dart';

class CheckoutPage extends StatelessWidget {
  CheckoutPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _couponController = TextEditingController();

  String _selectedPaymentMethod = 'Thanh toán khi nhận hàng';

  final List<String> _paymentMethods = [
    'Thanh toán khi nhận hàng',
    'Ngân hàng',
    'Momo'
  ];

  final bool _isBuyNow = true;

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final cart = Provider.of<CartProvider>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        if (_isBuyNow) {
          final product = cart.items.first;
          handleBackAction(product, cart);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Xác nhận thanh toán'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin người nhận',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập họ và tên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số điện thoại';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ nhận hàng',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập địa chỉ nhận hàng';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _couponController,
                    decoration: const InputDecoration(
                      labelText: 'Mã giảm giá (nếu có)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Hình thức thanh toán',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: _paymentMethods
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ))
                        .toList(),
                    onChanged: (value) {
                      _selectedPaymentMethod = value!;
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Danh sách sản phẩm',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final product = cart.items[index];
                      return ListTile(
                        leading: Image.network(
                          product.photos.first,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(product.title),
                        subtitle: Text(
                            '${product.quantity} x ${formatCurrency.format(product.price)}'),
                        trailing: Text(
                          formatCurrency
                              .format(product.quantity * product.price),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatCurrency.format(cart.totalAmount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Tạo danh sách sản phẩm từ giỏ hàng
                        final cartItems = cart.items.map((item) {
                          return {
                            'id': item.id,
                            'quantity': item.quantity,
                          };
                        }).toList();

                        // Tạo JSON gửi tới API
                        final orderData = {
                          "name": _nameController.text,
                          "phone": _phoneController.text,
                          "shipping_address": _addressController.text,
                          "payment_method": _selectedPaymentMethod,
                          "total_amount": cart.totalAmount,
                          "cart": cartItems,
                        };

                        try {
                          final success =
                              await OrderService.createOrder(orderData);
                          if (success) {
                            Navigator.pushNamed(context, '/checkout-success');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lỗi khi tạo đơn hàng'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Xác nhận thanh toán',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm để xử lý khi bấm nút back
  void handleBackAction(Product product, CartProvider cart) {
    if (_isBuyNow) {
      // Nếu là hành động "Mua ngay", xóa sản phẩm khỏi giỏ hàng
      cart.removeFromCart(product);
    }
  }
}
