import 'package:flutter/material.dart';
class BankPaymentPage extends StatelessWidget {
  const BankPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán qua Ngân hàng'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Quét mã QR để thanh toán',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 200, // Chiều rộng mong muốn
                height: 200, // Chiều cao mong muốn
                child: Image.asset(
                  'assets/images/qrcode.jpg',
                  fit: BoxFit.contain, // Hiển thị đầy đủ ảnh
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.error,
                      size: 100,
                      color: Colors.red,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hoặc chuyển khoản qua thông tin bên dưới:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ngân hàng: TP BANK - Ngân Hàng Tiên Phong\n'
              'Chủ tài khoản: THÁI TUẤN TÀI\n'
              'Số tài khoản: 4949 437 7979',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xác nhận chuyển khoản'),
                    content: const Text(
                      'Vui lòng xác nhận nếu bạn đã hoàn tất việc chuyển khoản.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/checkout-success');
                        },
                        child: const Text('Xác nhận'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Xác nhận đã chuyển khoản',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
