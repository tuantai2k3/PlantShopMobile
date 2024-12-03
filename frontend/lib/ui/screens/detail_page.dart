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

  const DetailPage({super.key, required this.productId});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Product? product;
  List<Product> recommendedProducts = [];
  List<Map<String, dynamic>> reviews = [];
  bool _isLoading = true;
  bool isBuyingNow = false;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  int _quantity = 1;
  final TextEditingController reviewController = TextEditingController();

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
        } else {
          _showSnackBar('Không thể tải thông tin sản phẩm', Colors.red);
          setState(() {
            _isLoading = false;
            product = null;
          });
        }
      } else {
        _showSnackBar('Không thể tải thông tin sản phẩm', Colors.red);
        setState(() {
          _isLoading = false;
          product = null;
        });
      }
    } catch (e) {
      print("Error loading product details: $e");
      _showSnackBar('Lỗi khi tải thông tin sản phẩm', Colors.red);
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
        Uri.parse('$baseUrl/comments?product_id=${widget.productId}'),
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Accessing the 'data' array from the response
        final List<dynamic> commentsData = responseData['data'];

        setState(() {
          reviews = commentsData
              .map((item) => {
                    'id': item['id'],
                    'user_id': item['user_id'],
                    'name': item['name'] ?? 'Anonymous',
                    'email': item['email'],
                    'url': item['url'],
                    'content': item['content'],
                    'status': item['status'],
                    'created_at': item['created_at'],
                    'updated_at': item['updated_at'],
                    'product_id': item['product_id'],
                  })
              .toList();
        });
      } else {
        _showSnackBar('Không thể tải bình luận', Colors.red);
        setState(() => reviews = []);
      }
    } catch (e) {
      print("Error loading reviews: $e");
      _showSnackBar('Lỗi khi tải bình luận', Colors.red);
      setState(() => reviews = []);
    }
  }

  Future<void> _addReview(String content) async {
    if (content.isEmpty) {
      _showSnackBar('Vui lòng nhập nội dung bình luận', Colors.red);
      return;
    }

    const name = 'Anonymous'; // Có thể thay bằng tên người dùng thực tế
    final data = {
      'name': name,
      'content': content,
      'url': 'user-comment',
      'product_id': widget.productId.toString(),
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/comments'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar('Đã thêm bình luận thành công!', Colors.green);

        // Sau khi thêm bình luận thành công, gọi lại phương thức _loadReviews để tải lại danh sách bình luận
        await _loadReviews();
        setState(() {
          // Gọi setState để UI cập nhật lại với danh sách bình luận mới
        });
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = 'Không thể thêm bình luận. ';
        if (errorData['errors'] != null) {
          errorMessage += (errorData['errors'] as Map<String, dynamic>)
              .values
              .expand((x) => x as List<dynamic>)
              .join(', ');
        }
        _showSnackBar(errorMessage, Colors.red);
      }
    } catch (e) {
      print('Error adding comment: $e');
      _showSnackBar('Đã xảy ra lỗi khi thêm bình luận', Colors.red);
    }
  }

  Future<void> _addToCart(CartProvider cartProvider) async {
    if (product != null) {
      final success = await cartProvider.addToCart(
        product!.copyWith(quantity: _quantity),
      );
      if (success) {
        _showSnackBar('Đã thêm vào giỏ hàng!', Colors.green);
      } else {
        _showSnackBar('Thêm vào giỏ hàng thất bại.', Colors.red);
      }
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
    if (recommendedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

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
                      .addToCart(product!.copyWith(quantity: _quantity));
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
                onPressed: () => _handleBuyNow(
                  Provider.of<CartProvider>(context, listen: false),
                ),
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Mua ngay'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBuyNow(CartProvider cartProvider) async {
    setState(() {
      isBuyingNow = true;
    });

    await _addToCart(cartProvider);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(),
        ),
      );
    }
  }

  Widget _buildReviews() {
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
          if (reviews.isEmpty)
            const Text(
              'Chưa có đánh giá nào',
              style: TextStyle(color: Colors.grey),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        Text(
                          review['name'] ?? 'Anonymous',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (review['status'] == 'active')
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(review['content'] ?? ''),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm')
                              .format(DateTime.parse(review['created_at'])),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Text(
                        (review['name'] != null &&
                                review['name'].toString().isNotEmpty)
                            ? review['name'].toString()[0].toUpperCase()
                            : 'A',
                        style: TextStyle(
                          color: Constants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          const Divider(),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: reviewController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Viết đánh giá của bạn...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Constants.primaryColor,
                    ),
                    onPressed: () {
                      final content = reviewController.text.trim();
                      if (content.isNotEmpty) {
                        _addReview(content);
                        reviewController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  //-Thay anonymous thành username nhưng đang lỗi-//
  // Widget _buildReviews() {
  // final currentUser = ref.watch(authProvider).user;

  // return Container(
  //   padding: const EdgeInsets.all(16),
  //   child: Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Đánh giá sản phẩm',
  //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(height: 12),
  //       if (reviews.isEmpty)
  //         const Text(
  //           'Chưa có đánh giá nào',
  //           style: TextStyle(color: Colors.grey),
  //         )
  //       else
  //         ListView.builder(
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           itemCount: reviews.length,
  //           itemBuilder: (context, index) {
  //             final review = reviews[index];
  //             final reviewerName = review['name'] ??
  //               (currentUser?.fullName.isNotEmpty ?? false
  //                 ? currentUser?.fullName
  //                 : currentUser?.username ?? 'Anonymous');

  //               return Card(
  //                 margin: const EdgeInsets.only(bottom: 8),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                   side: BorderSide(color: Colors.grey.shade300),
  //                 ),
  //                 child: ListTile(
  //                   title: Row(
  //                     children: [
  //                       Text(
  //                         reviewerName,
  //                         style: const TextStyle(fontWeight: FontWeight.bold),
  //                       ),
  //                       if (review['status'] == 'active')
  //                         Container(
  //                           margin: const EdgeInsets.only(left: 8),
  //                           padding: const EdgeInsets.symmetric(
  //                               horizontal: 8, vertical: 2),
  //                           decoration: BoxDecoration(
  //                             color: Colors.green.withOpacity(0.1),
  //                             borderRadius: BorderRadius.circular(12),
  //                           ),
  //                           child: const Text(
  //                             'Active',
  //                             style:
  //                                 TextStyle(fontSize: 12, color: Colors.green),
  //                           ),
  //                         ),
  //                     ],
  //                   ),
  //                   subtitle: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       const SizedBox(height: 4),
  //                       Text(review['content'] ?? ''),
  //                       const SizedBox(height: 4),
  //                       Text(
  //                         DateFormat('dd/MM/yyyy HH:mm')
  //                             .format(DateTime.parse(review['created_at'])),
  //                         style: const TextStyle(
  //                           fontSize: 12,
  //                           color: Colors.grey,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   leading: CircleAvatar(
  //                     backgroundColor: Colors.blue.withOpacity(0.1),
  //                     child: Text(
  //                       (review['name'] != null &&
  //                               review['name'].toString().isNotEmpty)
  //                           ? review['name'].toString()[0].toUpperCase()
  //                           : 'A',
  //                       style: TextStyle(
  //                         color: Constants.primaryColor,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         const Divider(),
  //         Card(
  //           elevation: 0,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(8),
  //             side: BorderSide(color: Colors.grey.shade300),
  //           ),
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //             child: Row(
  //               crossAxisAlignment: CrossAxisAlignment.end,
  //               children: [
  //                 Expanded(
  //                   child: TextField(
  //                     controller: reviewController,
  //                     maxLines: null,
  //                     decoration: const InputDecoration(
  //                       hintText: 'Viết đánh giá của bạn...',
  //                       border: InputBorder.none,
  //                       contentPadding: EdgeInsets.symmetric(vertical: 8),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 8),
  //                 IconButton(
  //                   icon: Icon(
  //                     Icons.send,
  //                     color: Constants.primaryColor,
  //                   ),
  //                   onPressed: () {
  //                     final content = reviewController.text.trim();
  //                     if (content.isNotEmpty) {
  //                       _addReview(content);
  //                       reviewController.clear();
  //                     }
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
