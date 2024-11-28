import 'package:flutter/material.dart';
import 'package:frontend/ui/root_page.dart';
import 'package:frontend/ui/scan_page.dart';
import 'package:provider/provider.dart' as provider; // Alias cho provider package
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod cho ConsumerWidget

import 'package:frontend/ui/screens/bank_payment_page.dart';
import 'package:frontend/ui/screens/checkout_page.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/providers/favorite_provider.dart';
import 'package:frontend/ui/screens/signin_page.dart';
import 'package:frontend/ui/onboarding_screen.dart';
import 'package:frontend/ui/screens/checkout_success_page.dart';
import 'package:frontend/ui/screens/home_page.dart';
import 'package:frontend/ui/screens/cart_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Khởi tạo đối tượng lưu trữ bảo mật
final storage = const FlutterSecureStorage();

// Hàm để lưu token vào Secure Storage
Future<void> saveToken(String token) async {
  await storage.write(key: 'user_token', value: token); // Lưu token vào Secure Storage
}

// Hàm để lấy token từ Secure Storage
Future<String?> getToken() async {
  return await storage.read(key: 'user_token'); // Lấy token từ Secure Storage
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kiểm tra token trước khi chạy ứng dụng
  String? token = await getToken();

  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
          provider.ChangeNotifierProvider<FavoriteProvider>(create: (_) => FavoriteProvider()),
        ],
        child: MyApp(token: token),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final String? token;
  const MyApp({super.key, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Plant Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // Điều hướng dựa trên token
      initialRoute: token == null ? '/signin' : '/home', // Nếu không có token, chuyển tới SignIn
      routes: {
        '/onboardingscreen': (context) => const OnboardingScreen(),
        '/main': (context) => const RootPage(),
        '/home': (context) => const HomePage(),
        '/signin': (context) => const SignIn(), // Đảm bảo route cho trang đăng nhập
        '/bank-payment': (context) => const BankPaymentPage(),
        '/scan': (context) => const ScanPage(),
        '/cart': (context) => const CartPage(),
        '/checkout-success': (context) => const CheckoutSuccessPage(),
        '/checkout': (context) => CheckoutPage(),
      },
    );
  }
}
