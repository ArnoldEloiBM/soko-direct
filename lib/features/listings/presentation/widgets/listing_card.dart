import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/time_ago.dart';
import '../../domain/constants/listing_options.dart';
import '../../domain/entities/listing.dart';
import '../../domain/entities/listing_status.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onDelete,
  });

  final Listing listing;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onDelete,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CropThumbnail(
                cropType: listing.cropType,
                photoUrl: listing.photoUrl,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            listing.cropType,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        _StatusBadge(listing: listing),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${listing.quantityKg.toStringAsFixed(0)} kg · '
                      '${listing.pricePerKg.toStringAsFixed(0)} RWF/kg · '
                      '${listing.location}',
                      style: const TextStyle(
                        color: AppColors.subtitleGrey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.status == ListingStatus.sold
                          ? formatSoldTimeAgo(
                              listing.updatedAt ?? listing.createdAt,
                            )
                          : formatTimeAgo(listing.createdAt),
                      style: const TextStyle(
                        color: AppColors.captionGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CropThumbnail extends StatelessWidget {
  const _CropThumbnail({required this.cropType, required this.photoUrl});

  final String cropType;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.marketPriceBg,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl.isNotEmpty
          ? Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _emojiFallback(),
            )
          : _emojiFallback(),
    );
  }

  Widget _emojiFallback() {
    return Center(
      child: Text(
        ListingOptions.emojiFor(cropType),
        style: const TextStyle(fontSize: 28),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    if (listing.status == ListingStatus.sold) {
      return _badge('Sold', AppColors.badgeSoldBg, AppColors.badgeSoldText);
    }
    if (listing.offerCount > 0) {
      return _badge(
        '${listing.offerCount} Offers',
        AppColors.badgeOffersBg,
        AppColors.badgeOffersText,
      );
    }
    return _badge('Active', AppColors.badgeActiveBg, AppColors.badgeActiveText);
  }

  Widget _badge(String label, Color background, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
