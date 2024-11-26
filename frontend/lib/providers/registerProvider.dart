// lib/Provider/registerProvider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/Services/api_service.dart';
import 'package:frontend/models/user.dart';

// Định nghĩa RegisterState
class RegisterState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final User? user;

  RegisterState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.user,
  });

  RegisterState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    User? user,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
      user: user ?? this.user,
    );
  }
}

// Provider
final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>(
  (ref) => RegisterNotifier(),
);

class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier() : super(RegisterState());

  Future<bool> register(
    String username,
    String phone,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      // Validate input
      if (username.trim().isEmpty ||
          phone.trim().isEmpty ||
          email.trim().isEmpty ||
          password.isEmpty) {
        state = state.copyWith(
          error: 'Vui lòng điền đầy đủ thông tin',
          isSuccess: false,
        );
        return false;
      }

      // Set loading state
      state = state.copyWith(isLoading: true, error: null);

      // Call API
      final response = await ApiService.register(
        username.trim(),
        phone.trim(),
        email.trim(),
        password,
        confirmPassword,
      );

      // Debug log
      print('Register Response: $response');

      if (response['success'] == true) {
        // Parse user data from response
        if (response['user'] != null) {
          try {
            final user = User(
              id: response['user']['id'] ?? 0,
              email: response['user']['email'] ?? '',
              password: password, // Lưu password đã hash từ server
              username: response['user']['username'] ?? '',
              // fullName: response['user']['full_name'] ?? '',
              phone: response['user']['phone'],
              role: response['user']['role'] ?? 'user',
              status: response['user']['status'] ?? 'inactive',
            );

            // Update state với user data
            state = state.copyWith(
              isLoading: false,
              error: null,
              isSuccess: true,
              user: user,
            );

            // Lưu token nếu có
            if (response['token'] != null) {
              String token = response['token']['token'];
              ApiService.setToken(token); // Cập nhật token trong ApiService
            }

            return true;
          } catch (e) {
            print('Error parsing user data: $e');
            state = state.copyWith(
              isLoading: false,
              error: 'Lỗi xử lý dữ liệu người dùng',
              isSuccess: false,
            );
            return false;
          }
        } else {
          state = state.copyWith(
            isLoading: false,
            error: 'Không nhận được dữ liệu người dùng',
            isSuccess: false,
          );
          return false;
        }
      } else {
        // Handle error from API
        String errorMessage = response['message'] ?? 'Đăng ký thất bại';
        state = state.copyWith(
          isLoading: false,
          error: errorMessage,
          isSuccess: false,
        );
        return false;
      }
    } catch (e) {
      print('Register Error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Có lỗi xảy ra: $e',
        isSuccess: false,
      );
      return false;
    }
  }
}