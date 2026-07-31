import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/firestore_listings_repository.dart';
import '../../domain/listing.dart';
import '../../domain/listing_status.dart';
import '../browse_listings_cubit.dart';
import '../browse_listings_state.dart';
import '../listing_detail_screen.dart';
import '../widgets/listing_card.dart';
import '../widgets/search_filter_bar.dart';

/// Self-contained: creates its own [BrowseListingsCubit] over a fresh
/// [FirestoreListingsRepository], same pattern as TransactionHistoryScreen.
class BuyerDashboardPage extends StatelessWidget {
  const BuyerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          BrowseListingsCubit(repository: FirestoreListingsRepository()),
      child: const _BuyerDashboardView(),
    );
  }
}

class _BuyerDashboardView extends StatefulWidget {
  const _BuyerDashboardView();

  @override
  State<_BuyerDashboardView> createState() => _BuyerDashboardViewState();
}

class _BuyerDashboardViewState extends State<_BuyerDashboardView> {
  String searchText = '';
  String? cropFilter;

  List<Listing> _visibleListings(List<Listing> listings) {
    return listings.where((listing) {
      if (listing.status == ListingStatus.sold) return false;
      final matchesSearch =
          searchText.isEmpty ||
          listing.cropType.toLowerCase().contains(searchText.toLowerCase());
      final matchesCrop = cropFilter == null || listing.cropType == cropFilter;
      return matchesSearch && matchesCrop;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Produce'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchFilterBar(
              onChanged: (query, crop) {
                setState(() {
                  searchText = query;
                  cropFilter = crop;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<BrowseListingsCubit, BrowseListingsState>(
                builder: (context, state) {
                  if (state.status == BrowseListingsStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == BrowseListingsStatus.error) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Something went wrong.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final visible = _visibleListings(state.listings);
                  if (visible.isEmpty) {
                    return const Center(
                      child: Text('No produce matches your search.'),
                    );
                  }

                  final currentUserId =
                      context.read<AuthCubit>().state.user?.id ?? '';

                  return GridView.builder(
                    itemCount: visible.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                    itemBuilder: (context, i) {
                      final listing = visible[i];
                      return ListingCard(
                        cropName: listing.cropType,
                        district: listing.location,
                        pricePerKg: listing.pricePerKg,
                        photoUrl: listing.photoUrl,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ListingDetailScreen(
                                listing: listing,
                                currentUserId: currentUserId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
