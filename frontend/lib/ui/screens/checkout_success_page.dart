import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Khởi tạo đối tượng lưu trữ bảo mật
final storage = const FlutterSecureStorage();

class CheckoutSuccessPage extends StatelessWidget {
  const CheckoutSuccessPage({super.key});

  Future<String?> getToken() async {
    return await storage.read(key: 'user_token'); // Lấy token từ Secure Storage
  }

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
              onPressed: () async {
                // Kiểm tra token trước khi điều hướng
                String? token = await getToken();
                
                if (token != null) {
                  // Nếu có token (nghĩa là người dùng đã đăng nhập), điều hướng về trang chính
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home', // Điều hướng về trang home nếu người dùng đã đăng nhập
                    (route) => false, // Xóa toàn bộ stack trước đó
                  );
                } else {
                  // Nếu không có token (nghĩa là người dùng chưa đăng nhập), điều hướng về trang đăng nhập
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/signin', // Điều hướng về trang signin nếu người dùng chưa đăng nhập
                    (route) => false, // Xóa toàn bộ stack trước đó
                  );
                }
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
