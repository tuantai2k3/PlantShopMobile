import 'package:flutter/material.dart';

class CheckoutSuccessPage extends StatelessWidget {
  const CheckoutSuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán thành công'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 16),
            const Text(
              'Thanh toán của bạn đã thành công!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
           ElevatedButton(
  onPressed: () {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main', // Định danh route của Home Page
      (route) => false, // Xóa toàn bộ stack trước đó
    );
  },
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(
      horizontal: 32,
      vertical: 12,
    ),
    backgroundColor: Colors.green,
  ),
  child: const Text('Quay về Trang chính'),
),

          ],
        ),
      ),
    );
  }
}
