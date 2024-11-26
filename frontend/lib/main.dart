import 'package:flutter/material.dart';
import 'package:frontend/ui/root_page.dart';
import 'package:frontend/ui/scan_page.dart';
import 'package:provider/provider.dart'
    as provider; // Alias cho provider package
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod cho ConsumerWidget

import 'package:frontend/ui/screens/bank_payment_page.dart';
import 'package:frontend/ui/screens/checkout_page.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/providers/favorite_provider.dart';
import 'package:frontend/ui/screens/signin_page.dart';
import 'package:frontend/ui/onboarding_screen.dart';
import 'package:frontend/ui/screens/checkout_success_page.dart';
import 'package:frontend/ui/screens/home_page.dart';

void main() {
  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider<CartProvider>(
            create: (_) => CartProvider(),
          ),
          provider.ChangeNotifierProvider<FavoriteProvider>(
            create: (_) => FavoriteProvider(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Plant Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/onboardingscreen',
      routes: {
        '/onboardingscreen': (context) => const OnboardingScreen(),
        '/main': (context) => const RootPage(),
        '/home': (context) => const HomePage(),
        '/signin': (context) => const SignIn(),
        '/checkout-success': (context) => const CheckoutSuccessPage(),
        // '/checkout': (context) => CheckoutPage(),
        '/bank-payment': (context) => const BankPaymentPage(),
        '/scan': (context) =>const ScanPage(),
      },
    );
  }
}
