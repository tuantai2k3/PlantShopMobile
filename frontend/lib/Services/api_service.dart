// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api/v1";
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> get _headers {
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
    if (_token != null) {
      headers["Authorization"] = "Bearer $_token";
    }
    return headers;
  }

  // Authentication Methods
  // Đăng nhập
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['token'] != null) {
          final String token = data['token']['token'];
          // Lưu token vào secure storage hoặc SharedPreferences
        }
        return data;
      } else {
        return {
          'success': false,
          'message': 'Đăng nhập thất bại: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối: $e',
      };
    }
  }

  // Đăng ký
  static Future<Map<String, dynamic>> register(
    String username,
    String phone,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "username": username,
          "phone": phone,
          "email": email,
          "password": password,
          "password_confirmation": confirmPassword,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
          return {
            'success': true,
            'message': responseData['message'] ?? 'Đăng ký thành công',
            'user': responseData['user'],
            'token': responseData['token'],
          };

        case 422:
          var errors = responseData['errors'];
          String errorMessage = '';
          if (errors != null && errors is Map) {
            errorMessage = errors.values.first.first ?? 'Dữ liệu không hợp lệ';
          } else {
            errorMessage = responseData['message'] ?? 'Dữ liệu không hợp lệ';
          }
          return {
            'success': false,
            'message': errorMessage,
          };

        case 409:
          return {
            'success': false,
            'message': responseData['message'] ??
                'Email hoặc số điện thoại đã tồn tại',
          };

        default:
          return {
            'success': false,
            'message': responseData['message'] ??
                'Đăng ký thất bại (${response.statusCode})',
          };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối: $e',
      };
    }
  }

  // Đăng xuất
  static Future<void> logout() async {
    // Xóa token hoặc làm gì đó khi người dùng đăng xuất
  }
  Future<Map<String, dynamic>> checkout(
      List<Map<String, dynamic>> items, String paymentMethod) async {
    try {
      if (_token == null) {
        return {
          'success': false,
          'message': 'Token is not set',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/cart/checkout'),
        headers: _headers,
        body: jsonEncode({
          'items': items,
          'payment_method': paymentMethod, // Add the payment method here
        }),
      );

      print('Checkout Response Status: ${response.statusCode}');
      print('Checkout Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Thanh toán thành công',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Thanh toán thất bại',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Thanh toán thất bại (${response.statusCode})',
        };
      }
    } catch (e) {
      print('Checkout Error: $e');
      return {
        'success': false,
        'message': 'Lỗi kết nối: $e',
      };
    }
  }

  // Password Reset Methods
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email}),
      );

      print('Forgot Password Status Code: ${response.statusCode}');
      print('Forgot Password Response: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
          return {
            'success': true,
            'message': responseData['message'] ??
                'Email khôi phục mật khẩu đã được gửi',
          };
        case 404:
          return {
            'success': false,
            'message': 'Email không tồn tại trong hệ thống',
          };
        default:
          return {
            'success': false,
            'message':
                responseData['message'] ?? 'Không thể gửi email khôi phục',
          };
      }
    } catch (e) {
      print('Forgot Password Error: $e');
      return {
        'success': false,
        'message': 'Lỗi kết nối: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/password/reset'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "token": token,
          "email": email,
          "password": password,
          "password_confirmation": passwordConfirmation,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Mật khẩu đã được cập nhật',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Không thể đặt lại mật khẩu',
        };
      }
    } catch (e) {
      print('Reset Password Error: $e');
      return {
        'success': false,
        'message': 'Lỗi kết nối: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: _headers,
        body: jsonEncode({
          "current_password": currentPassword,
          "password": newPassword,
          "password_confirmation": passwordConfirmation,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
          return {
            'success': true,
            'message': responseData['message'] ?? 'Đổi mật khẩu thành công',
          };
        case 401:
          return {
            'success': false,
            'message': 'Vui lòng đăng nhập lại',
          };
        case 422:
          var errors = responseData['errors'];
          String errorMessage = '';
          if (errors != null && errors is Map) {
            if (errors['current_password'] != null) {
              errorMessage = 'Mật khẩu hiện tại không đúng';
            } else if (errors['password'] != null) {
              errorMessage = errors['password'].first;
            }
          }
          return {
            'success': false,
            'message': errorMessage,
          };
        default:
          return {
            'success': false,
            'message': responseData['message'] ?? 'Không thể đổi mật khẩu',
          };
      }
    } catch (e) {
      print('Change Password Error: $e');
      return {
        'success': false,
        'message': 'Lỗi kết nối: $e',
      };
    }
  }

  // Product Methods
  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: _headers,
      );

      print('Products API Response Status: ${response.statusCode}');
      print('Products API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['products'] != null) {
          return (data['products'] as List)
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error loading products: $e');
      return [];
    }
  }

  Future<Product?> getProductById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: _headers,
      );

      print('Product Detail Response Status: ${response.statusCode}');
      print('Product Detail Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['product'] != null) {
          return Product.fromJson(data['product']);
        }
      }
      return null;
    } catch (e) {
      print('Error loading product details: $e');
      return null;
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/search?q=$query'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['products'] != null) {
          return (data['products'] as List)
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/category/$categoryId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['products'] != null) {
          return (data['products'] as List)
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error loading category products: $e');
      return [];
    }
  }

  // Favorite Methods
  Future<List<Product>> getFavoriteProducts() async {
    try {
      if (_token == null) {
        print('Token is not set');
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/favorites'),
        headers: _headers,
      );

      print('Favorites Response Status: ${response.statusCode}');
      print('Favorites Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['products'] != null) {
          return (data['products'] as List)
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } else if (response.statusCode == 404) {
        print('No favorites found');
      } else if (response.statusCode == 401) {
        print('Unauthorized access to favorites');
      }
      return [];
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }

  Future<bool> toggleFavorite(int productId) async {
    try {
      if (_token == null) {
        print('Token is not set');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/products/$productId/favorite'),
        headers: _headers,
      );

      print('Toggle Favorite Response Status: ${response.statusCode}');
      print('Toggle Favorite Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          // Check if the API returns the new favorite status
          if (data['is_favorited'] != null) {
            return data['is_favorited'];
          }
          return true;
        }
      } else if (response.statusCode == 401) {
        print('Unauthorized - Please log in');
        return false;
      }

      return false;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  Future<bool> isProductFavorited(int productId) async {
    try {
      if (_token == null) {
        return false;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId/favorite/check'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['is_favorited'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Cart Methods
  Future<List<Product>> getCartProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['products'] != null) {
          return (data['products'] as List)
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error loading cart: $e');
      return [];
    }
  }

  Future<bool> addToCart(int productId, {int quantity = 1}) async {
    try {
      if (_token == null) {
        print('Token is not set');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/cart/add'),
        headers: _headers,
        body: jsonEncode({
          "product_id": productId,
          "quantity": quantity,
        }),
      );

      print('Add to Cart Response Status: ${response.statusCode}');
      print('Add to Cart Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  Future<bool> removeFromCart(int productId) async {
    try {
      if (_token == null) {
        print('Token is not set');
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/cart/remove/$productId'),
        headers: _headers,
      );

      print('Remove from Cart Response Status: ${response.statusCode}');
      print('Remove from Cart Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  Future<bool> updateCartQuantity(int productId, int quantity) async {
    try {
      if (_token == null) {
        print('Token is not set');
        return false;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/cart/update/$productId'),
        headers: _headers,
        body: jsonEncode({
          "quantity": quantity,
        }),
      );

      print('Update Cart Response Status: ${response.statusCode}');
      print('Update Cart Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error updating cart: $e');
      return false;
    }
  }

  Future<bool> clearCart() async {
    try {
      if (_token == null) {
        print('Token is not set');
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/cart/clear'),
        headers: _headers,
      );

      print('Clear Cart Response Status: ${response.statusCode}');
      print('Clear Cart Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  // User Profile Methods
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      if (_token == null) {
        return {'success': false, 'message': 'Token is not set'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: _headers,
      );

      print('Get Profile Response Status: ${response.statusCode}');
      print('Get Profile Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {'success': true, 'profile': data['user']};
      }
      return {'success': false, 'message': 'Failed to get profile'};
    } catch (e) {
      print('Error getting profile: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateUserProfile({
    String? username,
    String? phone,
    String? address,
    String? description,
  }) async {
    try {
      if (_token == null) {
        return {'success': false, 'message': 'Token is not set'};
      }

      final Map<String, dynamic> updateData = {
        if (username != null) 'username': username,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (description != null) 'description': description,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/profile/update'),
        headers: _headers,
        body: jsonEncode(updateData),
      );

      print('Update Profile Response Status: ${response.statusCode}');
      print('Update Profile Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Profile updated successfully',
          'user': responseData['user']
        };
      }

      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to update profile'
      };
    } catch (e) {
      print('Error updating profile: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Utility Methods
  static Future<bool> checkEmailExists(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check-email'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email}),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['exists'] ?? false;
    } catch (e) {
      print('Check Email Error: $e');
      return false;
    }
  }

  static Future<bool> verifyResetToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-token'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"token": token}),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['valid'] ?? false;
    } catch (e) {
      print('Verify Token Error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> resendResetEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resend-reset-email'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Email đã được gửi lại',
        };
      }

      return {
        'success': false,
        'message': responseData['message'] ?? 'Không thể gửi lại email',
      };
    } catch (e) {
      print('Resend Reset Email Error: $e');
      return {
        'success': false,
        'message': 'Lỗi kết nối: $e',
      };
    }
  }

  // Phương thức thêm bình luận
Future<void> addComment(int productId, String content, String name, Uri? url) async {
  final apiUrl = Uri.parse('http://127.0.0.1:8000/api/v1/comments/');
  
  final urlString = url?.toString();

  final data = {
    'name': name,
    'content': content,
    'url': urlString?.isNotEmpty ?? false ? urlString : null,
    'product_id': productId.toString(),
  };

  try {
    final response = await http.post(
      apiUrl,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: json.encode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('Bình luận đã được thêm thành công');
      // Sau khi thêm bình luận, không trả về gì
    } else {
      final errorData = json.decode(response.body);
      print('Lỗi: ${errorData['message']}');
      print('Chi tiết lỗi: ${errorData['errors']}');
    }
  } catch (e) {
    print('Lỗi khi gửi yêu cầu: $e');
  }
}
// Phương thức lấy danh sách bình luận
Future<List<dynamic>> getCommentsForProduct(int productId) async {
  final apiUrl = Uri.parse('http://127.0.0.1:8000/api/v1/comments/$productId');
  
  try {
    final response = await http.get(
      apiUrl,
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> comments = json.decode(response.body);
      return comments;  // Trả về danh sách bình luận
    } else {
      print('Lỗi khi lấy bình luận');
      return [];
    }
  } catch (e) {
    print('Lỗi khi lấy bình luận: $e');
    return [];
  }
}

}