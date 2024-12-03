import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Provider quản lý người dùng
final userProvider = StateProvider<User?>((ref) => null);

// Provider quản lý trạng thái đăng nhập
final loginProvider = StateNotifierProvider<LoginNotifier, bool>((ref) => LoginNotifier(ref));

class LoginNotifier extends StateNotifier<bool> {
  final Ref ref;
  String? lastErrorMessage;

  LoginNotifier(this.ref) : super(false);

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Lưu token vào bộ nhớ
  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
    ApiService.setToken(token); // Cập nhật token cho ApiService
  }

  // Lấy token từ bộ nhớ
  Future<String?> _getToken() async {
    final token = await _secureStorage.read(key: 'auth_token');
    if (token != null) {
      ApiService.setToken(token); // Cập nhật token cho ApiService
    }
    return token;
  }

  // Xóa token khỏi bộ nhớ
  Future<void> _clearToken() async {
    await _secureStorage.delete(key: 'auth_token');
    ApiService.setToken(''); // Xóa token trong ApiService
  }

  // Đăng nhập người dùng
  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.login(email, password);

      if (response['success'] == true) {
        final userData = response['user'];
        final token = response['token'];

        if (token == null || token.toString().isEmpty) {
          lastErrorMessage = 'Token không hợp lệ';
          state = false;
          return false;
        }

        // Lưu thông tin người dùng vào provider
        ref.read(userProvider.notifier).state = User(
          id: userData['id'],
          full_name: userData['full_name'],
          email: userData['email'],
          photo: userData['photo'],
          password: "", // Không lưu password trong User object
          phone: userData['phone'],
          username: userData['username'],
          address: userData['address'],
          status: userData['status'],
          role: userData['role'],
        );

        // Lưu token vào bộ nhớ
        await _saveToken(token.toString());
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

  // Đăng xuất người dùng
  Future<void> logout() async {
    try {
      await _clearToken(); // Xóa token
      ref.read(userProvider.notifier).state = null; // Xóa thông tin người dùng
      state = false;
      lastErrorMessage = null;
    } catch (e) {
      print('Logout Error: $e');
      lastErrorMessage = 'Lỗi khi đăng xuất: $e';
    }
  }

  // Cập nhật thông tin người dùng
  Future<bool> updateProfile(Map<String, dynamic> updateData) async {
    try {
      final token = await _getToken();
      if (token == null) {
        lastErrorMessage = 'Không tìm thấy token xác thực';
        return false;
      }

      final response = await ApiService.updateUserProfile(
        token: token, // Gửi token xác thực
        username: updateData['username'],
        phone: updateData['phone'],
        address: updateData['address'],
        description: updateData['description'],
        taxname: updateData['taxname'],
        taxcode: updateData['taxcode'],
        taxaddress: updateData['taxaddress'],
      );

      if (response['success'] == true) {
        final userData = response['user'];

        // Cập nhật thông tin người dùng
        ref.read(userProvider.notifier).state = User(
          id: userData['id'],
          email: userData['email'],
          username: userData['username'],
          password: "", // Không lưu password
          phone: userData['phone'],
          full_name: userData['full_name'] ?? '',
          address: userData['address'],
          description: userData['description'],
          status: userData['status'],
          role: userData['role'] ?? 'user',
        );

        lastErrorMessage = null;
        return true;
      } else {
        lastErrorMessage = response['message'] ?? 'Cập nhật thất bại';
        return false;
      }
    } catch (e) {
      print('Update Profile Error: $e');
      lastErrorMessage = e.toString();
      return false;
    }
  }

  // Kiểm tra trạng thái đăng nhập
  Future<bool> checkAuthStatus() async {
    try {
      final token = await _getToken();
      if (token == null) {
        state = false;
        return false;
      }

      // Kiểm tra token với server nếu cần
      state = true;
      return true;
    } catch (e) {
      print('Check Auth Status Error: $e');
      state = false;
      return false;
    }
  }
}
