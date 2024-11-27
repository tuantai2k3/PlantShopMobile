import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/ui/screens/signin_page.dart';
import 'package:frontend/ui/screens/widgets/custom_textfield.dart';
import 'package:page_transition/page_transition.dart';
import 'package:frontend/Services/api_service.dart';
import 'package:email_validator/email_validator.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Sửa lại validator để nhận dynamic
  String? _validateEmail(dynamic value) {
    final String? email = value?.toString();
    if (email == null || email.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!EmailValidator.validate(email)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.forgotPassword(_emailController.text);

      if (result['success']) {
        _showSuccessDialog(
          'Email khôi phục mật khẩu đã được gửi',
          'Vui lòng kiểm tra email của bạn và làm theo hướng dẫn để đặt lại mật khẩu.',
        );
      } else {
        _showErrorDialog(result['message'] ?? 'Có lỗi xảy ra');
      }
    } catch (e) {
      _showErrorDialog('Có lỗi xảy ra: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                PageTransition(
                  child: const SignIn(),
                  type: PageTransitionType.bottomToTop,
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/images/reset-password.png'),
                const Text(
                  'Forgot\nPassword',
                  style: TextStyle(
                    fontSize: 35.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 30),
                CustomTextfield(
                  obscureText: false,
                  hintText: 'Enter Email',
                  icon: Icons.alternate_email,
                  controller: _emailController,
                  validator: _validateEmail, // Validator đã được sửa để nhận dynamic
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GestureDetector(
                        onTap: _resetPassword,
                        child: Container(
                          width: size.width,
                          decoration: BoxDecoration(
                            color: Constants.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 20,
                          ),
                          child: const Center(
                            child: Text(
                              'Reset Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageTransition(
                        child: const SignIn(),
                        type: PageTransitionType.bottomToTop,
                      ),
                    );
                  },
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Have an Account? ',
                            style: TextStyle(
                              color: Constants.blackColor,
                            ),
                          ),
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: Constants.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}