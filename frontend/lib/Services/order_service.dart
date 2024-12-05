import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService {
  static const String apiUrl = 'http://127.0.0.1:8000/api/v1/order';

  static Future<bool> createOrder(Map<String, dynamic> orderData) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(orderData),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to create order: ${response.body}');
    }
  }
}
