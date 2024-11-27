import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/ui/screens/cart_page.dart';
import 'package:frontend/ui/screens/favorite_page.dart';
import 'package:frontend/ui/screens/home_page.dart';
import 'package:frontend/ui/screens/profile_page.dart';
import 'package:frontend/ui/screens/widgets/base_scaffold.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  List<Product> _products = [];
  List<Product> _favorites = [];
  int _selectedIndex = 0;
  bool _isLoading = false;

  final String _baseUrl = "http://127.0.0.1:8000/api/v1";
  
  final List<Widget> _pages = [
    const HomePage(),
    FavoritePage(),
    const CartPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    // Load cart data
    Provider.of<CartProvider>(context, listen: false).loadCart();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.wait([_loadProducts(), _loadFavoriteProducts()]);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['products'] != null) {
          setState(() {
            _products = List<Product>.from(
              data['products'].map((json) => Product.fromJson(json))
            );
          });
        } else {
          setState(() => _products = []);
        }
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error loading products: $e');
      setState(() => _products = []);
    }
  }

  Future<void> _loadFavoriteProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/favorites'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['products'] != null) {
          setState(() {
            _favorites = List<Product>.from(
              data['products'].map((json) => Product.fromJson(json))
            );
          });
        } else {
          setState(() => _favorites = []);
        }
      } else {
        throw Exception('Failed to load favorites');
      }
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() => _favorites = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Giỏ hàng',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
