import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../listing_photo.dart';

//one produce card on the buyer dashboard
class ListingCard extends StatelessWidget {
  final String cropName;
  final String? farmerName;
  final String district;
  final double pricePerKg;
  final String photoUrl;
  final double? rating;
  final bool verified;
  final VoidCallback onTap;

  const ListingCard({
    super.key,
    required this.cropName,
    this.farmerName,
    required this.district,
    required this.pricePerKg,
    required this.photoUrl,
    this.rating,
    this.verified = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ListingPhotoImage(
                photoUrl: photoUrl,
                fallback: Container(
                  color: AppColors.lightGreen.withValues(alpha: 0.3),
                  child: const Center(
                    child: Icon(Icons.image, size: 40, color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          cropName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (verified)
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: AppColors.primaryGreen,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    farmerName != null ? '$farmerName · $district' : district,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${pricePerKg.toStringAsFixed(0)} RWF/kg',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      if (rating != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating!.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
