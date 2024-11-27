  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:frontend/Services/api_service.dart';
  import 'package:frontend/models/user.dart';

  final userProvider = StateProvider<User?>((ref) => null);

  final loginProvider =
      StateNotifierProvider<LoginNotifier, bool>((ref) => LoginNotifier(ref));

  class LoginNotifier extends StateNotifier<bool> {
    final Ref ref;
    String? lastErrorMessage;

    LoginNotifier(this.ref) : super(false);

    String? token; // Lưu token sau đăng nhập

    Future<bool> login(String email, String password) async {
      try {
        final response = await ApiService.login(email, password);

        if (response['success'] == true) {
          // Lấy thông tin user từ response
          final userData = response['user'];

          ref.read(userProvider.notifier).state = User(
            id: userData['id'],
            full_name: userData['full_name'], // Sử dụng full_name thay vì name
            email: userData['email'],
            photo: userData['photo'],
            password: "",
            phone: userData['phone'],
            username: userData['username'],
            address: userData['address'],
            status: userData['status'],
            role: userData['role'],
    
            // Có thể là null
          );

          // Lưu token nếu cần
          // Bạn có thể lưu token vào secure storage để sử dụng sau này
          lastErrorMessage = null;
          state = true;
          return true;
        } else {
          lastErrorMessage = response['message'] ?? 'Đăng nhập thất bại.';
          state = false;
          return false;
        }
      } catch (e) {
        print('Login Error: $e');
        lastErrorMessage = e.toString();
        state = false;
        return false;
      }
    }
  }
