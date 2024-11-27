import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/loginProvider.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/ui/root_page.dart';
import 'package:frontend/ui/screens/forgot_password.dart';
import 'package:frontend/ui/screens/signup_page.dart';
import 'package:frontend/ui/screens/widgets/custom_textfield.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignIn extends ConsumerStatefulWidget {
  const SignIn({super.key});

  @override
  ConsumerState<SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(); // Khởi tạo flutter_secure_storage

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm lưu token vào secure storage
  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: 'user_token', value: token); // Lưu token vào Secure Storage
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true; // Bắt đầu quá trình đăng nhập, hiển thị spinner
    });
    try {
      final success = await ref.read(loginProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );

      if (success) {
        // Lấy thông tin người dùng từ provider
        final user = ref.read(userProvider);

        // Lấy token từ provider sau khi đăng nhập thành công
        const token = 'example_token'; // Bạn cần thay thế bằng token thực tế nhận được từ API

        // Lưu token vào secure storage
        await _saveToken(token);

        // Hiển thị thông báo đăng nhập thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Đăng nhập thành công, chào mừng ${user?.full_name}!'),
            backgroundColor: Colors.green,
          ),
        );

        // Chuyển hướng đến trang chính
        Navigator.pushReplacement(
          context,
          PageTransition(
            child: const RootPage(),
            type: PageTransitionType.bottomToTop,
          ),
        );
      } else {
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Email hoặc mật khẩu không đúng. Vui lòng kiểm tra lại!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Xử lý lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _forgotPassword() {
    Navigator.push(
      context,
      PageTransition(
        child: const ForgotPassword(),
        type: PageTransitionType.bottomToTop,
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      PageTransition(
        child: const SignUp(),
        type: PageTransitionType.bottomToTop,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/signin.png'),
              const Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 35.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 30),
              CustomTextfield(
                obscureText: false,
                hintText: 'Email của bạn',
                icon: Icons.alternate_email,
                controller: _emailController,
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextfield(
                obscureText: true,
                hintText: 'Mật khẩu của bạn',
                icon: Icons.lock,
                controller: _passwordController,
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(size.width, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Đăng nhập'),
                    ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _forgotPassword,
                child: Text(
                  'Quên Mật Khẩu? Reset tại đây.',
                  style: TextStyle(
                    color: Constants.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Divider(
                color: Constants.blackColor.withOpacity(0.5),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToSignUp,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(size.width, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Constants.primaryColor,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                ),
                child: Text(
                  'Tạo tài khoản mới',
                  style: TextStyle(
                    color: Constants.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
