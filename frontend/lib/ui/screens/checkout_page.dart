import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:intl/intl.dart';
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
    // 'VISA/MasterCard',
    'Momo'
  ];

  final bool _isBuyNow = true; // Giả sử bạn có biến này để xác định có "Mua ngay" hay không.

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final cart = Provider.of<CartProvider>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        // Kiểm tra nếu là hành động "Mua ngay", xóa sản phẩm khỏi giỏ hàng
        if (_isBuyNow) {
          // Giả sử bạn có hàm `removeFromCart()` để xóa sản phẩm khỏi giỏ hàng
          final product = cart.items.first; // Bạn có thể lấy sản phẩm mà người dùng chọn
          handleBackAction(product, cart);
        }
        return true; // Quay lại trang trước
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
                          formatCurrency.format(product.quantity * product.price),
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedPaymentMethod == 'Ngân hàng') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const BankPaymentPage()),
                          );
                        } else {
                        cart.checkout(context, _selectedPaymentMethod).then((success) {
  if (success) {
    Navigator.pushNamed(context, '/checkout-success');
  }
});

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
