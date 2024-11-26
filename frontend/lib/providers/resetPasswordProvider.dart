// lib/Provider/resetPasswordProvider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/Services/api_service.dart';

class ResetPasswordState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  ResetPasswordState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  ResetPasswordState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return ResetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

final resetPasswordProvider = StateNotifierProvider<ResetPasswordNotifier, ResetPasswordState>(
  (ref) => ResetPasswordNotifier(),
);

class ResetPasswordNotifier extends StateNotifier<ResetPasswordState> {
  ResetPasswordNotifier() : super(ResetPasswordState());

  Future<bool> forgotPassword(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await ApiService.forgotPassword(email);

      if (response['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          isSuccess: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response['message'] ?? 'Có lỗi xảy ra',
          isSuccess: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Có lỗi xảy ra: $e',
        isSuccess: false,
      );
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await ApiService.resetPassword(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (response['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          isSuccess: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response['message'] ?? 'Không thể đặt lại mật khẩu',
          isSuccess: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Có lỗi xảy ra: $e',
        isSuccess: false,
      );
      return false;
    }
  }
}