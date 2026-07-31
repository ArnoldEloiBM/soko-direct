import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

//one produce card on the buyer dashboard
//still using fake data for now, will hook to firebase later
class ListingCard extends StatelessWidget {
  final String cropName;
  final String farmerName;
  final String district;
  final double pricePerKg;
  final String photoUrl; // not used yet, placeholder image for now
  final double rating;
  final bool verified;
  final VoidCallback onTap;

  const ListingCard({
    super.key,
    required this.cropName,
    required this.farmerName,
    required this.district,
    required this.pricePerKg,
    required this.photoUrl,
    required this.rating,
    required this.verified,
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
            // just a green box for now instead of a real photo
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                color: AppColors.lightGreen.withOpacity(0.3),
                child: const Center(
                  child: Icon(Icons.image, size: 40, color: Colors.white),
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
                    '$farmerName · $district',
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
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
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
