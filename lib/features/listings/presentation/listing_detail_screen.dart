import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../ratings/data/rating_repository_impl.dart';
import '../../ratings/presentation/rating_cubit.dart';
import '../../ratings/presentation/rating_screen.dart';
import '../domain/listing.dart';
import '../domain/listing_status.dart';
import 'listing_form_screen.dart';

/// Shows full details for one listing. Receives an already-loaded
/// [Listing] (passed in via navigation from My Listings or Buyer
/// search) — this screen does not fetch from Firebase itself.
class ListingDetailScreen extends StatelessWidget {
  final Listing listing;
  final String currentUserId;

  const ListingDetailScreen({
    super.key,
    required this.listing,
    required this.currentUserId,
  });

  Color _statusColor(ListingStatus status) {
    switch (status) {
      case ListingStatus.active:
        return Colors.green;
      case ListingStatus.withOffers:
        return Colors.orange;
      case ListingStatus.sold:
        return Colors.grey;
    }
  }

  String _statusLabel(ListingStatus status) {
    switch (status) {
      case ListingStatus.active:
        return 'Active';
      case ListingStatus.withOffers:
        return 'With Offers';
      case ListingStatus.sold:
        return 'Sold';
    }
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';

  @override
  Widget build(BuildContext context) {
    final totalValue = listing.pricePerKg * listing.quantityKg;
    final isOwnListing = currentUserId == listing.sellerId;

    return Scaffold(
      appBar: AppBar(
        title: Text(listing.cropType),
        actions: [
          if (isOwnListing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit listing',
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => ListingFormScreen(listing: listing),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: listing.photoUrl.isNotEmpty
                  ? Image.network(
                      listing.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.eco,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.cropType,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Chip(
                        label: Text(
                          _statusLabel(listing.status),
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: _statusColor(listing.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.attach_money,
                    label: 'Price per kg',
                    value: '${listing.pricePerKg.toStringAsFixed(2)} RWF',
                  ),
                  _DetailRow(
                    icon: Icons.scale,
                    label: 'Quantity',
                    value: '${listing.quantityKg.toStringAsFixed(1)} kg',
                  ),
                  _DetailRow(
                    icon: Icons.payments,
                    label: 'Total value',
                    value: '${totalValue.toStringAsFixed(2)} RWF',
                  ),
                  _DetailRow(
                    icon: Icons.calendar_today,
                    label: 'Available from',
                    value: _formatDate(listing.availableFrom),
                  ),
                  _DetailRow(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: listing.location,
                  ),
                  _DetailRow(
                    icon: Icons.local_offer,
                    label: 'Offers so far',
                    value: '${listing.offerCount}',
                  ),
                  const SizedBox(height: 20),
                  if (!isOwnListing) ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.handshake),
                      label: const Text('Make an Offer'),
                      onPressed: () {
                        // Hooks into the Make Offer / Negotiation screen
                        // (features/offers) once wired up from here.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Offer flow coming soon'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                  OutlinedButton.icon(
                    icon: const Icon(Icons.star_border),
                    label: const Text('View Seller Ratings'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) =>
                                RatingCubit(repository: RatingRepositoryImpl()),
                            child: RatingScreen(
                              transactionId: '',
                              raterId: currentUserId,
                              rateeId: listing.sellerId,
                              rateeName: 'Seller',
                            ),
                          ),
                        ),
                      );
                    },
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
