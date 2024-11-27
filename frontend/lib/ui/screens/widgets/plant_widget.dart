import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/ui/screens/detail_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';

class PlantWidget extends StatelessWidget {
  const PlantWidget({
    super.key,
    required this.index,
    required this.plantList,
  });

  final int index;
  final List<Product> plantList;

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'en_US');
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            child: DetailPage(
              productId: plantList[index].id,
            ),
            type: PageTransitionType.bottomToTop,
          ),
        );
            },
      child: Container(
        decoration: BoxDecoration(
          color: Constants.primaryColor.withOpacity(.1),
          borderRadius: BorderRadius.circular(10),
        ),
        height: 100.0,
        padding: const EdgeInsets.only(left: 10, top: 10),
        margin: const EdgeInsets.only(bottom: 10, top: 10),
        width: size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    color: Constants.primaryColor.withOpacity(.2),
                    shape: BoxShape.circle,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 5,
                  child: ClipOval(
                    child: SizedBox(
                      height: 70,
                      width: 70,
                      child: plantList[index].photos.isNotEmpty
                          ? Image.network(
                              plantList[index].photos.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.broken_image,
                                color: Colors.red,
                              ),
                            )
                          : const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 5,
                  left: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plantList[index].catId?.toString() ?? 'No Category',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        plantList[index].title.isNotEmpty ? plantList[index].title : 'No Title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Constants.blackColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                formatCurrency.format(plantList[index].price ?? 0),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Constants.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}