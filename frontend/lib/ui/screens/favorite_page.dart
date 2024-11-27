import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/providers/favorite_provider.dart';
import 'package:frontend/ui/screens/detail_page.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class FavoritePage extends StatelessWidget {
  FavoritePage({super.key});

  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final favoritedPlants = favoriteProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách yêu thích'),
      ),
      body: favoritedPlants.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                // // Nếu cần tải lại danh sách yêu thích từ server
                // await favoriteProvider.refreshFavorites();
              },
              child: _buildFavoriteList(favoritedPlants, context),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có sản phẩm yêu thích',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm sản phẩm yêu thích của bạn',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteList(List<Product> favoritedPlants, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoritedPlants.length,
      itemBuilder: (context, index) {
        final product = favoritedPlants[index];
        return Dismissible(
          key: Key(product.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            Provider.of<FavoriteProvider>(context, listen: false)
                .removeFavorite(product);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.photos.isNotEmpty ? product.photos.first : '',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported),
                ),
              ),
              title: Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency.format(product.price),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: product.isSold == 1
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.isSold == 1 ? 'Còn hàng' : 'Hết hàng',
                      style: TextStyle(
                        color: product.isSold == 1 ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  Provider.of<FavoriteProvider>(context, listen: false)
                      .removeFavorite(product);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: DetailPage(productId: product.id),
                    type: PageTransitionType.rightToLeft,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
