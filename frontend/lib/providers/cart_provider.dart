import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart';
import 'package:http/http.dart' as http;

class CartProvider extends ChangeNotifier {
  List<Product> _items = [];
  List<Product> get items => _items;
  bool isLoading = false;
  bool _isBuyNow = false; // Biến theo dõi nếu là hành động "Mua ngay"

  final String _baseUrl = "http://127.0.0.1:8000/api/v1";

  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Hàm tải giỏ hàng
  Future<void> loadCart() async {
    isLoading = true;
    notifyListeners();

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/cart'),
        headers: headers,
      );
      print('Load cart response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          _items = (data['data'] as List)
              .map<Product>((json) => Product.fromJson(json))
              .toList();
        }
      } else {
        print('Error loading cart: ${response.statusCode}');
        _items = [];
      }
    } catch (e) {
      print('Error loading cart: $e');
      _items = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Hàm thêm sản phẩm vào giỏ
  Future<bool> addToCart(Product product, {bool isBuyNow = false}) async {
    _isBuyNow = isBuyNow; // Đánh dấu nếu hành động là "Mua ngay"
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/cart/add'),
        headers: headers,
        body: json.encode({
          'product_id': product.id,
          'quantity': product.quantity ?? 1,
        }),
      );
      print('Add to cart response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final existingProductIndex =
              _items.indexWhere((item) => item.id == product.id);

          if (existingProductIndex != -1) {
            // Nếu sản phẩm đã tồn tại, tăng số lượng
            _items[existingProductIndex] = _items[existingProductIndex]
                .copyWith(
                    quantity: _items[existingProductIndex].quantity +
                        (product.quantity ?? 1));
          } else {
            // Nếu chưa tồn tại, thêm sản phẩm mới
            _items.add(product.copyWith(quantity: product.quantity ?? 1));
          }

          notifyListeners();
          return true;
        }
      }
      print('Failed to add to cart: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  // Hàm cập nhật số lượng sản phẩm trong giỏ
  Future<bool> updateQuantity(Product product, int quantity) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/cart/${product.id}'),
        headers: headers,
        body: json.encode({'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final productIndex =
              _items.indexWhere((item) => item.id == product.id);
          if (productIndex != -1) {
            _items[productIndex] =
                _items[productIndex].copyWith(quantity: quantity);
            notifyListeners(); // Quan trọng để cập nhật UI
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error updating quantity: $e');
      return false;
    }
  }

  // Hàm xóa sản phẩm khỏi giỏ
  Future<bool> removeFromCart(Product product) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/cart/${product.id}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _items.removeWhere((item) => item.id == product.id);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  // Hàm tính tổng giá trị giỏ hàng
  double get totalAmount {
    return _items.fold(
      0,
      (sum, item) => sum + (item.price * (item.quantity ?? 1)),
    );
  }

  // Kiểm tra sản phẩm có trong giỏ hay không
  bool isProductInCart(Product product) {
    return _items.any((item) => item.id == product.id);
  }

  // Hàm xóa giỏ hàng
  void clearCart() {
    _items = [];
    notifyListeners();
  }

  // Hàm thanh toán giỏ hàng với phương thức thanh toán
  Future<bool> checkout(BuildContext context, String paymentMethod) async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giỏ hàng của bạn trống.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$_baseUrl/cart/checkout'),
            headers: headers,
            body: json.encode({
              'items': _items.map((item) {
                return {
                  'product_id': item.id,
                  'quantity': item.quantity,
                };
              }).toList(),
              'payment_method': paymentMethod,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Checkout response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Xóa giỏ hàng và cập nhật UI
          clearCart();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thanh toán thành công!'),
              backgroundColor: Colors.green,
            ),
          );

          // Quay lại trang trước (trang chủ hoặc giỏ hàng)
          Navigator.pop(context); // Quay lại trang trước
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Thanh toán thất bại.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanh toán thất bại. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } catch (e) {
      print('Error during checkout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể kết nối tới server: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Hàm để xử lý khi bấm nút back
  void handleBackAction(Product product) {
    if (_isBuyNow) {
      // Nếu là hành động "Mua ngay", xóa sản phẩm khỏi giỏ hàng
      removeFromCart(product);
    }
  }
}
