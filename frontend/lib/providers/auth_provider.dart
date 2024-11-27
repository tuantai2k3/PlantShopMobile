import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/services/api_service.dart'; // Import ApiService
import 'package:frontend/models/user.dart'; // Model người dùng

// Định nghĩa trạng thái của quá trình đăng nhập
class AuthState {
  final User? user;
  final String? error;
  final bool isLoading;

  AuthState({
    this.user,
    this.error,
    this.isLoading = false,
  });

  // Trạng thái đăng nhập thành công
  AuthState.loggedIn(User user)
      : user = user,
        error = null,
        isLoading = false;

  // Trạng thái lỗi
  AuthState.error(String error)
      : user = null,
        error = error,
        isLoading = false;

  // Trạng thái đang xử lý
  AuthState.loading()
      : user = null,
        error = null,
        isLoading = true;

  // Trạng thái đăng xuất
  AuthState.loggedOut()
      : user = null,
        error = null,
        isLoading = false;
}

// StateNotifierProvider cho việc quản lý trạng thái đăng nhập
class AuthProvider extends StateNotifier<AuthState> {
  AuthProvider() : super(AuthState.loggedOut());

  // Đăng nhập
  Future<void> login(String email, String password) async {
    state = AuthState.loading(); // Đang xử lý
    try {
      final response = await ApiService.login(email, password); // Gọi phương thức login từ ApiService
      if (response['success'] == true) {
        final user = User.fromJson(response['user']);
        state = AuthState.loggedIn(user); // Đăng nhập thành công
      } else {
        state = AuthState.error(response['message']); // Lỗi đăng nhập
      }
    } catch (e) {
      state = AuthState.error('Lỗi kết nối: $e'); // Lỗi kết nối
    }
  }

  // Đăng ký
  Future<void> register(
    String username,
    String phone,
    String email,
    String password,
    String confirmPassword,
  ) async {
    state = AuthState.loading(); // Đang xử lý
    try {
      final response = await ApiService.register(
        username,
        phone,
        email,
        password,
        confirmPassword,
      ); // Gọi phương thức register từ ApiService
      if (response['success'] == true) {
        final user = User.fromJson(response['user']);
        state = AuthState.loggedIn(user); // Đăng ký thành công và đăng nhập luôn
      } else {
        state = AuthState.error(response['message']); // Lỗi đăng ký
      }
    } catch (e) {
      state = AuthState.error('Lỗi kết nối: $e'); // Lỗi kết nối
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    state = AuthState.loading(); // Đang xử lý
    await ApiService.logout(); // Gọi phương thức logout từ ApiService
    state = AuthState.loggedOut(); // Đăng xuất thành công
  }
}

// Cung cấp AuthProvider cho toàn bộ ứng dụng
final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  return AuthProvider();
});
