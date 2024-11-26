import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants.dart';
import 'package:frontend/models/product.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/providers/favorite_provider.dart';
import 'package:frontend/ui/screens/checkout_page.dart';

class DetailPage extends StatefulWidget {
  final int productId;

  const DetailPage({Key? key, required this.productId}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Product? product;
  List<Product> recommendedProducts = [];
  List<Map<String, dynamic>> reviews = [];
  bool _isLoading = true;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  int _quantity = 1;

  final String baseUrl = "http://127.0.0.1:8000/api/v1";

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
    _loadRecommendedProducts();
    _loadReviews();
  }

  Future<void> _loadProductDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/${widget.productId}'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          setState(() {
            product = Product.fromJson(responseData['data']);
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load product details');
      }
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRecommendedProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/recommended/${widget.productId}'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['data'];
        setState(() {
          recommendedProducts =
              responseData.map((e) => Product.fromJson(e)).toList();
        });
      }
    } catch (e) {
      print("Error loading recommended products: $e");
    }
  }

  Future<void> _loadReviews() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/${widget.productId}/reviews'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          reviews = List<Map<String, dynamic>>.from(
              json.decode(response.body)['data']);
        });
      }
    } catch (e) {
      print("Error loading reviews: $e");
    }
  }

  Future<void> _addReview(String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/${widget.productId}/reviews'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'content': content}),
      );

      if (response.statusCode == 201) {
        setState(() {
          reviews.insert(0, json.decode(response.body)['data']);
        });
        _showSnackBar('Đánh giá đã được thêm!', Colors.green);
      } else {
        throw Exception('Failed to add review');
      }
    } catch (e) {
      _showSnackBar('Lỗi khi thêm đánh giá.', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showFullScreenImage(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: PhotoViewGallery.builder(
            pageController: PageController(initialPage: initialIndex),
            itemCount: product!.photos.length,
            builder: (context, index) => PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(product!.photos[index]),
              heroAttributes:
                  PhotoViewHeroAttributes(tag: 'product-image-$index'),
            ),
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (product == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy sản phẩm')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSlider(),
            _buildProductInfo(),
            _buildDescription(),
            _buildRecommendedProducts(),
            _buildReviews(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Consumer<FavoriteProvider>(
          builder: (context, favoriteProvider, _) => IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                favoriteProvider.isFavorite(product!)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: favoriteProvider.isFavorite(product!)
                    ? Colors.red
                    : Colors.grey,
              ),
            ),
            onPressed: () =>
                Provider.of<FavoriteProvider>(context, listen: false)
                    .toggleFavorite(product!),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildImageSlider() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemCount: product!.photos.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showFullScreenImage(index),
                child: Hero(
                  tag: 'product-image-$index',
                  child: Image.network(
                    product!.photos[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          if (product!.photos.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: product!.photos.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == entry.key
                          ? Constants.primaryColor
                          : Colors.grey.withOpacity(0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product!.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                    .format(product!.price),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Constants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: product!.isSold == 1
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product!.isSold == 1 ? 'Còn hàng' : 'Hết hàng',
                  style: TextStyle(
                    color: product!.isSold == 1 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả sản phẩm',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Html(
            data: product!.description,
            style: {
              "body": Style(
                fontSize: FontSize(16),
                lineHeight: const LineHeight(1.6),
                color: Colors.black87,
              ),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedProducts() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sản phẩm đề xuất',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: recommendedProducts.map((product) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(productId: product.id),
                      ),
                    );
                  },
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            product.photos.first,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.title,
                          style: const TextStyle(fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                              .format(product.price),
                          style: TextStyle(
                            color: Constants.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    final TextEditingController reviewController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đánh giá sản phẩm',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return ListTile(
                title: Text(review['user']),
                subtitle: Text(review['content']),
                leading: CircleAvatar(
                  child: Text(review['user'][0]),
                ),
              );
            },
          ),
          const Divider(),
          TextField(
            controller: reviewController,
            decoration: InputDecoration(
              labelText: 'Viết đánh giá',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  _addReview(reviewController.text);
                  reviewController.clear();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false)
                      .addToCart(product!);
                  _showSnackBar('Đã thêm vào giỏ hàng', Colors.green);
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Thêm vào giỏ'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Constants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                onPressed: () => _handleBuyNow(),
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Mua ngay'),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Add the Buy Now functionality
  Future<void> _handleBuyNow() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Add the product to the cart temporarily
    cartProvider.addToCart(product!);

    // Navigate to CheckoutPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(),
      ),
    );
  }
}
